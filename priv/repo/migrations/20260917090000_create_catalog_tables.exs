defmodule FootballMarket.Repo.Migrations.CreateCatalogTables do
  use Ecto.Migration

  def change do
    create table(:leagues, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :code, :text, null: false
      add :name, :text, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:leagues, :leagues_code_not_blank, check: "btrim(code) <> ''")
    create constraint(:leagues, :leagues_name_not_blank, check: "btrim(name) <> ''")

    create constraint(:leagues, :leagues_supported_code,
             check: "upper(btrim(code)) IN ('PL','BL1','PD','SA','FL1')"
           )

    execute "CREATE UNIQUE INDEX leagues_normalized_code_index ON leagues (lower(btrim(code)))",
            "DROP INDEX leagues_normalized_code_index"

    execute "CREATE UNIQUE INDEX leagues_normalized_name_index ON leagues (lower(btrim(name)))",
            "DROP INDEX leagues_normalized_name_index"

    create table(:seasons, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :league_id, references(:leagues, type: :uuid, on_delete: :restrict), null: false
      add :start_year, :integer, null: false
      add :end_year, :integer, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:seasons, :seasons_valid_year_span,
             check: "end_year = start_year OR end_year = start_year + 1"
           )

    create unique_index(:seasons, [:league_id, :start_year, :end_year],
             name: :seasons_league_years_index
           )

    create index(:seasons, [:league_id], name: :seasons_league_id_index)

    create table(:teams, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict), null: false
      add :code, :text, null: false
      add :name, :text, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:teams, :teams_code_not_blank, check: "btrim(code) <> ''")
    create constraint(:teams, :teams_name_not_blank, check: "btrim(name) <> ''")
    create unique_index(:teams, [:id, :season_id], name: :teams_id_season_id_index)
    create index(:teams, [:season_id], name: :teams_season_id_index)

    execute "CREATE UNIQUE INDEX teams_season_normalized_code_index ON teams (season_id, lower(btrim(code)))",
            "DROP INDEX teams_season_normalized_code_index"

    execute "CREATE UNIQUE INDEX teams_season_normalized_name_index ON teams (season_id, lower(btrim(name)))",
            "DROP INDEX teams_season_normalized_name_index"

    create table(:positions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :code, :text, null: false
      add :name, :text, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:positions, :positions_code_not_blank, check: "btrim(code) <> ''")
    create constraint(:positions, :positions_name_not_blank, check: "btrim(name) <> ''")

    execute "CREATE UNIQUE INDEX positions_normalized_code_index ON positions (lower(btrim(code)))",
            "DROP INDEX positions_normalized_code_index"

    execute "CREATE UNIQUE INDEX positions_normalized_name_index ON positions (lower(btrim(name)))",
            "DROP INDEX positions_normalized_name_index"

    create table(:players, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :team_id, :uuid, null: false
      add :season_id, references(:seasons, type: :uuid, on_delete: :restrict), null: false
      add :position_id, references(:positions, type: :uuid, on_delete: :restrict), null: false
      add :catalog_identity, :text, null: false
      add :display_name, :text, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:players, :players_catalog_identity_not_blank,
             check: "btrim(catalog_identity) <> ''"
           )

    create constraint(:players, :players_display_name_not_blank,
             check: "btrim(display_name) <> ''"
           )

    execute "ALTER TABLE players ADD CONSTRAINT players_team_season_fkey FOREIGN KEY (team_id, season_id) REFERENCES teams(id, season_id) ON DELETE RESTRICT",
            "ALTER TABLE players DROP CONSTRAINT players_team_season_fkey"

    execute "CREATE UNIQUE INDEX players_season_normalized_identity_index ON players (season_id, lower(btrim(catalog_identity)))",
            "DROP INDEX players_season_normalized_identity_index"

    create index(:players, [:team_id], name: :players_team_id_index)
    create index(:players, [:position_id], name: :players_position_id_index)
    create index(:players, [:season_id], name: :players_season_id_index)
    create index(:players, [:team_id, :position_id, :id], name: :players_team_position_id_index)
  end
end
