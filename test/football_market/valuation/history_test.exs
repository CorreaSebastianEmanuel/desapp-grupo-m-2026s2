defmodule FootballMarket.Valuation.HistoryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog}

  test "half-open exact subject history, byte ordered ties, offsets and transfers" do
    f = fixture()
    record(f, "before", %{goals: 99}, "2026-10-04T23:59:59.999999Z")
    {_, a} = record(f, "Zulu", %{goals: 1, minutes_played: 90}, "2026-10-05T00:00:00Z")

    {_, b} =
      record(
        f,
        "alpha",
        %{goals: 2, minutes_played: 45, team_id: f.away.id},
        "2026-10-04T21:00:00-03:00"
      )

    record(f, "closing", %{goals: 99}, "2026-10-12T00:00:00Z")
    record(f, "other-player", %{goals: 99, player_id: List.last(f.players).id})
    record(f, "after", %{goals: 99}, "2026-10-12T00:00:00.000001Z")
    other = fixture("PL", 2026)
    record(other, "other-season", %{goals: 99})
    assert {:ok, p} = Valuation.prepare(request(f))
    assert Enum.map(p.facts, & &1.performance_id) == [a.id, b.id]
    assert p.scopes.overall.total_minutes == 135
    assert p.scopes.overall.totals.goals == 3
    assert p.scopes.overall.features.goals == "0.750000"
    assert Enum.map(p.facts, & &1.team_id) == [f.home.id, f.away.id]
    assert hd(p.facts).metrics.assists == nil
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: position.id})

    assert {:ok, ^p} = Valuation.prepare(request(f))

    assert {:ok, ^p} =
             Valuation.prepare(
               request(f, %{
                 week_start: "2026-10-04T21:00:00-03:00",
                 week_end: "2026-10-11T21:00:00-03:00"
               })
             )

    assert {:error, %{kind: :validation, reason: :missing_position_mapping}} =
             Valuation.prepare(request(f, %{position_mapping: []}))
  end
end
