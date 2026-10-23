defmodule FootballMarket.Quotes.Mapping do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_conversion_mappings" do
    field :name, :string
    field :version, :string
    field :schema_version, :integer, default: 1
    field :scale, :decimal
    field :rounding_rule, :string
    field :inserted_at, :utc_datetime_usec, read_after_writes: true
  end

  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [:id, :name, :version, :scale, :rounding_rule])
    |> validate_required([:id, :name, :version, :scale, :rounding_rule])
    |> validate_number(:scale, greater_than: 0)
    |> validate_change(:rounding_rule, fn :rounding_rule, value ->
      if value == "two-half-away-v1", do: [], else: [rounding_rule: "unsupported"]
    end)
    |> unique_constraint([:name, :version], name: :quote_mapping_version_unique)
  end
end

defmodule FootballMarket.Quotes.Evaluation do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_evaluation_requests" do
    field :quote_id, :binary_id
    field :calculation_id, :binary_id
    field :player_id, :binary_id
    field :idempotency_key, :string
    field :state, :string, default: "pending"
    field :delivery_attempts, :integer, default: 0
    field :lease_fence, :integer, default: 0
    field :lease_started_at, :utc_datetime_usec
    field :lease_until, :utc_datetime_usec
    field :acknowledged_at, :utc_datetime_usec
    field :consumer_receipt, :string
    field :inserted_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Quotes.CalculationRequest do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_calculation_requests" do
    field :source, :string, default: "import"
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
    field :inserted_at, :utc_datetime_usec
  end
end
