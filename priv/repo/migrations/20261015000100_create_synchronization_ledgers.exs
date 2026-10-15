defmodule FootballMarket.Repo.Migrations.CreateSynchronizationLedgers do
  use Ecto.Migration

  def change do
    create table(:synchronization_runs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :league_code, :text, null: false
      add :start_year, :integer, null: false
      add :end_year, :integer, null: false
      add :source_ref, :text, null: false
      add :fixture_ref, :text
      add :input, :map, null: false
      add :input_digest, :text, null: false
      add :policy, :map, null: false
      add :original_trigger, :text, null: false
      add :state, :text, null: false
      add :requested_at, :utc_datetime_usec, null: false
      add :started_at, :utc_datetime_usec
      add :finished_at, :utc_datetime_usec
      add :next_retry_at, :utc_datetime_usec
      add :outcome, :map
      add :reason, :text
      add :recovery, :text
      add :delivery_id, :uuid
      add :job_id, :bigint
    end

    create unique_index(:synchronization_runs, [:league_code, :start_year, :end_year],
             where: "state IN ('queued', 'executing', 'retry_wait')",
             name: :synchronization_active_scope
           )

    create constraint(:synchronization_runs, :synchronization_run_state,
             check: "state IN ('queued', 'executing', 'retry_wait', 'succeeded', 'failed')"
           )

    create constraint(:synchronization_runs, :synchronization_run_policy,
             check: "(policy->>'attempt_limit')::integer > 0"
           )

    create table(:synchronization_attempts, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict),
        null: false

      add :number, :integer, null: false
      add :delivery_id, :uuid, null: false
      add :started_at, :utc_datetime_usec, null: false
      add :finished_at, :utc_datetime_usec
      add :status, :text, null: false
      add :outcome, :map
      add :next_retry_at, :utc_datetime_usec
    end

    create unique_index(:synchronization_attempts, [:run_id, :number])
    create unique_index(:synchronization_attempts, [:delivery_id])

    create constraint(:synchronization_attempts, :synchronization_attempt_positive,
             check: "number > 0"
           )

    create table(:synchronization_schedules, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :config_key, :text, null: false
      add :generation, :uuid, null: false
      add :enabled, :boolean, null: false, default: false
      add :enabled_at, :utc_datetime_usec
      add :disabled_at, :utc_datetime_usec
      add :recurrence, :text, null: false
      add :definition, :map, null: false
    end

    create unique_index(:synchronization_schedules, [:config_key])

    create table(:synchronization_occurrences, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :schedule_id, references(:synchronization_schedules, type: :uuid, on_delete: :restrict),
        null: false

      add :generation, :uuid, null: false
      add :due_at, :utc_datetime_usec, null: false
      add :state, :text, null: false
      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict)
      add :superseded_from, :utc_datetime_usec
      add :superseded_until, :utc_datetime_usec
    end

    create unique_index(:synchronization_occurrences, [:schedule_id, :generation, :due_at])

    create unique_index(:synchronization_occurrences, [:schedule_id, :generation],
             where: "state = 'pending'",
             name: :synchronization_latest_pending
           )

    create constraint(:synchronization_occurrences, :synchronization_occurrence_state,
             check: "state IN ('pending', 'handled', 'superseded')"
           )

    create table(:synchronization_triggers, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict),
        null: false

      add :kind, :text, null: false
      add :requested_at, :utc_datetime_usec, null: false

      add :occurrence_id,
          references(:synchronization_occurrences, type: :uuid, on_delete: :restrict)
    end

    create unique_index(:synchronization_triggers, [:occurrence_id])

    create constraint(:synchronization_triggers, :synchronization_trigger_kind,
             check: "kind IN ('initial', 'manual', 'scheduled')"
           )
  end
end
