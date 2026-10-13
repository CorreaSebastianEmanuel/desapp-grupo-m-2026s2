defmodule FootballMarket.Valuation.PositionAware.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, record: 3]
  import FootballMarket.PositionAwareCase
  alias FootballMarket.{Valuation, Catalog}
  alias FootballMarket.Valuation.{Request, Preparation, Evidence}

  test "US4.4 US4.5 descriptor binds full original rules and survives fresh changes and late arrivals" do
    f = fixture()
    record(f, "original", %{goals: 1})
    d = definition(rules(%{goals: 2}))
    overrides = %{position_mapping: [{f.position.id, :forward}]}
    old = calculate(f, d, %{goals: 2}, overrides)
    assert old.score == "1.000000"
    p = old.prepared
    descriptor = old.descriptor
    assert descriptor.request == p.request
    assert descriptor.facts == p.facts
    assert descriptor.scopes == p.scopes
    assert descriptor.request.references == %{goals: 2}
    assert descriptor.request.position_mapping == [{f.position.id, :forward}]
    assert descriptor.request.week_start == ~U[2026-10-05 00:00:00.000000Z]
    assert descriptor.request.week_end == ~U[2026-10-12 00:00:00.000000Z]
    assert descriptor.rounding == "six-half-away-v1"
    assert descriptor.normalization == "weekly-count-reference-cap-v1"
    assert descriptor.strategy.strategy_id == "position_aware"
    assert descriptor.strategy.version == "1"
    assert descriptor.strategy.requirements == Map.new(groups(), &{&1, [:goals]})
    assert descriptor.strategy.config == Evidence.canonical(d.config)
    assert descriptor.score == old.score
    refute Map.has_key?(p.scopes, :goalkeeper)
    assert p.scopes.forward.features.goals == "0.500000"
    assert {:ok, ^p} = Valuation.replay(p.descriptor, nil)

    for weights <- [rules(%{goals: 4}), Map.put(d.config.weights, :goalkeeper, %{goals: -9})] do
      changed = calculate(f, definition(weights), %{goals: 2}, overrides)
      refute changed.descriptor == descriptor
      if weights.forward.goals == 4, do: assert(changed.score == "2.000000")

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(descriptor, definition(weights))
    end

    for change <- [%{references: %{goals: 4}}, %{position_mapping: [{f.position.id, :defender}]}] do
      changed =
        calculate(
          f,
          d,
          Map.get(change, :references, %{goals: 2}),
          Map.merge(overrides, Map.delete(change, :references))
        )

      refute changed.descriptor == descriptor
      req = Map.merge(Map.from_struct(p.request), change)

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(%{descriptor | request: req}, d)
    end

    record(f, "late", %{goals: 2})
    new_position = position()

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: new_position.id})

    fresh = calculate(f, d, %{goals: 2}, overrides)
    assert fresh.score == "2.000000"
    assert length(fresh.prepared.facts) == 2
    assert {:ok, ^old} = Valuation.replay(descriptor, d)
  end

  test "US4.6 unsupported and unavailable originals are distinguishable from inconsistent evidence" do
    f = fixture()
    record(f, "original", %{goals: 1})
    d = definition(rules(%{goals: 2}))
    r = calculate(f, d, %{goals: 2})
    p = r.prepared
    [row] = p.facts

    for changed <- [
          %{d | version: "2"},
          %{d | strategy_id: "unknown"},
          %{d | module: UnavailableOriginal}
        ] do
      assert {:error, %{kind: :unsupported_strategy}} = Valuation.score(p, changed)
      assert {:error, %{kind: :unavailable_replay}} = Valuation.replay(r.descriptor, changed)
    end

    assert {:error, %{kind: :unavailable_replay}} = Valuation.replay(r.descriptor, nil)

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay(
               %{r.descriptor | facts: [%{row | match_id: Ecto.UUID.generate()}]},
               d
             )

    for altered <- [
          %{row | metrics: %{row.metrics | goals: 2}},
          %{row | minutes: 0},
          %{row | position_id: Ecto.UUID.generate()},
          %{row | group: :forward},
          %{row | kickoff: ~U[2026-10-12 00:00:00.000000Z]},
          %{row | team_id: f.away.id}
        ] do
      assert {:error, %{kind: kind}} = Valuation.replay(%{r.descriptor | facts: [altered]}, d)
      assert kind in [:inconsistent_replay, :unavailable_replay]
      assert {:error, _} = Valuation.score(%{p | facts: [altered]}, d)
    end

    scope = p.scopes.defender

    for descriptor <- [
          %{r.descriptor | facts: []},
          %{r.descriptor | facts: [row, row]},
          %{r.descriptor | facts: [row | :tail]},
          %{r.descriptor | facts: [[row | :tail]]},
          %{
            r.descriptor
            | scopes: %{
                p.scopes
                | defender: %{scope | membership: [row.performance_id, row.performance_id]}
              }
          },
          %{
            r.descriptor
            | scopes: %{p.scopes | defender: %{scope | membership: [row.performance_id | :tail]}}
          },
          %{
            r.descriptor
            | scopes: %{p.scopes | defender: %{scope | features: %{goals: "0.999999"}}}
          },
          %{r.descriptor | score: "99.000000"},
          %{r.descriptor | strategy: nil},
          %{
            r.descriptor
            | strategy: %{r.descriptor.strategy | config: %{weights: rules(%{goals: 4})}}
          },
          %{r.descriptor | strategy: %{r.descriptor.strategy | config: [1 | :tail]}},
          %{r.descriptor | strategy: %{r.descriptor.strategy | config: %{nested: [[1 | :tail]]}}}
        ] do
      assert {:error, %{kind: :inconsistent_replay}} = Valuation.replay(descriptor, d)
    end

    for field <- Map.keys(Map.from_struct(r.descriptor)) do
      assert {:error, _} = Valuation.replay(Map.delete(r.descriptor, field), d)
    end

    for field <- Map.keys(Map.from_struct(row)) do
      assert {:error, _} = Valuation.replay(%{r.descriptor | facts: [Map.delete(row, field)]}, d)
    end

    assert {:ok, ^r} = Valuation.replay(r.descriptor, d)
  end

  test "US4.6 coordinated raw and derived tampering fails before the score callback" do
    f = fixture()
    record(f, "original", %{goals: 1})
    d = definition(rules(%{goals: 2}))
    r = calculate(f, d, %{goals: 2})
    probe = %{d | module: __MODULE__.CallbackProbe}
    assert {:ok, ^r} = Valuation.score(r.prepared, probe)
    assert_receive :position_callback
    [row] = r.prepared.facts
    forged_row = %{row | metrics: %{row.metrics | goals: 2}}
    assert {:ok, forged} = Preparation.build(r.prepared.request, [forged_row])
    assert forged.scopes.defender.features.goals == "1.000000"
    assert {:error, %{kind: :inconsistent_replay}} = Valuation.score(forged, probe)
    refute_receive :position_callback
    forged_descriptor = %{forged.descriptor | strategy: r.descriptor.strategy, score: "2.000000"}
    assert {:error, %{kind: :inconsistent_replay}} = Valuation.replay(forged_descriptor, probe)
    refute_receive :position_callback
  end

  test "US4.7 24 multi-group multi-metric fact rule and mapping permutations are canonical" do
    old_provider = Application.fetch_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)

    on_exit(fn ->
      case old_provider do
        {:ok, config} -> Application.put_env(:football_market, FootballMarket.Providers, config)
        :error -> Application.delete_env(:football_market, FootballMarket.Providers)
      end
    end)

    f = fixture()
    p = position()

    for n <- 1..4 do
      record(f, "permutation-#{n}", %{
        goals: n,
        assists: 5 - n,
        position_id: if(rem(n, 2) == 0, do: p.id, else: f.position.id)
      })
    end

    entries = [goals: Decimal.new("2.00"), assists: -1]
    d = definition(rules(Map.new(entries)))
    mapping = [{f.position.id, :defender}, {p.id, :forward}]
    req = position_request(f, d, %{goals: 20, assists: 20}, %{position_mapping: mapping})
    result = calculate(f, d, %{goals: 20, assists: 20}, %{position_mapping: mapping})
    assert result.score == "0.500000"
    rows = permutations(result.prepared.facts)
    assert length(rows) == 24
    group_orders = permutations(groups())

    for {facts, n} <- Enum.with_index(rows) do
      metrics =
        Map.new(
          if(rem(n, 2) == 0,
            do: Enum.reverse(entries),
            else: [goals: Decimal.new("2"), assists: -1]
          )
        )

      reordered = definition(Map.new(Enum.at(group_orders, n), &{&1, metrics}))

      changed_req = %{
        req
        | requirements:
            Map.new(
              groups(),
              &{&1, if(rem(n, 2) == 0, do: [:assists, :goals], else: [:goals, :assists])}
            ),
          position_mapping: if(rem(n, 2) == 0, do: Enum.reverse(mapping), else: mapping)
      }

      assert {:ok, canonical} = Request.validate(changed_req)
      assert {:ok, prepared} = Preparation.build(canonical, facts)
      assert {:ok, ^result} = Valuation.score(prepared, reordered)
      assert {:ok, ^result} = Valuation.evaluate(changed_req, reordered)
      assert {:ok, ^result} = Valuation.replay(result.descriptor, reordered)
    end

    IO.puts("POSITION_PERMUTATIONS count=24")
  end
end
