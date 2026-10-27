defmodule FootballMarket.Market do
  @moduledoc "Trusted issuance and atomic trading for existing local identities."
  alias FootballMarket.Market.{Input, Store}

  defdelegate purchase(actor, input), to: FootballMarket.Market.Purchases
  defdelegate sell(actor, input), to: FootballMarket.Market.Sales

  def initialize_player(player_id, assertions \\ %{}) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    with {:ok, input} <- Input.validate(player_id, designation, assertions),
         do: Store.initialize(input)
  end

  def get_initial_issuance(player_id) do
    with {:ok, id} <- Input.identifier(player_id), do: Store.get(id)
  end
end
