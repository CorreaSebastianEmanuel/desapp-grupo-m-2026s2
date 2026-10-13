defmodule Task022FreshAcceptanceTest do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Definition, Descriptor, Request}
  import FootballMarket.ValuationCase

  defp definition do
    %Definition{module: FootballMarket.ValuationScorers.Restricted,
      strategy_id: "illustrative", version: "1",
      config: %{weights: %{overall: %{goals: 2}}, policy: :require_all}}
  end

  test "public weighted scores depend on counts, not recorded participation minutes" do
    f = fixture()
    other = List.last(f.players)
    record(f, "A1", %{goals: 1, minutes_played: 0})
    record(f, "A2", %{goals: 2, minutes_played: 0})
    record(f, "B1", %{player_id: other.id, goals: 1, minutes_played: 90})
    record(f, "B2", %{player_id: other.id, goals: 2, minutes_played: 45})
    assert {:ok, zero} = Valuation.evaluate(request(f), definition())
    assert {:ok, positive} = Valuation.evaluate(request(f, %{player_id: other.id}), definition())
    assert zero.score == "1.500000"
    assert positive.score == zero.score
    assert zero.prepared.scopes.overall.features == positive.prepared.scopes.overall.features
    assert zero.prepared.scopes.overall.total_minutes == 0
    assert positive.prepared.scopes.overall.total_minutes == 135
    assert {:ok, ^zero} = Valuation.replay(zero.descriptor, definition())
    assert {:ok, ^positive} = Valuation.replay(positive.descriptor, definition())
  end

  test "malformed structures across all public entrypoints yield only ordinary no-score errors" do
    f = fixture()
    record(f, "valid", %{goals: 1})
    base = request(f)
    d = definition()
    assert {:ok, good} = Valuation.evaluate(base, d)
    invalid = [nil, false, 1.25, self(), fn -> :value end, [1 | :bad], %Decimal{sign: 1, coef: 1, exp: nil}]
    for field <- Map.keys(base), value <- invalid do
      assert {:error, %{kind: kind}} = Valuation.prepare(Map.put(base, field, value))
      assert kind == :validation
    end
    for field <- [:module, :strategy_id, :version, :config], value <- invalid do
      altered = Map.put(d, field, value)
      assert {:error, _} = Valuation.evaluate(base, altered)
      assert {:error, _} = Valuation.score(good.prepared, altered)
    end
    for field <- Map.keys(Map.from_struct(good.descriptor)), value <- invalid do
      assert {:error, _} = Valuation.replay(Map.put(good.descriptor, field, value), d)
    end
    for field <- Map.keys(Map.from_struct(good.prepared)), value <- invalid do
      assert {:error, _} = Valuation.score(Map.put(good.prepared, field, value), d)
    end
    [fact] = good.prepared.facts
    for field <- Map.keys(Map.from_struct(fact)), value <- invalid do
      altered = Map.put(fact, field, value)
      assert {:error, _} = Valuation.replay(%{good.descriptor | facts: [altered]}, d)
    end
    scope = good.prepared.scopes.overall
    for field <- Map.keys(Map.from_struct(scope)), value <- invalid do
      scopes = %{overall: Map.put(scope, field, value)}
      assert {:error, _} = Valuation.replay(%{good.descriptor | scopes: scopes}, d)
      assert {:error, _} = Valuation.score(%{good.prepared | scopes: scopes}, d)
    end
    for field <- Map.keys(Map.from_struct(%Request{})) do
      assert {:error, _} = Valuation.prepare(Map.delete(struct!(Request, base), field))
    end
    for field <- Map.keys(Map.from_struct(d)) do
      assert {:error, _} = Valuation.evaluate(base, Map.delete(d, field))
    end
    assert {:error, _} = Valuation.replay(%Descriptor{request: base, facts: [fact | :bad]}, nil)
    assert {:ok, ^good} = Valuation.replay(good.descriptor, d)
  end
end
