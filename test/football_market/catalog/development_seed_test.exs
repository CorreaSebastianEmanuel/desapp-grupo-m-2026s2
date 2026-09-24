defmodule FootballMarket.Catalog.DevelopmentSeedTest do
  use FootballMarket.DataCase, async: false

  alias FootballMarket.Catalog.DevelopmentSeed
  alias FootballMarket.Catalog.DevelopmentSeed.Manifest
  alias FootballMarket.{Catalog, Repo}
  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}

  describe "manifest" do
    test "defines the exact stable demonstration catalog" do
      manifest = Manifest.definition()

      assert Enum.map(manifest.leagues, &{&1.code, &1.name}) == [
               {"PL", "Premier League"},
               {"BL1", "Bundesliga"},
               {"PD", "La Liga"},
               {"SA", "Serie A"},
               {"FL1", "Ligue 1"}
             ]

      assert length(manifest.seasons) == 5
      assert length(manifest.teams) == 10

      assert Enum.map(manifest.positions, &{&1.code, &1.name}) ==
               [
                 {"GK", "Goalkeeper"},
                 {"DEF", "Defender"},
                 {"MID", "Midfielder"},
                 {"FWD", "Forward"}
               ]

      assert length(manifest.players) == 20
      assert Enum.all?(manifest.seasons, &(&1.start_year == 2026 and &1.end_year == 2027))

      assert canonical_player_rows(manifest) == [
               {"BL1", "DEMO-BL1-A", "Demo BL1 Alpha FC", "DEF", "Demo BL1 Defender",
                "demo-2026-27-bl1-def"},
               {"BL1", "DEMO-BL1-A", "Demo BL1 Alpha FC", "GK", "Demo BL1 Goalkeeper",
                "demo-2026-27-bl1-gk"},
               {"BL1", "DEMO-BL1-B", "Demo BL1 Beta FC", "FWD", "Demo BL1 Forward",
                "demo-2026-27-bl1-fwd"},
               {"BL1", "DEMO-BL1-B", "Demo BL1 Beta FC", "MID", "Demo BL1 Midfielder",
                "demo-2026-27-bl1-mid"},
               {"FL1", "DEMO-FL1-A", "Demo FL1 Alpha FC", "DEF", "Demo FL1 Defender",
                "demo-2026-27-fl1-def"},
               {"FL1", "DEMO-FL1-A", "Demo FL1 Alpha FC", "GK", "Demo FL1 Goalkeeper",
                "demo-2026-27-fl1-gk"},
               {"FL1", "DEMO-FL1-B", "Demo FL1 Beta FC", "FWD", "Demo FL1 Forward",
                "demo-2026-27-fl1-fwd"},
               {"FL1", "DEMO-FL1-B", "Demo FL1 Beta FC", "MID", "Demo FL1 Midfielder",
                "demo-2026-27-fl1-mid"},
               {"PD", "DEMO-PD-A", "Demo PD Alpha FC", "DEF", "Demo PD Defender",
                "demo-2026-27-pd-def"},
               {"PD", "DEMO-PD-A", "Demo PD Alpha FC", "GK", "Demo PD Goalkeeper",
                "demo-2026-27-pd-gk"},
               {"PD", "DEMO-PD-B", "Demo PD Beta FC", "FWD", "Demo PD Forward",
                "demo-2026-27-pd-fwd"},
               {"PD", "DEMO-PD-B", "Demo PD Beta FC", "MID", "Demo PD Midfielder",
                "demo-2026-27-pd-mid"},
               {"PL", "DEMO-PL-A", "Demo PL Alpha FC", "DEF", "Demo PL Defender",
                "demo-2026-27-pl-def"},
               {"PL", "DEMO-PL-A", "Demo PL Alpha FC", "GK", "Demo PL Goalkeeper",
                "demo-2026-27-pl-gk"},
               {"PL", "DEMO-PL-B", "Demo PL Beta FC", "FWD", "Demo PL Forward",
                "demo-2026-27-pl-fwd"},
               {"PL", "DEMO-PL-B", "Demo PL Beta FC", "MID", "Demo PL Midfielder",
                "demo-2026-27-pl-mid"},
               {"SA", "DEMO-SA-A", "Demo SA Alpha FC", "DEF", "Demo SA Defender",
                "demo-2026-27-sa-def"},
               {"SA", "DEMO-SA-A", "Demo SA Alpha FC", "GK", "Demo SA Goalkeeper",
                "demo-2026-27-sa-gk"},
               {"SA", "DEMO-SA-B", "Demo SA Beta FC", "FWD", "Demo SA Forward",
                "demo-2026-27-sa-fwd"},
               {"SA", "DEMO-SA-B", "Demo SA Beta FC", "MID", "Demo SA Midfielder",
                "demo-2026-27-sa-mid"}
             ]

      for season <- manifest.seasons do
        teams = Enum.filter(manifest.teams, &(&1.season == season.key))
        players = Enum.filter(manifest.players, &(&1.season == season.key))

        assert length(teams) == 2
        assert length(players) == 4

        assert Enum.sort(Enum.map(players, & &1.position)) == [
                 :defender,
                 :forward,
                 :goalkeeper,
                 :midfielder
               ]

        assert Enum.all?(teams, fn team -> Enum.count(players, &(&1.team == team.key)) == 2 end)
      end

      assert Enum.all?(manifest.teams, fn team ->
               String.contains?(team.name, "Demo") and String.starts_with?(team.code, "D")
             end)

      assert Enum.all?(manifest.players, fn player ->
               String.contains?(player.display_name, "Demo") and
                 String.starts_with?(player.catalog_identity, "demo-")
             end)

      assert :ok = Manifest.validate(manifest)
    end

    test "rejects invalid definitions before persistence" do
      manifest = Manifest.definition()
      duplicate = hd(manifest.players)

      assert {:error, errors} =
               Manifest.validate(%{manifest | players: [duplicate | manifest.players]})

      assert :duplicate_player_identity in errors

      missing_team =
        update_in(manifest.players, fn [player | rest] ->
          [%{player | team: :missing_team} | rest]
        end)

      assert {:error, errors} = Manifest.validate(missing_team)
      assert :unknown_player_team in errors
    end

    test "rejects invalid per-season team and player distributions" do
      manifest = Manifest.definition()
      [first_season | _] = manifest.seasons
      last_team = List.last(manifest.teams)

      invalid_teams = %{
        manifest
        | teams: List.replace_at(manifest.teams, -1, %{last_team | season: first_season.key})
      }

      assert {:error, errors} = Manifest.validate(invalid_teams)
      assert :invalid_team_distribution in errors

      [first_player | remaining_players] = manifest.players
      target_team = Enum.find(manifest.teams, &(&1.season != first_player.season))

      invalid_players = %{
        manifest
        | players: [
            %{first_player | season: target_team.season, team: target_team.key}
            | remaining_players
          ]
      }

      assert {:error, errors} = Manifest.validate(invalid_players)
      assert :invalid_player_distribution in errors
    end

    test "rejects invalid per-team allocation and per-season position coverage" do
      manifest = Manifest.definition()
      [first_player | remaining_players] = manifest.players

      other_team =
        Enum.find(
          manifest.teams,
          &(&1.season == first_player.season and &1.key != first_player.team)
        )

      invalid_team_allocation = %{
        manifest
        | players: [%{first_player | team: other_team.key} | remaining_players]
      }

      assert {:error, errors} = Manifest.validate(invalid_team_allocation)
      assert :invalid_team_player_distribution in errors

      invalid_position_coverage = %{
        manifest
        | players: [%{first_player | position: :defender} | remaining_players]
      }

      assert {:error, errors} = Manifest.validate(invalid_position_coverage)
      assert :invalid_position_distribution in errors
    end

    test "rejects missing required fields and malformed records without raising" do
      manifest = Manifest.definition()

      required_fields = %{
        leagues: [:key, :code, :name],
        seasons: [:key, :league, :start_year, :end_year],
        teams: [:key, :season, :code, :name],
        positions: [:key, :code, :name],
        players: [:season, :team, :position, :catalog_identity, :display_name]
      }

      expected_errors = %{
        leagues: :invalid_league_structure,
        seasons: :invalid_season_structure,
        teams: :invalid_team_structure,
        positions: :invalid_position_structure,
        players: :invalid_player_structure
      }

      for {collection, fields} <- required_fields,
          invalid_record <- [
            :malformed | Enum.map(fields, &Map.delete(hd(manifest[collection]), &1))
          ] do
        invalid_manifest =
          Map.update!(manifest, collection, &List.replace_at(&1, 0, invalid_record))

        assert {:error, errors} = Manifest.validate(invalid_manifest)
        assert expected_errors[collection] in errors
      end
    end

    test "rejects malformed top-level collections without raising" do
      manifest = Manifest.definition()

      for collection <- [:leagues, :seasons, :teams, :positions, :players] do
        assert {:error, errors} = Manifest.validate(Map.put(manifest, collection, :malformed))
        assert [_ | _] = errors
      end
    end
  end

  describe "capability boundary" do
    test "direct calls are denied while the capability is disabled" do
      previous = Application.get_env(:football_market, :development_seed_enabled)
      Application.put_env(:football_market, :development_seed_enabled, false)

      on_exit(fn ->
        if is_nil(previous),
          do: Application.delete_env(:football_market, :development_seed_enabled),
          else: Application.put_env(:football_market, :development_seed_enabled, previous)
      end)

      assert {:error, %{category: :disabled, entity: :seed, identity: "development-seed"}} =
               DevelopmentSeed.run()
    end
  end

  describe "empty catalog" do
    test "creates the complete catalog and exposes it through public lookups" do
      assert {:ok,
              %{
                total: 44,
                created: 44,
                reused: 0,
                totals: %{leagues: 5, seasons: 5, teams: 10, positions: 4, players: 20}
              }} = DevelopmentSeed.run()

      assert Repo.aggregate(League, :count) == 5
      assert Repo.aggregate(Season, :count) == 5
      assert Repo.aggregate(Team, :count) == 10
      assert Repo.aggregate(Position, :count) == 4
      assert Repo.aggregate(Player, :count) == 20

      manifest = Manifest.definition()

      for league_definition <- manifest.leagues do
        assert {:ok, league} = Catalog.get_league_by_code(league_definition.code)
        assert league.name == league_definition.name

        assert {:ok, season} = Catalog.get_season(league.id, 2026, 2027)
        players = Catalog.list_players(%{league_id: league.id})
        assert length(players) == 4
        assert Enum.sort(Enum.map(players, & &1.position.code)) == ["DEF", "FWD", "GK", "MID"]

        target_teams =
          Enum.filter(manifest.teams, &(&1.season == season_key(manifest, league_definition.key)))

        for target_team <- target_teams do
          assert {:ok, team} = Catalog.get_team_by_code(season.id, target_team.code)
          assert length(Catalog.list_players(%{team_id: team.id})) == 2
        end
      end

      for position_definition <- manifest.positions do
        assert {:ok, position} = Catalog.get_position_by_code(position_definition.code)
        assert length(Catalog.list_players(%{position_id: position.id})) == 5
      end
    end

    test "does not depend on Redis, a provider, or network access" do
      previous = Application.get_env(:football_market, :redis)
      Application.put_env(:football_market, :redis, host: "invalid.example", port: 1)
      on_exit(fn -> Application.put_env(:football_market, :redis, previous) end)

      assert {:ok, %{total: 44}} = DevelopmentSeed.run()
    end
  end

  describe "repeat and partial convergence" do
    test "a second run reuses every record without changing identities, values, or timestamps" do
      assert {:ok, %{created: 44, reused: 0}} = DevelopmentSeed.run()
      before = catalog_snapshot()

      assert {:ok, %{created: 0, reused: 44}} = DevelopmentSeed.run()
      assert catalog_snapshot() == before
    end

    test "a matching partial hierarchy is reused and only missing descendants are created" do
      manifest = Manifest.definition()
      league_definition = hd(manifest.leagues)
      season_definition = hd(manifest.seasons)
      team_definition = hd(manifest.teams)
      position_definition = hd(manifest.positions)
      player_definition = hd(manifest.players)

      assert {:ok, league} =
               Catalog.create_league(%{
                 code: league_definition.code,
                 name: league_definition.name
               })

      assert {:ok, season} =
               Catalog.create_season(%{
                 league_id: league.id,
                 start_year: season_definition.start_year,
                 end_year: season_definition.end_year
               })

      assert {:ok, team} =
               Catalog.create_team(%{
                 season_id: season.id,
                 code: team_definition.code,
                 name: team_definition.name
               })

      assert {:ok, position} =
               Catalog.create_position(%{
                 code: position_definition.code,
                 name: position_definition.name
               })

      assert {:ok, player} =
               Catalog.create_player(%{
                 team_id: team.id,
                 position_id: position.id,
                 catalog_identity: player_definition.catalog_identity,
                 display_name: player_definition.display_name
               })

      identities = [league.id, season.id, team.id, position.id, player.id]

      assert {:ok, %{created: 39, reused: 5}} = DevelopmentSeed.run()

      assert Enum.all?(
               [League, Season, Team, Position, Player]
               |> Enum.zip(identities),
               fn {schema, id} -> Repo.get(schema, id) != nil end
             )
    end

    test "normalized-equivalent identities are reused verbatim" do
      manifest = Manifest.definition()
      season_definition = hd(manifest.seasons)
      player_definition = hd(manifest.players)
      now = DateTime.utc_now(:microsecond)

      league_id = Ecto.UUID.generate()
      season_id = Ecto.UUID.generate()
      team_id = Ecto.UUID.generate()
      position_id = Ecto.UUID.generate()
      player_id = Ecto.UUID.generate()

      Repo.insert_all(League, [
        %{
          id: league_id,
          code: " pl ",
          name: " premier league ",
          inserted_at: now,
          updated_at: now
        }
      ])

      Repo.insert_all(Season, [
        %{
          id: season_id,
          league_id: league_id,
          start_year: season_definition.start_year,
          end_year: season_definition.end_year,
          inserted_at: now,
          updated_at: now
        }
      ])

      Repo.insert_all(Team, [
        %{
          id: team_id,
          season_id: season_id,
          code: " demo-pl-a ",
          name: " demo pl alpha fc ",
          inserted_at: now,
          updated_at: now
        }
      ])

      Repo.insert_all(Position, [
        %{
          id: position_id,
          code: " gk ",
          name: " goalkeeper ",
          inserted_at: now,
          updated_at: now
        }
      ])

      Repo.insert_all(Player, [
        %{
          id: player_id,
          season_id: season_id,
          team_id: team_id,
          position_id: position_id,
          catalog_identity: " DEMO-2026-27-PL-GK ",
          display_name: player_definition.display_name,
          inserted_at: now,
          updated_at: now
        }
      ])

      before = catalog_snapshot()
      assert {:ok, %{created: 39, reused: 5}} = DevelopmentSeed.run()

      after_run = catalog_snapshot()

      for {schema, id} <- [
            {League, league_id},
            {Season, season_id},
            {Team, team_id},
            {Position, position_id},
            {Player, player_id}
          ] do
        assert snapshot_record(after_run, schema, id) == snapshot_record(before, schema, id)
      end

      assert Repo.get!(League, league_id).code == " pl "
      assert Repo.get!(Team, team_id).name == " demo pl alpha fc "
      assert Repo.get!(Position, position_id).code == " gk "
      assert Repo.get!(Player, player_id).catalog_identity == " DEMO-2026-27-PL-GK "
    end
  end

  describe "preservation, conflicts, and rollback" do
    test "unrelated valid catalog data remains unchanged" do
      assert {:ok, _summary} = DevelopmentSeed.run()
      {:ok, league} = Catalog.get_league_by_code("PL")

      {:ok, season} =
        Catalog.create_season(%{league_id: league.id, start_year: 2025, end_year: 2026})

      {:ok, team} =
        Catalog.create_team(%{season_id: season.id, code: "LOCAL", name: "Local Developer Club"})

      {:ok, position} = Catalog.create_position(%{code: "LOCAL", name: "Local Role"})

      {:ok, player} =
        Catalog.create_player(%{
          team_id: team.id,
          position_id: position.id,
          catalog_identity: "local-player",
          display_name: "Local Player"
        })

      before = catalog_snapshot()
      assert {:ok, %{created: 0, reused: 44}} = DevelopmentSeed.run()
      after_run = catalog_snapshot()

      for {schema, id} <- [
            {Season, season.id},
            {Team, team.id},
            {Position, position.id},
            {Player, player.id}
          ] do
        assert snapshot_record(after_run, schema, id) == snapshot_record(before, schema, id)
      end
    end

    test "partial and split alternate league identities fail without changes" do
      now = DateTime.utc_now(:microsecond)

      Repo.insert_all(League, [
        %{
          id: Ecto.UUID.generate(),
          code: "PL",
          name: "Demo Wrong League",
          inserted_at: now,
          updated_at: now
        },
        %{
          id: Ecto.UUID.generate(),
          code: "SA",
          name: "Premier League",
          inserted_at: now,
          updated_at: now
        }
      ])

      before = catalog_snapshot()

      assert {:error,
              %{category: :conflict, entity: :league, identity: "PL", cause: :alternate_identity}} =
               DevelopmentSeed.run()

      assert catalog_snapshot() == before
    end

    test "a target team under the wrong season is a relationship conflict and rolls back" do
      manifest = Manifest.definition()
      league_definition = hd(manifest.leagues)
      team_definition = hd(manifest.teams)

      {:ok, league} =
        Catalog.create_league(%{code: league_definition.code, name: league_definition.name})

      {:ok, wrong_season} =
        Catalog.create_season(%{league_id: league.id, start_year: 2025, end_year: 2026})

      {:ok, _team} =
        Catalog.create_team(%{
          season_id: wrong_season.id,
          code: team_definition.code,
          name: team_definition.name
        })

      before = catalog_snapshot()

      assert {:error,
              %{
                category: :conflict,
                entity: :team,
                identity: "PL:2026-2027:DEMO-PL-A",
                cause: :misplaced_relationship
              }} = DevelopmentSeed.run()

      assert catalog_snapshot() == before
    end

    test "an exact player-name mismatch reports an attribute conflict and rolls back" do
      assert {:ok, _summary} = DevelopmentSeed.run()
      player_definition = hd(Manifest.definition().players)
      {:ok, league} = Catalog.get_league_by_code("PL")
      {:ok, season} = Catalog.get_season(league.id, 2026, 2027)
      {:ok, player} = Catalog.get_player(season.id, player_definition.catalog_identity)

      Repo.update_all(from(p in Player, where: p.id == ^player.id),
        set: [display_name: "Conflicting Local Name"]
      )

      before = catalog_snapshot()

      assert {:error,
              %{
                category: :conflict,
                entity: :player,
                identity: "demo-2026-27-pl-gk",
                cause: :attribute_mismatch
              }} = DevelopmentSeed.run()

      assert catalog_snapshot() == before
    end

    test "a player assigned to the wrong canonical position reports a relationship conflict" do
      assert {:ok, _summary} = DevelopmentSeed.run()
      {:ok, season} = Catalog.get_season(Repo.get_by!(League, code: "PL").id, 2026, 2027)
      {:ok, player} = Catalog.get_player(season.id, "demo-2026-27-pl-gk")
      {:ok, wrong_position} = Catalog.get_position_by_code("FWD")

      Repo.update_all(from(p in Player, where: p.id == ^player.id),
        set: [position_id: wrong_position.id]
      )

      before = catalog_snapshot()

      assert {:error,
              %{
                category: :conflict,
                entity: :player,
                identity: "demo-2026-27-pl-gk",
                cause: :relationship_mismatch
              }} = DevelopmentSeed.run()

      assert catalog_snapshot() == before
    end

    test "a named late database failure returns a typed error and rolls back all inserts" do
      Ecto.Adapters.SQL.query!(Repo, """
      CREATE FUNCTION reject_last_demo_player() RETURNS trigger AS $$
      BEGIN
        IF NEW.catalog_identity = 'demo-2026-27-fl1-fwd' THEN
          RAISE EXCEPTION 'sentinel raw database failure';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """)

      Ecto.Adapters.SQL.query!(Repo, """
      CREATE TRIGGER reject_last_demo_player
      BEFORE INSERT ON players
      FOR EACH ROW EXECUTE FUNCTION reject_last_demo_player();
      """)

      assert {:error,
              %{
                category: :persistence,
                entity: :player,
                identity: "demo-2026-27-fl1-fwd",
                cause: :database
              }} = DevelopmentSeed.run()

      assert Repo.aggregate(League, :count) == 0
      assert Repo.aggregate(Season, :count) == 0
      assert Repo.aggregate(Team, :count) == 0
      assert Repo.aggregate(Position, :count) == 0
      assert Repo.aggregate(Player, :count) == 0
    end
  end

  defp season_key(manifest, league_key) do
    manifest.seasons |> Enum.find(&(&1.league == league_key)) |> Map.fetch!(:key)
  end

  defp canonical_player_rows(manifest) do
    manifest.players
    |> Enum.map(fn player ->
      season = Enum.find(manifest.seasons, &(&1.key == player.season))
      league = Enum.find(manifest.leagues, &(&1.key == season.league))
      team = Enum.find(manifest.teams, &(&1.key == player.team))
      position = Enum.find(manifest.positions, &(&1.key == player.position))

      {league.code, team.code, team.name, position.code, player.display_name,
       player.catalog_identity}
    end)
    |> Enum.sort()
  end

  defp catalog_snapshot do
    for schema <- [League, Season, Team, Position, Player], into: %{} do
      fields = schema.__schema__(:fields)
      {schema, schema |> Repo.all() |> Enum.map(&Map.take(&1, fields)) |> Enum.sort_by(& &1.id)}
    end
  end

  defp snapshot_record(snapshot, schema, id) do
    snapshot |> Map.fetch!(schema) |> Enum.find(&(&1.id == id))
  end
end

defmodule FootballMarket.Catalog.DevelopmentSeedRaceTest do
  use ExUnit.Case, async: false

  alias Ecto.Adapters.SQL.Sandbox
  alias FootballMarket.Catalog.DevelopmentSeed
  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}
  alias FootballMarket.Repo

  setup do
    owner = Sandbox.start_owner!(Repo, shared: false, sandbox: false)
    clear_catalog()

    on_exit(fn ->
      Sandbox.stop_owner(owner)
      Sandbox.unboxed_run(Repo, &clear_catalog/0)
    end)

    :ok
  end

  test "separate unsandboxed connections prevent duplicates and retry converges" do
    parent = self()

    racers =
      for _ <- 1..2 do
        Task.async(fn ->
          :ok = Sandbox.checkout(Repo, sandbox: false)
          send(parent, {:ready, self()})

          receive do
            :go -> :ok
          end

          result = DevelopmentSeed.run()
          :ok = Sandbox.checkin(Repo)
          result
        end)
      end

    ready =
      for _ <- racers,
          do:
            (
              assert_receive {:ready, pid}
              pid
            )

    Enum.each(ready, &send(&1, :go))
    results = Enum.map(racers, &Task.await(&1, 15_000))

    assert Enum.count(results, &match?({:ok, %{created: 44}}, &1)) == 1

    assert Enum.count(results, fn
             {:error, %{category: :persistence, cause: :concurrent_write}} -> true
             _ -> false
           end) == 1

    assert Repo.aggregate(League, :count) == 5
    assert Repo.aggregate(Season, :count) == 5
    assert Repo.aggregate(Team, :count) == 10
    assert Repo.aggregate(Position, :count) == 4
    assert Repo.aggregate(Player, :count) == 20

    assert {:ok, %{created: 0, reused: 44}} = DevelopmentSeed.run()
    clear_catalog()
  end

  defp clear_catalog do
    Repo.delete_all(Player)
    Repo.delete_all(Team)
    Repo.delete_all(Season)
    Repo.delete_all(Position)
    Repo.delete_all(League)
  end
end
