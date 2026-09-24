# Quickstart: Validate Development Seed Data

## Prerequisites

- Repository-pinned Elixir/Erlang toolchain and fetched/compiled dependencies.
- Local PostgreSQL running with the repository defaults; Redis and network access are not required.
- A dedicated development database name that does not contain valuable local data.

## Prepare a fresh reference database

Database/service startup, dependency preparation, database creation, and migrations are setup and are excluded from the ten-second measurement:

```sh
POSTGRES_DB=football_market_seed_demo mix infrastructure.database.setup
```

Expected: the dedicated database exists and all migrations are current. The seed action has not run automatically.

## Run and time the supported action

```sh
POSTGRES_DB=football_market_seed_demo /usr/bin/time -p mix catalog.seed
```

Measure wall time from command launch through process exit. Expected: exit zero in at most 10.0 seconds, 44 records created and 0 reused, with target totals 5 leagues, 5 seasons, 10 teams, 4 positions, and 20 players. The command must succeed if Redis and external-provider access are unavailable.

Run the identical command again:

```sh
POSTGRES_DB=football_market_seed_demo mix catalog.seed
```

Expected: exit zero, 0 records created, 44 reused, and no identity, value, timestamp, or relationship changes.

## Focused automated validation

```sh
MIX_ENV=test mix test test/football_market/catalog/development_seed_test.exs test/mix/tasks/catalog.seed_test.exs
```

Expected coverage:

- exact empty-catalog counts and all league/team/position relationships;
- complete second-run snapshots remain unchanged;
- partial states at each hierarchy level converge;
- normalized identity variants are preserved and reused;
- unrelated valid records remain unchanged;
- split identities, exact attribute mismatches (`attribute_mismatch`), wrong relationships (`relationship_mismatch`), and a late failure return safe entity/identity errors and roll back everything from the run;
- a race cannot create duplicates or commit a partial target, though both invocations need not succeed;
- production/unknown environments are denied before database access, and existing setup/startup paths do not seed;
- task success/error exit and output contain no SQL debug logging, connection target, operational advice, sentinel credential, URL, raw exception, UUID, or arbitrary row value, including when PostgreSQL is unreachable.

The public failure contract is limited to categories `disabled`, `validation`, `conflict`, and `persistence`; causes `invalid_manifest`, `alternate_identity`, `misplaced_relationship`, `attribute_mismatch`, `relationship_mismatch`, `database`, `write_failed`, `concurrent_write`, and `database_unavailable`; allowlisted entities; and identities owned by the fixed manifest. Unknown internal category, cause, entity, identity, or malformed error data is reported only as `category=persistence entity=seed identity=development-seed cause=write_failed`.

## Catalog visibility checks

Run the following against the seeded reference database. It uses the existing Catalog lookup boundary rather than inspecting the seed manifest:

```sh
POSTGRES_DB=football_market_seed_demo mix run -e '
Logger.configure(level: :warning)
alias FootballMarket.{Catalog, Repo}
alias FootballMarket.Catalog.{League, Player, Position, Season, Team}

expected = [{League, 5}, {Season, 5}, {Team, 10}, {Position, 4}, {Player, 20}]
Enum.each(expected, fn {schema, count} ->
  actual = Repo.aggregate(schema, :count)
  if actual != count, do: raise("unexpected #{inspect(schema)} count: #{actual}")
end)

Enum.each(Catalog.supported_leagues(), fn {code, _name} ->
  {:ok, league} = Catalog.get_league_by_code(code)
  {:ok, season} = Catalog.get_season(league.id, 2026, 2027)
  players = Catalog.list_players(%{league_id: league.id})
  positions = players |> Enum.map(& &1.position.code) |> Enum.sort()
  team_counts = players |> Enum.frequencies_by(& &1.team_id) |> Map.values() |> Enum.sort()
  if length(players) != 4 or positions != ["DEF", "FWD", "GK", "MID"] or team_counts != [2, 2],
    do: raise("invalid seeded coverage for #{code}")
  Enum.each(players, fn player ->
    if player.season_id != season.id or player.team.season_id != season.id or
         player.team.season.league_id != league.id,
      do: raise("invalid seeded relationship for #{player.id}")
  end)
end)

IO.puts("catalog visibility: PASS")
'
```

Expected: `catalog visibility: PASS`. Together with the focused tests, this proves:

- each supported league returns exactly four seed-owned players spanning GK, DEF, MID, and FWD;
- each of the ten seed-owned teams returns exactly two players;
- every player resolves to its expected team, season, league, and position;
- target totals remain exact while unrelated valid data may increase overall table totals.

## Regression gate

```sh
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test
```

Expected: all commands exit zero. Scope inspection must find no seed call from application startup, setup/Ecto aliases, migrations, releases, deployments, web routes, jobs, provider adapters, or Redis code.
