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
