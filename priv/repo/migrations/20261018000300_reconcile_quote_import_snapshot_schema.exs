defmodule FootballMarket.Repo.Migrations.ReconcileQuoteImportSnapshotSchema do
  use Ecto.Migration

  def change do
    execute(
      "ALTER TABLE quote_import_scope_snapshots ADD COLUMN IF NOT EXISTS schema_version integer NOT NULL DEFAULT 1",
      "SELECT 1"
    )
  end
end
