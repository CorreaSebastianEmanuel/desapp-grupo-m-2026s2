defmodule FootballMarket.Repo.Migrations.CreateInitialPlayerIssuance do
  use Ecto.Migration

  def up do
    schema = prefix() || "public"
    s = "\"#{schema}\""

    create table(:market_initialization_locks, primary_key: false) do
      add :id, :integer, primary_key: true
    end

    execute("INSERT INTO #{s}.market_initialization_locks(id) VALUES(1)")

    create table(:market_initial_recipients, primary_key: false) do
      add :id, :integer, primary_key: true

      add :user_id, references(:users, type: :uuid, on_delete: :restrict, on_update: :restrict),
        null: false

      add :fixed_at, :utc_datetime_usec, null: false
    end

    create table(:market_quotes, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :player_id,
          references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      add :unit_price, :decimal, null: false
      add :effective_at, :utc_datetime_usec, null: false
      add :inserted_at, :utc_datetime_usec, null: false
      add :rule_id, :text, null: false
      add :rule_version, :text, null: false
    end

    create table(:market_holdings, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :player_id,
          references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      add :user_id, references(:users, type: :uuid, on_delete: :restrict, on_update: :restrict),
        null: false

      add :quantity, :integer, null: false
    end

    create table(:market_issuances, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :player_id,
          references(:players, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      add :recipient_id,
          references(:users, type: :uuid, on_delete: :restrict, on_update: :restrict), null: false

      add :quantity, :integer, null: false
      add :initial_unit_price, :decimal, null: false

      add :initial_quote_id,
          references(:market_quotes, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      add :completed_at, :utc_datetime_usec, null: false
    end

    create constraint(:market_initialization_locks, :market_lock_singleton, check: "id = 1")
    create constraint(:market_initial_recipients, :market_recipient_singleton, check: "id = 1")

    create unique_index(:market_holdings, [:player_id, :user_id],
             name: :market_holding_owner_unique
           )

    create constraint(:market_holdings, :market_holding_nonnegative, check: "quantity >= 0")
    create unique_index(:market_issuances, [:player_id], name: :market_issuance_player_unique)

    create unique_index(:market_issuances, [:initial_quote_id],
             name: :market_issuance_quote_unique
           )

    create unique_index(:market_quotes, [:id, :player_id], name: :market_quote_player_unique)

    create unique_index(:market_quotes, [:player_id],
             where: "rule_id = 'initial_issuance'",
             name: :market_quote_initial_unique
           )

    create constraint(:market_quotes, :market_quote_canonical,
             check:
               "unit_price > 0 AND unit_price < 'Infinity'::numeric AND btrim(rule_id) <> '' AND btrim(rule_version) <> '' AND (rule_id <> 'initial_issuance' OR (unit_price = 1 AND rule_version = '1'))"
           )

    create constraint(:market_issuances, :market_issuance_canonical,
             check: "quantity = 100 AND initial_unit_price = 1"
           )

    execute(
      "ALTER TABLE #{s}.market_issuances ADD CONSTRAINT market_issuance_quote_player_fkey FOREIGN KEY(initial_quote_id, player_id) REFERENCES #{s}.market_quotes(id, player_id) ON DELETE RESTRICT ON UPDATE RESTRICT"
    )

    execute("""
    CREATE FUNCTION #{s}.market_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      RAISE EXCEPTION 'immutable market history' USING ERRCODE='23514', CONSTRAINT='market_history_immutable';
    END $$
    """)

    for table <-
          ~w(market_initialization_locks market_initial_recipients market_quotes market_issuances) do
      execute(
        "CREATE TRIGGER market_history_immutable BEFORE UPDATE OR DELETE ON #{s}.#{table} FOR EACH ROW EXECUTE FUNCTION #{s}.market_immutable()"
      )
    end

    for table <-
          ~w(market_initialization_locks market_initial_recipients market_quotes market_issuances market_holdings) do
      execute(
        "CREATE TRIGGER market_no_truncate BEFORE TRUNCATE ON #{s}.#{table} FOR EACH STATEMENT EXECUTE FUNCTION #{s}.market_immutable()"
      )
    end

    execute("""
    CREATE FUNCTION #{s}.market_lock_write() RETURNS trigger LANGUAGE plpgsql VOLATILE AS $$
    DECLARE player uuid;
    BEGIN
      IF current_setting('transaction_isolation') <> 'read committed' THEN
        RAISE EXCEPTION 'unsupported market isolation' USING ERRCODE='23514', CONSTRAINT='market_write_isolation';
      END IF;
      IF TG_TABLE_NAME IN ('market_initial_recipients', 'market_issuances') THEN
        PERFORM id FROM #{s}.market_initialization_locks WHERE id=1 FOR UPDATE;
        IF NOT FOUND THEN
          RAISE EXCEPTION 'missing market anchor' USING ERRCODE='23514', CONSTRAINT='market_recipient_consistent';
        END IF;
      END IF;
      IF TG_TABLE_NAME = 'market_initial_recipients' THEN RETURN NEW; END IF;
      IF TG_OP='DELETE' THEN player := OLD.player_id; ELSE player := NEW.player_id; END IF;
      IF TG_TABLE_NAME='market_holdings' AND TG_OP='UPDATE' THEN
        IF NEW.player_id IS DISTINCT FROM OLD.player_id OR NEW.user_id IS DISTINCT FROM OLD.user_id THEN
          RAISE EXCEPTION 'holding keys immutable' USING ERRCODE='23514', CONSTRAINT='market_holding_keys';
        END IF;
      END IF;
      PERFORM id FROM #{s}.players WHERE id=player FOR UPDATE;
      IF TG_OP='DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
    END $$
    """)

    for table <- ~w(market_quotes market_issuances market_initial_recipients) do
      execute(
        "CREATE TRIGGER market_lock_write BEFORE INSERT ON #{s}.#{table} FOR EACH ROW EXECUTE FUNCTION #{s}.market_lock_write()"
      )
    end

    execute(
      "CREATE TRIGGER market_lock_write BEFORE INSERT OR UPDATE OR DELETE ON #{s}.market_holdings FOR EACH ROW EXECUTE FUNCTION #{s}.market_lock_write()"
    )

    execute("""
    CREATE FUNCTION #{s}.market_validate_commit() RETURNS trigger LANGUAGE plpgsql VOLATILE AS $$
    DECLARE player uuid; issue #{s}.market_issuances%ROWTYPE; quote #{s}.market_quotes%ROWTYPE; recipient uuid; total bigint;
    BEGIN
      SELECT user_id INTO recipient FROM #{s}.market_initial_recipients WHERE id=1;
      IF EXISTS(SELECT 1 FROM #{s}.market_issuances WHERE recipient_id IS DISTINCT FROM recipient) THEN
        RAISE EXCEPTION 'market recipient mismatch' USING ERRCODE='23514', CONSTRAINT='market_recipient_consistent';
      END IF;
      IF TG_TABLE_NAME='market_initial_recipients' THEN
        IF NOT EXISTS(SELECT 1 FROM #{s}.market_issuances) THEN
          RAISE EXCEPTION 'recipient without issuance' USING ERRCODE='23514', CONSTRAINT='market_recipient_consistent';
        END IF;
        RETURN NULL;
      END IF;
      IF TG_OP='DELETE' THEN player := OLD.player_id; ELSE player := NEW.player_id; END IF;
      SELECT * INTO issue FROM #{s}.market_issuances WHERE player_id=player;
      IF NOT FOUND THEN RETURN NULL; END IF;
      SELECT coalesce(sum(quantity),0) INTO total FROM #{s}.market_holdings WHERE player_id=player;
      IF total <> 100 THEN
        RAISE EXCEPTION 'supply not conserved' USING ERRCODE='23514', CONSTRAINT='market_supply_conserved';
      END IF;
      SELECT * INTO quote FROM #{s}.market_quotes WHERE id=issue.initial_quote_id;
      IF quote.id IS NULL OR quote.player_id <> player OR quote.unit_price <> 1 OR quote.rule_id <> 'initial_issuance' OR quote.rule_version <> '1' OR quote.effective_at <> issue.completed_at THEN
        RAISE EXCEPTION 'invalid original quote' USING ERRCODE='23514', CONSTRAINT='market_issuance_quote_consistent';
      END IF;
      IF TG_TABLE_NAME='market_issuances' AND TG_OP='INSERT' THEN
        IF NOT EXISTS(SELECT 1 FROM #{s}.market_holdings WHERE player_id=player AND user_id=issue.recipient_id AND quantity=100) OR EXISTS(SELECT 1 FROM #{s}.market_holdings WHERE player_id=player AND user_id<>issue.recipient_id AND quantity<>0) THEN
          RAISE EXCEPTION 'incorrect initial owner' USING ERRCODE='23514', CONSTRAINT='market_initial_owner';
        END IF;
      END IF;
      RETURN NULL;
    END $$
    """)

    for table <- ~w(market_initial_recipients market_issuances market_holdings) do
      execute(
        "CREATE CONSTRAINT TRIGGER market_validate_commit AFTER INSERT OR UPDATE OR DELETE ON #{s}.#{table} DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{s}.market_validate_commit()"
      )
    end
  end

  def down do
    schema = prefix() || "public"

    for table <- [
          :market_issuances,
          :market_holdings,
          :market_quotes,
          :market_initial_recipients,
          :market_initialization_locks
        ],
        do: drop(table(table))

    for function <- ~w(market_validate_commit market_lock_write market_immutable),
        do: execute("DROP FUNCTION \"#{schema}\".#{function}()")
  end
end
