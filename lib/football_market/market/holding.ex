defmodule FootballMarket.Market.Holding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_holdings" do
    belongs_to :player, FootballMarket.Catalog.Player
    belongs_to :user, FootballMarket.Accounts.User
    field :quantity, :integer
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:player_id, :user_id, :quantity])
    |> validate_required([:player_id, :user_id, :quantity])
    |> foreign_key_constraint(:player_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:player_id, :user_id], name: :market_holding_owner_unique)
    |> check_constraint(:quantity, name: :market_holding_nonnegative)
    |> check_constraint(:quantity, name: :market_supply_conserved)
  end
end
