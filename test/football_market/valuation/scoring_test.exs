defmodule FootballMarket.Valuation.ScoringTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Definition, Prepared, FeatureView}
  alias FootballMarket.ValuationScorers, as: S

  defp definition(config, module \\ S.Weighted, version \\ "1"),
    do: %Definition{module: module, strategy_id: "illustrative", version: version, config: config}

  defp config(weights, policy \\ :require_all), do: %{weights: weights, policy: policy}

  test "signed weighted scores consume rounded features only, without clamp" do
    f = fixture()
    record(f, "first", %{goals: 1, goals_conceded: 2, minutes_played: 0})
    record(f, "second", %{goals: 2, goals_conceded: 0, minutes_played: 123})

    req =
      request(f, %{
        requirements: %{overall: [:goals, :goals_conceded]},
        references: %{goals: 4, goals_conceded: 4}
      })

    d = definition(config(%{overall: %{goals: 2, goals_conceded: -1}}))
    assert {:ok, result} = Valuation.evaluate(req, d)
    assert result.score == "1.000000"
    assert result.prepared.scopes.overall.features.goals_conceded == "0.500000"
    assert result.descriptor.strategy != nil
    assert result.descriptor.score == result.score

    assert {:ok, negative} =
             Valuation.evaluate(
               %{
                 req
                 | requirements: %{overall: [:goals_conceded]},
                   references: %{goals_conceded: 4}
               },
               definition(config(%{overall: %{goals_conceded: -2}}))
             )

    assert negative.score == "-1.000000"
    assert {:ok, _} = Valuation.evaluate(req, definition(d.config, S.Restricted))
    assert Map.keys(%FeatureView{}) |> Enum.sort() == [:__struct__, :features]
    assert %Prepared{} = result.prepared
  end

  test "feature-before-score rounding, signed ties and exact large sums under low precision" do
    f = fixture()
    record(f, "goal", %{goals: 1})

    for {ref, want} <- [{6, "0.500001"}, {128, "0.023439"}] do
      assert {:ok, result} =
               Valuation.evaluate(
                 request(f, %{references: %{goals: ref}}),
                 definition(config(%{overall: %{goals: 3}}))
               )

      assert result.score == want
    end

    for {weight, want} <- [
          {"1.2345674", "1.234567"},
          {"1.2345675", "1.234568"},
          {"-1.2345675", "-1.234568"},
          {"-0.0000004", "0.000000"}
        ] do
      assert {:ok, result} =
               Valuation.evaluate(
                 request(f, %{references: %{goals: 1}}),
                 definition(config(%{overall: %{goals: Decimal.new(weight)}}))
               )

      assert result.score == want
    end

    Decimal.Context.with(%Decimal.Context{precision: 2}, fn ->
      assert {:ok, r} =
               Valuation.evaluate(
                 request(f, %{references: %{goals: 1}}),
                 definition(
                   config(%{overall: %{goals: Decimal.new("12345678901234567890.1234567")}})
                 )
               )

      assert r.score == "12345678901234567890.123457"
    end)
  end

  test "explicit definition/config requirements validate before callback, failures stay ordinary" do
    f = fixture()
    record(f, "goal", %{goals: 1})
    req = request(f)
    base = definition(config(%{overall: %{goals: 1}}))

    for d <- [
          nil,
          %{},
          %{base | config: nil},
          %{base | config: %{weights: %{overall: %{goals: 1}}}},
          %{base | config: config(%{overall: %{goals: 1.0}})},
          %{base | config: config(%{overall: %{minutes: 1}}), module: S.MustNotScore},
          %{base | config: Map.put(base.config, :extra, 1)},
          %{base | config: config(%{overall: %{goals: true}})},
          %{base | config: config(%{overall: %{goals: Decimal.new("NaN")}})}
        ] do
      assert {:error, %{kind: :validation}} = Valuation.evaluate(req, d)
    end

    assert {:error, %{kind: :validation, reason: :definition_requirements_mismatch}} =
             Valuation.evaluate(
               req,
               definition(config(%{overall: %{assists: 1}}), S.MustNotScore)
             )

    assert {:error, %{kind: :unsupported_strategy}} =
             Valuation.evaluate(req, %{base | version: "unknown"})

    assert {:error, %{kind: :unsupported_strategy}} =
             Valuation.evaluate(req, %{base | module: MissingScorer})

    for module <- [
          S.Failure,
          S.Exception,
          S.IntegerResult,
          S.FloatResult,
          S.Nonfinite,
          S.MalformedDecimal,
          S.Infinity,
          S.Malformed
        ] do
      assert {:error, %{kind: :strategy_failure} = error} =
               Valuation.evaluate(req, %{base | module: module})

      refute inspect(error) =~ "private callback detail"
    end
  end

  test "absent scopes are governed by an explicit illustrative combination policy" do
    f = fixture()
    record(f, "defender", %{tackles: 2})

    req =
      request(f, %{
        requirements: %{defender: [:tackles], goalkeeper: [:saves]},
        references: %{tackles: 4, saves: 4}
      })

    weights = %{defender: %{tackles: 2}, goalkeeper: %{saves: 3}}

    assert {:error, %{kind: :strategy_failure, reason: :scorer_error}} =
             Valuation.evaluate(req, definition(config(weights)))

    assert {:ok, r} = Valuation.evaluate(req, definition(config(weights, :populated_only)))
    assert r.score == "1.000000"
    refute Map.has_key?(r.prepared.scopes, :goalkeeper)
  end
end
