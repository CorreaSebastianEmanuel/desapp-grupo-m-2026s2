defmodule FootballMarket.Statistics.Ingestion.Check do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_import_checks" do
    field :scope_id, :binary_id
    field :run_id, :binary_id
    field :attempt_id, :binary_id
    field :accepted_at, :utc_datetime_usec
    field :retrieved_at, :utc_datetime_usec
    field :evidence_version, :integer
    field :evidence, :map
    field :outcome, :string
    field :canonical_digest, :string
    field :canonical_material, :map
    field :changed_matches, :integer, default: 0
    field :changed_performances, :integer, default: 0
    field :replay_of_id, :binary_id
  end
end
