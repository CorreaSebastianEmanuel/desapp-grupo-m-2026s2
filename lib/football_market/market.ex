defmodule FootballMarket.Market do
  @moduledoc """
  Public facade for the Market domain.

  Every market operation enters through this module and delegates to a focused
  1-file-per-module implementation under `lib/football_market/market/`:

    * `Initialization` (`initialization.ex`) — one-time 100-token issuance per player
    * `Trading` (`trading.ex`) — atomic, idempotent token purchases and sales
    * `Portfolio` (`portfolio.ex`) — current holdings, spendable credit balance, initial inventory
    * `TransactionHistory` (`transaction_history.ex`) — paginated buy/sell history
    * `Analytics` (`analytics.ex`) — allocation weights and daily historical portfolio valuation
    * `ConditionalOrders` (`conditional_orders.ex`) — user-owned conditional buy orders
    * `OrderEvaluation` (`order_evaluation.ex`) — background evaluation passes & PubSub hints
    * `Settlement` (`settlement.ex`) & `schemas.ex` — shared money/locking helpers & Ecto schemas
  """

  alias FootballMarket.Market.{
    Analytics,
    ConditionalOrders,
    Initialization,
    Portfolio,
    Trading,
    TransactionHistory
  }

  # --- Trading ---

  defdelegate purchase(actor, input), to: Trading
  defdelegate sale(actor, input), to: Trading
  defdelegate transaction_history(actor, options), to: TransactionHistory, as: :list

  # --- Portfolio & Balances ---

  defdelegate portfolio(actor), to: Portfolio, as: :list
  defdelegate credit_balance(actor), to: Portfolio
  defdelegate initial_inventory(actor), to: Portfolio
  defdelegate initial_recipient?(actor), to: Portfolio
  defdelegate portfolio_allocation(actor), to: Analytics, as: :allocation
  defdelegate portfolio_history(actor, options), to: Analytics, as: :history

  # --- Conditional Buy Orders ---

  defdelegate create_conditional_order(actor, terms), to: ConditionalOrders, as: :create
  defdelegate list_conditional_orders(actor), to: ConditionalOrders, as: :list
  defdelegate get_conditional_order(actor, id), to: ConditionalOrders, as: :get
  defdelegate cancel_conditional_order(actor, id), to: ConditionalOrders, as: :cancel
  defdelegate evaluate_conditional_order(id), to: ConditionalOrders, as: :evaluate

  # --- Initial Token Issuance ---

  def initialize_player(player_id, assertions \\ %{}) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    with {:ok, input} <- Initialization.validate_input(player_id, designation, assertions),
         do: Initialization.initialize(input)
  end

  def initialize_primary_player(player_id) do
    primary_player_action(player_id, fn ->
      case Application.get_env(:football_market, :initial_issuance_recipients, []) do
        [] -> {:error, :primary_account_not_configured}
        [_recipient] -> initialize_player(player_id)
        _recipients -> {:error, :ambiguous_initial_issuance_recipient}
      end
    end)
  end

  def initialize_primary_player_in_transaction(player_id) do
    primary_player_action(player_id, fn -> initialize_primary_in_transaction(player_id) end)
  end

  def get_initial_issuance(player_id) do
    with {:ok, id} <- Initialization.validate_player_id(player_id),
         do: Initialization.get(id)
  end

  defp initialize_primary_in_transaction(player_id) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    case designation do
      [] ->
        {:error, :primary_account_not_configured}

      [_recipient] ->
        with {:ok, input} <- Initialization.validate_input(player_id, designation, %{}),
             do: Initialization.initialize_in_transaction(input)

      _recipients ->
        {:error, :ambiguous_initial_issuance_recipient}
    end
  end

  defp primary_player_action(player_id, initialize_fn) do
    case get_initial_issuance(player_id) do
      {:ok, issuance} -> {:ok, %{outcome: :already_completed, issuance: issuance}}
      {:error, %{reason: :not_initialized}} -> initialize_fn.()
      {:error, error} -> {:error, error}
    end
  end
end
