defmodule FootballMarket.Repo.Migrations.CreateMarketSales do
  use Ecto.Migration

  def up do
    create table(:market_sales, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :seller_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :buyer_id, references(:users, type: :uuid, on_delete: :restrict), null: false
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
               "seller_id <> buyer_id AND quantity > 0 AND btrim(request_key) <> '' AND char_length(request_key) <= 128 AND unit_price > 0 AND unit_price < 'Infinity'::numeric AND unit_price = round(unit_price,2) AND total = quantity * unit_price"
           )

    s = "\"#{prefix() || "public"}\""

    execute(
      "ALTER TABLE #{s}.market_sales ADD CONSTRAINT market_sale_quote_player FOREIGN KEY(quote_id,player_id) REFERENCES #{s}.market_quotes(id,player_id)"
    )

    alter table(:market_credit_entries) do
      modify :purchase_id, :uuid, null: true
      add :sale_id, references(:market_sales, type: :uuid, on_delete: :restrict)
    end

    create constraint(:market_credit_entries, :market_entry_owner,
             check: "num_nonnulls(purchase_id, sale_id) = 1"
           )

    create unique_index(:market_credit_entries, [:sale_id, :side])

    alter table(:market_token_transfers) do
      modify :purchase_id, :uuid, null: true
      add :sale_id, references(:market_sales, type: :uuid, on_delete: :restrict)
    end

    create constraint(:market_token_transfers, :market_transfer_owner,
             check: "num_nonnulls(purchase_id, sale_id) = 1"
           )

    create unique_index(:market_token_transfers, [:sale_id])

    replace_financial_completion_trigger(s)

    execute(
      "CREATE CONSTRAINT TRIGGER market_sale_complete AFTER INSERT ON #{s}.market_sales DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{s}.market_purchase_complete()"
    )

    # market_credit_entries and market_token_transfers keep their existing
    # completion triggers from the purchase migration; they call the replaced
    # shared function, which now routes purchase and sale evidence.
    execute(
      "CREATE TRIGGER market_history_immutable BEFORE UPDATE OR DELETE ON #{s}.market_sales FOR EACH ROW EXECUTE FUNCTION #{s}.market_immutable()"
    )

    execute(
      "CREATE TRIGGER market_no_truncate BEFORE TRUNCATE ON #{s}.market_sales FOR EACH STATEMENT EXECUTE FUNCTION #{s}.market_immutable()"
    )
  end

  def down do
    schema = prefix() || "public"
    s = "\"#{schema}\""

    for t <- ~w(market_sales market_credit_entries market_token_transfers) do
      execute("DROP TRIGGER IF EXISTS market_no_truncate ON #{s}.#{t}")
      execute("DROP TRIGGER IF EXISTS market_history_immutable ON #{s}.#{t}")
      execute("DROP TRIGGER IF EXISTS market_financial_complete ON #{s}.#{t}")
    end

    execute("DROP FUNCTION IF EXISTS #{s}.market_purchase_complete()")
    restore_purchases_only_completion_trigger(s)

    drop constraint(:market_credit_entries, :market_entry_owner)
    drop constraint(:market_token_transfers, :market_transfer_owner)

    alter table(:market_credit_entries) do
      remove :sale_id
      modify :purchase_id, :uuid, null: false
    end

    alter table(:market_token_transfers) do
      remove :sale_id
      modify :purchase_id, :uuid, null: false
    end

    drop table(:market_sales)
  end

  defp replace_financial_completion_trigger(s) do
    execute("""
    CREATE OR REPLACE FUNCTION #{s}.market_purchase_complete() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE
      op #{s}.market_purchases%ROWTYPE;
      sale #{s}.market_sales%ROWTYPE;
      q #{s}.market_quotes%ROWTYPE;
      operation uuid;
      is_sale boolean;
    BEGIN
      IF TG_TABLE_NAME = 'market_purchases' THEN
        operation := NEW.id; op := NEW; is_sale := false;
      ELSIF TG_TABLE_NAME = 'market_sales' THEN
        operation := NEW.id; sale := NEW; is_sale := true;
      ELSE
        IF NEW.purchase_id IS NOT NULL THEN
          SELECT * INTO STRICT op FROM #{s}.market_purchases WHERE id = NEW.purchase_id;
          operation := NEW.purchase_id; is_sale := false;
        ELSIF NEW.sale_id IS NOT NULL THEN
          SELECT * INTO STRICT sale FROM #{s}.market_sales WHERE id = NEW.sale_id;
          operation := NEW.sale_id; is_sale := true;
        ELSE
          RAISE EXCEPTION 'dangling financial evidence' USING ERRCODE='23514', CONSTRAINT='market_financial_owner';
        END IF;
      END IF;

      IF NOT is_sale THEN
        SELECT * INTO STRICT q FROM #{s}.market_quotes WHERE id=op.quote_id;
        IF ROW(op.player_id,op.unit_price,op.quote_effective_at,op.rule_id,op.rule_version,op.configuration_version_id,op.mapping_id,op.performance_sequence)
          IS DISTINCT FROM ROW(q.player_id,q.unit_price,q.effective_at,q.rule_id,q.rule_version,q.configuration_version_id,q.mapping_id,q.performance_sequence)
          OR op.recipient_id IS DISTINCT FROM (SELECT recipient_id FROM #{s}.market_issuances WHERE player_id=op.player_id)
          OR (SELECT count(*) FROM #{s}.market_credit_entries WHERE purchase_id=operation) <> 2
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE purchase_id=operation AND side='debit' AND user_id=op.buyer_id AND amount=op.total)
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE purchase_id=operation AND side='credit' AND user_id=op.recipient_id AND amount=op.total)
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_token_transfers WHERE purchase_id=operation AND player_id=op.player_id AND from_user_id=op.recipient_id AND to_user_id=op.buyer_id AND quantity=op.quantity)
        THEN RAISE EXCEPTION 'incomplete purchase evidence' USING ERRCODE='23514', CONSTRAINT='market_purchase_complete'; END IF;
      ELSE
        SELECT * INTO STRICT q FROM #{s}.market_quotes WHERE id=sale.quote_id;
        IF ROW(sale.player_id,sale.unit_price,sale.quote_effective_at,sale.rule_id,sale.rule_version,sale.configuration_version_id,sale.mapping_id,sale.performance_sequence)
          IS DISTINCT FROM ROW(q.player_id,q.unit_price,q.effective_at,q.rule_id,q.rule_version,q.configuration_version_id,q.mapping_id,q.performance_sequence)
          OR sale.buyer_id IS DISTINCT FROM (SELECT recipient_id FROM #{s}.market_issuances WHERE player_id=sale.player_id)
          OR (SELECT count(*) FROM #{s}.market_credit_entries WHERE sale_id=operation) <> 2
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE sale_id=operation AND side='debit' AND user_id=sale.buyer_id AND amount=sale.total)
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_credit_entries WHERE sale_id=operation AND side='credit' AND user_id=sale.seller_id AND amount=sale.total)
          OR NOT EXISTS(SELECT 1 FROM #{s}.market_token_transfers WHERE sale_id=operation AND player_id=sale.player_id AND from_user_id=sale.seller_id AND to_user_id=sale.buyer_id AND quantity=sale.quantity)
        THEN RAISE EXCEPTION 'incomplete sale evidence' USING ERRCODE='23514', CONSTRAINT='market_sale_complete'; END IF;
      END IF;

      RETURN NULL;
    END $$
    """)
  end

  defp restore_purchases_only_completion_trigger(s) do
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
  end
end
