defmodule FootballMarket.Repo.Migrations.AddConditionalOrderEvaluationPasses do
  use Ecto.Migration

  def change do
    create table(:market_order_evaluation_passes, primary_key: false) do
      add :id, :integer, primary_key: true, default: 1
      add :state, :text, null: false, default: "idle"
      add :generation, :bigint, null: false, default: 0
      add :cursor_ordinal, :bigint, null: false, default: 0
      add :rescan_requested, :boolean, null: false, default: false
      add :upper_created_at, :utc_datetime_usec
      add :upper_order_id, :uuid
      add :started_at, :utc_datetime_usec
      add :updated_at, :utc_datetime_usec
    end

    create constraint(:market_order_evaluation_passes, :market_evaluation_singleton,
             check:
               "id=1 AND generation>=0 AND cursor_ordinal>=0 AND state IN ('idle','running') AND ((upper_created_at IS NULL)=(upper_order_id IS NULL)) AND (state<>'idle' OR (cursor_ordinal=0 AND upper_order_id IS NULL))"
           )

    create unique_index(:market_order_evaluation_passes, [:generation])

    create table(:market_order_evaluation_members, primary_key: false) do
      add :pass_generation, :bigint, primary_key: true
      add :ordinal, :bigint, primary_key: true
      add :captured_created_at, :utc_datetime_usec, null: false

      add :order_id,
          references(:market_conditional_buy_orders, type: :uuid, on_delete: :restrict),
          null: false
    end

    create unique_index(:market_order_evaluation_members, [:pass_generation, :order_id])

    create constraint(:market_order_evaluation_members, :market_evaluation_member_position,
             check: "pass_generation>0 AND ordinal>0"
           )

    schema = "\"#{prefix() || "public"}\""

    execute(
      "ALTER TABLE #{schema}.market_order_evaluation_members ADD CONSTRAINT market_evaluation_generation_fk FOREIGN KEY(pass_generation) REFERENCES #{schema}.market_order_evaluation_passes(generation) DEFERRABLE INITIALLY DEFERRED",
      "ALTER TABLE #{schema}.market_order_evaluation_members DROP CONSTRAINT market_evaluation_generation_fk"
    )

    create index(:market_conditional_buy_orders, [:created_at, :id], where: "status='pending'")

    execute(
      "INSERT INTO #{prefix() || "public"}.market_order_evaluation_passes(id) VALUES(1)",
      "SELECT 1"
    )
  end
end
