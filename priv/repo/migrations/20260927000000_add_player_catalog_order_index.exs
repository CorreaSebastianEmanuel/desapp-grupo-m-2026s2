defmodule FootballMarket.Repo.Migrations.AddPlayerCatalogOrderIndex do
  use Ecto.Migration

  def change do
    execute(
      "CREATE INDEX players_catalog_order_index ON players (lower(btrim(display_name)), id)",
      "DROP INDEX players_catalog_order_index"
    )
  end
end
