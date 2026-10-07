defmodule FootballMarket.Providers.ScrapingIsolationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Catalog, CatalogCase, Providers, Repo, Statistics}
  alias Catalog.{League, Season, Team, Position, Player}
  alias Providers.{Scraping, ScrapingFixtureData}
  alias ScrapingFixtureData, as: Data

  defp snapshot do
    Enum.map(
      [League, Season, Team, Position, Player, Statistics.Match, Statistics.Performance],
      fn schema -> Repo.all(schema) |> Enum.sort_by(& &1.id) end
    )
  end

  defp reads(catalog, match) do
    [
      Catalog.list_players(),
      Catalog.get_league(catalog.league.id),
      Catalog.get_season(catalog.season.id),
      Enum.map(catalog.players, &Catalog.get_player_detail(&1.id)),
      Statistics.get_match(match.id),
      Enum.map(catalog.players, &Statistics.get_performance(&1.id, match.id))
    ]
  end

  test "every offline success/failure/deadline leaves exact persisted facts and local reads unchanged" do
    assert %{rows: [[1]]} = Ecto.Adapters.SQL.query!(Repo, "SELECT 1", [])

    {:ok, redis} =
      FootballMarket.Infrastructure.Redis.start_link(
        FootballMarket.Infrastructure.Configuration.redis()
      )

    assert {:ok, "PONG"} = Redix.command(redis, ["PING"])
    on_exit(fn -> if Process.alive?(redis), do: GenServer.stop(redis) end)
    catalog = CatalogCase.insert_catalog!(["Alex Example", "Alex Example"])
    home = catalog.team
    {:ok, away} = Catalog.create_team(CatalogCase.team_attrs(catalog.season))
    [player | _] = catalog.players
    position = catalog.position

    assert {:ok, match} =
             Statistics.record_match(%{
               match_identity: "synthetic-local-isolation",
               season_id: catalog.season.id,
               home_team_id: home.id,
               away_team_id: away.id,
               kickoff_at: ~U[2025-08-01 12:00:00.000000Z]
             })

    assert {:ok, _} =
             Statistics.record_performance(%{
               match_id: match.id,
               player_id: player.id,
               team_id: home.id,
               position_id: position.id,
               minutes_played: 90,
               goals: 0
             })

    state = snapshot()
    local = reads(catalog, match)
    original = Application.get_env(:football_market, Providers)

    on_exit(fn ->
      if is_nil(original),
        do: Application.delete_env(:football_market, Providers),
        else: Application.put_env(:football_market, Providers, original)
    end)

    Application.put_env(:football_market, Providers,
      provider: {Scraping, Data.state(Data.case!("catalog-PL-2024"))},
      positions: Data.positions()
    )

    for c <- Data.cases() do
      assert reads(catalog, match) == local
      refute_receive {:scraping_fetch, _, _}, 0
      Data.assert_case!(c)
      flush()
      assert snapshot() == state
      assert reads(catalog, match) == local
      refute_receive {:scraping_fetch, _, _}, 0
    end
  end

  defp flush do
    receive do
      {:scraping_fetch, _, _} -> flush()
    after
      0 -> :ok
    end
  end
end
