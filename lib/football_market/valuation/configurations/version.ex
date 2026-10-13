defmodule FootballMarket.Valuation.Configurations.Version do
  @moduledoc "Immutable stored version with complete decoded virtual rules."
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "valuation_configuration_versions" do
    field :strategy_id, :string
    field :formula_version, :string
    field :rules, :map
    field :created_at, :utc_datetime_usec, read_after_writes: true
    field :config, :map, virtual: true
    field :references, :map, virtual: true
    field :requirements, :map, virtual: true
    field :position_mapping, {:array, :any}, virtual: true
  end
end
