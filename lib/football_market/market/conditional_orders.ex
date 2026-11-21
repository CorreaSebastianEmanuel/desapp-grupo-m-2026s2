defmodule FootballMarket.Market.ConditionalOrders do
  @moduledoc """
  User-owned conditional buy orders (limit orders evaluated when quotes publish).

  Owns input validation, creation, listing, cancellation, and locked order
  evaluation against `FootballMarket.Market.Trading`.
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
    Settlement,
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
    case cast_uuid(order_id) do
      {:ok, uuid} ->
        transition_command(fn ->
          order = fetch_owned(owner_id, uuid, true)
          {cancel_locked(order), order && order.status == "pending"}
        end)

      _ ->
        {:error, :not_found}
    end
  end

  def cancel(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  def evaluate(order_id) do
    case cast_uuid(order_id) do
      {:ok, uuid} -> transition_command(fn -> evaluate_in_transaction!(uuid) end)
      _ -> {:error, :not_found}
    end
  end

  def list(%AuthenticatedActor{account_id: owner_id}) do
    Settlement.safely(fn ->
      now = Settlement.clock()

      orders =
        Repo.all(
          from order in ConditionalOrder,
            where: order.owner_id == ^owner_id,
            order_by: [order.created_at, order.id]
        )
        |> Enum.map(fn order -> project(order, now) end)

      {:ok, orders}
    end)
  end

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  def get(%AuthenticatedActor{account_id: owner_id}, order_id) do
    case cast_uuid(order_id) do
      {:ok, uuid} -> Settlement.safely(fn -> read_owned_order(owner_id, uuid) end)
      _ -> {:error, :not_found}
    end
  end

  def get(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp read_owned_order(owner_id, uuid) do
    case fetch_owned(owner_id, uuid) do
      nil -> {:error, :not_found}
      order -> {:ok, project(order, Settlement.clock())}
    end
  end

  # --- Input Validation ---

  def validate_terms(%AuthenticatedActor{account_id: owner_id}, terms) when is_map(terms) do
    with true <- Enum.sort(Map.keys(terms)) == Enum.sort(@term_keys),
         {:ok, owner_uuid} <- cast_uuid(owner_id),
         {:ok, player_uuid} <- cast_uuid(terms.player_id),
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

  def validate_terms(%AuthenticatedActor{}, _),
    do: Error.new(:invalid_request, :invalid_request)

  def validate_terms(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  def cast_uuid(id) when is_binary(id) and byte_size(id) == 36, do: Ecto.UUID.cast(id)
  def cast_uuid(_), do: :error

  # --- Transaction Participants (Shared with OrderEvaluation) ---

  @doc "Internal transaction participant; caller owns commit."
  def create_in_transaction!(terms) do
    unless Repo.in_transaction?(), do: raise(ArgumentError, "transaction required")
    Settlement.isolation!()

    player = Repo.one(from p in Player, where: p.id == ^terms.player_id, lock: "FOR UPDATE")
    if is_nil(player), do: Settlement.reject(:player_not_found)

    issuance = Repo.one(from i in Issuance, where: i.player_id == ^terms.player_id)
    if is_nil(issuance), do: Settlement.reject(:not_initialized)
    if issuance.recipient_id == terms.owner_id, do: Settlement.reject(:self_purchase)

    now = Settlement.clock()
    if DateTime.compare(terms.expires_at, now) != :gt, do: Settlement.reject(:invalid_request)

    order = Repo.insert!(struct!(ConditionalOrder, Map.merge(terms, %{created_at: now})))
    project(order, now)
  end

  @doc "Internal transaction participant; caller owns commit and post-commit notifications."
  def evaluate_in_transaction!(order_id) do
    unless Repo.in_transaction?(), do: raise(ArgumentError, "transaction required")
    order = Repo.one(from o in ConditionalOrder, where: o.id == ^order_id, lock: "FOR UPDATE")

    case order do
      nil ->
        {nil, false}

      %{status: "pending"} ->
        result = decide_order(order)
        {result, result.status != "pending"}

      _ ->
        {project(order, Settlement.clock()), false}
    end
  end

  def pending_candidates(player_id, after_id, limit)
      when is_integer(limit) and limit in 1..100 do
    Settlement.safely(fn ->
      query =
        from o in ConditionalOrder, where: o.status == "pending", order_by: o.id, limit: ^limit

      query = if player_id, do: from(o in query, where: o.player_id == ^player_id), else: query
      query = if after_id, do: from(o in query, where: o.id > ^after_id), else: query
      {:ok, Repo.all(query)}
    end)
  end

  def pending_candidates(_, _, _), do: Error.new(:invalid_request, :invalid_request)

  def command(fun) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      Settlement.safely(fn ->
        Repo.transaction(fn ->
          Settlement.isolation!()
          fun.()
        end)
      end)
    end
  end

  def project(order, now) do
    record = order |> Map.from_struct() |> Map.drop([:__meta__])

    execution =
      if order.purchase_id,
        do: summarize_purchase(Repo.get!(Purchase, order.purchase_id)),
        else: nil

    record
    |> Map.put(:execution, execution)
    |> Map.put(:expiry_reached, DateTime.compare(now, record.expires_at) != :lt)
  end

  # --- Private Helpers ---

  defp fetch_owned(owner_id, order_id, locked \\ false) do
    query = from o in ConditionalOrder, where: o.owner_id == ^owner_id and o.id == ^order_id
    query = if locked, do: from(o in query, lock: "FOR UPDATE"), else: query
    Repo.one(query)
  end

  defp cancel_locked(nil), do: Repo.rollback(:not_found)

  defp cancel_locked(%{status: "pending"} = order) do
    now = Settlement.clock()
    status = if DateTime.compare(now, order.expires_at) == :lt, do: "cancelled", else: "expired"
    finish_order(order, [status: status, completed_at: now], now)
  end

  defp cancel_locked(order), do: project(order, Settlement.clock())

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
    now = Settlement.clock()

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
        Settlement.reject(kind)
    end
  end

  defp finish_order(order, attrs, now),
    do: order |> Ecto.Changeset.change(attrs) |> Repo.update!() |> project(now)

  defp summarize_purchase(purchase) do
    purchase
    |> Map.take([:quote_id, :unit_price, :total, :completed_at])
    |> Map.put(:purchase_id, purchase.id)
  end

  defp parse_money(%Decimal{sign: 1, coef: coefficient} = value)
       when is_integer(coefficient) and coefficient > 0 do
    if Decimal.equal?(value, Decimal.round(value, 2)), do: {:ok, value}, else: :error
  end

  defp parse_money(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> parse_money(decimal)
      _ -> :error
    end
  end

  defp parse_money(_), do: :error

  defp parse_expiry(%DateTime{utc_offset: 0, std_offset: 0} = value),
    do: {:ok, %{value | microsecond: {elem(value.microsecond, 0), 6}}}

  defp parse_expiry(value) when is_binary(value) do
    iso_utc_pattern = ~r/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{1,6})?(?:Z|\+00:00)$/

    if Regex.match?(iso_utc_pattern, value) do
      case DateTime.from_iso8601(value) do
        {:ok, datetime, 0} -> parse_expiry(datetime)
        _ -> :error
      end
    else
      :error
    end
  end

  defp parse_expiry(_), do: :error
end
