defmodule FootballMarket.Market do
  @moduledoc "Trusted initial allocation for existing local player and user identities."
  alias FootballMarket.Market.{Input, Store}

  defdelegate purchase(actor, input), to: FootballMarket.Market.Purchases

  defdelegate sale(actor, input), to: FootballMarket.Market.Sales

  defdelegate transaction_history(actor, options),
    to: FootballMarket.Market.TransactionHistory,
    as: :list

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

  def get_initial_issuance(player_id) do
    with {:ok, id} <- Input.identifier(player_id), do: Store.get(id)
  end
end
