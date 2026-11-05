defmodule FootballMarket.Statistics.Ingestion.FactProvenance do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fact_provenance" do
    field :match_id, :binary_id
    field :performance_id, :binary_id
    field :accepted_check_id, :binary_id
    field :run_id, :binary_id
    field :provider, :string
    field :retrieved_at, :utc_datetime_usec
    field :source_identity, :map
    field :source_material, :map
    field :fixture_artifact_id, :binary_id
  end
end
