defmodule FootballMarket.Repo.Migrations.AddQuoteImportSnapshots do
  use Ecto.Migration

  def change do
    create table(:quote_import_scope_snapshots, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :intent_id, references(:statistics_calculation_intents, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :player_id, references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :week_start, :utc_datetime_usec, null: false
      add :week_end, :utc_datetime_usec, null: false
      add :schema_version, :integer, null: false, default: 1
      add :membership, {:array, :uuid}, null: false
      add :fact_material, :map, null: false
      add :digest, :text, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:quote_import_scope_snapshots, [:intent_id, :player_id, :season_id, :week_start], name: :quote_import_scope_unique)
    create constraint(:quote_import_scope_snapshots, :quote_import_scope_week, check: "week_end > week_start AND cardinality(membership) > 0")
    create constraint(:quote_import_scope_snapshots, :quote_import_scope_digest, check: "btrim(digest) <> ''")
    execute("CREATE TRIGGER quote_import_scope_snapshots_immutable BEFORE UPDATE OR DELETE ON quote_import_scope_snapshots FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()")
    execute("CREATE TRIGGER quote_import_scope_snapshots_no_truncate BEFORE TRUNCATE ON quote_import_scope_snapshots FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()")

    create table(:quote_import_snapshot_facts, primary_key: false) do
      add :snapshot_id, references(:quote_import_scope_snapshots, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :performance_id, references(:player_match_performances, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :ordinal, :integer, null: false
      add :fact_material, :map, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
    create unique_index(:quote_import_snapshot_facts, [:snapshot_id, :performance_id], name: :quote_import_snapshot_fact_unique)
    create unique_index(:quote_import_snapshot_facts, [:snapshot_id, :ordinal], name: :quote_import_snapshot_ordinal_unique)
    create constraint(:quote_import_snapshot_facts, :quote_import_snapshot_ordinal, check: "ordinal > 0")
    execute("CREATE TRIGGER quote_import_snapshot_facts_immutable BEFORE UPDATE OR DELETE ON quote_import_snapshot_facts FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()")
    execute("CREATE TRIGGER quote_import_snapshot_facts_no_truncate BEFORE TRUNCATE ON quote_import_snapshot_facts FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()")

    create table(:quote_calculation_requests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :source, :text, null: false, default: "import"
      add :snapshot_id, references(:quote_import_scope_snapshots, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :intent_id, references(:statistics_calculation_intents, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :player_id, references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :week_start, :utc_datetime_usec, null: false
      add :week_end, :utc_datetime_usec, null: false
      add :selector, :text, null: false, default: "active"
      add :mapping_id, references(:quote_conversion_mappings, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :configuration_version_id, references(:valuation_configuration_versions, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :calculation_id, references(:quote_calculations, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :explicit_membership, {:array, :uuid}
      add :explicit_fact_material, :map
      add :state, :text, null: false, default: "pending"
      add :attempt_count, :integer, null: false, default: 0
      add :lease_fence, :bigint, null: false, default: 0
      add :lease_until, :utc_datetime_usec
      add :next_attempt_at, :utc_datetime_usec
      add :reason, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
    create unique_index(:quote_calculation_requests, [:snapshot_id], where: "snapshot_id IS NOT NULL", name: :quote_calculation_request_snapshot_unique)
    create index(:quote_calculation_requests, [:state, :inserted_at])
    create constraint(:quote_calculation_requests, :quote_calculation_request_selector, check: "selector = 'active' OR selector LIKE 'version:%'")
    create constraint(:quote_calculation_requests, :quote_calculation_request_state, check: "state IN ('pending','running','retrying','successful','no_quote','validation_failed','unsupported_strategy','unreproducible','exhausted')")
    create constraint(:quote_calculation_requests, :quote_calculation_request_attempts, check: "attempt_count BETWEEN 0 AND 3 AND lease_fence >= 0")
    create constraint(:quote_calculation_requests, :quote_calculation_request_origin,
             check: "(source = 'import' AND snapshot_id IS NOT NULL AND intent_id IS NOT NULL AND explicit_membership IS NULL AND explicit_fact_material IS NULL) OR (source = 'explicit' AND snapshot_id IS NULL AND intent_id IS NULL AND ((explicit_membership IS NULL AND explicit_fact_material IS NULL) OR (explicit_membership IS NOT NULL AND explicit_fact_material IS NOT NULL)))")

    execute("""
    CREATE FUNCTION quote_calculation_request_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW.source IS DISTINCT FROM OLD.source OR NEW.snapshot_id IS DISTINCT FROM OLD.snapshot_id
        OR NEW.intent_id IS DISTINCT FROM OLD.intent_id OR NEW.player_id IS DISTINCT FROM OLD.player_id
        OR NEW.season_id IS DISTINCT FROM OLD.season_id OR NEW.week_start IS DISTINCT FROM OLD.week_start
        OR NEW.week_end IS DISTINCT FROM OLD.week_end OR NEW.selector IS DISTINCT FROM OLD.selector
        OR NEW.inserted_at IS DISTINCT FROM OLD.inserted_at
        OR (OLD.explicit_membership IS NOT NULL AND NEW.explicit_membership IS DISTINCT FROM OLD.explicit_membership)
        OR (OLD.explicit_fact_material IS NOT NULL AND NEW.explicit_fact_material IS DISTINCT FROM OLD.explicit_fact_material)
        OR (OLD.mapping_id IS NOT NULL AND NEW.mapping_id IS DISTINCT FROM OLD.mapping_id)
        OR (OLD.configuration_version_id IS NOT NULL AND NEW.configuration_version_id IS DISTINCT FROM OLD.configuration_version_id) THEN
        RAISE EXCEPTION 'quote calculation request binding is write once' USING ERRCODE='23514', CONSTRAINT='quote_calculation_request_write_once';
      END IF;
      RETURN NEW;
    END $$
    """, "DROP FUNCTION quote_calculation_request_guard()")
    execute("CREATE TRIGGER quote_calculation_request_write_once BEFORE UPDATE ON quote_calculation_requests FOR EACH ROW EXECUTE FUNCTION quote_calculation_request_guard()")

    create table(:quote_calculation_attempts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :request_id, references(:quote_calculation_requests, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :attempt_number, :integer, null: false
      add :fence, :bigint, null: false
      add :started_at, :utc_datetime_usec, null: false
      add :finished_at, :utc_datetime_usec, null: false
      add :status, :text, null: false
      add :reason, :text
    end
    create unique_index(:quote_calculation_attempts, [:request_id, :attempt_number], name: :quote_calculation_attempt_unique)
    create constraint(:quote_calculation_attempts, :quote_calculation_attempt_state, check: "attempt_number BETWEEN 1 AND 3 AND status IN ('successful','no_quote','validation_failed','unsupported_strategy','unreproducible','retryable','interrupted','exhausted')")
    execute("CREATE TRIGGER quote_calculation_attempts_immutable BEFORE UPDATE OR DELETE ON quote_calculation_attempts FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()")
    execute("CREATE TRIGGER quote_calculation_attempts_no_truncate BEFORE TRUNCATE ON quote_calculation_attempts FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()")
  end
end
