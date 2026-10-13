defmodule FootballMarket.Repo.Migrations.CreateValuationConfigurations do
  use Ecto.Migration

  def up do
    create table(:valuation_configuration_versions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :strategy_id, :text, null: false
      add :formula_version, :text, null: false
      add :rules, :map, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("clock_timestamp()")
    end

    create constraint(:valuation_configuration_versions, :valuation_formula_identity,
             check:
               "strategy_id <> '' AND formula_version <> '' AND jsonb_typeof(rules) = 'object'"
           )

    create index(:valuation_configuration_versions, [:created_at, :id])

    create table(:valuation_selection_locks, primary_key: false) do
      add :id, :integer, primary_key: true
    end

    create constraint(:valuation_selection_locks, :valuation_singleton, check: "id = 1")
    execute("INSERT INTO valuation_selection_locks(id) VALUES(1)")
    execute("CREATE SEQUENCE valuation_change_order_seq AS bigint")

    create table(:valuation_selection_changes, primary_key: false) do
      add :change_order, :bigint, primary_key: true

      add :previous_version_id,
          references(:valuation_configuration_versions,
            type: :uuid,
            on_delete: :restrict,
            on_update: :restrict
          )

      add :new_version_id,
          references(:valuation_configuration_versions,
            type: :uuid,
            on_delete: :restrict,
            on_update: :restrict
          ), null: false

      add :effective_at, :utc_datetime_usec, null: false
    end

    execute(
      "ALTER SEQUENCE valuation_change_order_seq OWNED BY valuation_selection_changes.change_order"
    )

    schema = prefix() || "public"

    execute("""
    CREATE FUNCTION valuation_immutable() RETURNS trigger LANGUAGE plpgsql
    SET search_path TO "#{schema}" AS $$
    BEGIN
      RAISE EXCEPTION 'immutable valuation record' USING ERRCODE = '23514', CONSTRAINT = 'valuation_immutable';
    END $$
    """)

    for table <-
          ~w(valuation_configuration_versions valuation_selection_changes valuation_selection_locks) do
      execute(
        "CREATE TRIGGER valuation_immutable BEFORE UPDATE OR DELETE ON #{table} FOR EACH ROW EXECUTE FUNCTION valuation_immutable()"
      )

      execute(
        "CREATE TRIGGER valuation_no_truncate BEFORE TRUNCATE ON #{table} FOR EACH STATEMENT EXECUTE FUNCTION valuation_immutable()"
      )
    end

    execute("""
    CREATE FUNCTION valuation_select_insert() RETURNS trigger LANGUAGE plpgsql VOLATILE
    SET search_path TO "#{schema}" AS $$
    DECLARE predecessor uuid;
    BEGIN
      IF current_setting('transaction_isolation') <> 'read committed' THEN
        RAISE EXCEPTION 'valuation write isolation' USING ERRCODE = '23514', CONSTRAINT = 'valuation_write_isolation';
      END IF;
      PERFORM id FROM valuation_selection_locks WHERE id = 1 FOR UPDATE;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'valuation anchor missing' USING ERRCODE = '23514', CONSTRAINT = 'valuation_anchor';
      END IF;
      SELECT new_version_id INTO predecessor FROM valuation_selection_changes ORDER BY change_order DESC LIMIT 1;
      IF NEW.previous_version_id IS DISTINCT FROM predecessor OR NEW.new_version_id IS NOT DISTINCT FROM predecessor THEN
        RAISE EXCEPTION 'valuation predecessor conflict' USING ERRCODE = '23514', CONSTRAINT = 'valuation_predecessor';
      END IF;
      NEW.change_order := nextval('valuation_change_order_seq');
      NEW.effective_at := transaction_timestamp() AT TIME ZONE 'UTC';
      RETURN NEW;
    END $$
    """)

    execute(
      "CREATE TRIGGER valuation_select_insert BEFORE INSERT ON valuation_selection_changes FOR EACH ROW EXECUTE FUNCTION valuation_select_insert()"
    )
  end

  def down do
    drop table(:valuation_selection_changes)
    drop table(:valuation_selection_locks)
    drop table(:valuation_configuration_versions)
    execute("DROP FUNCTION valuation_select_insert()")
    execute("DROP FUNCTION valuation_immutable()")
  end
end
