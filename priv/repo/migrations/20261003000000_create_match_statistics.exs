defmodule FootballMarket.Repo.Migrations.CreateMatchStatistics do
  use Ecto.Migration

  @counts [
    :minutes_played,
    :goals,
    :assists,
    :shots_on_target,
    :tackles,
    :interceptions,
    :saves,
    :goals_conceded,
    :yellow_cards,
    :red_cards
  ]
  def up do
    create unique_index(:seasons, [:id, :league_id, :start_year, :end_year],
             name: :seasons_statistics_witness_index
           )

    create unique_index(:players, [:id, :season_id], name: :players_id_season_id_index)

    create table(:matches, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :match_identity, :text, null: false
      add :kickoff_at, :utc_datetime_usec, null: false
      add :season_id, :uuid, null: false
      add :home_team_id, :uuid, null: false
      add :away_team_id, :uuid, null: false
      add :season_league_id, :uuid, null: false
      add :season_start_year, :integer, null: false
      add :season_end_year, :integer, null: false
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    execute(
      "ALTER TABLE matches ADD COLUMN normalized_identity text GENERATED ALWAYS AS (lower(regexp_replace(match_identity, '^[[:space:]]+|[[:space:]]+$', '', 'g'))) STORED"
    )

    create constraint(:matches, :matches_identity_not_blank, check: "normalized_identity <> ''")
    create constraint(:matches, :matches_distinct_teams, check: "home_team_id <> away_team_id")

    create unique_index(:matches, [:season_id, :normalized_identity],
             name: :matches_season_identity_index
           )

    create unique_index(:matches, [:id, :season_id], name: :matches_id_season_id_index)
    create index(:matches, [:kickoff_at, :id])

    execute(
      "ALTER TABLE matches ADD CONSTRAINT matches_season_witness_fkey FOREIGN KEY (season_id, season_league_id, season_start_year, season_end_year) REFERENCES seasons(id, league_id, start_year, end_year) ON UPDATE RESTRICT ON DELETE RESTRICT"
    )

    for field <- [:home_team_id, :away_team_id] do
      execute(
        "ALTER TABLE matches ADD CONSTRAINT matches_#{field}_season_fkey FOREIGN KEY (#{field}, season_id) REFERENCES teams(id, season_id) ON UPDATE RESTRICT ON DELETE RESTRICT"
      )
    end

    create table(:player_match_performances, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :match_id, :uuid, null: false
      add :player_id, :uuid, null: false
      add :season_id, :uuid, null: false
      add :team_id, :uuid, null: false

      add :position_id,
          references(:positions, type: :uuid, on_delete: :restrict, on_update: :restrict),
          null: false

      for field <- @counts, do: add(field, :numeric, null: field != :minutes_played)
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create unique_index(:player_match_performances, [:player_id, :match_id],
             name: :performances_player_match_index
           )

    for {field, target} <- [{:match_id, :matches}, {:player_id, :players}, {:team_id, :teams}] do
      execute(
        "ALTER TABLE player_match_performances ADD CONSTRAINT performances_#{field}_season_fkey FOREIGN KEY (#{field}, season_id) REFERENCES #{target}(id, season_id) ON UPDATE RESTRICT ON DELETE RESTRICT"
      )
    end

    for field <- @counts do
      create constraint(:player_match_performances, "performances_#{field}_count",
               check:
                 "#{field} IS NULL OR (#{field} >= 0 AND #{field} = trunc(#{field}) AND #{field} NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric))"
             )
    end

    execute("""
    CREATE FUNCTION statistics_participation() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF EXISTS (SELECT 1 FROM matches WHERE id = NEW.match_id AND NEW.team_id NOT IN (home_team_id, away_team_id)) THEN
        RAISE EXCEPTION 'nonparticipant' USING ERRCODE = '23514', CONSTRAINT = 'performances_participation';
      END IF;
      RETURN NEW;
    END $$
    """)

    execute(
      "CREATE TRIGGER performances_participation BEFORE INSERT ON player_match_performances FOR EACH ROW EXECUTE FUNCTION statistics_participation()"
    )

    execute("""
    CREATE FUNCTION statistics_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      RAISE EXCEPTION 'immutable facts' USING ERRCODE = '23514', CONSTRAINT = 'statistics_immutable';
    END $$
    """)

    for table <- [:matches, :player_match_performances] do
      execute(
        "CREATE TRIGGER statistics_immutable BEFORE UPDATE OR DELETE ON #{table} FOR EACH ROW EXECUTE FUNCTION statistics_immutable()"
      )
    end
  end

  def down do
    drop table(:player_match_performances)
    drop table(:matches)
    execute("DROP FUNCTION statistics_participation()")
    execute("DROP FUNCTION statistics_immutable()")
    drop index(:players, [:id, :season_id], name: :players_id_season_id_index)

    drop index(:seasons, [:id, :league_id, :start_year, :end_year],
           name: :seasons_statistics_witness_index
         )
  end
end
