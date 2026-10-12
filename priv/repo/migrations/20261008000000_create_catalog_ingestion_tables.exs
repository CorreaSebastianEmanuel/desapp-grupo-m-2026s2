defmodule FootballMarket.Repo.Migrations.CreateCatalogIngestionTables do
  use Ecto.Migration

  def up do
    execute "CREATE UNIQUE INDEX seasons_id_league_id_index ON seasons(id, league_id)"

    execute """
    CREATE TABLE catalog_ingestion_scopes (
      id uuid PRIMARY KEY, league_code text NOT NULL, start_year integer NOT NULL, end_year integer NOT NULL,
      league_id uuid NOT NULL REFERENCES leagues(id) ON DELETE RESTRICT,
      season_id uuid NOT NULL, revision bigint NOT NULL CHECK (revision >= 1), latest_observation_id uuid NOT NULL,
      UNIQUE (league_code, start_year, end_year), UNIQUE(id, season_id, league_id),
      FOREIGN KEY (season_id, league_id) REFERENCES seasons(id, league_id) ON DELETE RESTRICT
    )
    """

    execute """
    CREATE TABLE catalog_source_bindings (
      id uuid PRIMARY KEY, scope_id uuid NOT NULL, season_scope_id uuid NOT NULL, league_scope_id uuid NOT NULL,
      provider text NOT NULL CHECK(btrim(provider) <> ''), kind text NOT NULL,
      source_id text NOT NULL CHECK(btrim(source_id) <> ''),
      league_id uuid REFERENCES leagues(id) ON DELETE RESTRICT,
      season_id uuid REFERENCES seasons(id) ON DELETE RESTRICT, team_id uuid, player_id uuid,
      UNIQUE(scope_id, provider, kind, source_id), UNIQUE(id, scope_id),
      FOREIGN KEY(scope_id, season_scope_id, league_scope_id) REFERENCES catalog_ingestion_scopes(id, season_id, league_id) ON DELETE RESTRICT,
      FOREIGN KEY(team_id, season_scope_id) REFERENCES teams(id, season_id) ON DELETE RESTRICT,
      FOREIGN KEY(player_id, season_scope_id) REFERENCES players(id, season_id) ON DELETE RESTRICT,
      CHECK (
        (kind = 'league' AND league_id = league_scope_id AND season_id IS NULL AND team_id IS NULL AND player_id IS NULL) OR
        (kind = 'season' AND season_id = season_scope_id AND league_id IS NULL AND team_id IS NULL AND player_id IS NULL) OR
        (kind = 'team' AND team_id IS NOT NULL AND league_id IS NULL AND season_id IS NULL AND player_id IS NULL) OR
        (kind = 'player' AND player_id IS NOT NULL AND league_id IS NULL AND season_id IS NULL AND team_id IS NULL)
      ),
      CHECK(num_nonnulls(league_id, season_id, team_id, player_id) = 1)
    )
    """

    for kind <- ~w(league season team player) do
      execute "CREATE UNIQUE INDEX catalog_source_bindings_#{kind}_target ON catalog_source_bindings(scope_id, provider, #{kind}_id) WHERE #{kind}_id IS NOT NULL"
    end

    execute """
    CREATE TABLE catalog_ingestion_observations (
      id uuid PRIMARY KEY, scope_id uuid NOT NULL REFERENCES catalog_ingestion_scopes(id) ON DELETE RESTRICT,
      revision bigint NOT NULL CHECK(revision >= 1), operation text NOT NULL CHECK(operation = 'catalog'),
      provider text NOT NULL, retrieved_at timestamptz NOT NULL, accepted_at timestamptz NOT NULL, fixture_id text,
      canonical_version integer NOT NULL CHECK(canonical_version = 1), delivery_digest bytea NOT NULL,
      canonical_delivery jsonb NOT NULL, counts jsonb NOT NULL,
      UNIQUE(scope_id, revision), UNIQUE(scope_id, delivery_digest), UNIQUE(id, scope_id, revision), UNIQUE(id, scope_id)
    )
    """

    execute """
    ALTER TABLE catalog_ingestion_scopes ADD CONSTRAINT catalog_ingestion_latest_observation_fkey
    FOREIGN KEY(latest_observation_id, id, revision) REFERENCES catalog_ingestion_observations(id, scope_id, revision)
    DEFERRABLE INITIALLY DEFERRED
    """

    execute """
    CREATE TABLE catalog_ingestion_observation_bindings (
      observation_id uuid NOT NULL, binding_id uuid NOT NULL, scope_id uuid NOT NULL,
      PRIMARY KEY(observation_id, binding_id),
      FOREIGN KEY(observation_id, scope_id) REFERENCES catalog_ingestion_observations(id, scope_id) ON DELETE RESTRICT,
      FOREIGN KEY(binding_id, scope_id) REFERENCES catalog_source_bindings(id, scope_id) ON DELETE RESTRICT
    )
    """
  end

  def down do
    execute "DROP TABLE catalog_ingestion_observation_bindings"

    execute "ALTER TABLE catalog_ingestion_scopes DROP CONSTRAINT catalog_ingestion_latest_observation_fkey"

    execute "DROP TABLE catalog_ingestion_observations"
    execute "DROP TABLE catalog_source_bindings"
    execute "DROP TABLE catalog_ingestion_scopes"
    execute "DROP INDEX seasons_id_league_id_index"
  end
end
