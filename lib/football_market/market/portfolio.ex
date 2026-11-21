defmodule FootballMarket.Market.Portfolio do
  @moduledoc """
  Authenticated read models for an account's balances, token holdings, and initial inventory.

  Owns:
    * Current portfolio positions (`list/1`) with average cost basis and unrealized P&L
    * Spendable credit balance (`credit_balance/1`)
    * Initial recipient inventory (`initial_inventory/1`, `initial_recipient?/1`)
    * Shared weighted-average position ledger math (`exact/1`, `apply_transaction/2`, `calculate/1`)
  """

  import Ecto.Query

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    CreditBalance,
    Error,
    Holding,
    InitialRecipient,
    Issuance,
    Purchase,
    Quote,
    Sale
  }

  alias FootballMarket.Repo

  # High-precision decimal context preserves accounting accuracy independently of caller settings.
  @average_decimals 18

  # --- Portfolio Positions ---

  def list(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    with {:ok, transactions} <- load_transactions(owner_id) do
      build_portfolio_view(transactions)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  # --- Credit Balance ---

  def credit_balance(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    case Ecto.UUID.cast(owner_id) do
      {:ok, uuid} -> read_credit_balance(uuid)
      :error -> Error.new(:unauthenticated, :unauthenticated)
    end
  end

  def credit_balance(_), do: Error.new(:unauthenticated, :unauthenticated)

  defp read_credit_balance(owner_id) do
    amount =
      Repo.one(
        from balance in CreditBalance,
          where: balance.user_id == ^owner_id,
          select: balance.amount
      )

    {:ok, amount || Decimal.new("0.00")}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  # --- Initial Recipient Inventory ---

  def initial_inventory(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    query =
      from issuance in Issuance,
        join: holding in Holding,
        on: holding.player_id == issuance.player_id and holding.user_id == issuance.recipient_id,
        join: player in Player,
        on: player.id == issuance.player_id,
        where: issuance.recipient_id == ^owner_id and holding.quantity > 0,
        order_by: [asc: player.display_name, asc: player.id],
        select: %{
          player_id: player.id,
          player_name: player.display_name,
          quantity: holding.quantity
        }

    {:ok, Repo.all(query)}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def initial_inventory(_), do: Error.new(:unauthenticated, :unauthenticated)

  def initial_recipient?(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    case Ecto.UUID.cast(owner_id) do
      {:ok, uuid} -> read_initial_recipient?(uuid)
      :error -> Error.new(:unauthenticated, :unauthenticated)
    end
  end

  def initial_recipient?(_), do: Error.new(:unauthenticated, :unauthenticated)

  defp read_initial_recipient?(recipient_id) do
    exists =
      Repo.exists?(from recipient in InitialRecipient, where: recipient.user_id == ^recipient_id)

    {:ok, exists}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  # --- Weighted-Average Ledger Math (Shared with Analytics) ---

  @doc "Runs a calculation under a 200-digit Decimal context to avoid rounding drift."
  def exact(fun), do: Decimal.Context.with(%Decimal.Context{precision: 200}, fun)

  @doc """
  Applies one purchase or sale to the position map.
  Closed positions stay in the map so analytics keeps their cumulative realized profit/loss.
  """
  def apply_transaction(%{type: "purchase"} = transaction, positions) do
    prior = Map.get(positions, transaction.player_id, empty_position())
    quantity = prior.quantity + transaction.quantity

    basis =
      Decimal.add(
        Decimal.mult(prior.average_unit_cost, prior.quantity),
        transaction.total
      )

    average =
      basis
      |> Decimal.div(quantity)
      |> Decimal.round(@average_decimals, :half_up)

    Map.put(positions, transaction.player_id, %{
      quantity: quantity,
      average_unit_cost: average,
      realized_profit_loss: prior.realized_profit_loss
    })
  end

  def apply_transaction(%{type: "sale"} = transaction, positions) do
    prior = Map.get(positions, transaction.player_id, empty_position())
    cost = Decimal.mult(prior.average_unit_cost, transaction.quantity)

    Map.put(positions, transaction.player_id, %{
      quantity: prior.quantity - transaction.quantity,
      average_unit_cost: prior.average_unit_cost,
      realized_profit_loss:
        Decimal.add(prior.realized_profit_loss, Decimal.sub(transaction.total, cost))
    })
  end

  def calculate(transactions) do
    exact(fn ->
      transactions
      |> Enum.sort_by(fn tx ->
        {DateTime.to_unix(tx.completed_at, :microsecond), tx.type, tx.id}
      end)
      |> Enum.reduce(%{}, &apply_transaction/2)
      |> Enum.filter(fn {_player_id, position} -> position.quantity > 0 end)
      |> Enum.map(fn {player_id, position} -> Map.put(position, :player_id, player_id) end)
      |> Enum.sort_by(fn position -> position.player_id end)
    end)
  end

  def transaction_query(owner_id) do
    purchases =
      from purchase in Purchase,
        where: purchase.buyer_id == ^owner_id,
        select: %{
          id: purchase.id,
          player_id: purchase.player_id,
          type: type(^"purchase", :string),
          quantity: purchase.quantity,
          total: purchase.total,
          completed_at: purchase.completed_at
        }

    sales =
      from sale in Sale,
        where: sale.seller_id == ^owner_id,
        select: %{
          id: sale.id,
          player_id: sale.player_id,
          type: type(^"sale", :string),
          quantity: sale.quantity,
          total: sale.total,
          completed_at: sale.completed_at
        }

    # Both trade kinds are fetched in one statement so the reducer reads a single
    # committed snapshot and no concurrent trade can interleave.
    union_all(purchases, ^sales)
  end

  # --- Private Helpers ---

  defp empty_position do
    %{quantity: 0, average_unit_cost: Decimal.new(0), realized_profit_loss: Decimal.new(0)}
  end

  defp load_transactions(owner_id) do
    {:ok, Repo.all(transaction_query(owner_id))}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  defp build_portfolio_view(transactions) do
    positions = calculate(transactions)

    if positions == [] do
      {:ok, []}
    else
      player_ids = Enum.map(positions, fn position -> position.player_id end)

      with {:ok, details} <- load_player_details(player_ids) do
        {:ok, exact(fn -> present_positions(positions, details) end)}
      end
    end
  end

  defp load_player_details(player_ids) do
    players =
      Repo.all(from p in Player, where: p.id in ^player_ids, select: {p.id, p.display_name})
      |> Map.new()

    quotes =
      from(q in Quote,
        where: q.player_id in ^player_ids,
        distinct: q.player_id,
        order_by: [
          asc: q.player_id,
          desc: fragment("COALESCE(?, 0)", q.performance_sequence),
          desc: q.effective_at,
          desc: q.inserted_at,
          desc: q.id
        ],
        select: {q.player_id, q.unit_price}
      )
      |> Repo.all()
      |> Map.new()

    all_present? =
      Enum.all?(player_ids, fn id -> Map.has_key?(players, id) and Map.has_key?(quotes, id) end)

    if all_present? do
      details =
        Map.new(player_ids, fn player_id ->
          {player_id,
           %{
             player_name: Map.fetch!(players, player_id),
             current_quote: Map.fetch!(quotes, player_id)
           }}
        end)

      {:ok, details}
    else
      Error.new(:temporarily_unavailable, :quote_unavailable)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  defp present_positions(positions, details) do
    Enum.map(positions, fn position ->
      detail = Map.fetch!(details, position.player_id)
      current_value = Decimal.mult(detail.current_quote, position.quantity)

      unrealized =
        Decimal.mult(
          Decimal.sub(detail.current_quote, position.average_unit_cost),
          position.quantity
        )

      Map.merge(position, %{
        player_name: detail.player_name,
        current_quote: detail.current_quote,
        current_value: current_value,
        unrealized_profit_loss: unrealized
      })
    end)
  end
end
