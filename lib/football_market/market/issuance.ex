defmodule FootballMarket.Market.Issuance do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_issuances" do
    belongs_to :player, FootballMarket.Catalog.Player
    belongs_to :recipient, FootballMarket.Accounts.User
    belongs_to :initial_quote, FootballMarket.Market.Quote
    field :quantity, :integer
    field :initial_unit_price, :decimal
    field :completed_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [
      :player_id,
      :recipient_id,
      :initial_quote_id,
      :quantity,
      :initial_unit_price,
      :completed_at
    ])
    |> validate_required([
      :player_id,
      :recipient_id,
      :initial_quote_id,
      :quantity,
      :initial_unit_price,
      :completed_at
    ])
    |> foreign_key_constraint(:player_id)
    |> foreign_key_constraint(:recipient_id)
    |> foreign_key_constraint(:initial_quote_id, name: :market_issuance_quote_player_fkey)
    |> unique_constraint(:player_id, name: :market_issuance_player_unique)
    |> unique_constraint(:initial_quote_id, name: :market_issuance_quote_unique)
    |> check_constraint(:quantity, name: :market_issuance_canonical)
    |> check_constraint(:recipient_id, name: :market_recipient_consistent)
    |> check_constraint(:quantity, name: :market_supply_conserved)
  end
end
