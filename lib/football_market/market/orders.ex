defmodule FootballMarket.Market.Orders do
  @moduledoc """
  Conditional buy orders: create, list, get, cancel, and evaluate limit orders
  when player quotes publish.

  When an investor places a conditional buy order (`maximum_unit_price`,
  `quantity`, `expires_at`), the order stays `"pending"` until either:
    * A confirmed quote is `<= maximum_unit_price` → executes atomically via `Market.Trading` (`"executed"`)
    * Funds or inventory are insufficient when triggered → `"rejected"`
    * The deadline passes → `"expired"`
    * The investor cancels it → `"cancelled"`
  """

  import Ecto.Query

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    ConditionalOrder,
    Error,
    Issuance,
    OrderEvaluation,
    Purchase,
    Trading
  }

  alias FootballMarket.Repo

  @term_keys [:player_id, :quantity, :maximum_unit_price, :expires_at]

  # --- Public API ---

  def create(actor, terms) do
    with {:ok, canonical} <- validate_terms(actor, terms) do
      command(fn ->
        order = create_in_transaction!(canonical)
        OrderEvaluation.enqueue!(%{"source" => "order", "order_id" => order.id})
        order
      end)
    end
  end

  def cancel(%AuthenticatedActor{account_id: owner_id}, order_id) do
    case strict_uuid(order_id) do
      {:ok, uuid} ->
        transition_command(fn ->
          order = fetch_owned(owner_id, uuid, true)
          {cancel_locked(order), order != nil and order.status == "pending"}
        end)

      _ ->
        {:error, :not_found}
    end
  end

  def cancel(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  def evaluate(order_id) do
    case strict_uuid(order_id) do
      {:ok, uuid} -> transition_command(fn -> evaluate_in_transaction!(uuid) end)
      _ -> {:error, :not_found}
    end
  end

  def list(%AuthenticatedActor{account_id: owner_id}) do
    Trading.safely(fn ->
      now = Trading.db_clock()

      orders =
        Repo.all(
          from o in ConditionalOrder,
            where: o.owner_id == ^owner_id,
            order_by: [o.created_at, o.id]
        )
        |> Enum.map(&project(&1, now))

      {:ok, orders}
    end)
  end

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  def get(%AuthenticatedActor{account_id: owner_id}, order_id) do
    case strict_uuid(order_id) do
      {:ok, uuid} -> Trading.safely(fn -> lookup_owned(owner_id, uuid) end)
      _ -> {:error, :not_found}
    end
  end

  def get(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp lookup_owned(owner_id, uuid) do
    case fetch_owned(owner_id, uuid) do
      nil -> {:error, :not_found}
      order -> {:ok, project(order, Trading.db_clock())}
    end
  end

  # --- Transaction Participants ---

  def create_in_transaction!(terms) do
    Trading.require_read_committed!()

    player = Repo.one(from p in Player, where: p.id == ^terms.player_id, lock: "FOR UPDATE")
    if is_nil(player), do: Trading.reject(:player_not_found)

    issuance = Repo.one(from i in Issuance, where: i.player_id == ^terms.player_id)
    if is_nil(issuance), do: Trading.reject(:not_initialized)
    if issuance.recipient_id == terms.owner_id, do: Trading.reject(:self_purchase)

    now = Trading.db_clock()
    if DateTime.compare(terms.expires_at, now) != :gt, do: Trading.reject(:invalid_request)

    order = Repo.insert!(struct!(ConditionalOrder, Map.merge(terms, %{created_at: now})))
    project(order, now)
  end

  def evaluate_in_transaction!(order_id) do
    order = Repo.one(from o in ConditionalOrder, where: o.id == ^order_id, lock: "FOR UPDATE")

    case order do
      nil ->
        {nil, false}

      %{status: "pending"} ->
        result = decide_order(order)
        {result, result.status != "pending"}

      _ ->
        {project(order, Trading.db_clock()), false}
    end
  end

  def command(fun) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      Trading.safely(fn ->
        Repo.transaction(fn ->
          Trading.require_read_committed!()
          fun.()
        end)
      end)
    end
  end

  # --- Private Helpers ---

  defp validate_terms(%AuthenticatedActor{account_id: owner_id}, terms) when is_map(terms) do
    with true <- Enum.sort(Map.keys(terms)) == Enum.sort(@term_keys),
         {:ok, owner_uuid} <- strict_uuid(owner_id),
         {:ok, player_uuid} <- strict_uuid(terms.player_id),
         quantity when is_integer(quantity) and quantity in 1..100 <- terms.quantity,
         {:ok, max_price} <- parse_money(terms.maximum_unit_price),
         {:ok, expiry} <- parse_expiry(terms.expires_at) do
      {:ok,
       %{
         owner_id: owner_uuid,
         player_id: player_uuid,
         quantity: quantity,
         maximum_unit_price: max_price,
         expires_at: expiry
       }}
    else
      _ -> Error.new(:invalid_request, :invalid_request)
    end
  end

  defp validate_terms(%AuthenticatedActor{}, _),
    do: Error.new(:invalid_request, :invalid_request)

  defp validate_terms(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp fetch_owned(owner_id, order_id, locked \\ false) do
    query = from o in ConditionalOrder, where: o.owner_id == ^owner_id and o.id == ^order_id
    query = if locked, do: from(o in query, lock: "FOR UPDATE"), else: query
    Repo.one(query)
  end

  defp cancel_locked(nil), do: Repo.rollback(:not_found)

  defp cancel_locked(%{status: "pending"} = order) do
    now = Trading.db_clock()
    status = if DateTime.compare(now, order.expires_at) == :lt, do: "cancelled", else: "expired"
    finish_order(order, [status: status, completed_at: now], now)
  end

  defp cancel_locked(order), do: project(order, Trading.db_clock())

  defp transition_command(fun) do
    case command(fun) do
      {:ok, {nil, _changed}} ->
        {:error, :not_found}

      {:ok, {result, changed}} ->
        if changed, do: OrderEvaluation.notify_changed(result.id)
        {:ok, result}

      error ->
        error
    end
  end

  defp decide_order(order) do
    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      "conditional:" <> order.id
    ])

    request = %{
      buyer_id: order.owner_id,
      player_id: order.player_id,
      quantity: order.quantity,
      request_key: "conditional:" <> order.id,
      conditional_order_id: order.id
    }

    {issuance, balances, holdings} = Trading.lock_resources!(:purchase, request)
    now = Trading.db_clock()

    if DateTime.compare(now, order.expires_at) != :lt do
      finish_order(order, [status: "expired", completed_at: now], now)
    else
      quote = Trading.current_quote!(:purchase, order.player_id)

      if is_nil(quote) or Decimal.compare(quote.unit_price, order.maximum_unit_price) == :gt do
        project(order, now)
      else
        execute_order(order, request, issuance, balances, holdings, quote, now)
      end
    end
  end

  defp execute_order(order, request, issuance, balances, holdings, quote, now) do
    case Trading.eligible(:purchase, request, issuance, balances, holdings, quote) do
      {:ok, resources} ->
        purchase = Trading.write!(:purchase, request, issuance, holdings, quote, resources, now)

        finish_order(
          order,
          [status: "executed", completed_at: now, purchase_id: purchase.id],
          now
        )

      {:error, kind} when kind in [:insufficient_funds, :insufficient_inventory] ->
        finish_order(
          order,
          [status: "rejected", completed_at: now, rejection_reason: Atom.to_string(kind)],
          now
        )

      {:error, kind} ->
        Trading.reject(kind)
    end
  end

  defp finish_order(order, attrs, now),
    do: order |> Ecto.Changeset.change(attrs) |> Repo.update!() |> project(now)

  defp project(order, now) do
    record = order |> Map.from_struct() |> Map.drop([:__meta__])

    execution =
      if order.purchase_id do
        purchase = Repo.get!(Purchase, order.purchase_id)

        purchase
        |> Map.take([:quote_id, :unit_price, :total, :completed_at])
        |> Map.put(:purchase_id, purchase.id)
      end

    record
    |> Map.put(:execution, execution)
    |> Map.put(:expiry_reached, DateTime.compare(now, record.expires_at) != :lt)
  end

  defp strict_uuid(id) when is_binary(id) and byte_size(id) == 36, do: Ecto.UUID.cast(id)
  defp strict_uuid(_), do: :error

  defp parse_money(%Decimal{sign: 1, coef: c} = val) when is_integer(c) and c > 0 do
    if Decimal.equal?(val, Decimal.round(val, 2)), do: {:ok, val}, else: :error
  end

  defp parse_money(val) when is_binary(val) do
    case Decimal.parse(val) do
      {dec, ""} -> parse_money(dec)
      _ -> :error
    end
  end

  defp parse_money(_), do: :error

  defp parse_expiry(%DateTime{utc_offset: 0, std_offset: 0} = dt),
    do: {:ok, %{dt | microsecond: {elem(dt.microsecond, 0), 6}}}

  defp parse_expiry(val) when is_binary(val) do
    if Regex.match?(~r/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{1,6})?(?:Z|\+00:00)$/, val) do
      case DateTime.from_iso8601(val) do
        {:ok, dt, 0} -> parse_expiry(dt)
        _ -> :error
      end
    else
      :error
    end
  end

  defp parse_expiry(_), do: :error
end

# --- Background Evaluation Sweep & PubSub Notifications ---

defmodule FootballMarket.Market.OrderEvaluation do
  @moduledoc """
  Background evaluation passes, missed-quote recovery sweeps, and post-commit
  PubSub reload hints for conditional buy orders.
  """

  import Ecto.Query

  alias FootballMarket.Market.{
    ConditionalOrder,
    OrderEvaluationMember,
    OrderEvaluationPass,
    Orders,
    Trading
  }

  alias FootballMarket.Quotes
  alias FootballMarket.Repo
  alias FootballMarket.Workers.{ConditionalOrderEvaluation, ConditionalOrderRecovery}

  def oban_name do
    Application.get_env(:football_market, FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  def enqueue!(args) do
    name = oban_name()
    if is_nil(Oban.Registry.lookup(name)), do: Trading.reject(:temporarily_unavailable)
    Oban.insert!(name, ConditionalOrderEvaluation.new(args))
  end

  def startup, do: Oban.insert(oban_name(), ConditionalOrderRecovery.new(%{}))

  def run(wake) when is_boolean(wake) do
    with :ok <- if(wake, do: unwrap(request_pass()), else: :ok), do: run_steps(100)
  end

  @doc "Claims pending quote evaluation events and evaluates all pending orders."
  def recover(_after_id \\ nil) do
    Trading.safely(&run_recovery/0)
  end

  defp run_recovery do
    Enum.each(Quotes.pending_evaluations(), &acknowledge_event/1)

    with {:ok, _} <- request_pass(),
         :ok <- run(false) do
      :ok
    else
      _ -> {:error, :temporarily_unavailable}
    end
  end

  defp acknowledge_event(event) do
    receipt = "conditional-evaluation:" <> event.id

    with {:ok, claim} <- Quotes.claim_evaluation(event.id) do
      _ = Quotes.acknowledge_evaluation(event.id, claim.fence, receipt)
    end
  end

  def request_pass do
    Orders.command(fn ->
      pass = lock_pass!()

      if pass.state == "idle",
        do: capture_pass!(pass),
        else: update_pass!(pass, rescan_requested: true)

      :ok
    end)
  end

  def step do
    Orders.command(fn ->
      pass = lock_pass!()
      if pass.state == "idle", do: :idle, else: advance_pass!(pass)
    end)
  end

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

  defp run_steps(0) do
    Orders.command(fn ->
      pass = lock_pass!()
      if pass.state == "running", do: enqueue!(%{"source" => "continuation"})
      :ok
    end)
    |> unwrap()
  end

  defp run_steps(remaining) do
    case step() do
      {:ok, :idle} ->
        :ok

      {:ok, :rescan} ->
        run_steps(remaining)

      {:ok, {:decided, {order, changed}}} ->
        if changed and order, do: notify_changed(order.id)
        run_steps(remaining - 1)

      {:error, _} ->
        {:error, :temporarily_unavailable}
    end
  end

  defp lock_pass!,
    do: Repo.one!(from pass in OrderEvaluationPass, where: pass.id == 1, lock: "FOR UPDATE")

  defp capture_pass!(pass) do
    generation = pass.generation + 1

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
        from m in OrderEvaluationMember,
          join: o in ConditionalOrder,
          on: o.id == m.order_id,
          where: m.pass_generation == ^generation,
          order_by: [desc: m.ordinal],
          limit: 1,
          select: {o.created_at, o.id}
      )

    {upper_at, upper_id} = highest || {nil, nil}

    update_pass!(pass,
      state: if(highest, do: "running", else: "idle"),
      generation: generation,
      started_at: Trading.db_clock(),
      cursor_ordinal: 0,
      upper_created_at: upper_at,
      upper_order_id: upper_id,
      rescan_requested: false
    )
  end

  defp advance_pass!(pass) do
    next_member =
      Repo.one(
        from m in OrderEvaluationMember,
          where: m.pass_generation == ^pass.generation and m.ordinal > ^pass.cursor_ordinal,
          order_by: m.ordinal,
          limit: 1
      )

    case next_member do
      nil ->
        Repo.delete_all(
          from m in OrderEvaluationMember, where: m.pass_generation == ^pass.generation
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

      member ->
        result = Orders.evaluate_in_transaction!(member.order_id)
        update_pass!(pass, cursor_ordinal: member.ordinal)
        {:decided, result}
    end
  end

  defp update_pass!(pass, attrs) do
    pass
    |> Ecto.Changeset.change(Keyword.put(attrs, :updated_at, Trading.db_clock()))
    |> Repo.update!()
  end

  defp unwrap({:ok, _}), do: :ok
  defp unwrap({:error, _}), do: {:error, :temporarily_unavailable}
end
