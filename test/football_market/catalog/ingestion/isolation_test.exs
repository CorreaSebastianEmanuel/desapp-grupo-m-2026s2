defmodule FootballMarket.Catalog.Ingestion.IsolationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Catalog.Ingestion

  setup do
    positions!()
    :ok
  end

  test "accepted local reads stay available when a subsequent provider fails" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    [p] = Repo.all(Player)
    before = snapshot()

    assert {:error, _} =
             Ingestion.import_catalog(request(), options({:error, %{category: :unavailable}}))

    assert {:ok, detail} = Catalog.get_player_detail(p.id)
    assert detail.id == p.id
    assert snapshot() == before
  end

  test "local search filters details and historical/account baselines survive transfer and source outage" do
    f = FootballMarket.StatisticsCase.fixture("BL1", 2024)

    assert {:ok, match} =
             FootballMarket.Statistics.record_match(FootballMarket.StatisticsCase.match_attrs(f))

    assert {:ok, _} =
             FootballMarket.Statistics.record_performance(
               FootballMarket.StatisticsCase.performance_attrs(f, match)
             )

    assert {:ok, user} =
             FootballMarket.Accounts.register_user(
               FootballMarket.AccountsCase.registration_attrs()
             )

    assert {:ok, _} = FootballMarket.Accounts.issue_api_key(user.id)
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    original = snapshot()

    untouched =
      Map.take(
        original,
        ~w(users password_credentials api_keys matches player_match_performances)
      )

    c = candidate()
    transfer = %{c | facts: %{c.facts | players: [%{hd(c.facts.players) | team_ref: "team-b"}]}}

    assert {:ok, _} =
             Ingestion.import_catalog(
               request(),
               options(transfer, ~U[2026-10-07 12:00:00.000000Z])
             )

    assert Map.take(snapshot(), Map.keys(untouched)) == untouched
    assert Repo.get!(Player, hd(f.players).id).team_id == f.home.id
    original_config = Application.get_env(:football_market, FootballMarket.Providers)

    on_exit(fn ->
      if is_nil(original_config),
        do: Application.delete_env(:football_market, FootballMarket.Providers),
        else: Application.put_env(:football_market, FootballMarket.Providers, original_config)
    end)

    Application.put_env(:football_market, FootballMarket.Providers,
      provider: {FootballMarket.IngestionFixtureAdapter, {:notify, self(), candidate()}},
      positions: %{"GK" => "Goalkeeper"},
      runtime:
        {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-06 12:00:00.000000Z]}}
    )

    imported = Repo.one!(from p in Player, where: p.display_name == "Alex")

    assert [found] =
             Catalog.list_players(%{season_id: imported.season_id, team_id: imported.team_id})

    assert found.id == imported.id
    assert {:ok, detail} = Catalog.get_player_detail(imported.id)
    assert detail.team.code == "BET"
    refute_receive :source_called
  end

  test "selected offline scraper remains explicit and live access stays blocked" do
    alias FootballMarket.Providers.{Scraping, ScrapingFixtureData, FixtureRuntime}
    {:ok, _} = Catalog.create_position(%{code: "FW", name: "Forward"})
    c = ScrapingFixtureData.case!("catalog-PL-2024")
    opts = [provider: {Scraping, ScrapingFixtureData.state(c)}, runtime: {FixtureRuntime, %{}}]
    assert {:ok, outcome} = Ingestion.import_catalog(ScrapingFixtureData.request(c), opts)
    assert outcome.provider == "fotmob-shaped-offline"
    assert outcome.fixture_id == "catalog-PL-2024"
    expected = ScrapingFixtureData.expected_facts(c, %{"kind" => "catalog"})

    assert Enum.sort(Enum.map(Repo.all(Player), & &1.display_name)) ==
             Enum.sort(Enum.map(expected.players, & &1.display_name))

    before = {snapshot(), acceptance_snapshot()}

    assert {:error, blocked} =
             Ingestion.import_catalog(ScrapingFixtureData.request(c),
               provider: {Scraping, %{mode: :live}},
               runtime: {FixtureRuntime, %{}}
             )

    assert blocked.status == :provider_failure
    assert blocked.provider_error.category == :unsupported_capability
    assert {snapshot(), acceptance_snapshot()} == before
  end
end
