defmodule FootballMarket.Valuation.PositionAware.SelectionTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, fixture: 2, record: 4]
  import FootballMarket.PositionAwareCase
  alias FootballMarket.Valuation

  test "US5.1 stored kickoff selects half-open UTC week despite late arrival" do
    f = fixture()
    record(f, "before", %{goals: 99}, "2026-10-04T23:59:59.999999Z")
    {opening_match, opening} = record(f, "opening", %{goals: 1}, "2026-10-05T00:00:00Z")
    {_, ending} = record(f, "ending", %{goals: 1}, "2026-10-11T23:59:59.999999Z")
    record(f, "closing", %{goals: 99}, "2026-10-12T00:00:00Z")
    record(f, "after", %{goals: 99}, "2026-10-12T00:00:00.000001Z")
    d = definition(rules(%{goals: 2}))
    r = calculate(f, d, %{goals: 4})
    assert r.score == "1.000000"
    assert DateTime.compare(opening_match.inserted_at, opening_match.kickoff_at) == :gt
    assert hd(r.prepared.facts).kickoff == opening_match.kickoff_at
    assert r.prepared.scopes.defender.membership == [opening.id, ending.id]
    assert r.prepared.scopes.defender.totals.goals == 2

    assert {:ok, ^r} =
             Valuation.evaluate(
               position_request(f, d, %{goals: 4}, %{
                 week_start: "2026-10-04T21:00:00-03:00",
                 week_end: "2026-10-11T21:00:00-03:00"
               }),
               d
             )
  end

  test "US5.2 year crossing isolates exact player and season while retaining same-instant matches" do
    f = fixture()
    {_, a} = record(f, "Zulu", %{goals: 1}, "2026-12-28T00:00:00Z")
    {_, b} = record(f, "alpha", %{goals: 1}, "2026-12-27T21:00:00-03:00")

    record(
      f,
      "other-player",
      %{goals: 99, player_id: List.last(f.players).id, team_id: f.away.id},
      "2026-12-29T00:00:00Z"
    )

    record(f, "closing", %{goals: 99}, "2027-01-04T00:00:00Z")
    other = fixture("PD", 2024)
    record(other, "other-season", %{goals: 99}, "2026-12-29T00:00:00Z")
    d = definition(rules(%{goals: 2}))
    overrides = %{week_start: "2026-12-28T00:00:00Z", week_end: "2027-01-04T00:00:00Z"}
    r = calculate(f, d, %{goals: 4}, overrides)
    assert r.score == "1.000000"
    assert r.prepared.scopes.defender.membership == [a.id, b.id]
    assert r.prepared.scopes.defender.row_count == 2
    assert length(Enum.uniq(Enum.map(r.prepared.facts, & &1.match_id))) == 2

    assert Enum.all?(
             r.prepared.facts,
             &(&1.player_id == hd(f.players).id and &1.season_id == f.season.id)
           )

    assert {:error, %{kind: :validation, reason: :season_mismatch}} =
             Valuation.evaluate(
               position_request(
                 f,
                 d,
                 %{goals: 4},
                 Map.put(overrides, :season_id, other.season.id)
               ),
               d
             )
  end

  test "US5.3 every invalid week class fails without a current week default" do
    f = fixture()
    d = definition(rules(%{goals: 2}))

    for {a, b} <- [
          {nil, nil},
          {"bad", "bad"},
          {"2026-10-05T00:00:00", "2026-10-12T00:00:00Z"},
          {"2026-10-05T00:00:00.000001Z", "2026-10-12T00:00:00Z"},
          {"2026-10-05T00:00:00.0000001Z", "2026-10-12T00:00:00Z"},
          {"2026-10-06T00:00:00Z", "2026-10-13T00:00:00Z"},
          {"2026-10-05T00:00:00Z", "2026-10-05T00:00:00Z"},
          {"2026-10-12T00:00:00Z", "2026-10-05T00:00:00Z"},
          {"2026-10-05T00:00:00Z", "2026-10-19T00:00:00Z"}
        ] do
      req = position_request(f, d, %{goals: 2}, %{week_start: a, week_end: b})
      assert {:error, %{kind: :validation}} = Valuation.evaluate(req, d)
    end

    req = position_request(f, d, %{goals: 2})

    for key <- [:week_start, :week_end] do
      assert {:error, %{kind: :validation}} = Valuation.evaluate(Map.delete(req, key), d)
    end

    assert {:error, %{kind: :not_found}} =
             Valuation.evaluate(%{req | player_id: Ecto.UUID.generate()}, d)
  end

  test "US5.4 zero boundary and arbitrary-size accepted counts saturate without ceilings" do
    f = fixture()
    d = definition(rules(%{goals: 2}))

    for {count, a, b, feature, score} <- [
          {0, "2026-10-05", "2026-10-12", "0.000000", "0.000000"},
          {2, "2026-10-12", "2026-10-19", "1.000000", "2.000000"},
          {Integer.pow(10, 40), "2026-10-19", "2026-10-26", "1.000000", "2.000000"}
        ] do
      record(f, "count-#{a}", %{goals: count, minutes_played: 0}, a <> "T12:00:00Z")

      r =
        calculate(f, d, %{goals: 2}, %{week_start: a <> "T00:00:00Z", week_end: b <> "T00:00:00Z"})

      assert r.score == score
      assert r.prepared.scopes.defender.features.goals == feature
      assert r.prepared.scopes.defender.totals.goals == count
      assert r.prepared.scopes.defender.row_count == 1
    end
  end
end
