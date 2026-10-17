defmodule FootballMarket.Repo.Migrations.ExtendStatisticsPositionEvidence do
  use Ecto.Migration

  def up do
    alter table(:player_match_performances) do
      add :position_basis, :text, null: false, default: "legacy_direct"
      add :participation, :text
      add :position_reason, :text
      add :position_evidence, :map
    end

    execute("ALTER TABLE player_match_performances ALTER COLUMN position_id DROP NOT NULL")

    create constraint(:player_match_performances, :performances_position_evidence_state,
             check: """
             (position_basis = 'legacy_direct' AND position_id IS NOT NULL AND participation IS NULL AND position_reason IS NULL AND position_evidence IS NULL)
             OR (position_basis = 'direct_source' AND position_id IS NOT NULL AND (participation IS NULL OR participation IN ('starter', 'substitute_entered')) AND position_reason IS NULL AND position_evidence IS NOT NULL)
             OR (position_basis = 'derived_history' AND position_id IS NOT NULL AND participation = 'substitute_entered' AND position_reason IS NULL AND position_evidence IS NOT NULL)
             OR (position_basis = 'unknown_history' AND position_id IS NULL AND participation IS NOT NULL AND participation = 'substitute_entered' AND position_reason IS NOT NULL AND position_reason IN ('tie', 'insufficient_history') AND position_evidence IS NOT NULL)
             """
           )

    create table(:statistics_position_basis, primary_key: false) do
      add :performance_id,
          references(:player_match_performances,
            type: :uuid,
            on_delete: :restrict,
            on_update: :restrict
          ),
          null: false

      add :prior_performance_id,
          references(:player_match_performances,
            type: :uuid,
            on_delete: :restrict,
            on_update: :restrict
          ),
          null: false

      add :position_id,
          references(:positions, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      add :frequency, :integer, null: false
    end

    create unique_index(:statistics_position_basis, [:performance_id, :prior_performance_id],
             name: :statistics_position_basis_subject_prior_index
           )

    create constraint(:statistics_position_basis, :statistics_position_basis_positive,
             check: "frequency > 0"
           )

    execute("""
    CREATE FUNCTION statistics_position_basis_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      RAISE EXCEPTION 'immutable position evidence' USING ERRCODE = '23514', CONSTRAINT = 'statistics_position_basis_immutable';
    END $$
    """)

    execute("""
    CREATE TRIGGER statistics_position_basis_immutable
    BEFORE UPDATE OR DELETE ON statistics_position_basis
    FOR EACH ROW EXECUTE FUNCTION statistics_position_basis_immutable()
    """)

    execute("""
    CREATE FUNCTION statistics_position_basis_insert_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE subject player_match_performances%ROWTYPE;
    BEGIN
      SELECT * INTO subject FROM player_match_performances WHERE id = NEW.performance_id;
      IF NOT FOUND OR subject.position_basis NOT IN ('derived_history', 'unknown_history') OR
         EXISTS (SELECT 1 FROM statistics_fact_provenance WHERE performance_id = NEW.performance_id) THEN
        RAISE EXCEPTION 'position basis can only be added with its subject fact' USING ERRCODE = '23514', CONSTRAINT = 'statistics_position_basis_immutable';
      END IF;
      RETURN NEW;
    END $$
    """)

    execute("""
    CREATE TRIGGER statistics_position_basis_insert_guard
    BEFORE INSERT ON statistics_position_basis
    FOR EACH ROW EXECUTE FUNCTION statistics_position_basis_insert_guard()
    """)

    execute("""
    CREATE FUNCTION statistics_position_basis_validate() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE subject player_match_performances%ROWTYPE; computed jsonb; basis_count integer; max_count integer; max_positions integer;
    BEGIN
      IF NEW.position_basis IN ('derived_history', 'unknown_history') THEN
        SELECT * INTO subject FROM player_match_performances WHERE id = NEW.id;
        IF subject.participation IS DISTINCT FROM 'substitute_entered' OR
           subject.position_evidence->>'policy_version' IS DISTINCT FROM '1' OR
           jsonb_typeof(subject.position_evidence->'frequencies') IS DISTINCT FROM 'object' THEN
          RAISE EXCEPTION 'invalid participation evidence' USING ERRCODE = '23514', CONSTRAINT = 'performances_position_evidence_state';
        END IF;

        IF EXISTS (
          SELECT 1 FROM statistics_position_basis b
          JOIN player_match_performances prior ON prior.id = b.prior_performance_id
          JOIN matches pm ON pm.id = prior.match_id
          JOIN matches sm ON sm.id = subject.match_id
          WHERE b.performance_id = subject.id AND
            ((prior.player_id <> subject.player_id OR prior.season_id <> subject.season_id OR
              prior.position_id IS NULL OR prior.match_id = subject.match_id OR pm.kickoff_at >= sm.kickoff_at)
              OR b.position_id <> prior.position_id)
        ) THEN
          RAISE EXCEPTION 'invalid historical position basis' USING ERRCODE = '23514', CONSTRAINT = 'statistics_position_basis_subject_prior_index';
        END IF;

        SELECT count(*) INTO basis_count FROM statistics_position_basis WHERE performance_id = subject.id;
        SELECT jsonb_object_agg(position_id::text, n), max(n), count(*) FILTER (WHERE n = m)
          INTO computed, max_count, max_positions
          FROM (SELECT position_id, count(*)::integer n, max(count(*)) OVER () m
                FROM statistics_position_basis WHERE performance_id = subject.id GROUP BY position_id) counts;
        computed := COALESCE(computed, '{}'::jsonb);
        IF computed IS DISTINCT FROM subject.position_evidence->'frequencies' THEN
          RAISE EXCEPTION 'position frequency evidence mismatch' USING ERRCODE = '23514', CONSTRAINT = 'performances_position_evidence_state';
        END IF;
        IF EXISTS (
          SELECT 1 FROM statistics_position_basis b
          WHERE b.performance_id = subject.id AND b.frequency <> (
            SELECT count(*) FROM statistics_position_basis bx
            WHERE bx.performance_id = subject.id AND bx.position_id = b.position_id
          )
        ) THEN
          RAISE EXCEPTION 'position basis count mismatch' USING ERRCODE = '23514', CONSTRAINT = 'statistics_position_basis_positive';
        END IF;
        IF NEW.position_basis = 'derived_history' AND
           (basis_count = 0 OR max_positions <> 1 OR NOT EXISTS (
             SELECT 1 FROM statistics_position_basis b WHERE b.performance_id = subject.id AND b.position_id = subject.position_id
             GROUP BY b.position_id HAVING count(*) = max_count
           )) THEN
          RAISE EXCEPTION 'position is not unique historical mode' USING ERRCODE = '23514', CONSTRAINT = 'performances_position_evidence_state';
        END IF;
        IF NEW.position_basis = 'unknown_history' AND NOT (
          (basis_count = 0 AND subject.position_reason = 'insufficient_history') OR
          (basis_count > 0 AND max_positions > 1 AND subject.position_reason = 'tie')
        ) THEN
          RAISE EXCEPTION 'unknown position reason is inconsistent' USING ERRCODE = '23514', CONSTRAINT = 'performances_position_evidence_state';
        END IF;
      END IF;
      RETURN NULL;
    END $$
    """)

    execute("""
    CREATE CONSTRAINT TRIGGER statistics_position_basis_validate
    AFTER INSERT ON player_match_performances DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION statistics_position_basis_validate()
    """)
  end

  def down do
    execute(
      "DO $$ BEGIN IF EXISTS (SELECT 1 FROM player_match_performances WHERE position_id IS NULL) THEN RAISE EXCEPTION 'cannot downgrade with unknown position facts'; END IF; END $$"
    )

    execute("ALTER TABLE player_match_performances ALTER COLUMN position_id SET NOT NULL")
    execute("DROP TRIGGER statistics_position_basis_validate ON player_match_performances")
    execute("DROP FUNCTION statistics_position_basis_validate()")
    execute("DROP TRIGGER statistics_position_basis_insert_guard ON statistics_position_basis")
    execute("DROP FUNCTION statistics_position_basis_insert_guard()")
    drop table(:statistics_position_basis)
    execute("DROP FUNCTION statistics_position_basis_immutable()")

    alter table(:player_match_performances) do
      remove :position_evidence
      remove :position_reason
      remove :participation
      remove :position_basis
    end
  end
end
