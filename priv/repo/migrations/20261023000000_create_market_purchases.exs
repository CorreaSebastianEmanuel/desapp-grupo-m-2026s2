defmodule FootballMarket.Repo.Migrations.CreateMarketPurchases do
  use Ecto.Migration

  def up do
    create table(:market_credit_balances, primary_key: false) do
      add :user_id, references(:users, type: :uuid, on_delete: :restrict), primary_key: true
      add :amount, :decimal, null: false
      add :updated_at, :utc_datetime_usec, null: false
    end

    create constraint(:market_credit_balances, :market_balance_exact,
             check: "amount >= 0 AND amount < 'Infinity'::numeric AND amount = round(amount,2)"
           )

    create table(:market_purchases, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :buyer_id, references(:users, type: :uuid, on_delete: :restrict), null: false
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

    create unique_index(:market_purchases, [:buyer_id, :request_key])

    create constraint(:market_purchases, :market_purchase_exact,
             check:
               "buyer_id <> recipient_id AND quantity > 0 AND btrim(request_key) <> '' AND char_length(request_key) <= 128 AND unit_price > 0 AND unit_price < 'Infinity'::numeric AND unit_price = round(unit_price,2) AND total = quantity * unit_price"
           )

    create table(:market_credit_entries, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :purchase_id, references(:market_purchases, type: :uuid, on_delete: :restrict),
        null: false

      add :user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :side, :text, null: false
      add :amount, :decimal, null: false
      add :inserted_at, :utc_datetime_usec, null: false
    end

    create unique_index(:market_credit_entries, [:purchase_id, :side])

    create constraint(:market_credit_entries, :market_entry_exact,
             check:
               "side IN ('debit','credit') AND amount > 0 AND amount < 'Infinity'::numeric AND amount = round(amount,2)"
           )

    create table(:market_token_transfers, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :purchase_id, references(:market_purchases, type: :uuid, on_delete: :restrict),
        null: false

      add :player_id, references(:players, type: :uuid, on_delete: :restrict), null: false
      add :from_user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :to_user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :quantity, :integer, null: false
      add :inserted_at, :utc_datetime_usec, null: false
    end

    create unique_index(:market_token_transfers, [:purchase_id])

    create constraint(:market_token_transfers, :market_transfer_positive,
             check: "quantity > 0 AND from_user_id <> to_user_id"
           )

    s = "\"#{prefix() || "public"}\""

    execute(
      "ALTER TABLE #{s}.market_purchases ADD CONSTRAINT market_purchase_quote_player FOREIGN KEY(quote_id,player_id) REFERENCES #{s}.market_quotes(id,player_id)"
    )

    execute("""
    CREATE FUNCTION #{s}.market_purchase_complete() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE op #{s}.market_purchases%ROWTYPE; q #{s}.market_quotes%ROWTYPE; operation uuid;
    BEGIN
      IF TG_TABLE_NAME='market_purchases' THEN operation := NEW.id; ELSE operation := NEW.purchase_id; END IF;
      SELECT * INTO STRICT op FROM #{s}.market_purchases WHERE id=operation;
      SELECT * INTO STRICT q FROM #{s}.market_quotes WHERE id=op.quote_id;
      IF ROW(op.player_id,op.unit_price,op.quote_effective_at,op.rule_id,op.rule_version,op.configuration_version_id,op.mapping_id,op.performance_sequence)
        IS DISTINCT FROM ROW(q.player_id,q.unit_price,q.effective_at,q.rule_id,q.rule_version,q.configuration_version_id,q.mapping_id,q.performance_sequence)
        OR op.recipient_id IS DISTINCT FROM (SELECT recipient_id FROM #{s}.market_issuances WHERE player_id=op.player_id)
        OR (SELECT count(*) FROM #{s}.market_credit_entries WHERE purchase_id=operation) <> 2
        OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE purchase_id=operation AND side='debit' AND user_id=op.buyer_id AND amount=op.total)
        OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE purchase_id=operation AND side='credit' AND user_id=op.recipient_id AND amount=op.total)
        OR NOT EXISTS(SELECT 1 FROM #{s}.market_token_transfers WHERE purchase_id=operation AND player_id=op.player_id AND from_user_id=op.recipient_id AND to_user_id=op.buyer_id AND quantity=op.quantity)
      THEN RAISE EXCEPTION 'incomplete purchase evidence' USING ERRCODE='23514', CONSTRAINT='market_purchase_complete'; END IF;
      RETURN NULL;
    END $$
    """)

    for t <- ~w(market_purchases market_credit_entries market_token_transfers) do
      execute(
        "CREATE CONSTRAINT TRIGGER market_purchase_complete AFTER INSERT ON #{s}.#{t} DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{s}.market_purchase_complete()"
      )

      execute(
        "CREATE TRIGGER market_history_immutable BEFORE UPDATE OR DELETE ON #{s}.#{t} FOR EACH ROW EXECUTE FUNCTION #{s}.market_immutable()"
      )

      execute(
        "CREATE TRIGGER market_no_truncate BEFORE TRUNCATE ON #{s}.#{t} FOR EACH STATEMENT EXECUTE FUNCTION #{s}.market_immutable()"
      )
    end
  end

  def down do
    for t <- [
          :market_token_transfers,
          :market_credit_entries,
          :market_purchases,
          :market_credit_balances
        ],
        do: drop(table(t))

    execute("DROP FUNCTION \"#{prefix() || "public"}\".market_purchase_complete()")
  end
end
