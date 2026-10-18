defmodule FootballMarket.Repo.Migrations.CreateStatisticsIngestion do
  use Ecto.Migration

  def change do
    create table(:statistics_import_scopes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :provider, :text, null: false
      add :identity_namespace, :text, null: false
      add :league_code, :text, null: false
      add :start_year, :integer, null: false
      add :end_year, :integer, null: false
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict), null: false
      add :last_checked_at, :utc_datetime_usec
      add :last_accepted_check_id, :uuid
    end

    create unique_index(:statistics_import_scopes, [:identity_namespace, :season_id],
             name: :statistics_import_scope_identity_index
           )

    create table(:statistics_fixture_artifacts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :fixture_id, :text, null: false
      add :artifact_path, :text, null: false
      add :sha256, :text, null: false
      add :origin, :text, null: false
      add :captured_at, :utc_datetime_usec
      add :synthetic_created_at, :utc_datetime_usec
      add :expected_case, :text, null: false
      add :rule_ids, {:array, :text}, null: false
      add :non_live, :boolean, null: false, default: true
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:statistics_fixture_artifacts, [:fixture_id, :sha256],
             name: :statistics_fixture_digest_index
           )

    create constraint(:statistics_fixture_artifacts, :statistics_fixture_non_live,
             check: "non_live = true AND sha256 ~ '^[0-9a-f]{64}$'"
           )

    create table(:statistics_import_checks, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :scope_id, references(:statistics_import_scopes, type: :uuid, on_delete: :restrict),
        null: false

      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict),
        null: false

      add :attempt_id, references(:synchronization_attempts, type: :uuid, on_delete: :restrict),
        null: false

      add :accepted_at, :utc_datetime_usec, null: false
      add :retrieved_at, :utc_datetime_usec, null: false
      add :evidence_version, :integer, null: false
      add :evidence, :map, null: false
      add :outcome, :text, null: false
      add :canonical_digest, :text, null: false
      add :canonical_material, :map, null: false
      add :changed_matches, :integer, null: false, default: 0
      add :changed_performances, :integer, null: false, default: 0
      add :replay_of_id, references(:statistics_import_checks, type: :uuid, on_delete: :restrict)
    end

    create constraint(:statistics_import_checks, :statistics_import_check_outcome,
             check:
               "outcome IN ('accepted_changes', 'accepted_unchanged', 'replay', 'accepted_empty') AND evidence_version > 0 AND changed_matches >= 0 AND changed_performances >= 0"
           )

    create table(:statistics_match_bindings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :provider, :text, null: false
      add :kind, :text, null: false, default: "match"
      add :league_code, :text, null: false
      add :start_year, :integer, null: false
      add :end_year, :integer, null: false
      add :source_id, :text, null: false

      add :match_id,
          references(:matches, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false
    end

    create unique_index(
             :statistics_match_bindings,
             [:provider, :kind, :league_code, :start_year, :end_year, :source_id],
             name: :statistics_match_binding_source_index
           )

    create unique_index(:statistics_match_bindings, [:match_id, :provider],
             name: :statistics_match_binding_target_index
           )

    create table(:statistics_fact_provenance, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :match_id, references(:matches, type: :uuid, on_delete: :restrict, on_update: :restrict)

      add :performance_id,
          references(:player_match_performances,
            type: :uuid,
            on_delete: :restrict,
            on_update: :restrict
          )

      add :accepted_check_id,
          references(:statistics_import_checks, type: :uuid, on_delete: :restrict), null: false

      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict),
        null: false

      add :provider, :text, null: false
      add :retrieved_at, :utc_datetime_usec, null: false
      add :source_identity, :map, null: false
      add :source_material, :map, null: false

      add :fixture_artifact_id,
          references(:statistics_fixture_artifacts, type: :uuid, on_delete: :restrict)
    end

    create unique_index(:statistics_fact_provenance, [:match_id],
             where: "match_id IS NOT NULL",
             name: :statistics_fact_provenance_match_index
           )

    create unique_index(:statistics_fact_provenance, [:performance_id],
             where: "performance_id IS NOT NULL",
             name: :statistics_fact_provenance_performance_index
           )

    create constraint(:statistics_fact_provenance, :statistics_fact_provenance_exactly_one_fact,
             check: "(match_id IS NULL) <> (performance_id IS NULL)"
           )

    create table(:statistics_fact_observations, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :provenance_id,
          references(:statistics_fact_provenance, type: :uuid, on_delete: :restrict), null: false

      add :check_id, references(:statistics_import_checks, type: :uuid, on_delete: :restrict),
        null: false
    end

    create unique_index(:statistics_fact_observations, [:provenance_id, :check_id])

    create table(:statistics_calculation_intents, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :accepted_check_id,
          references(:statistics_import_checks, type: :uuid, on_delete: :restrict), null: false

      add :changed_performance_ids, {:array, :uuid}, null: false
      add :requested_at, :utc_datetime_usec, null: false
      add :state, :text, null: false, default: "pending"
      add :attempts, :integer, null: false, default: 0
      add :next_attempt_at, :utc_datetime_usec
      add :delivered_at, :utc_datetime_usec
    end

    create unique_index(:statistics_calculation_intents, [:accepted_check_id])

    create constraint(:statistics_calculation_intents, :statistics_calculation_intent_state,
             check:
               "state IN ('pending', 'delivered', 'failed') AND attempts >= 0 AND cardinality(changed_performance_ids) > 0"
           )

    create table(:valuation_calculation_requests, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :intent_id,
          references(:statistics_calculation_intents, type: :uuid, on_delete: :restrict),
          null: false

      add :accepted_check_id,
          references(:statistics_import_checks, type: :uuid, on_delete: :restrict), null: false

      add :changed_performance_ids, {:array, :uuid}, null: false
      add :accepted_at, :utc_datetime_usec, null: false
      add :state, :text, null: false, default: "requested"
    end

    create unique_index(:valuation_calculation_requests, [:intent_id])

    create constraint(:valuation_calculation_requests, :valuation_calculation_request_state,
             check: "state = 'requested' AND cardinality(changed_performance_ids) > 0"
           )

    execute(
      "ALTER TABLE statistics_import_scopes ADD CONSTRAINT statistics_import_scope_last_check_fkey FOREIGN KEY (last_accepted_check_id) REFERENCES statistics_import_checks(id) ON UPDATE RESTRICT ON DELETE RESTRICT"
    )

    for table <- [
          :statistics_fixture_artifacts,
          :statistics_import_checks,
          :statistics_match_bindings,
          :statistics_fact_provenance,
          :statistics_fact_observations,
          :valuation_calculation_requests
        ] do
      function = "#{table}_append_only"
      trigger = "#{table}_append_only"

      execute(
        "CREATE FUNCTION #{function}() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'append-only statistics evidence' USING ERRCODE = '23514', CONSTRAINT = '#{trigger}'; END $$",
        "DROP FUNCTION #{function}()"
      )

      execute(
        "CREATE TRIGGER #{trigger} BEFORE UPDATE OR DELETE ON #{table} FOR EACH ROW EXECUTE FUNCTION #{function}()",
        "DROP TRIGGER #{trigger} ON #{table}"
      )
    end

    execute(
      """
      CREATE FUNCTION statistics_calculation_intent_identity_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN
        IF NEW.id <> OLD.id OR NEW.accepted_check_id <> OLD.accepted_check_id OR NEW.changed_performance_ids <> OLD.changed_performance_ids OR NEW.requested_at <> OLD.requested_at THEN
          RAISE EXCEPTION 'immutable calculation intent' USING ERRCODE = '23514', CONSTRAINT = 'statistics_calculation_intent_immutable';
        END IF;
        RETURN NEW;
      END $$
      """,
      "DROP FUNCTION statistics_calculation_intent_identity_immutable()"
    )

    execute(
      "CREATE TRIGGER statistics_calculation_intent_identity_immutable BEFORE UPDATE ON statistics_calculation_intents FOR EACH ROW EXECUTE FUNCTION statistics_calculation_intent_identity_immutable()",
      "DROP TRIGGER statistics_calculation_intent_identity_immutable ON statistics_calculation_intents"
    )
  end
end
