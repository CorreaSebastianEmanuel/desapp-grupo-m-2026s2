defmodule FootballMarket.Market do
  @moduledoc "Trusted initial allocation for existing local player and user identities."
  alias FootballMarket.Market.{Input, Store}

  defdelegate purchase(actor, input), to: FootballMarket.Market.Purchases

  defdelegate sale(actor, input), to: FootballMarket.Market.Sales

  defdelegate transaction_history(actor, options),
    to: FootballMarket.Market.TransactionHistory,
    as: :list

  defdelegate portfolio_allocation(actor), to: FootballMarket.Market.Analytics, as: :allocation

  defdelegate portfolio_history(actor, options), to: FootballMarket.Market.Analytics, as: :history

  defdelegate portfolio(actor), to: FootballMarket.Market.Portfolio, as: :list

  defdelegate initial_inventory(actor),
    to: FootballMarket.Market.InitialInventory,
    as: :list

  defdelegate initial_recipient?(actor),
    to: FootballMarket.Market.InitialInventory

  defdelegate credit_balance(actor),
    to: FootballMarket.Market.CreditBalances,
    as: :available

  defdelegate create_conditional_order(actor, terms),
    to: FootballMarket.Market.ConditionalOrders,
    as: :create

  defdelegate list_conditional_orders(actor),
    to: FootballMarket.Market.ConditionalOrders,
    as: :list

  defdelegate get_conditional_order(actor, id),
    to: FootballMarket.Market.ConditionalOrders,
    as: :get

  defdelegate cancel_conditional_order(actor, id),
    to: FootballMarket.Market.ConditionalOrders,
    as: :cancel

  defdelegate evaluate_conditional_order(id),
    to: FootballMarket.Market.ConditionalOrders,
    as: :evaluate

  def initialize_player(player_id, assertions \\ %{}) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    with {:ok, input} <- Input.validate(player_id, designation, assertions),
         do: Store.initialize(input)
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

  defp initialize_primary_in_transaction(player_id) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    case designation do
      [] ->
        {:error, :primary_account_not_configured}

      [_] ->
        with {:ok, input} <- Input.validate(player_id, designation, %{}),
             do: Store.initialize_in_transaction(input)

      _ ->
        {:error, :ambiguous_initial_issuance_recipient}
    end
  end

  defp primary_player_action(player_id, initialize) do
    case get_initial_issuance(player_id) do
      {:ok, issuance} -> {:ok, %{outcome: :already_completed, issuance: issuance}}
      {:error, %{reason: :not_initialized}} -> initialize.()
      {:error, error} -> {:error, error}
    end
  end

  def get_initial_issuance(player_id) do
    with {:ok, id} <- Input.identifier(player_id), do: Store.get(id)
  end
end
