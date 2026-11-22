defmodule FootballMarket.ValuationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Statistics, Valuation}
  alias FootballMarket.Valuation.Configurations

  test "evaluates balanced and position_aware strategies accurately with Decimal math" do
    fixture = create_catalog_fixture!()
    kickoff = ~U[2026-10-10 15:00:00.000000Z]

    {:ok, match} =
      Statistics.record_match(%{
        season_id: fixture.season.id,
        home_team_id: fixture.home_team.id,
        away_team_id: fixture.away_team.id,
        match_identity: "val-match-1",
        kickoff_at: kickoff
      })

    {:ok, _perf} =
      Statistics.record_performance(%{
        match_id: match.id,
        player_id: fixture.player.id,
        team_id: fixture.home_team.id,
        position_id: fixture.positions.fwd.id,
        minutes_played: 90,
        goals: 2,
        assists: 2,
        shots_on_target: 6,
        tackles: 0,
        interceptions: 0,
        saves: 0,
        goals_conceded: 0,
        yellow_cards: 0,
        red_cards: 0
      })

    {:ok, [balanced, pos_aware]} = Configurations.ensure_presets()

    window = %{
      season_id: fixture.season.id,
      week_start: DateTime.add(kickoff, -3600, :second),
      week_end: DateTime.add(kickoff, 3600, :second)
    }

    # Balanced: (2/2)*4 + (2/2)*3 = 7.000000
    assert {:ok, bal_eval} =
             Valuation.evaluate_player(fixture.player.id, window, {:version, balanced.id})

    assert Decimal.equal?(bal_eval.score, Decimal.new("7.000000"))

    # Position-aware forward: (2/2)*5 + (2/2)*3 + (6/6)*2 = 10.000000
    assert {:ok, pos_eval} =
             Valuation.evaluate_player(fixture.player.id, window, {:version, pos_aware.id})

    assert Decimal.equal?(pos_eval.score, Decimal.new("10.000000"))
  end

  test "enforces optimistic predecessor lock and admin authorization on strategy activation" do
    admin = create_admin!()
    investor = create_user!()
    _fixture = create_catalog_fixture!()

    assert {:error, :forbidden} = Configurations.inspect_for(actor_for(investor))

    assert {:ok, %{versions: [v1, v2], active_version_id: nil}} =
             Configurations.inspect_for(actor_for(admin))

    assert {:ok, %{version: active1}} = Configurations.activate_for(actor_for(admin), v1.id, nil)
    assert active1.id == v1.id

    # Stale predecessor rejected
    assert {:error, :predecessor_conflict} =
             Configurations.activate_for(actor_for(admin), v2.id, nil)

    # Valid transition succeeds
    assert {:ok, %{version: active2}} =
             Configurations.activate_for(actor_for(admin), v2.id, v1.id)

    assert active2.id == v2.id

    assert {:ok, history} = Configurations.history()
    assert length(history) == 2
  end
end
