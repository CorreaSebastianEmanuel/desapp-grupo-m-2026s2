defmodule FootballMarket.Repo.Migrations.ReconcileQuoteMappingSchema do
  use Ecto.Migration

  def change do
    execute(
      "ALTER TABLE quote_conversion_mappings ADD COLUMN IF NOT EXISTS schema_version integer NOT NULL DEFAULT 1",
      "SELECT 1"
    )
  end
end
