defmodule FootballMarket.Repo.Migrations.MakeTeamBusinessKeysDeferrable do
  use Ecto.Migration

  def up do
    for key <- ~w(code name) do
      execute "ALTER TABLE teams ADD COLUMN normalized_#{key} text GENERATED ALWAYS AS (lower(btrim(#{key}))) STORED"
      execute "DROP INDEX teams_season_normalized_#{key}_index"

      execute "ALTER TABLE teams ADD CONSTRAINT teams_season_normalized_#{key}_index UNIQUE(season_id, normalized_#{key}) DEFERRABLE INITIALLY IMMEDIATE"
    end
  end

  def down do
    for key <- ~w(code name) do
      execute "ALTER TABLE teams DROP CONSTRAINT teams_season_normalized_#{key}_index"
      execute "ALTER TABLE teams DROP COLUMN normalized_#{key}"

      execute "CREATE UNIQUE INDEX teams_season_normalized_#{key}_index ON teams(season_id, lower(btrim(#{key})))"
    end
  end
end
