defmodule FootballMarket.Market.Quote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "market_quotes" do
    belongs_to :player, FootballMarket.Catalog.Player
    field :unit_price, :decimal
    field :effective_at, :utc_datetime_usec
    field :inserted_at, :utc_datetime_usec
    field :rule_id, :string
    field :rule_version, :string
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [:player_id, :unit_price, :effective_at, :inserted_at, :rule_id, :rule_version])
    |> validate_required([
      :player_id,
      :unit_price,
      :effective_at,
      :inserted_at,
      :rule_id,
      :rule_version
    ])
    |> foreign_key_constraint(:player_id)
    |> unique_constraint(:player_id, name: :market_quote_initial_unique)
    |> check_constraint(:unit_price, name: :market_quote_canonical)
  end
end
