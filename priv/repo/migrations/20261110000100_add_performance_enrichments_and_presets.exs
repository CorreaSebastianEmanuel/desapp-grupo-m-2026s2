defmodule FootballMarket.Repo.Migrations.AddPerformanceEnrichmentsAndPresets do
  use Ecto.Migration

  def change do
    create table(:performance_enrichments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :performance_id, references(:player_match_performances, type: :binary_id), null: false
      add :check_id, references(:statistics_import_checks, type: :binary_id), null: false
      add :values, :map, null: false
      add :revision, :integer, null: false
    end

    create unique_index(:performance_enrichments, [:performance_id, :revision])
    create constraint(:performance_enrichments, :positive_revision, check: "revision > 0")

    create table(:valuation_presets, primary_key: false) do
      add :key, :text, primary_key: true

      add :version_id, references(:valuation_configuration_versions, type: :binary_id),
        null: false
    end

    for table <- ["performance_enrichments", "valuation_presets"] do
      execute """
              CREATE TRIGGER #{table}_immutable BEFORE UPDATE OR DELETE ON #{table}
              FOR EACH ROW EXECUTE FUNCTION statistics_immutable()
              """,
              "DROP TRIGGER #{table}_immutable ON #{table}"
    end
  end
end
