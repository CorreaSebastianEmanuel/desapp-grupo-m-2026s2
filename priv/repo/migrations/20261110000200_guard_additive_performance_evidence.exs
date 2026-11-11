defmodule FootballMarket.Repo.Migrations.GuardAdditivePerformanceEvidence do
  use Ecto.Migration

  def up do
    execute """
    CREATE FUNCTION guard_performance_enrichment() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE original jsonb; previous jsonb; last_revision integer; key text; added boolean := false;
      fields text[] := ARRAY['minutes_played','goals','assists','shots_on_target','tackles',
        'interceptions','saves','goals_conceded','yellow_cards','red_cards'];
    BEGIN
      SELECT to_jsonb(p) INTO original FROM player_match_performances p
        WHERE p.id = NEW.performance_id FOR UPDATE;
      SELECT e.values, e.revision INTO previous, last_revision FROM performance_enrichments e
        WHERE e.performance_id = NEW.performance_id ORDER BY e.revision DESC LIMIT 1;
      previous := COALESCE(previous, original);
      IF NEW.revision != COALESCE(last_revision, 0) + 1 OR jsonb_typeof(NEW.values) != 'object'
        OR (SELECT count(*) FROM jsonb_object_keys(NEW.values)) != cardinality(fields) THEN
        RAISE EXCEPTION 'invalid enrichment revision or shape' USING ERRCODE = '23514';
      END IF;
      FOREACH key IN ARRAY fields LOOP
        IF NOT (NEW.values ? key) OR
          (NEW.values->key != 'null'::jsonb AND
            (jsonb_typeof(NEW.values->key) != 'number' OR NEW.values->>key !~ '^[0-9]+$')) OR
          (previous->key != 'null'::jsonb AND previous->key IS DISTINCT FROM NEW.values->key) THEN
          RAISE EXCEPTION 'known statistics are immutable' USING ERRCODE = '23514';
        END IF;
        IF previous->key = 'null'::jsonb AND NEW.values->key != 'null'::jsonb THEN added := true; END IF;
      END LOOP;
      IF NOT added THEN RAISE EXCEPTION 'enrichment must add a known metric' USING ERRCODE = '23514'; END IF;
      RETURN NEW;
    END $$
    """

    execute """
    CREATE TRIGGER performance_enrichment_additive BEFORE INSERT ON performance_enrichments
    FOR EACH ROW EXECUTE FUNCTION guard_performance_enrichment()
    """
  end

  def down do
    execute "DROP TRIGGER performance_enrichment_additive ON performance_enrichments"
    execute "DROP FUNCTION guard_performance_enrichment()"
  end
end
