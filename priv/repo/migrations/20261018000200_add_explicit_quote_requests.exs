defmodule FootballMarket.Repo.Migrations.AddExplicitQuoteRequests do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE quote_calculation_requests ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'import'")
    execute("ALTER TABLE quote_calculation_requests ADD COLUMN IF NOT EXISTS explicit_membership uuid[]")
    execute("ALTER TABLE quote_calculation_requests ADD COLUMN IF NOT EXISTS explicit_fact_material jsonb")
    execute("ALTER TABLE quote_calculation_requests ALTER COLUMN snapshot_id DROP NOT NULL")
    execute("ALTER TABLE quote_calculation_requests ALTER COLUMN intent_id DROP NOT NULL")
    execute("DROP INDEX IF EXISTS quote_calculation_request_snapshot_unique")
    execute("CREATE UNIQUE INDEX quote_calculation_request_snapshot_unique ON quote_calculation_requests(snapshot_id) WHERE snapshot_id IS NOT NULL")
    execute("ALTER TABLE quote_calculation_requests DROP CONSTRAINT IF EXISTS quote_calculation_request_origin")
    execute("""
    ALTER TABLE quote_calculation_requests ADD CONSTRAINT quote_calculation_request_origin CHECK (
      (source = 'import' AND snapshot_id IS NOT NULL AND intent_id IS NOT NULL AND explicit_membership IS NULL AND explicit_fact_material IS NULL)
      OR (source = 'explicit' AND snapshot_id IS NULL AND intent_id IS NULL AND
        ((explicit_membership IS NULL AND explicit_fact_material IS NULL) OR
         (explicit_membership IS NOT NULL AND explicit_fact_material IS NOT NULL)))
    )
    """)
    execute("""
    CREATE OR REPLACE FUNCTION quote_calculation_request_guard() RETURNS trigger LANGUAGE plpgsql AS $$
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
    """)
  end

  def down do
    execute("ALTER TABLE quote_calculation_requests DROP CONSTRAINT IF EXISTS quote_calculation_request_origin")
    execute("DROP INDEX IF EXISTS quote_calculation_request_snapshot_unique")
    execute("ALTER TABLE quote_calculation_requests ALTER COLUMN snapshot_id SET NOT NULL")
    execute("ALTER TABLE quote_calculation_requests ALTER COLUMN intent_id SET NOT NULL")
    execute("ALTER TABLE quote_calculation_requests DROP COLUMN IF EXISTS explicit_fact_material")
    execute("ALTER TABLE quote_calculation_requests DROP COLUMN IF EXISTS explicit_membership")
    execute("ALTER TABLE quote_calculation_requests DROP COLUMN IF EXISTS source")
    execute("CREATE UNIQUE INDEX quote_calculation_request_snapshot_unique ON quote_calculation_requests(snapshot_id)")
  end
end
