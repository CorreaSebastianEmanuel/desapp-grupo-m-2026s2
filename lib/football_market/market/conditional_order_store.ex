defmodule FootballMarket.Market.ConditionalOrderStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    ConditionalOrder,
    ConditionalOrderProjection,
    Error,
    Issuance,
    Purchase,
    PurchaseTransaction
  }

  def create(terms) do
    command(fn ->
      order = create_in_transaction!(terms)

      FootballMarket.Market.OrderEvaluation.enqueue!(%{
        "source" => "order",
        "order_id" => order.id
      })

      order
    end)
  end

  @doc "Internal transaction participant for TASK-060; caller owns commit."
  def create_in_transaction!(terms) do
    unless Repo.in_transaction?(), do: raise(ArgumentError, "transaction required")
    isolation!()
    player = Repo.one(from p in Player, where: p.id == ^terms.player_id, lock: "FOR UPDATE")
    if is_nil(player), do: reject(:player_not_found)
    issuance = Repo.one(from i in Issuance, where: i.player_id == ^terms.player_id)
    if is_nil(issuance), do: reject(:not_initialized)
    if issuance.recipient_id == terms.owner_id, do: reject(:self_purchase)
    now = clock()
    if DateTime.compare(terms.expires_at, now) != :gt, do: reject(:invalid_request)
    order = Repo.insert!(struct!(ConditionalOrder, Map.merge(terms, %{created_at: now})))
    project(order, now)
  end

  def cancel(owner, id) do
    transition_command(fn ->
      order = owned(owner, id, true)
      {cancel_locked(order), order && order.status == "pending"}
    end)
  end

  defp cancel_locked(nil), do: Repo.rollback(:not_found)

  defp cancel_locked(%{status: "pending"} = order) do
    now = clock()
    status = if DateTime.compare(now, order.expires_at) == :lt, do: "cancelled", else: "expired"
    finish(order, [status: status, completed_at: now], now)
  end

  defp cancel_locked(order), do: project(order, clock())

  def evaluate(id), do: transition_command(fn -> evaluate_in_transaction!(id) end)

  @doc "Internal Market transaction participant; the caller owns commit and notifications."
  def evaluate_in_transaction!(id) do
    unless Repo.in_transaction?(), do: raise(ArgumentError, "transaction required")
    order = Repo.one(from o in ConditionalOrder, where: o.id == ^id, lock: "FOR UPDATE")

    case order do
      nil ->
        {nil, false}

      %{status: "pending"} ->
        result = decide(order)
        {result, result.status != "pending"}

      _ ->
        {project(order, clock()), false}
    end
  end

  defp transition_command(fun) do
    case command(fun) do
      {:ok, {nil, _}} ->
        {:error, :not_found}

      {:ok, {result, changed}} ->
        if changed, do: FootballMarket.Market.OrderNotifications.changed(result.id)
        {:ok, result}

      error ->
        error
    end
  end

  defp decide(order) do
    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      "conditional:" <> order.id
    ])

    input = %{
      buyer_id: order.owner_id,
      player_id: order.player_id,
      quantity: order.quantity,
      request_key: "conditional:" <> order.id,
      conditional_order_id: order.id
    }

    {issue, balances, holdings} = PurchaseTransaction.lock_resources!(input)
    now = clock()

    if DateTime.compare(now, order.expires_at) != :lt do
      finish(order, [status: "expired", completed_at: now], now)
    else
      quote = PurchaseTransaction.current_quote!(order.player_id)

      if is_nil(quote) or Decimal.compare(quote.unit_price, order.maximum_unit_price) == :gt do
        project(order, now)
      else
        execute(order, input, issue, balances, holdings, quote, now)
      end
    end
  end

  defp execute(order, input, issue, balances, holdings, quote, now) do
    case PurchaseTransaction.eligible(input, issue, balances, holdings, quote) do
      {:ok, resources} ->
        purchase = PurchaseTransaction.write!(input, issue, holdings, quote, resources, now)
        finish(order, [status: "executed", completed_at: now, purchase_id: purchase.id], now)

      {:error, kind} when kind in [:insufficient_funds, :insufficient_inventory] ->
        finish(
          order,
          [status: "rejected", completed_at: now, rejection_reason: Atom.to_string(kind)],
          now
        )

      {:error, kind} ->
        reject(kind)
    end
  end

  defp finish(order, attrs, now),
    do: order |> Ecto.Changeset.change(attrs) |> Repo.update!() |> project(now)

  def list(owner) do
    safely(fn ->
      # One database clock sample per response; no transaction/queue mutation.
      now = clock()

      {:ok,
       Repo.all(
         from o in ConditionalOrder, where: o.owner_id == ^owner, order_by: [o.created_at, o.id]
       )
       |> Enum.map(&project(&1, now))}
    end)
  end

  def get(owner, id) do
    safely(fn ->
      case owned(owner, id) do
        nil -> {:error, :not_found}
        order -> {:ok, project(order, clock())}
      end
    end)
  end

  def pending_candidates(player, after_id, limit) when is_integer(limit) and limit in 1..100 do
    safely(fn ->
      query =
        from o in ConditionalOrder, where: o.status == "pending", order_by: o.id, limit: ^limit

      query = if player, do: from(o in query, where: o.player_id == ^player), else: query
      query = if after_id, do: from(o in query, where: o.id > ^after_id), else: query
      {:ok, Repo.all(query)}
    end)
  end

  def pending_candidates(_, _, _), do: Error.new(:invalid_request, :invalid_request)

  def command(fun) do
    if Repo.in_transaction?(),
      do: Error.new(:invalid_request, :transaction_in_progress),
      else:
        safely(fn ->
          Repo.transaction(fn ->
            isolation!()
            fun.()
          end)
        end)
  end

  def owned(owner, id, locked \\ false) do
    query = from o in ConditionalOrder, where: o.owner_id == ^owner and o.id == ^id
    query = if locked, do: from(o in query, lock: "FOR UPDATE"), else: query
    Repo.one(query)
  end

  def clock do
    [[now]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    DateTime.from_naive!(now, "Etc/UTC")
  end

  def isolation! do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: reject(:invalid_request)
  end

  def reject(kind), do: Repo.rollback(%Error{kind: kind, reason: kind})

  def project(order, now) do
    record = order |> Map.from_struct() |> Map.drop([:__meta__])

    execution =
      if order.purchase_id, do: purchase(Repo.get!(Purchase, order.purchase_id)), else: nil

    record |> Map.put(:execution, execution) |> ConditionalOrderProjection.at(now)
  end

  defp purchase(p),
    do:
      Map.take(p, [:quote_id, :unit_price, :total, :completed_at]) |> Map.put(:purchase_id, p.id)

  def safely(fun) do
    fun.()
  rescue
    _ in [
      Postgrex.Error,
      DBConnection.ConnectionError,
      Ecto.ConstraintError,
      Ecto.InvalidChangesetError
    ] ->
      Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
