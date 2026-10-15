defmodule FootballMarket.Repo.Migrations.AddOban do
  use Ecto.Migration
  def up, do: Oban.Migration.up(prefix: prefix() || "public")
  def down, do: Oban.Migration.down(prefix: prefix() || "public", version: 1)
end
