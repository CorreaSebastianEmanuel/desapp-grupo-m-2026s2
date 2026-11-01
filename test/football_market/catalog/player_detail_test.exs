defmodule FootballMarket.Catalog.PlayerDetailTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  import FootballMarket.CatalogCase

  test "loads authoritative hierarchy and collapses malformed and absent identities" do
    %{players: [player], league: league} = insert_catalog!()
    assert {:ok, loaded} = FootballMarket.Catalog.get_player_detail(player.id)
    assert loaded.team.season.league.id == league.id
    assert {:error, :not_found} = FootballMarket.Catalog.get_player_detail("malformed")
    assert {:error, :not_found} = FootballMarket.Catalog.get_player_detail(Ecto.UUID.generate())
  end

  test "recorded season totals preserve missing metrics and distinguish explicit zero" do
    f = FootballMarket.StatisticsCase.fixture()
    player = hd(f.players)
    assert {:ok, detail} = FootballMarket.Catalog.player_card(player.id)
    assert detail.statistics.recorded_match_count == 0
    assert detail.statistics.goals == nil
    assert detail.statistics.minutes_played == nil

    {:ok, match} =
      FootballMarket.Statistics.record_match(FootballMarket.StatisticsCase.match_attrs(f))

    {:ok, _} =
      FootballMarket.Statistics.record_performance(
        FootballMarket.StatisticsCase.performance_attrs(f, match, %{
          minutes_played: 90,
          goals: 0,
          assists: 1
        })
      )

    assert {:ok, detail} = FootballMarket.Catalog.player_card(player.id)
    assert detail.statistics.goals == 0
    assert detail.statistics.assists == 1
    assert detail.statistics.minutes_played == 90

    {:ok, match} =
      FootballMarket.Statistics.record_match(FootballMarket.StatisticsCase.match_attrs(f))

    {:ok, _} =
      FootballMarket.Statistics.record_performance(
        FootballMarket.StatisticsCase.performance_attrs(f, match, %{minutes_played: 30, goals: 2})
      )

    assert {:ok, detail} = FootballMarket.Catalog.player_card(player.id)
    assert detail.statistics.recorded_match_count == 2
    assert detail.statistics.minutes_played == 120
    assert detail.statistics.goals == 2
    assert detail.statistics.assists == nil
    assert detail.statistics.season_id == player.season_id
    assert detail.statistics.coverage == "recorded_local_facts"
    assert {:ok, other} = FootballMarket.Catalog.player_card(List.last(f.players).id)
    assert other.statistics.recorded_match_count == 0
  end
end
