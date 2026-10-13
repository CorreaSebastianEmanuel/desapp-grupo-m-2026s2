defmodule FootballMarket.Valuation.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog}
  alias FootballMarket.Valuation.Definition
  alias FootballMarket.ValuationScorers.Weighted

  defp definition(weight \\ 3),
    do: %Definition{
      module: Weighted,
      strategy_id: "illustrative",
      version: "1",
      config: %{weights: %{overall: %{goals: weight}}, policy: :require_all}
    }

  test "original membership survives late arrival, transfer and new effective rules" do
    f = fixture()
    record(f, "original", %{goals: 1})
    req = request(f, %{references: %{goals: 6}})
    d = definition()
    assert {:ok, old} = Valuation.evaluate(req, d)
    assert {:ok, original_prepared} = Valuation.replay(old.prepared.descriptor, nil)
    assert original_prepared == old.prepared
    record(f, "late", %{goals: 2})
    {:ok, new_position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: new_position.id})

    assert {:ok, ^old} = Valuation.replay(old.descriptor, d)
    assert {:ok, new} = Valuation.evaluate(req, d)
    assert new.score == "1.500000"
    assert length(new.prepared.facts) == 2
    refute new.descriptor == old.descriptor

    for {r, definition} <- [
          {%{req | references: %{goals: 4}}, d},
          {req, definition(2)},
          {%{req | position_mapping: [{f.position.id, :forward}]}, d},
          {req, %{d | module: FootballMarket.ValuationScorers.Version2, version: "2"}}
        ] do
      assert {:ok, fresh} = Valuation.evaluate(r, definition)
      refute fresh.descriptor == old.descriptor
      assert {:ok, ^old} = Valuation.replay(old.descriptor, d)
    end

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay(old.descriptor, definition(2))

    assert {:error, %{kind: :unavailable_replay}} = Valuation.replay(old.descriptor, nil)

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay(old.descriptor, %{d | module: UnavailableOriginal})
  end

  test "authoritative facts defeat coordinated raw and derived tampering and caller-mutated Prepared" do
    f = fixture()
    record(f, "original", %{goals: 1})
    assert {:ok, r} = Valuation.evaluate(request(f), definition())
    p = r.prepared
    [row] = p.facts

    for altered <- [
          %{row | metrics: %{row.metrics | goals: 2}},
          %{row | minutes: 0},
          %{row | position_id: Ecto.UUID.generate()},
          %{row | team_id: f.away.id},
          %{row | group: :forward},
          %{row | kickoff: ~U[2026-10-12 00:00:00.000000Z]},
          %{row | player_id: List.last(f.players).id},
          %{row | season_id: Ecto.UUID.generate()},
          %{row | match_identity: "changed"},
          %{row | home_team_id: f.away.id}
        ] do
      assert {:error, %{kind: kind}} =
               Valuation.replay(%{r.descriptor | facts: [altered]}, definition())

      assert kind in [:inconsistent_replay, :unavailable_replay]
      assert {:error, _} = Valuation.score(%{p | facts: [altered]}, definition())
    end

    scope = %{p.scopes.overall | totals: %{goals: 2}, features: %{goals: "0.500000"}}

    altered = %{
      r.descriptor
      | facts: [%{row | metrics: %{row.metrics | goals: 2}}],
        scopes: %{p.scopes | overall: scope},
        score: "1.500000"
    }

    assert {:error, %{kind: :inconsistent_replay}} = Valuation.replay(altered, definition())

    for descriptor <- [
          %{r.descriptor | facts: [row, row]},
          %{r.descriptor | facts: [row, %{row | performance_id: Ecto.UUID.generate()}]},
          %{r.descriptor | scopes: %{p.scopes | overall: scope}},
          %{r.descriptor | score: "99.000000"},
          %{r.descriptor | rounding: "different"},
          %{r.descriptor | normalization: "different"},
          %{r.descriptor | schema_version: 2},
          %{r.descriptor | facts: []}
        ] do
      assert {:error, _} = Valuation.replay(descriptor, definition())
    end

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay(
               %{r.descriptor | facts: [%{row | match_id: Ecto.UUID.generate()}]},
               definition()
             )

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.score(%{p | scopes: %{p.scopes | overall: scope}}, definition())

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.score(%{p | descriptor: %{p.descriptor | score: "1.000000"}}, definition())
  end

  test "deleted struct fields and malformed nested evidence fail ordinarily" do
    f = fixture()
    record(f, "original", %{goals: 1})
    {:ok, r} = Valuation.evaluate(request(f), definition())
    [row] = r.prepared.facts

    for field <- Map.keys(Map.from_struct(r.descriptor)) do
      assert {:error, _} = Valuation.replay(Map.delete(r.descriptor, field), definition())
    end

    for field <- Map.keys(Map.from_struct(r.prepared)) do
      assert {:error, _} = Valuation.score(Map.delete(r.prepared, field), definition())
    end

    for field <- Map.keys(Map.from_struct(row)) do
      assert {:error, _} =
               Valuation.replay(%{r.descriptor | facts: [Map.delete(row, field)]}, definition())
    end

    scope = %{r.prepared.scopes.overall | features: %{goals: Decimal.new("NaN")}}

    assert {:error, _} =
             Valuation.replay(%{r.descriptor | scopes: %{overall: scope}}, definition())

    assert {:error, _} =
             Valuation.replay(%{r.descriptor | facts: [%{row | metrics: nil}]}, definition())

    assert {:error, _} =
             Valuation.replay(
               %{r.descriptor | facts: [%{row | kickoff: "invalid"}]},
               definition()
             )
  end

  test "malformed public evidence is an ordinary no-score failure" do
    for value <- [nil, %{}, [], "bad"] do
      assert {:error, _} = Valuation.replay(value, nil)
      assert {:error, _} = Valuation.score(value, definition())
    end
  end

  test "public replay and score reject improper lists throughout retained evidence" do
    f = fixture()
    record(f, "original", %{goals: 1})
    assert {:ok, result} = Valuation.evaluate(request(f), definition())
    p = result.prepared
    [row] = p.facts

    for facts <- [[row | :invalid_tail], [[row | :invalid_tail]], [row, row | :invalid_tail]] do
      altered = %{p.descriptor | facts: facts}
      assert {:error, %{kind: :inconsistent_replay}} = Valuation.replay(altered, nil)

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.score(%{p | descriptor: altered}, definition())

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.score(%{p | facts: facts}, definition())
    end

    for membership <- [
          [row.performance_id | :invalid_tail],
          [[row.performance_id | :invalid_tail]]
        ] do
      scope = %{p.scopes.overall | membership: membership}
      scopes = %{p.scopes | overall: scope}

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(%{p.descriptor | scopes: scopes}, nil)

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.score(%{p | scopes: scopes}, definition())
    end

    for config <- [[1 | :invalid_tail], %{nested: [[1 | :invalid_tail]]}] do
      strategy = %{result.descriptor.strategy | config: config}

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(%{result.descriptor | strategy: strategy}, definition())
    end

    assert {:ok, ^result} = Valuation.replay(result.descriptor, definition())
  end
end
