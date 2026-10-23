defmodule FootballMarket.Repo.Migrations.CreateQuoteCalculations do
  use Ecto.Migration

  def change do
    create table(:quote_conversion_mappings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text, null: false
      add :version, :text, null: false
      add :schema_version, :integer, null: false, default: 1
      add :scale, :decimal, null: false
      add :rounding_rule, :text, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("timezone('utc', now())")
    end

    create unique_index(:quote_conversion_mappings, [:name, :version], name: :quote_mapping_version_unique)
    create constraint(:quote_conversion_mappings, :quote_mapping_positive_scale, check: "scale > 0 AND scale < 'Infinity'::numeric")
    create constraint(:quote_conversion_mappings, :quote_mapping_rounding, check: "rounding_rule = 'two-half-away-v1'")

    create table(:quote_calculations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :player_id, references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :week_start, :utc_datetime_usec, null: false
      add :week_end, :utc_datetime_usec, null: false
      add :configuration_version_id, references(:valuation_configuration_versions, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :mapping_id, references(:quote_conversion_mappings, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :membership, {:array, :uuid}, null: false
      add :canonical_identity, :jsonb, null: false
      add :status, :text, null: false
      add :reason, :text
      add :score, :decimal
      add :unit_price, :decimal
      add :effective_at, :utc_datetime_usec
      add :evidence, :map, null: false
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("timezone('utc', now())")
    end

    create unique_index(:quote_calculations, [:canonical_identity], name: :quote_calculation_identity_unique)
    create constraint(:quote_calculations, :quote_calculation_week, check: "week_end > week_start")
    create constraint(:quote_calculations, :quote_calculation_status, check: "status IN ('successful','no_quote','validation_failed','unsupported_strategy','unreproducible','exhausted')")
    create constraint(:quote_calculations, :quote_calculation_success_shape, check: "(status = 'successful' AND unit_price > 0 AND effective_at IS NOT NULL) OR (status <> 'successful' AND unit_price IS NULL)")

    alter table(:market_quotes) do
      add :calculation_id, references(:quote_calculations, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :configuration_version_id, references(:valuation_configuration_versions, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :mapping_id, references(:quote_conversion_mappings, type: :uuid, on_delete: :restrict, on_update: :restrict)
      add :performance_sequence, :bigint
    end

    create unique_index(:market_quotes, [:calculation_id], where: "calculation_id IS NOT NULL", name: :market_quote_calculation_unique)
    create unique_index(:market_quotes, [:player_id, :performance_sequence], where: "performance_sequence IS NOT NULL", name: :market_quote_performance_sequence_unique)
    create constraint(:market_quotes, :market_quote_performance_shape,
             check: "(rule_id = 'initial_issuance' AND calculation_id IS NULL AND configuration_version_id IS NULL AND mapping_id IS NULL AND performance_sequence IS NULL) OR (rule_id <> 'initial_issuance' AND calculation_id IS NOT NULL AND configuration_version_id IS NOT NULL AND mapping_id IS NOT NULL AND performance_sequence > 0)")

    create table(:quote_evaluation_requests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :quote_id, references(:market_quotes, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :calculation_id, references(:quote_calculations, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :player_id, references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :idempotency_key, :text, null: false
      add :state, :text, null: false, default: "pending"
      add :delivery_attempts, :integer, null: false, default: 0
      add :lease_fence, :bigint, null: false, default: 0
      add :lease_started_at, :utc_datetime_usec
      add :lease_until, :utc_datetime_usec
      add :acknowledged_at, :utc_datetime_usec
      add :consumer_receipt, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("timezone('utc', now())")
    end

    create unique_index(:quote_evaluation_requests, [:quote_id], name: :quote_evaluation_quote_unique)
    create unique_index(:quote_evaluation_requests, [:idempotency_key], name: :quote_evaluation_key_unique)
    create constraint(:quote_evaluation_requests, :quote_evaluation_pending, check: "state IN ('pending','leased','acknowledged')")
    create constraint(:quote_evaluation_requests, :quote_evaluation_state_shape,
             check: "(state = 'pending' AND lease_started_at IS NULL AND lease_until IS NULL AND acknowledged_at IS NULL AND consumer_receipt IS NULL) OR (state = 'leased' AND lease_started_at IS NOT NULL AND lease_until IS NOT NULL AND acknowledged_at IS NULL AND consumer_receipt IS NULL) OR (state = 'acknowledged' AND lease_started_at IS NULL AND lease_until IS NULL AND acknowledged_at IS NOT NULL AND btrim(consumer_receipt) <> '')")

    create table(:quote_evaluation_delivery_attempts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :event_id, references(:quote_evaluation_requests, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false
      add :attempt_number, :integer, null: false
      add :fence, :bigint, null: false
      add :claimed_at, :utc_datetime_usec, null: false
      add :finished_at, :utc_datetime_usec, null: false
      add :status, :text, null: false
      add :reason, :text
      add :consumer_receipt, :text
    end
    create unique_index(:quote_evaluation_delivery_attempts, [:event_id, :attempt_number], name: :quote_evaluation_delivery_attempt_unique)
    create constraint(:quote_evaluation_delivery_attempts, :quote_evaluation_delivery_attempt_status, check: "attempt_number > 0 AND status IN ('acknowledged','expired','failed')")

    execute("""
    CREATE FUNCTION quote_calculation_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN RAISE EXCEPTION 'immutable quote calculation' USING ERRCODE='23514', CONSTRAINT='quote_calculation_immutable'; END $$
    """, "DROP FUNCTION quote_calculation_immutable()")

    for table <- ~w(quote_conversion_mappings quote_calculations quote_evaluation_delivery_attempts) do
      execute("CREATE TRIGGER #{table}_immutable BEFORE UPDATE OR DELETE ON #{table} FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()")
      execute("CREATE TRIGGER #{table}_no_truncate BEFORE TRUNCATE ON #{table} FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()")
    end

    execute("""
    CREATE FUNCTION quote_performance_link_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE q market_quotes%ROWTYPE; c quote_calculations%ROWTYPE; e_count integer;
    BEGIN
      IF TG_TABLE_NAME = 'market_quotes' THEN
        SELECT * INTO q FROM market_quotes WHERE id = NEW.id;
        IF q.calculation_id IS NULL THEN RETURN NULL; END IF;
        SELECT * INTO c FROM quote_calculations WHERE id = q.calculation_id;
        IF NOT FOUND OR c.status <> 'successful' OR c.player_id <> q.player_id
          OR c.configuration_version_id <> q.configuration_version_id OR c.mapping_id <> q.mapping_id
          OR c.unit_price <> q.unit_price OR c.effective_at <> q.effective_at THEN
          RAISE EXCEPTION 'performance quote does not match successful calculation' USING ERRCODE='23514', CONSTRAINT='quote_calculation_link_mismatch';
        END IF;
        SELECT count(*) INTO e_count FROM quote_evaluation_requests WHERE quote_id=q.id AND calculation_id=c.id AND player_id=q.player_id;
        IF e_count <> 1 THEN
          RAISE EXCEPTION 'performance quote requires exactly one matching evaluation request' USING ERRCODE='23514', CONSTRAINT='quote_evaluation_required';
        END IF;
      ELSE
        SELECT * INTO q FROM market_quotes WHERE id = NEW.quote_id;
        SELECT * INTO c FROM quote_calculations WHERE id = NEW.calculation_id;
        IF q.calculation_id IS DISTINCT FROM c.id OR c.status <> 'successful'
          OR NEW.player_id <> q.player_id OR q.player_id <> c.player_id THEN
          RAISE EXCEPTION 'evaluation request does not match confirmed quote' USING ERRCODE='23514', CONSTRAINT='quote_evaluation_link_mismatch';
        END IF;
      END IF;
      RETURN NULL;
    END $$
    """, "DROP FUNCTION quote_performance_link_guard()")

    execute("CREATE CONSTRAINT TRIGGER market_quote_evaluation_required AFTER INSERT ON market_quotes DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION quote_performance_link_guard()")
    execute("CREATE CONSTRAINT TRIGGER quote_evaluation_linked_quote AFTER INSERT ON quote_evaluation_requests DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION quote_performance_link_guard()")

    execute("""
    CREATE FUNCTION quote_evaluation_core_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW.id <> OLD.id OR NEW.quote_id <> OLD.quote_id OR NEW.calculation_id <> OLD.calculation_id
        OR NEW.player_id <> OLD.player_id OR NEW.idempotency_key <> OLD.idempotency_key
        OR NEW.inserted_at <> OLD.inserted_at THEN
        RAISE EXCEPTION 'quote evaluation request identity is immutable' USING ERRCODE='23514', CONSTRAINT='quote_evaluation_write_once';
      END IF;
      RETURN NEW;
    END $$
    """, "DROP FUNCTION quote_evaluation_core_guard()")
    execute("CREATE TRIGGER quote_evaluation_core_write_once BEFORE UPDATE ON quote_evaluation_requests FOR EACH ROW EXECUTE FUNCTION quote_evaluation_core_guard()")
  end
end
