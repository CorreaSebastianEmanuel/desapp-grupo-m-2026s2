defmodule FootballMarket.Repo.Migrations.ExtendSynchronizationOperations do
  use Ecto.Migration

  def up do
    schema = prefix() || "public"
    s = "\"#{schema}\""

    execute(
      "ALTER TABLE #{s}.synchronization_runs ADD COLUMN IF NOT EXISTS operation text DEFAULT 'catalog'"
    )

    execute("UPDATE #{s}.synchronization_runs SET operation = 'catalog' WHERE operation IS NULL")
    execute("ALTER TABLE #{s}.synchronization_runs ALTER COLUMN operation SET NOT NULL")

    execute(
      "ALTER TABLE #{s}.catalog_delivery_receipts ADD COLUMN IF NOT EXISTS operation text DEFAULT 'catalog'"
    )

    execute("UPDATE #{s}.catalog_delivery_receipts SET operation = 'catalog' WHERE operation IS NULL")
    execute("ALTER TABLE #{s}.catalog_delivery_receipts ALTER COLUMN operation SET NOT NULL")

    drop_if_exists index(:synchronization_runs, [:league_code, :start_year, :end_year],
                     name: :synchronization_active_scope,
                     prefix: prefix()
                   )

    create unique_index(:synchronization_runs, [:operation, :league_code, :start_year, :end_year],
             where: "state IN ('queued', 'executing', 'retry_wait')",
             name: :synchronization_active_scope,
             prefix: prefix()
           )

    execute("ALTER TABLE #{s}.synchronization_runs DROP CONSTRAINT IF EXISTS synchronization_operation")
    execute("ALTER TABLE #{s}.catalog_delivery_receipts DROP CONSTRAINT IF EXISTS catalog_delivery_receipt_operation")

    create constraint(:synchronization_runs, :synchronization_operation,
             check: "operation IN ('catalog', 'statistics')",
             prefix: prefix()
           )

    create constraint(:catalog_delivery_receipts, :catalog_delivery_receipt_operation,
             check: "operation IN ('catalog', 'statistics')",
             prefix: prefix()
           )
  end

  def down do
    drop constraint(:catalog_delivery_receipts, :catalog_delivery_receipt_operation,
           prefix: prefix()
         )

    drop constraint(:synchronization_runs, :synchronization_operation, prefix: prefix())

    drop index(:synchronization_runs, [:operation, :league_code, :start_year, :end_year],
           name: :synchronization_active_scope,
           prefix: prefix()
         )

    create unique_index(:synchronization_runs, [:league_code, :start_year, :end_year],
             where: "state IN ('queued', 'executing', 'retry_wait')",
             name: :synchronization_active_scope,
             prefix: prefix()
           )

    alter table(:catalog_delivery_receipts, prefix: prefix()), do: remove(:operation)
    alter table(:synchronization_runs, prefix: prefix()), do: remove(:operation)
  end
end
