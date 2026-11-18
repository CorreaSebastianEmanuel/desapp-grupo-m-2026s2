defmodule FootballMarketWeb.CatalogScoutingLiveTest do
  use FootballMarket.BrowserSessionCase

  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint FootballMarketWeb.Endpoint

  test "a catalog miss reports that scouting is unavailable when no trusted scope is configured" do
    user = account("catalog-scouting@example.com")
    {:ok, view, _html} = live(authenticated_conn(user), "/players")

    view
    |> form("#player-catalog-search", player_search: "Messi")
    |> render_submit()

    assert has_element?(
             view,
             "#catalog-scout-status[role=status]",
             "no hay fuentes configuradas"
           )

    assert has_element?(view, ".catalog-hint", "No encontramos jugadores")
  end

  test "catalog browsing combines name and labeled filters and retains page state through detail navigation" do
    fixture = FootballMarket.CatalogFilterCase.build!()
    user = account("catalog-parity@example.com")

    query =
      URI.encode_query(%{
        q: "Tie",
        league_id: fixture.target.team.season.league.id,
        team_id: fixture.target.team.id,
        position_id: fixture.target.position.id,
        page_size: 1
      })

    {:ok, view, _html} = live(authenticated_conn(user), "/players?#{query}")

    assert has_element?(view, "#catalog-league", fixture.target.team.season.league.name)
    assert has_element?(view, "#catalog-team", fixture.target.team.name)
    assert has_element?(view, "#catalog-position", fixture.target.position.name)
    assert has_element?(view, "#catalog-next")
    assert has_element?(view, "#player-search-results tbody tr")

    send(
      view.pid,
      {:catalog_scout_changed, FootballMarket.Catalog.Scouting.normalize_identity("Tie")}
    )

    refute has_element?(view, "#player-search-results tbody tr:nth-child(2)")

    next_html = view |> element("#catalog-next") |> render()
    assert next_html =~ "cursor="
    assert next_html =~ "league_id="
    assert next_html =~ "team_id="
    assert next_html =~ "position_id="
    assert next_html =~ "q=Tie"
    assert next_html =~ "page_size=1"

    href = Regex.run(~r/href="([^"]+)"/, next_html) |> Enum.at(1) |> String.replace("&amp;", "&")
    next_params = href |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()

    {:ok, next_view, _html} =
      live(authenticated_conn(user), "/players?" <> URI.encode_query(next_params))

    detail_link = render(element(next_view, "a[href^='/players?player_id=']"))
    assert detail_link =~ "cursor="
    assert detail_link =~ "league_id="
    assert detail_link =~ "team_id="
    assert detail_link =~ "position_id="
    assert detail_link =~ "q=Tie"

    {:ok, invalid_view, _html} = live(authenticated_conn(user), "/players?league_id=invalid")
    assert has_element?(invalid_view, "[role=alert]", "búsqueda no está disponible")
  end

  test "resetting catalog filters restores the unfiltered catalog and default page size" do
    fixture = FootballMarket.CatalogFilterCase.build!()
    user = account("catalog-reset@example.com")

    query =
      URI.encode_query(%{q: "Tie", league_id: fixture.target.team.season.league.id, page_size: 1})

    {:ok, view, _html} = live(authenticated_conn(user), "/players?#{query}")

    assert has_element?(view, "#catalog-reset", "Limpiar filtros")
    view |> element("#catalog-reset") |> render_click()
    assert_patch(view, "/players")
    assert has_element?(view, ~s(#player-search[value=""]))
    assert has_element?(view, ~s(#catalog-page-size option[value="25"][selected]))
    refute has_element?(view, ~s(#catalog-league option[selected]))
    refute has_element?(view, "#catalog-reset")
    assert has_element?(view, "h2", "Todos los jugadores")
    assert has_element?(view, "#player-search-results tbody tr")
  end

  test "known unverified players disappear from browsing and searching without scouting or deletion" do
    f = FootballMarket.FreshnessCase.fixture()
    failed = FootballMarket.FreshnessCase.fail!(f, "unsupported_capability")

    Repo.update!(
      Ecto.Changeset.change(failed,
        input: Map.put(failed.input, "player_id", f.player.id)
      )
    )

    {:ok, visible} =
      FootballMarket.Catalog.create_player(
        FootballMarket.CatalogCase.player_attrs(f.player.team, f.player.position, %{
          display_name: "Visible market player"
        })
      )

    user = account("catalog-visible@example.com")
    {:ok, view, _html} = live(authenticated_conn(user), "/players")
    assert has_element?(view, "#player-search-results a[href*='#{visible.id}']")
    refute has_element?(view, "#player-search-results a[href*='#{f.player.id}']")

    view
    |> form("#player-catalog-search", player_search: f.player.display_name)
    |> render_submit()

    refute has_element?(view, "#player-search-results a[href*='#{f.player.id}']")
    assert has_element?(view, ".catalog-hint", "No encontramos jugadores")
    assert Repo.aggregate(FootballMarket.Catalog.ScoutRun, :count) == 0
    assert {:ok, _} = FootballMarket.Catalog.get_player_detail(f.player.id)

    assert Enum.any?(
             FootballMarket.Catalog.list_players_for_statistics(),
             &(&1.id == f.player.id)
           )
  end

  test "HTTP access denial reaches the worker and card without hiding a player" do
    alias FootballMarket.{Catalog, FreshnessCase, Synchronization}
    alias FootballMarket.Statistics.Freshness
    alias FootballMarket.Synchronization.Run

    f = FreshnessCase.fixture()
    user = account("catalog-access-denial@example.com")

    for {code, category, visible?, label} <- [
          {401, "access_refused", true,
           "El acceso a la fuente no está autorizado o fue denegado"},
          {403, "access_refused", true,
           "El acceso a la fuente no está autorizado o fue denegado"},
          {200, "invalid_response", false, "La fuente devolvió evidencia inconsistente"}
        ] do
      source = %{
        f.source
        | provider: {FootballMarket.Providers.Scraping, access_response_state(f.player, code)},
          runtime: {FootballMarket.Providers.Runtime, nil}
      }

      config = Application.get_env(:football_market, Synchronization)

      Application.put_env(
        :football_market,
        Synchronization,
        Keyword.put(config, :sources, %{"freshness-fixture" => source})
      )

      status = Freshness.for_player(f.player)
      assert status.refresh.state == "queued"
      run = Repo.get!(Run, status.refresh.run_id)

      assert :ok =
               FootballMarket.Workers.StatisticsImport.perform(Repo.get!(Oban.Job, run.job_id))

      failed = Repo.get!(Run, run.id)
      assert failed.state == "failed"
      assert failed.outcome["status"] == "provider_failure"
      assert failed.outcome["category"] == category
      refute failed.outcome["retryable"]
      assert Repo.aggregate(FootballMarket.Statistics.Ingestion.ScopeCheck, :count) == 0
      assert Repo.aggregate(FootballMarket.Statistics.Performance, :count) == 0

      assert {:ok, page} =
               Catalog.list_market_player_page(%{
                 page_size: 10,
                 filters: %{search_name: f.player.display_name}
               })

      assert Enum.any?(page.players, &(&1.id == f.player.id)) == visible?

      {:ok, view, _html} =
        live(authenticated_conn(user), "/players?player_id=#{f.player.id}")

      assert has_element?(view, "#player-scraping-status", label)
    end
  end

  defp access_response_state(player, code) do
    alias FootballMarket.Providers.ScrapingFixtureData, as: Data
    assessment = Data.assessment(Map.put(Data.case!("performance-PL-2024"), "year", 2025))
    [{key, row}] = Map.to_list(assessment.scopes)
    documents = %{("player_search:" <> player.display_name) => "https://example.test/access"}

    %{
      mode: :live,
      assessment: %{
        assessment
        | mode: :live,
          destinations: ["https://example.test"],
          scopes: %{key => Map.put(row, :documents, documents)}
      },
      admission: :ets.new(:http_access_admission, [:public, :set]),
      http_start: fn _, _, receiver ->
        id = make_ref()
        send(receiver, {:http, {id, {~c"HTTP/1.1", code, ~c"Response"}, [], "invalid document"}})
        {:ok, id}
      end
    }
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end
