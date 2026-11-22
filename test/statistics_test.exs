defmodule FootballMarket.StatisticsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Statistics

  test "records immutable matches and performances and computes season summary" do
    fixture = create_catalog_fixture!()
    kickoff = ~U[2026-10-01 18:00:00.000000Z]

    assert {:ok, match} =
             Statistics.record_match(%{
               season_id: fixture.season.id,
               home_team_id: fixture.home_team.id,
               away_team_id: fixture.away_team.id,
               match_identity: "PL-2026-MD1-ARS-LIV",
               kickoff_at: kickoff
             })

    assert {:ok, fetched} = Statistics.get_match(fixture.season.id, "pl-2026-md1-ars-liv")
    assert fetched.id == match.id
    assert {:error, :immutable} = Statistics.update_match(match.id, %{})
    assert {:error, :immutable} = Statistics.delete_match(match.id)

    assert {:ok, perf} =
             Statistics.record_performance(%{
               match_id: match.id,
               player_id: fixture.player.id,
               team_id: fixture.home_team.id,
               position_id: fixture.player.position_id,
               minutes_played: 90,
               goals: 2,
               assists: 1,
               shots_on_target: 4,
               tackles: 1,
               interceptions: 0,
               saves: 0,
               goals_conceded: 0,
               yellow_cards: 1,
               red_cards: 0
             })

    assert {:ok, loaded} = Statistics.get_performance(fixture.player.id, match.id)
    assert loaded.id == perf.id
    assert {:error, :immutable} = Statistics.update_performance(perf.id, %{})
    assert {:error, :immutable} = Statistics.delete_performance(perf.id)

    assert {:ok, [history_row]} = Statistics.list_player_history(fixture.player.id)
    assert history_row.id == loaded.id

    assert {:ok, summary} = Statistics.recorded_summary(fixture.player)
    assert summary.recorded_match_count == 1
    assert summary.minutes_played == 90
    assert summary.goals == 2
    assert summary.assists == 1
    assert summary.metric_coverage.goals.status == "complete"
  end

  test "records batches atomically and imports provider performances idempotently" do
    fixture = create_catalog_fixture!()
    kickoff = ~U[2026-10-05 19:00:00.000000Z]

    envelope = %{
      match: %{
        season_id: fixture.season.id,
        home_team_id: fixture.home_team.id,
        away_team_id: fixture.away_team.id,
        match_identity: "PL-2026-MD2",
        kickoff_at: kickoff
      },
      performances: [
        %{
          player_id: fixture.player.id,
          team_id: fixture.home_team.id,
          position_id: fixture.player.position_id,
          minutes_played: 80,
          goals: 1,
          assists: 0,
          yellow_cards: 0,
          red_cards: 0
        }
      ]
    }

    assert {:ok, first} =
             Statistics.import_performances(fixture.season.id, [envelope],
               provider: "fotmob-public-html",
               player_id: fixture.player.id
             )

    assert first.matches_added == 1
    assert first.performances_added == 1

    assert {:ok, second} =
             Statistics.import_performances(fixture.season.id, [envelope],
               provider: "fotmob-public-html",
               player_id: fixture.player.id
             )

    assert second.matches_added == 0
    assert second.performances_added == 0

    status = Statistics.Freshness.for_player(fixture.player)
    assert status.scope.player_id == fixture.player.id
    assert status.freshness == "never_checked"
  end
end
