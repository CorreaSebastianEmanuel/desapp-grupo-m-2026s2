defmodule FootballMarketWeb.PlayerLiveTest do
  use FootballMarketWeb.LiveCase, async: false

  @moduletag :integration

  alias FootballMarket.Catalog

  setup %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    Map.put(catalog!(), :conn, conn)
  end

  describe "index" do
    test "lists players alphabetically with their affiliation", %{conn: conn} = fixture do
      {:ok, view, html} = live(conn, ~p"/players")

      assert html =~ "Showing 3 players"
      assert row_names(view) == ["Alpha Keeper", "Bravo Striker", "Carlo Portiere"]
      assert has_element?(view, "#players-#{fixture.alpha.id}", "Arsenal")
      assert has_element?(view, "#players-#{fixture.alpha.id}", "Premier League")
      assert has_element?(view, "#players-#{fixture.alpha.id}", "2026–27")
      assert has_element?(view, "#players-#{fixture.alpha.id}", "GK")
    end

    test "changing the league filter patches the URL and narrows teams",
         %{conn: conn} = fixture do
      {:ok, view, _html} = live(conn, ~p"/players")

      view
      |> form("#player-filters", filters: %{league_id: fixture.premier_league.id})
      |> render_change()

      assert_patch(view, ~p"/players?#{[league_id: fixture.premier_league.id]}")
      assert row_names(view) == ["Alpha Keeper", "Bravo Striker"]
      assert has_element?(view, ~s(select[name="filters[team_id]"] option), "Arsenal")
      refute has_element?(view, ~s(select[name="filters[team_id]"] option), "Milan")
    end

    test "filters from the URL compose", %{conn: conn} = fixture do
      query = [league_id: fixture.premier_league.id, position_id: fixture.goalkeeper.id]
      {:ok, view, _html} = live(conn, ~p"/players?#{query}")

      assert row_names(view) == ["Alpha Keeper"]
      assert has_element?(view, "#players-count", "Showing 1 player")
    end

    test "a team outside the newly selected league is dropped", %{conn: conn} = fixture do
      {:ok, view, _html} = live(conn, ~p"/players?#{[team_id: fixture.arsenal.id]}")

      view
      |> form("#player-filters",
        filters: %{league_id: fixture.serie_a.id, team_id: fixture.arsenal.id}
      )
      |> render_change()

      assert_patch(view, ~p"/players?#{[league_id: fixture.serie_a.id]}")
      assert row_names(view) == ["Carlo Portiere"]
    end

    test "malformed filter values are ignored", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/players?league_id=not-a-uuid&team_id=1")

      assert length(row_names(view)) == 3
      assert has_element?(view, "#clear-filters[disabled]")
    end

    test "unknown filter IDs show the empty state and can be cleared", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/players?#{[team_id: Ecto.UUID.generate()]}")

      assert has_element?(view, "#players-empty", "No players match these filters.")
      refute has_element?(view, "#load-more")

      view |> element("#clear-filters") |> render_click()
      assert_patch(view, ~p"/players")
      refute has_element?(view, "#players-empty")
    end

    test "loads further pages with the catalog cursor", %{conn: conn} = fixture do
      for index <- 1..30 do
        {:ok, _player} =
          Catalog.create_player(%{
            team_id: fixture.milan.id,
            position_id: fixture.forward.id,
            catalog_identity: "extra-#{index}",
            display_name: "Zeta #{String.pad_leading(to_string(index), 2, "0")}"
          })
      end

      {:ok, view, _html} = live(conn, ~p"/players")
      assert length(row_names(view)) == 25
      assert has_element?(view, "#players-count", "Showing 25 players")

      view |> element("#load-more") |> render_click()

      names = row_names(view)
      assert length(names) == 33
      assert List.last(names) == "Zeta 30"
      assert names == Enum.uniq(names)
      refute has_element?(view, "#load-more")
    end

    test "player names navigate to the detail page", %{conn: conn} = fixture do
      {:ok, view, _html} = live(conn, ~p"/players")

      assert {:ok, _show, html} =
               view
               |> element("#players-#{fixture.alpha.id} a")
               |> render_click()
               |> follow_redirect(conn, ~p"/players/#{fixture.alpha.id}")

      assert html =~ "Alpha Keeper"
    end
  end

  describe "show" do
    test "renders the player detail and related catalog links", %{conn: conn} = fixture do
      {:ok, view, _html} = live(conn, ~p"/players/#{fixture.alpha.id}")

      assert has_element?(view, "#player-name", "Alpha Keeper")
      assert render(view) =~ "alpha-identity"
      assert render(view) =~ "Goalkeeper"

      assert has_element?(
               view,
               ~s(#related-team[href="#{~p"/players?#{[team_id: fixture.arsenal.id]}"}"])
             )

      assert has_element?(
               view,
               ~s(#related-league[href="#{~p"/players?#{[league_id: fixture.premier_league.id]}"}"])
             )
    end

    test "unknown or malformed IDs return to the catalog", %{conn: conn} do
      for id <- [Ecto.UUID.generate(), "not-a-uuid"] do
        assert {:error, {_kind, %{to: "/players", flash: %{"error" => "Player not found."}}}} =
                 live(conn, ~p"/players/#{id}")
      end
    end
  end

  defp row_names(view) do
    view
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#players tr td:first-child a")
    |> Enum.map(&(&1 |> LazyHTML.text() |> String.trim()))
  end

  defp catalog! do
    {:ok, premier_league} = Catalog.create_league(%{code: "PL", name: "Premier League"})
    {:ok, serie_a} = Catalog.create_league(%{code: "SA", name: "Serie A"})

    {:ok, pl_season} =
      Catalog.create_season(%{league_id: premier_league.id, start_year: 2026, end_year: 2027})

    {:ok, sa_season} =
      Catalog.create_season(%{league_id: serie_a.id, start_year: 2026, end_year: 2027})

    {:ok, arsenal} = Catalog.create_team(%{season_id: pl_season.id, code: "ARS", name: "Arsenal"})
    {:ok, milan} = Catalog.create_team(%{season_id: sa_season.id, code: "MIL", name: "Milan"})
    {:ok, goalkeeper} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})
    {:ok, forward} = Catalog.create_position(%{code: "FW", name: "Forward"})

    player = fn team, position, identity, name ->
      {:ok, player} =
        Catalog.create_player(%{
          team_id: team.id,
          position_id: position.id,
          catalog_identity: identity,
          display_name: name
        })

      player
    end

    %{
      premier_league: premier_league,
      serie_a: serie_a,
      arsenal: arsenal,
      milan: milan,
      goalkeeper: goalkeeper,
      forward: forward,
      alpha: player.(arsenal, goalkeeper, "alpha-identity", "Alpha Keeper"),
      bravo: player.(arsenal, forward, "bravo-identity", "Bravo Striker"),
      carlo: player.(milan, goalkeeper, "carlo-identity", "Carlo Portiere")
    }
  end
end
