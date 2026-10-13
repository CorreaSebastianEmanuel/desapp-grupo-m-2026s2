defmodule FootballMarket.Valuation.Configurations.CanonicalTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Valuation, ValuationCase, Catalog, CatalogCase}
  alias FootballMarket.Valuation.Configurations

  test "24 group/metric/mapping entry permutations produce identical complete evidence and distinct UUIDs" do
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1, assists: 1})
    {:ok, unused} = Catalog.create_position(CatalogCase.position_attrs())

    permutations =
      FootballMarket.PositionAwareCase.permutations([
        :goalkeeper,
        :defender,
        :midfielder,
        :forward
      ])

    assert length(permutations) >= 20

    for strategy <- ["balanced", "position_aware"] do
      results =
        for {groups, i} <- Enum.with_index(permutations) do
          metrics =
            if rem(i, 2) == 0,
              do: [goals: Decimal.new("2.00"), assists: -1],
              else: [assists: -1, goals: Decimal.new("2.0")]

          weights =
            if strategy == "balanced",
              do: Map.new(metrics),
              else: Map.new(groups, &{&1, Map.new(metrics)})

          r = rules(f.position.id, strategy)
          mappings = [{f.position.id, :defender}, {unused.id, :forward}]

          r = %{
            r
            | config: %{weights: weights},
              references: Map.new(Enum.reverse(goals: 2, assists: 2)),
              position_mapping: if(rem(i, 2) == 0, do: mappings, else: Enum.reverse(mappings))
          }

          {:ok, v} = Configurations.create(r)
          {:ok, x} = Valuation.evaluate_managed(subject(f), {:version, v.id})
          assert {:ok, ^x} = Valuation.replay_managed(x.descriptor)
          {v.id, x.score, canonical(x.descriptor.evidence)}
        end

      assert length(Enum.uniq_by(results, &elem(&1, 0))) == 24

      assert length(
               Enum.uniq(Enum.map(results, fn {_, score, evidence} -> {score, evidence} end))
             ) == 1
    end
  end

  test "integer and Decimal equal weights retain different evidence at the same score" do
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1})
    {:ok, a} = Configurations.create(rules(f.position.id, "balanced", %{goals: 1}))

    {:ok, b} =
      Configurations.create(rules(f.position.id, "balanced", %{goals: Decimal.new("1.0")}))

    {:ok, x} = Valuation.evaluate_managed(subject(f), {:version, a.id})
    {:ok, y} = Valuation.evaluate_managed(subject(f), {:version, b.id})
    assert x.score == y.score
    refute x.descriptor.evidence.strategy.config == y.descriptor.evidence.strategy.config

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay_managed(%{x.descriptor | configuration_version_id: b.id})
  end
end
