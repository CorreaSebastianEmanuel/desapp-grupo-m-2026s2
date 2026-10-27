defmodule FootballMarket.Repo.Migrations.CreateMarketSales do
  use Ecto.Migration

  def up do
    create table(:market_sales, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :seller_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :recipient_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :player_id, references(:players, type: :uuid, on_delete: :restrict), null: false
      add :quote_id, references(:market_quotes, type: :uuid, on_delete: :restrict), null: false
      add :request_key, :text, null: false
      add :quantity, :integer, null: false
      add :unit_price, :decimal, null: false
      add :total, :decimal, null: false
      add :quote_effective_at, :utc_datetime_usec, null: false
      add :rule_id, :text, null: false
      add :rule_version, :text, null: false
      add :configuration_version_id, :uuid
      add :mapping_id, :uuid
      add :performance_sequence, :bigint
      add :completed_at, :utc_datetime_usec, null: false
    end

    create unique_index(:market_sales, [:seller_id, :request_key])

    create constraint(:market_sales, :market_sale_exact,
             check:
               "seller_id <> recipient_id AND quantity > 0 AND btrim(request_key) <> '' AND char_length(request_key) <= 128 AND unit_price > 0 AND unit_price < 'Infinity'::numeric AND unit_price = round(unit_price,2) AND total = quantity * unit_price"
           )

    create table(:market_sale_credit_entries, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sale_id, references(:market_sales, type: :uuid, on_delete: :restrict), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :side, :text, null: false
      add :amount, :decimal, null: false
      add :inserted_at, :utc_datetime_usec, null: false
    end

    create unique_index(:market_sale_credit_entries, [:sale_id, :side])

    create constraint(:market_sale_credit_entries, :market_sale_entry_exact,
             check:
               "side IN ('debit','credit') AND amount > 0 AND amount < 'Infinity'::numeric AND amount = round(amount,2)"
           )

    create table(:market_sale_token_transfers, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sale_id, references(:market_sales, type: :uuid, on_delete: :restrict), null: false
      add :player_id, references(:players, type: :uuid, on_delete: :restrict), null: false
      add :from_user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :to_user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :quantity, :integer, null: false
      add :inserted_at, :utc_datetime_usec, null: false
    end

    create unique_index(:market_sale_token_transfers, [:sale_id])

    create constraint(:market_sale_token_transfers, :market_sale_transfer_positive,
             check: "quantity > 0 AND from_user_id <> to_user_id"
           )

    schema = "\"#{prefix() || "public"}\""

    execute(
      "ALTER TABLE #{schema}.market_sales ADD CONSTRAINT market_sale_quote_player FOREIGN KEY(quote_id,player_id) REFERENCES #{schema}.market_quotes(id,player_id)"
    )

    execute("""
    CREATE FUNCTION #{schema}.market_sale_complete() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE op #{schema}.market_sales%ROWTYPE; quote #{schema}.market_quotes%ROWTYPE; operation uuid;
    BEGIN
      IF TG_TABLE_NAME='market_sales' THEN operation := NEW.id; ELSE operation := NEW.sale_id; END IF;
      SELECT * INTO STRICT op FROM #{schema}.market_sales WHERE id=operation;
      SELECT * INTO STRICT quote FROM #{schema}.market_quotes WHERE id=op.quote_id;
      IF ROW(op.player_id,op.unit_price,op.quote_effective_at,op.rule_id,op.rule_version,op.configuration_version_id,op.mapping_id,op.performance_sequence)
        IS DISTINCT FROM ROW(quote.player_id,quote.unit_price,quote.effective_at,quote.rule_id,quote.rule_version,quote.configuration_version_id,quote.mapping_id,quote.performance_sequence)
        OR op.recipient_id IS DISTINCT FROM (SELECT recipient_id FROM #{schema}.market_issuances WHERE player_id=op.player_id)
        OR (SELECT count(*) FROM #{schema}.market_sale_credit_entries WHERE sale_id=operation) <> 2
        OR NOT EXISTS(SELECT 1 FROM #{schema}.market_sale_credit_entries WHERE sale_id=operation AND side='debit' AND user_id=op.recipient_id AND amount=op.total)
        OR NOT EXISTS(SELECT 1 FROM #{schema}.market_sale_credit_entries WHERE sale_id=operation AND side='credit' AND user_id=op.seller_id AND amount=op.total)
        OR NOT EXISTS(SELECT 1 FROM #{schema}.market_sale_token_transfers WHERE sale_id=operation AND player_id=op.player_id AND from_user_id=op.seller_id AND to_user_id=op.recipient_id AND quantity=op.quantity)
      THEN RAISE EXCEPTION 'incomplete sale evidence' USING ERRCODE='23514', CONSTRAINT='market_sale_complete'; END IF;
      RETURN NULL;
    END $$
    """)

    for table <- ~w(market_sales market_sale_credit_entries market_sale_token_transfers) do
      execute(
        "CREATE CONSTRAINT TRIGGER market_sale_complete AFTER INSERT ON #{schema}.#{table} DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{schema}.market_sale_complete()"
      )

      execute(
        "CREATE TRIGGER market_history_immutable BEFORE UPDATE OR DELETE ON #{schema}.#{table} FOR EACH ROW EXECUTE FUNCTION #{schema}.market_immutable()"
      )

      execute(
        "CREATE TRIGGER market_no_truncate BEFORE TRUNCATE ON #{schema}.#{table} FOR EACH STATEMENT EXECUTE FUNCTION #{schema}.market_immutable()"
      )
    end
  end

  def down do
    for table <- [:market_sale_token_transfers, :market_sale_credit_entries, :market_sales],
        do: drop(table(table))

    execute("DROP FUNCTION \"#{prefix() || "public"}\".market_sale_complete()")
  end
end
