defmodule FootballMarket.Valuation.Balanced.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog}
  alias FootballMarket.Valuation.{Balanced, Definition, Request, Preparation}

  defp definition(weights \\ %{goals: 2}),
    do: %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: weights}
    }

  test "descriptor binds complete inputs and old rules survive changes and late arrivals" do
    f = fixture()
    record(f, "original", %{goals: 1})
    req = request(f, %{references: %{goals: 2}})
    d = definition()
    assert {:ok, old} = Valuation.evaluate(req, d)
    assert old.score == "1.000000"
    assert {:ok, p} = Valuation.prepare(req)
    assert {:ok, ^old} = Valuation.score(p, d)
    assert {:ok, ^p} = Valuation.replay(p.descriptor, nil)
    descriptor = old.descriptor
    assert descriptor.request == p.request
    assert descriptor.facts == p.facts
    assert descriptor.scopes == p.scopes
    assert descriptor.rounding == "six-half-away-v1"
    assert descriptor.normalization == "weekly-count-reference-cap-v1"
    assert descriptor.strategy.strategy_id == "balanced"
    assert descriptor.strategy.version == "1"
    assert descriptor.strategy.requirements == %{overall: [:goals]}
    assert descriptor.strategy.config == FootballMarket.Valuation.Evidence.canonical(d.config)
    assert descriptor.score == old.score
    assert {:ok, changed} = Valuation.evaluate(req, definition(%{goals: 4}))
    assert changed.score == "2.000000"

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay(descriptor, definition(%{goals: 4}))

    record(f, "late", %{goals: 2})
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: position.id})

    assert {:ok, fresh} = Valuation.evaluate(req, d)
    assert fresh.score == "2.000000"
    assert length(fresh.prepared.facts) == 2

    for change <- [%{references: %{goals: 4}}, %{position_mapping: [{f.position.id, :forward}]}] do
      assert {:ok, changed} = Valuation.evaluate(Map.merge(req, change), d)
      refute changed.descriptor == descriptor
    end

    assert {:ok, ^old} = Valuation.replay(descriptor, d)

    for req_change <- [
          %{p.request | references: %{goals: 4}},
          %{p.request | position_mapping: [{f.position.id, :forward}]}
        ] do
      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(%{descriptor | request: req_change}, d)
    end
  end

  test "every successful arithmetic fixture retains its original score after late arrival" do
    f = fixture()
    record(f, "all-metrics", Map.new(Request.metrics(), &{&1, 1}))

    cases =
      Enum.map(Request.metrics(), &{%{&1 => 2}, %{&1 => 2}, "1.000000"}) ++
        [
          {%{goals: 3}, %{goals: 6}, "0.500001"},
          {%{goals: 0}, %{goals: 1}, "0.000000"},
          {%{red_cards: -2}, %{red_cards: 2}, "-1.000000"},
          {%{goals: 2, assists: 2}, %{goals: 1, assists: 1}, "4.000000"},
          {%{goals: Decimal.new("0.000001"), assists: Decimal.new("0.000001")},
           %{goals: 2, assists: 2}, "0.000001"},
          {%{goals: Decimal.new("-0.000001"), assists: Decimal.new("-0.000001")},
           %{goals: 2, assists: 2}, "-0.000001"},
          {%{goals: Decimal.new("0.000001")}, %{goals: 2}, "0.000001"},
          {%{goals: Decimal.new("-0.000001")}, %{goals: 2}, "-0.000001"},
          {%{goals: Decimal.new("-0.0000004")}, %{goals: 1}, "0.000000"},
          {%{
             goals: 1_000_000_000_000_000_000_000_000_000_001,
             assists: -1_000_000_000_000_000_000_000_000_000_000
           }, %{goals: 1, assists: 1}, "1.000000"}
        ]

    results =
      for {weights, refs, expected} <- cases do
        d = definition(weights)
        req = request(f, %{requirements: %{overall: Map.keys(weights)}, references: refs})
        assert {:ok, result} = Valuation.evaluate(req, d)
        assert result.score == expected
        {result, d}
      end

    record(f, "late", Map.new(Request.metrics(), &{&1, 2}))

    for {result, d} <- results,
        do: assert({:ok, result} == Valuation.replay(result.descriptor, d))
  end

  test "main, mixed-role saturation and known-zero examples replay after late facts" do
    f = fixture()
    record(f, "main", %{goals: 3, assists: 1, goals_conceded: 2, minutes_played: 0})

    req =
      request(f, %{
        requirements: %{overall: [:goals, :assists, :goals_conceded]},
        references: %{goals: 4, assists: 2, goals_conceded: 4}
      })

    d = definition(%{goals: 2, assists: 1, goals_conceded: -1})
    assert {:ok, main} = Valuation.evaluate(req, d)
    assert main.score == "1.500000"
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    record(f, "forward", %{goals: 2, assists: 0, goals_conceded: 0, position_id: position.id})

    mixed_req =
      request(f, %{
        references: %{goals: 2},
        position_mapping: [{f.position.id, :defender}, {position.id, :forward}]
      })

    assert {:ok, mixed} = Valuation.evaluate(mixed_req, definition())
    assert mixed.score == "2.000000"
    record(f, "zero", %{goals: 0, player_id: List.last(f.players).id, team_id: f.away.id})
    zero_req = request(f, %{player_id: List.last(f.players).id})
    assert {:ok, zero} = Valuation.evaluate(zero_req, definition())
    assert zero.score == "0.000000"
    record(f, "late", %{goals: 2, assists: 1, goals_conceded: 1})

    record(f, "late-zero-player", %{
      goals: 2,
      player_id: List.last(f.players).id,
      team_id: f.away.id
    })

    for {result, original} <- [{main, d}, {mixed, definition()}, {zero, definition()}] do
      assert {:ok, ^result} = Valuation.replay(result.descriptor, original)
    end
  end

  test "unsupported, unavailable, tampered facts and derived evidence never substitute" do
    f = fixture()
    record(f, "original", %{goals: 1})
    d = definition()
    assert {:ok, result} = Valuation.evaluate(request(f), d)
    p = result.prepared
    [row] = p.facts

    for change <- [
          %{d | version: "2"},
          %{d | strategy_id: "unknown"},
          %{d | module: UnavailableOriginal}
        ] do
      assert {:error, %{kind: :unsupported_strategy}} = Valuation.score(p, change)
      assert {:error, %{kind: :unavailable_replay}} = Valuation.replay(result.descriptor, change)
    end

    assert {:error, %{kind: :unavailable_replay}} = Valuation.replay(result.descriptor, nil)

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay(
               %{result.descriptor | facts: [%{row | match_id: Ecto.UUID.generate()}]},
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
      assert {:error, %{kind: kind}} =
               Valuation.replay(%{result.descriptor | facts: [altered]}, d)

      assert kind in [:inconsistent_replay, :unavailable_replay]
      assert {:error, _} = Valuation.score(%{p | facts: [altered]}, d)
    end

    scope = p.scopes.overall

    for descriptor <- [
          %{result.descriptor | facts: [row, row]},
          %{result.descriptor | facts: [row | :tail]},
          %{result.descriptor | facts: [[row | :tail]]},
          %{
            result.descriptor
            | scopes: %{
                p.scopes
                | overall: %{scope | membership: [row.performance_id, row.performance_id]}
              }
          },
          %{
            result.descriptor
            | scopes: %{p.scopes | overall: %{scope | membership: [row.performance_id | :tail]}}
          },
          %{
            result.descriptor
            | scopes: %{p.scopes | overall: %{scope | membership: [[row.performance_id | :tail]]}}
          },
          %{
            result.descriptor
            | scopes: %{p.scopes | overall: %{scope | features: %{goals: "0.999999"}}}
          },
          %{result.descriptor | score: "99.000000"},
          %{
            result.descriptor
            | strategy: %{result.descriptor.strategy | config: %{weights: %{goals: 4}}}
          },
          %{result.descriptor | strategy: %{result.descriptor.strategy | config: [1 | :tail]}},
          %{
            result.descriptor
            | strategy: %{result.descriptor.strategy | config: %{nested: [[1 | :tail]]}}
          }
        ] do
      assert {:error, %{kind: :inconsistent_replay}} = Valuation.replay(descriptor, d)
    end

    for field <- Map.keys(Map.from_struct(result.descriptor)) do
      assert {:error, _} = Valuation.replay(Map.delete(result.descriptor, field), d)
    end

    for field <- Map.keys(Map.from_struct(row)) do
      assert {:error, _} =
               Valuation.replay(%{result.descriptor | facts: [Map.delete(row, field)]}, d)
    end

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay(result.descriptor, %{d | config: %{weights: [{:goals, 2} | :tail]}})

    assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
  end

  test "24 fact and rule entry permutations produce identical canonical evidence" do
    f = fixture()
    for n <- 1..4, do: record(f, "permutation-#{n}", %{goals: n, assists: 5 - n, saves: 0})
    entries = [goals: Decimal.new("2.00"), assists: -1, saves: 0]

    req =
      request(f, %{
        requirements: %{overall: [:saves, :assists, :goals]},
        references: %{saves: 1, assists: 20, goals: 20}
      })

    d = definition(Map.new(entries))
    assert {:ok, result} = Valuation.evaluate(req, d)
    assert result.score == "0.500000"
    assert {:ok, canonical_request} = Request.validate(req)
    permutations = permutations(result.prepared.facts)
    assert length(permutations) == 24

    for {rows, n} <- Enum.with_index(permutations) do
      reordered = definition(Map.new(Enum.at(permutations(entries), rem(n, 6))))
      assert {:ok, p} = Preparation.build(canonical_request, rows)
      assert {:ok, ^result} = Valuation.score(p, reordered)
      assert {:ok, ^result} = Valuation.replay(result.descriptor, reordered)
    end
  end

  defp permutations([]), do: [[]]
  defp permutations(xs), do: for(x <- xs, rest <- permutations(xs -- [x]), do: [x | rest])
end
