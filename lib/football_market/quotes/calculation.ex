defmodule FootballMarket.Quotes.Calculation do
  @moduledoc "Persisted immutable outcome for one canonical quote calculation."
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_calculations" do
    field :player_id, :binary_id
    field :season_id, :binary_id
    field :week_start, :utc_datetime_usec
    field :week_end, :utc_datetime_usec
    field :configuration_version_id, :binary_id
    field :mapping_id, :binary_id
    field :membership, {:array, :binary_id}
    field :canonical_identity, :map
    field :status, :string
    field :reason, :string
    field :score, :decimal
    field :unit_price, :decimal
    field :effective_at, :utc_datetime_usec
    field :evidence, :map
    field :inserted_at, :utc_datetime_usec
  end
end
