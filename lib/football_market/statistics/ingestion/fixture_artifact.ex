defmodule FootballMarket.Statistics.Ingestion.FixtureArtifact do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fixture_artifacts" do
    field :fixture_id, :string
    field :artifact_path, :string
    field :sha256, :string
    field :origin, :string
    field :captured_at, :utc_datetime_usec
    field :synthetic_created_at, :utc_datetime_usec
    field :expected_case, :string
    field :rule_ids, {:array, :string}
    field :non_live, :boolean, default: true
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end
end
