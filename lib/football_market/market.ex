defmodule FootballMarket.Market do
  @moduledoc "Trusted initial allocation for existing local player and user identities."
  alias FootballMarket.Market.{Input, Store}

  def initialize_player(player_id, assertions \\ %{}) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    with {:ok, input} <- Input.validate(player_id, designation, assertions),
         do: Store.initialize(input)
  end

  def get_initial_issuance(player_id) do
    with {:ok, id} <- Input.identifier(player_id), do: Store.get(id)
  end
end
