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

defmodule FootballMarket.Statistics.Ingestion.MatchBinding do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_match_bindings" do
    field :provider, :string
    field :kind, :string, default: "match"
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :source_id, :string
    field :match_id, :binary_id
  end
end

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

defmodule FootballMarket.Statistics.Ingestion.FactObservation do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fact_observations" do
    field :provenance_id, :binary_id
    field :check_id, :binary_id
  end
end

defmodule FootballMarket.Valuation.CalculationRequest do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "valuation_calculation_requests" do
    field :intent_id, :binary_id
    field :accepted_check_id, :binary_id
    field :changed_performance_ids, {:array, :binary_id}
    field :accepted_at, :utc_datetime_usec
    field :state, :string, default: "requested"
  end
end

defmodule FootballMarket.Statistics.Ingestion.PositionBasis do
  use Ecto.Schema
  @primary_key false
  schema "statistics_position_basis" do
    field :performance_id, :binary_id, primary_key: true
    field :prior_performance_id, :binary_id, primary_key: true
    field :position_id, :binary_id
    field :frequency, :integer
  end
end
