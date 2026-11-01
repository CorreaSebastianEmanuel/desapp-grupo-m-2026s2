defmodule FootballMarket.Repo.Migrations.AddNightlyQuoteAdmission do
  use Ecto.Migration

  def up do
    alter table(:quote_calculation_requests) do
      add :admitted_at, :utc_datetime_usec
      add :admission_key, :text
    end

    # Existing requests already had calculation jobs dispatched. Preserve their
    # eligibility across the transition; only newly accepted imports are deferred.
    execute("UPDATE quote_calculation_requests SET admitted_at = inserted_at")

    create index(:quote_calculation_requests, [:season_id, :state, :admitted_at])
    create unique_index(:quote_calculation_requests, [:admission_key], where: "admission_key IS NOT NULL")

    execute("ALTER TABLE quote_calculation_requests DROP CONSTRAINT quote_calculation_request_origin")

    execute("""
    ALTER TABLE quote_calculation_requests ADD CONSTRAINT quote_calculation_request_origin CHECK (
      (source = 'import' AND snapshot_id IS NOT NULL AND intent_id IS NOT NULL
        AND explicit_membership IS NULL AND explicit_fact_material IS NULL AND admission_key IS NULL)
      OR (source = 'explicit' AND snapshot_id IS NULL AND intent_id IS NULL
        AND admission_key IS NULL AND
        ((explicit_membership IS NULL AND explicit_fact_material IS NULL) OR
         (explicit_membership IS NOT NULL AND explicit_fact_material IS NOT NULL)))
      OR (source = 'ttl' AND snapshot_id IS NULL AND intent_id IS NULL
        AND explicit_membership IS NOT NULL AND explicit_fact_material IS NOT NULL
        AND admission_key IS NOT NULL)
      OR (source = 'import' AND snapshot_id IS NULL AND intent_id IS NOT NULL
        AND state = 'unreproducible' AND reason IS NOT DISTINCT FROM 'original_unavailable'
        AND configuration_version_id IS NULL AND mapping_id IS NULL AND calculation_id IS NULL
        AND explicit_membership IS NULL AND explicit_fact_material IS NULL AND admission_key IS NULL)
    )
    """)

    execute("""
    CREATE OR REPLACE FUNCTION quote_calculation_request_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW.source IS DISTINCT FROM OLD.source OR NEW.admission_key IS DISTINCT FROM OLD.admission_key
        OR NEW.snapshot_id IS DISTINCT FROM OLD.snapshot_id OR NEW.intent_id IS DISTINCT FROM OLD.intent_id
        OR NEW.player_id IS DISTINCT FROM OLD.player_id OR NEW.season_id IS DISTINCT FROM OLD.season_id
        OR NEW.week_start IS DISTINCT FROM OLD.week_start OR NEW.week_end IS DISTINCT FROM OLD.week_end
        OR NEW.selector IS DISTINCT FROM OLD.selector OR NEW.inserted_at IS DISTINCT FROM OLD.inserted_at
        OR (OLD.admitted_at IS NOT NULL AND NEW.admitted_at IS DISTINCT FROM OLD.admitted_at)
        OR (OLD.explicit_membership IS NOT NULL AND NEW.explicit_membership IS DISTINCT FROM OLD.explicit_membership)
        OR (OLD.explicit_fact_material IS NOT NULL AND NEW.explicit_fact_material IS DISTINCT FROM OLD.explicit_fact_material)
        OR (OLD.mapping_id IS NOT NULL AND NEW.mapping_id IS DISTINCT FROM OLD.mapping_id)
        OR (OLD.configuration_version_id IS NOT NULL AND NEW.configuration_version_id IS DISTINCT FROM OLD.configuration_version_id) THEN
        RAISE EXCEPTION 'quote calculation request binding is write once'
          USING ERRCODE='23514', CONSTRAINT='quote_calculation_request_write_once';
      END IF;
      RETURN NEW;
    END $$
    """)
  end

  def down, do: raise("nightly quote admission is forward-only")
end
