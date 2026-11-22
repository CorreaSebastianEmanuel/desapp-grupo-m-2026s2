defmodule FootballMarket.CatalogTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Catalog
  alias FootballMarket.Catalog.{DevelopmentSeed, Scouting}

  test "creates leagues, seasons, teams, positions, and players with integrity checks" do
    fixture = create_catalog_fixture!()

    assert {:ok, league} = Catalog.get_league_by_code("pl")
    assert league.id == fixture.league.id

    assert {:ok, player} = Catalog.get_player_detail(fixture.player.id)
    assert player.display_name == "Bukayo Saka"
    assert player.team.code == "ARS"
    assert player.position.code == "FWD"

    assert {:ok, updated} =
             Catalog.update_player(player, %{
               team_id: fixture.away_team.id,
               display_name: "B. Saka"
             })

    assert updated.team_id == fixture.away_team.id
    assert updated.display_name == "B. Saka"

    # Reject unsupported league code
    assert {:error, cs} = Catalog.create_league(%{code: "FAKE", name: "Fake League"})
    refute cs.valid?
  end

  test "paginates and filters players with opaque cursors and loads filter options" do
    fixture = create_catalog_fixture!()

    for name <- ["Alexis Mac Allister", "Cole Palmer", "Declan Rice"] do
      {:ok, _} =
        Catalog.create_player(%{
          team_id: fixture.home_team.id,
          position_id: fixture.positions.mid.id,
          catalog_identity: "id-#{System.unique_integer([:positive])}",
          display_name: name
        })
    end

    assert {:ok, page1} =
             Catalog.list_player_page(%{
               page_size: 2,
               filters: %{league_id: fixture.league.id}
             })

    assert length(page1.players) == 2
    assert page1.pagination.has_more
    assert is_binary(page1.pagination.next_cursor)

    assert {:ok, page2} =
             Catalog.list_player_page(%{
               page_size: 2,
               cursor: page1.pagination.next_cursor,
               filters: %{league_id: fixture.league.id}
             })

    assert length(page2.players) == 2
    refute page2.pagination.has_more

    assert {:ok, opts} = Catalog.filter_options()
    assert length(opts.leagues) == 1
    assert length(opts.teams) == 2
    assert length(opts.positions) == 4
  end

  test "seeds the fixed development catalog idempotently" do
    assert {:ok, first} = DevelopmentSeed.run()
    assert first.totals == %{leagues: 5, seasons: 5, teams: 10, positions: 4, players: 20}
    assert first.created == 44
    assert first.reused == 0

    assert {:ok, second} = DevelopmentSeed.run()
    assert second.created == 0
    assert second.reused == 44
  end

  test "imports external catalog snapshots idempotently and supports scouting misses" do
    snapshot = %{
      league_code: "PL",
      start_year: 2026,
      end_year: 2027,
      teams: [%{code: "MCI", name: "Manchester City"}],
      players: [
        %{
          team_code: "MCI",
          position_code: "FWD",
          catalog_identity: "fdo-9",
          display_name: "Erling Haaland"
        }
      ]
    }

    assert {:ok, summary} = Catalog.import_catalog(snapshot, provider: "football-data-org")
    assert summary.teams == 1
    assert summary.players == 1
    assert {:ok, summary2} = Catalog.import_catalog(snapshot, provider: "football-data-org")
    assert summary2.players == 1

    assert {:ok, [found]} = Catalog.search_local_players("Haaland")
    assert found.display_name == "Erling Haaland"

    # Scouting with no configured scopes returns :unavailable cleanly
    assert {:ok, [], %{state: :unavailable}} = Catalog.search_players("Unknown Player")
    assert {:ok, "Líonel Messi", "lionel messi"} = Scouting.normalize_name("  Líonel   Messi ")
  end
end
