defmodule FootballMarket.Valuation.PositionAware.MixedTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, record: 3]
  import FootballMarket.PositionAwareCase
  alias FootballMarket.Valuation

  test "US2.1 US2.3 US2.5 mixed weights retain absent rules and known-zero group never dilutes" do
    f = fixture()
    forward = position()
    mid = position()
    {_, a} = record(f, "defender", %{goals: 1})
    {_, b} = record(f, "forward", %{goals: 1, position_id: forward.id})

    weights = %{
      goalkeeper: %{goals: -7},
      defender: %{goals: 1},
      midfielder: %{goals: 9},
      forward: %{goals: 4}
    }

    d = definition(weights)

    overrides = %{
      position_mapping: [
        {f.position.id, :defender},
        {forward.id, :forward},
        {mid.id, :midfielder}
      ]
    }

    r = calculate(f, d, %{goals: 2}, overrides)
    assert r.score == "2.500000"
    assert Enum.sort(Map.keys(Map.delete(r.prepared.scopes, :overall))) == [:defender, :forward]
    for g <- [:defender, :forward], do: assert(r.prepared.scopes[g].features.goals == "0.500000")
    assert r.prepared.scopes.defender.membership == [a.id]
    assert r.prepared.scopes.forward.membership == [b.id]
    assert map_size(r.descriptor.strategy.requirements) == 4
    {_, c} = record(f, "zero-midfielder", %{goals: 0, minutes_played: 0, position_id: mid.id})
    expanded = calculate(f, d, %{goals: 2}, overrides)
    assert expanded.score == r.score
    assert expanded.prepared.scopes.midfielder.features.goals == "0.000000"
    assert expanded.prepared.scopes.midfielder.membership == [c.id]
    assert length(expanded.prepared.facts) == 3

    assert Enum.flat_map(Map.delete(expanded.prepared.scopes, :overall), fn {_, s} ->
             s.membership
           end)
           |> Enum.sort() == Enum.sort([a.id, b.id, c.id])

    refute expanded.descriptor == r.descriptor
    assert {:ok, ^r} = Valuation.replay(r.descriptor, d)
  end

  test "US2.2 separate caps approve concentrated two versus split four" do
    f = fixture()
    p = position()
    record(f, "two-defender", %{goals: 2})
    record(f, "two-forward", %{goals: 2, position_id: p.id})
    d = definition(rules(%{goals: 2}))

    split =
      calculate(f, d, %{goals: 2}, %{
        position_mapping: [{f.position.id, :defender}, {p.id, :forward}]
      })

    assert split.score == "4.000000"

    for g <- [:defender, :forward],
        do: assert(split.prepared.scopes[g].features.goals == "1.000000")

    refute Map.has_key?(split.prepared.scopes, :goalkeeper)
    refute Map.has_key?(split.prepared.scopes, :midfielder)

    for g <- [:defender, :forward] do
      concentrated =
        calculate(f, d, %{goals: 2}, %{position_mapping: [{f.position.id, g}, {p.id, g}]})

      assert concentrated.score == "2.000000"
      assert concentrated.prepared.scopes[g].totals.goals == 4
      assert Map.keys(Map.delete(concentrated.prepared.scopes, :overall)) == [g]
    end
  end

  test "US2.4 explicit historical remap changes fresh score but original replay survives" do
    f = fixture()
    p = position()
    record(f, "historical-other", %{tackles: 1, goals: 0})
    record(f, "forward", %{goals: 1, position_id: p.id})

    d =
      definition(%{
        goalkeeper: %{goals: 0},
        defender: %{tackles: 2},
        midfielder: %{goals: 0},
        forward: %{goals: 4}
      })

    old =
      calculate(f, d, %{goals: 2, tackles: 2}, %{
        position_mapping: [{f.position.id, :defender}, {p.id, :forward}]
      })

    assert old.score == "3.000000"

    fresh =
      calculate(f, d, %{goals: 2, tackles: 2}, %{
        position_mapping: [{f.position.id, :forward}, {p.id, :forward}]
      })

    assert fresh.score == "2.000000"
    assert fresh.prepared.scopes.forward.features.goals == "0.500000"
    refute fresh.descriptor == old.descriptor
    assert {:ok, ^old} = Valuation.replay(old.descriptor, d)
  end
end
