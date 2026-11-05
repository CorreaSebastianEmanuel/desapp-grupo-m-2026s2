defmodule FootballMarket.Quotes.CalculationRequest do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_calculation_requests" do
    field :source, :string, default: "import"
    field :admission_key, :string
    field :snapshot_id, :binary_id
    field :intent_id, :binary_id
    field :player_id, :binary_id
    field :season_id, :binary_id
    field :week_start, :utc_datetime_usec
    field :week_end, :utc_datetime_usec
    field :selector, :string
    field :mapping_id, :binary_id
    field :requested_mapping_id, :binary_id
    field :configuration_version_id, :binary_id
    field :calculation_id, :binary_id
    field :explicit_membership, {:array, :binary_id}
    field :explicit_fact_material, :map
    field :state, :string
    field :attempt_count, :integer, default: 0
    field :lease_fence, :integer, default: 0
    field :lease_until, :utc_datetime_usec
    field :next_attempt_at, :utc_datetime_usec
    field :reason, :string
    field :admitted_at, :utc_datetime_usec
    field :inserted_at, :utc_datetime_usec
  end
end
