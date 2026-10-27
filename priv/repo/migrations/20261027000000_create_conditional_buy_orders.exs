defmodule FootballMarket.Repo.Migrations.CreateConditionalBuyOrders do
  use Ecto.Migration
  def up do
    create table(:market_conditional_buy_orders, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :owner_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :player_id, references(:market_issuances, column: :player_id, type: :uuid, on_delete: :restrict), null: false
      add :quantity, :integer, null: false
      add :maximum_unit_price, :decimal, null: false
      add :created_at, :utc_datetime_usec, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :status, :text, null: false, default: "pending"
      add :completed_at, :utc_datetime_usec
      add :rejection_reason, :text
      add :purchase_id, :uuid
    end
    create index(:market_conditional_buy_orders, [:owner_id, :created_at, :id])
    create index(:market_conditional_buy_orders, [:player_id, :id], where: "status='pending'")
    create index(:market_conditional_buy_orders, [:expires_at, :id], where: "status='pending'")
    create unique_index(:market_conditional_buy_orders, [:purchase_id])
    create constraint(:market_conditional_buy_orders, :market_order_terms, check: "quantity BETWEEN 1 AND 100 AND maximum_unit_price > 0 AND maximum_unit_price < 'Infinity'::numeric AND maximum_unit_price=round(maximum_unit_price,2) AND expires_at>created_at")
    create constraint(:market_conditional_buy_orders, :market_order_outcome, check: """
    (status='pending' AND completed_at IS NULL AND rejection_reason IS NULL AND purchase_id IS NULL)
    OR (status IN ('cancelled','expired') AND completed_at IS NOT NULL AND rejection_reason IS NULL AND purchase_id IS NULL)
    OR (status='rejected' AND completed_at IS NOT NULL AND rejection_reason IS NOT NULL AND rejection_reason IN ('insufficient_funds','insufficient_inventory') AND purchase_id IS NULL)
    OR (status='executed' AND completed_at IS NOT NULL AND rejection_reason IS NULL AND purchase_id IS NOT NULL)
    """)
    create constraint(:market_conditional_buy_orders, :market_order_decision_time, check: "completed_at IS NULL OR (completed_at>=created_at AND ((status='expired' AND completed_at>=expires_at) OR (status<>'expired' AND completed_at<expires_at)))")
    alter table(:market_purchases) do
      add :conditional_order_id, :uuid
    end
    drop unique_index(:market_purchases, [:buyer_id, :request_key])
    create unique_index(:market_purchases, [:buyer_id, :request_key], where: "conditional_order_id IS NULL")
    create unique_index(:market_purchases, [:conditional_order_id])
    s = "\"#{prefix() || "public"}\""
    execute("ALTER TABLE #{s}.market_purchases ADD CONSTRAINT market_purchase_order_fk FOREIGN KEY(conditional_order_id) REFERENCES #{s}.market_conditional_buy_orders(id) DEFERRABLE INITIALLY DEFERRED")
    execute("ALTER TABLE #{s}.market_conditional_buy_orders ADD CONSTRAINT market_order_purchase_fk FOREIGN KEY(purchase_id) REFERENCES #{s}.market_purchases(id) DEFERRABLE INITIALLY DEFERRED")
    execute("""
    CREATE FUNCTION #{s}.market_order_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF TG_OP <> 'UPDATE' THEN RAISE EXCEPTION 'immutable order history' USING ERRCODE='23514'; END IF;
      IF OLD.status <> 'pending' OR ROW(NEW.id,NEW.owner_id,NEW.player_id,NEW.quantity,NEW.maximum_unit_price,NEW.created_at,NEW.expires_at)
        IS DISTINCT FROM ROW(OLD.id,OLD.owner_id,OLD.player_id,OLD.quantity,OLD.maximum_unit_price,OLD.created_at,OLD.expires_at)
      THEN RAISE EXCEPTION 'immutable order terms or terminal outcome' USING ERRCODE='23514'; END IF;
      RETURN NEW;
    END $$
    """)
    execute("CREATE TRIGGER market_order_immutable BEFORE UPDATE OR DELETE ON #{s}.market_conditional_buy_orders FOR EACH ROW EXECUTE FUNCTION #{s}.market_order_immutable()")
    execute("CREATE TRIGGER market_order_no_truncate BEFORE TRUNCATE ON #{s}.market_conditional_buy_orders FOR EACH STATEMENT EXECUTE FUNCTION #{s}.market_immutable()")
    execute("""
    CREATE FUNCTION #{s}.market_order_complete() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE o #{s}.market_conditional_buy_orders%ROWTYPE; p #{s}.market_purchases%ROWTYPE; oid uuid;
    BEGIN
      IF TG_TABLE_NAME='market_purchases' THEN
        oid := NEW.conditional_order_id;
        IF oid IS NULL THEN RETURN NULL; END IF;
      ELSE oid := NEW.id; END IF;
      SELECT * INTO STRICT o FROM #{s}.market_conditional_buy_orders WHERE id=oid;
      IF o.status='executed' THEN
        SELECT * INTO p FROM #{s}.market_purchases WHERE id=o.purchase_id;
        IF NOT FOUND OR ROW(p.conditional_order_id,p.buyer_id,p.player_id,p.quantity,p.completed_at)
          IS DISTINCT FROM ROW(o.id,o.owner_id,o.player_id,o.quantity,o.completed_at)
          OR p.unit_price>o.maximum_unit_price OR p.completed_at>=o.expires_at
          OR (TG_TABLE_NAME='market_purchases' AND NEW.id<>o.purchase_id)
        THEN RAISE EXCEPTION 'incomplete order execution' USING ERRCODE='23514'; END IF;
      ELSIF EXISTS(SELECT 1 FROM #{s}.market_purchases WHERE conditional_order_id=o.id) THEN
        RAISE EXCEPTION 'purchase without executed order' USING ERRCODE='23514';
      END IF;
      RETURN NULL;
    END $$
    """)
    execute("CREATE CONSTRAINT TRIGGER market_order_complete AFTER INSERT OR UPDATE ON #{s}.market_conditional_buy_orders DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{s}.market_order_complete()")
    execute("CREATE CONSTRAINT TRIGGER market_order_complete AFTER INSERT ON #{s}.market_purchases DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{s}.market_order_complete()")
  end
  def down do
    # Append-only execution evidence makes automatic rollback unsafe.
    raise "conditional order evidence requires a forward migration"
  end
end
