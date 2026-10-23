defmodule FootballMarket.Repo.Migrations.ReconcileLegacyQuoteAdmission do
  use Ecto.Migration

  def up do
    execute(
      "ALTER TABLE quote_calculation_requests DROP CONSTRAINT quote_calculation_request_origin"
    )

    execute("""
    ALTER TABLE quote_calculation_requests ADD CONSTRAINT quote_calculation_request_origin CHECK (
      (source = 'import' AND snapshot_id IS NOT NULL AND intent_id IS NOT NULL
        AND explicit_membership IS NULL AND explicit_fact_material IS NULL)
      OR (source = 'explicit' AND snapshot_id IS NULL AND intent_id IS NULL AND
        ((explicit_membership IS NULL AND explicit_fact_material IS NULL) OR
         (explicit_membership IS NOT NULL AND explicit_fact_material IS NOT NULL)))
      OR (source = 'import' AND snapshot_id IS NULL AND intent_id IS NOT NULL
        AND state = 'unreproducible' AND reason IS NOT DISTINCT FROM 'original_unavailable'
        AND configuration_version_id IS NULL AND mapping_id IS NULL AND calculation_id IS NULL
        AND explicit_membership IS NULL AND explicit_fact_material IS NULL)
    )
    """)

    execute("""
    CREATE UNIQUE INDEX quote_legacy_request_scope_unique
    ON quote_calculation_requests(intent_id, player_id, season_id, week_start)
    WHERE snapshot_id IS NULL AND source = 'import'
    """)

    execute("""
    CREATE FUNCTION quote_requested_mapping_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW.requested_mapping_id IS DISTINCT FROM OLD.requested_mapping_id THEN
        RAISE EXCEPTION 'quote requested mapping identity is immutable'
          USING ERRCODE='23514', CONSTRAINT='quote_requested_mapping_immutable';
      END IF;
      RETURN NEW;
    END $$
    """)

    execute("""
    CREATE TRIGGER quote_requested_mapping_immutable BEFORE UPDATE ON quote_calculation_requests
    FOR EACH ROW EXECUTE FUNCTION quote_requested_mapping_guard()
    """)
  end

  def down, do: raise("quote admission reconciliation is forward-only")
end
