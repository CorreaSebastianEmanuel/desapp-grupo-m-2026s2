defmodule FootballMarket.RankingTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Catalog, Market, Ranking}

  test "returns error when no active valuation configuration exists" do
    assert {:error, :no_active_configuration} = Ranking.read()
  end

  test "orders issued players by active strategy quote descending with deterministic tie-breaking" do
    _admin = create_admin!()
    fixture = create_catalog_fixture!()

    {:ok, player2} =
      Catalog.create_player(%{
        team_id: fixture.home_team.id,
        position_id: fixture.positions.fwd.id,
        catalog_identity: "pl-fwd-second",
        display_name: "Gabriel Martinelli"
      })

    {:ok, _} = Market.initialize_player(fixture.player.id)
    {:ok, _} = Market.initialize_player(player2.id)

    %{version: version, mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)

    # Player 1 gets lower score (1 goal), Player 2 gets higher score (3 goals)
    q1 = record_performance_and_quote!(fixture, mapping.id, %{goals: 1, assists: 0})

    q2 =
      record_performance_and_quote!(%{fixture | player: player2}, mapping.id, %{
        goals: 3,
        assists: 0
      })

    assert {:ok, %{configuration: cfg, entries: entries}} = Ranking.read()
    assert cfg.id == version.id
    assert length(entries) == 2

    [first, second] = entries
    assert first.position == 1
    assert first.player_id == player2.id
    assert first.quote_id == q2.quote.id

    assert second.position == 2
    assert second.player_id == fixture.player.id
    assert second.quote_id == q1.quote.id
  end
end
