defmodule FootballMarket.IndependentConfigurationQA do
  use ExUnit.Case, async: false
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Catalog, CatalogCase, Repo, Valuation, ValuationCase}
  alias FootballMarket.Valuation.Configurations

  @tag timeout: 180_000
  test "90 independent rational vectors, all four roles, original replay and exact binding" do
    private_schema()
    # Exactly one season fixture for the entire probe: no repeated league/year pair.
    f = ValuationCase.fixture()
    groups = [:goalkeeper, :defender, :midfielder, :forward]
    positions = [f.position | for(_ <- 1..3, do: elem(Catalog.create_position(CatalogCase.position_attrs()), 1))]
    mappings = Enum.zip(Enum.map(positions, & &1.id), groups)
    metrics = FootballMarket.StatisticsCase.metrics()

    for {position, n} <- Enum.with_index(positions, 1) do
      attrs = Map.new(metrics, &{&1, n}) |> Map.put(:position_id, position.id)
      record(f, "qa-oracle-role-#{n}", attrs)
    end

    IO.puts("QA_SETUP_PASS fixtures=1 seasons=1 positions=4 facts=4")
    prior = Application.fetch_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)

    try do
      assert {:error, %{kind: :no_active_configuration}} = Configurations.active()
      vectors = System.fetch_env!("QA_ORACLE_PATH") |> File.read!() |> Jason.decode!()
      assert length(vectors) == 90

      {retained, active} =
        Enum.map_reduce(vectors, nil, fn vector, expected_current ->
          weights =
            if vector["strategy"] == "balanced" do
              numbers(vector["weights"], metrics)
            else
              Map.new(groups, fn group ->
                {group, numbers(vector["weights"][Atom.to_string(group)], metrics)}
              end)
            end

          r = %{
            strategy_id: vector["strategy"], formula_version: "1",
            config: %{weights: weights}, references: numbers(vector["references"], metrics),
            position_mapping: mappings
          }

          assert {:ok, v} = Configurations.create(r)
          assert {:ok, %{version: ^v}} = Configurations.get(v.id)
          assert {:ok, explicit} = Valuation.evaluate_managed(subject(f), {:version, v.id})
          assert explicit.score == vector["expected"], "rational oracle mismatch #{vector["id"]}"
          assert explicit.configuration_version_id == v.id
          assert explicit.descriptor.evidence.strategy.config == canonical(v.config)
          assert explicit.descriptor.evidence.request.references == v.references
          assert explicit.descriptor.evidence.request.requirements == v.requirements
          assert explicit.descriptor.evidence.request.position_mapping == v.position_mapping
          assert {:ok, ^explicit} = Valuation.replay_managed(explicit.descriptor)
          assert {:ok, _} = Configurations.activate(v.id, expected_current)
          assert {:ok, ^explicit} = Valuation.evaluate_managed(subject(f), :active)
          {explicit, v.id}
        end)

      # Four roles each cap independently at reference 1: 1+2+3+4, never average.
      four_role_rules = %{
        strategy_id: "position_aware", formula_version: "1",
        config: %{weights: Map.new(Enum.with_index(groups, 1), fn {g, n} -> {g, %{goals: n}} end)},
        references: %{goals: 1}, position_mapping: mappings
      }
      assert {:ok, four} = Configurations.create(four_role_rules)
      assert {:ok, split} = Valuation.evaluate_managed(subject(f), {:version, four.id})
      assert split.score == "10.000000"
      assert {:ok, ^split} = Valuation.replay_managed(split.descriptor)
      assert {:ok, _} = Configurations.activate(four.id, active)
      assert {:ok, ^split} = Valuation.evaluate_managed(subject(f), :active)
      concentrated_rules = %{four_role_rules | position_mapping: Enum.map(mappings, fn {id, _} -> {id, :forward} end)}
      assert {:ok, concentrated} = Configurations.create(concentrated_rules)
      assert {:ok, %{score: "4.000000"}} = Valuation.evaluate_managed(subject(f), {:version, concentrated.id})

      # Late facts must not alter the retained original membership of any vector.
      record(f, "qa-oracle-late", Map.new(metrics, &{&1, 1}))
      before_replay = snapshot()
      for original <- retained, do: assert({:ok, ^original} = Valuation.replay_managed(original.descriptor))
      assert {:ok, ^split} = Valuation.replay_managed(split.descriptor)
      assert before_replay == snapshot()
      assert {:ok, %{id: id}} = Configurations.active()
      assert id == four.id
      IO.puts("QA_ORACLE_PASS vectors=90 balanced=45 position_aware=45 metrics=9 active_and_explicit=180 original_replays=180")
      IO.puts("QA_FOUR_ROLE_PASS split=10.000000 concentrated=4.000000 late_fact_replay=10.000000 writes=0")
    after
      case prior do
        {:ok, config} -> Application.put_env(:football_market, FootballMarket.Providers, config)
        :error -> Application.delete_env(:football_market, FootballMarket.Providers)
      end
    end
  end

  defp numbers(values, allowed) do
    Map.new(values, fn {key, value} ->
      atom = Enum.find(allowed, &(Atom.to_string(&1) == key))
      assert atom != nil
      # Trusted generated vectors intentionally exceed Decimal's text-parser
      # defaults. Preserve their values instead of imposing harness ceilings.
      {atom, if(is_integer(value), do: value, else: Decimal.new(value, max_digits: :infinity, max_exponent: :infinity))}
    end)
  end

  defp snapshot do
    for table <- ~w(valuation_configuration_versions valuation_selection_changes matches player_match_performances) do
      # All table names are fixed trusted harness values. Full row state catches updates as well as insertions.
      Repo.query!("SELECT COALESCE(jsonb_agg(to_jsonb(t) ORDER BY to_jsonb(t)::text), '[]'::jsonb) FROM " <> table <> " t").rows
    end
  end
end
