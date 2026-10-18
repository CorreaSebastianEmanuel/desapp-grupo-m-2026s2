defmodule FootballMarket.Repo.Migrations.ReconcileQuoteImportSnapshotFacts do
  use Ecto.Migration

  def change do
    execute("""
    CREATE TABLE IF NOT EXISTS quote_import_snapshot_facts (
      snapshot_id uuid NOT NULL REFERENCES quote_import_scope_snapshots(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      performance_id uuid NOT NULL REFERENCES player_match_performances(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
      ordinal integer NOT NULL CHECK (ordinal > 0),
      fact_material jsonb NOT NULL,
      inserted_at timestamp(6) without time zone NOT NULL DEFAULT now()
    )
    """, "SELECT 1")

    execute(
      "CREATE UNIQUE INDEX IF NOT EXISTS quote_import_snapshot_fact_unique ON quote_import_snapshot_facts (snapshot_id, performance_id)",
      "SELECT 1"
    )

    execute(
      "CREATE UNIQUE INDEX IF NOT EXISTS quote_import_snapshot_ordinal_unique ON quote_import_snapshot_facts (snapshot_id, ordinal)",
      "SELECT 1"
    )

    execute("""
    DO $$ BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgrelid = 'quote_import_snapshot_facts'::regclass
          AND tgname = 'quote_import_snapshot_facts_immutable'
          AND NOT tgisinternal
      ) THEN
        EXECUTE 'CREATE TRIGGER quote_import_snapshot_facts_immutable
          BEFORE UPDATE OR DELETE ON quote_import_snapshot_facts
          FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()';
      END IF;
      IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgrelid = 'quote_import_snapshot_facts'::regclass
          AND tgname = 'quote_import_snapshot_facts_no_truncate'
          AND NOT tgisinternal
      ) THEN
        EXECUTE 'CREATE TRIGGER quote_import_snapshot_facts_no_truncate
          BEFORE TRUNCATE ON quote_import_snapshot_facts
          FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()';
      END IF;
    END $$;
    """, "SELECT 1")
  end
end
