defmodule FootballMarket.Market.OrderEvaluation do
  @moduledoc """
  Durable background evaluation passes, missed-work recovery, and post-commit
  PubSub reload hints for conditional buy orders.

  A singleton `OrderEvaluationPass` row captures a deterministic snapshot of all
  pending orders (`OrderEvaluationMember` rows ordered by `created_at, id`),
  evaluates them one by one inside transactions, and schedules continuations so
  work survives worker restarts without losing or double-executing orders.
  """

  import Ecto.Query

  alias FootballMarket.Market.{
    ConditionalOrder,
    ConditionalOrders,
    OrderEvaluationMember,
    OrderEvaluationPass,
    Settlement
  }

  alias FootballMarket.Quotes.{Evaluation, Recovery}
  alias FootballMarket.Repo
  alias FootballMarket.Workers.{ConditionalOrderEvaluation, ConditionalOrderRecovery}

  # --- Oban Scheduling & Entrypoints ---

  def oban_name do
    :football_market
    |> Application.get_env(FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  def enqueue!(args) do
    name = oban_name()

    if is_nil(Oban.Registry.lookup(name)),
      do: Settlement.reject(:temporarily_unavailable)

    Oban.insert!(name, ConditionalOrderEvaluation.new(args))
  end

  def startup, do: Oban.insert(oban_name(), ConditionalOrderRecovery.new(%{}))

  def accept_event(event_id) do
    Settlement.safely(fn -> Repo.transaction(fn -> accept_locked!(event_id) end) end)
  end

  def run(wake) when is_boolean(wake) do
    with :ok <- request_if_woken(wake), do: run_steps(100)
  end

  @doc """
  Bounded keyset recovery sweep that claims unacknowledged or lease-expired
  quote evaluation events and triggers an all-pending order pass.
  """
  def recover(after_id), do: Settlement.safely(fn -> recover_page(after_id) end)

  # --- Pass State Machine (Singleton Lock) ---

  def request_pass do
    ConditionalOrders.command(fn ->
      pass = lock_pass!()

      if pass.state == "idle",
        do: capture_pass!(pass),
        else: update_pass!(pass, rescan_requested: true)

      :ok
    end)
  end

  def step do
    ConditionalOrders.command(fn ->
      pass = lock_pass!()
      if pass.state == "idle", do: :idle, else: advance_pass!(pass)
    end)
  end

  # The continuation is committed under the same singleton lock as the state
  # inspection. A crash before it is repaired by the periodic/startup sweep.
  def continue do
    ConditionalOrders.command(fn ->
      pass = lock_pass!()
      if pass.state == "running", do: enqueue!(%{"source" => "continuation"})
      :ok
    end)
  end

  # --- Best-Effort Post-Commit PubSub Hints ---

  @doc "Broadcasts a reload hint to LiveView subscribers after commit (never inside a transaction)."
  def notify_changed(order_id) do
    unless Repo.in_transaction?() do
      case Repo.get(ConditionalOrder, order_id) do
        nil ->
          :ok

        order ->
          Phoenix.PubSub.broadcast(
            FootballMarket.PubSub,
            "conditional_orders:" <> order.owner_id,
            {:conditional_order_changed, order.id}
          )
      end
    end

    :ok
  rescue
    _ -> :ok
  catch
    :exit, _ -> :ok
  end

  # --- Private Helpers ---

  defp lock_pass!,
    do: Repo.one!(from pass in OrderEvaluationPass, where: pass.id == 1, lock: "FOR UPDATE")

  defp capture_pass!(pass) do
    generation = pass.generation + 1

    # One INSERT SELECT statement captures the exact membership and ordinal
    # order for the entire pass so concurrent creations cannot shift cursors.
    Repo.query!(
      """
      INSERT INTO market_order_evaluation_members(pass_generation,ordinal,order_id,captured_created_at)
      SELECT $1, row_number() OVER (ORDER BY created_at,id), id, created_at
      FROM market_conditional_buy_orders WHERE status='pending'
      """,
      [generation]
    )

    highest =
      Repo.one(
        from member in OrderEvaluationMember,
          join: order in ConditionalOrder,
          on: order.id == member.order_id,
          where: member.pass_generation == ^generation,
          order_by: [desc: member.ordinal],
          limit: 1,
          select: {order.created_at, order.id}
      )

    {upper_created_at, upper_order_id} = highest || {nil, nil}

    update_pass!(pass,
      state: if(highest, do: "running", else: "idle"),
      generation: generation,
      started_at: Settlement.clock(),
      cursor_ordinal: 0,
      upper_created_at: upper_created_at,
      upper_order_id: upper_order_id,
      rescan_requested: false
    )
  end

  defp advance_pass!(pass) do
    next_member =
      Repo.one(
        from member in OrderEvaluationMember,
          where:
            member.pass_generation == ^pass.generation and member.ordinal > ^pass.cursor_ordinal,
          order_by: member.ordinal,
          limit: 1
      )

    case next_member do
      nil ->
        complete_pass!(pass)

      member ->
        result = ConditionalOrders.evaluate_in_transaction!(member.order_id)
        update_pass!(pass, cursor_ordinal: member.ordinal)
        {:decided, result}
    end
  end

  defp complete_pass!(pass) do
    Repo.delete_all(
      from member in OrderEvaluationMember, where: member.pass_generation == ^pass.generation
    )

    idle =
      update_pass!(pass,
        state: "idle",
        cursor_ordinal: 0,
        upper_created_at: nil,
        upper_order_id: nil
      )

    if pass.rescan_requested do
      capture_pass!(idle)
      :rescan
    else
      :idle
    end
  end

  defp update_pass!(pass, attrs) do
    pass
    |> Ecto.Changeset.change(Keyword.put(attrs, :updated_at, Settlement.clock()))
    |> Repo.update!()
  end

  defp accept_locked!(event_id) do
    event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")
    receipt = "conditional-evaluation:" <> event_id

    case event do
      nil -> Repo.rollback(:not_found)
      %{state: "acknowledged", consumer_receipt: ^receipt} -> :ok
      %{state: "acknowledged"} -> Repo.rollback(:receipt_conflict)
      _ -> accept_claim!(event_id, receipt)
    end
  end

  defp accept_claim!(event_id, receipt) do
    case Recovery.claim_evaluation(event_id) do
      {:ok, claim} ->
        enqueue!(%{"source" => "recovery", "event_id" => event_id})

        case Recovery.acknowledge_evaluation(event_id, claim.fence, receipt) do
          :ok -> :ok
          {:error, reason} -> Repo.rollback(reason)
        end

      {:error, reason} ->
        Repo.rollback(reason)
    end
  end

  defp request_if_woken(false), do: :ok
  defp request_if_woken(true), do: unwrap(request_pass())

  defp run_steps(0), do: unwrap(continue())

  defp run_steps(remaining) do
    case step() do
      {:ok, :idle} ->
        :ok

      {:ok, :rescan} ->
        run_steps(remaining)

      {:ok, {:decided, {order, changed}}} ->
        if changed, do: notify_changed(order.id)
        run_steps(remaining - 1)

      {:error, _} ->
        {:error, :temporarily_unavailable}
    end
  end

  defp recover_page(after_id) do
    now = FootballMarket.Quotes.Store.database_clock_now!()

    query =
      from e in Evaluation,
        where: e.state == "pending" or (e.state == "leased" and e.lease_until <= ^now),
        order_by: e.id,
        limit: 100,
        select: e.id

    query = if after_id, do: from(e in query, where: e.id > ^after_id), else: query
    event_ids = Repo.all(query)

    with :ok <- accept_page(event_ids),
         {:ok, _} <- request_pass() do
      Repo.transaction(fn -> persist_recovery_continuation!(event_ids) end) |> unwrap()
    else
      _ -> {:error, :temporarily_unavailable}
    end
  end

  defp persist_recovery_continuation!(event_ids) do
    enqueue!(%{"source" => "continuation"})

    if length(event_ids) == 100 do
      Oban.insert!(oban_name(), ConditionalOrderRecovery.new(%{"after" => List.last(event_ids)}))
    end
  end

  defp accept_page(event_ids) do
    Enum.reduce_while(event_ids, :ok, fn event_id, _acc ->
      case accept_event(event_id) do
        {:ok, _} -> {:cont, :ok}
        {:error, reason} when reason in [:already_leased, :already_acknowledged] -> {:cont, :ok}
        _ -> {:halt, {:error, :temporarily_unavailable}}
      end
    end)
  end

  defp unwrap({:ok, _}), do: :ok
  defp unwrap({:error, _}), do: {:error, :temporarily_unavailable}
end
