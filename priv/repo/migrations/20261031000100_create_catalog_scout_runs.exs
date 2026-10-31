defmodule FootballMarket.Repo.Migrations.CreateCatalogScoutRuns do
  use Ecto.Migration

  def change do
    create table(:catalog_scout_runs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :normalized_name, :text, null: false
      add :display_name, :text, null: false
      add :state, :text, null: false
      add :config_digest, :text, null: false
      add :admitted_at, :utc_datetime_usec, null: false
      add :finished_at, :utc_datetime_usec
      add :next_attempt_at, :utc_datetime_usec
      add :scope_inputs, :map, null: false, default: %{}
      add :synchronization_run_ids, {:array, :binary_id}, null: false, default: []
      add :configured_scope_count, :integer, null: false
      add :request_count, :integer, null: false, default: 0
      add :error_category, :text
      add :job_id, :bigint

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:catalog_scout_runs, [:normalized_name])
    create index(:catalog_scout_runs, [:admitted_at])

    create constraint(:catalog_scout_runs, :catalog_scout_run_state,
             check: "state IN ('queued', 'scouting', 'found', 'not_found', 'provider_failure')"
           )

    create constraint(:catalog_scout_runs, :catalog_scout_scope_count,
             check: "configured_scope_count BETWEEN 1 AND 5"
           )

    create constraint(:catalog_scout_runs, :catalog_scout_request_count,
             check: "request_count BETWEEN 0 AND 5"
           )
  end
end
