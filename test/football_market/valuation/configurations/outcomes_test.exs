defmodule FootballMarket.Valuation.Configurations.OutcomesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Valuation, ValuationCase, Catalog, CatalogCase}
  alias FootballMarket.Valuation.Configurations

  test "strict subjects/selectors and no active/unknown/unsupported remain distinct before facts" do
    f = ValuationCase.fixture()
    s = subject(f)
    {:ok, v} = Configurations.create(rules(f.position.id))

    for key <- [
          :weights,
          :config,
          :references,
          :requirements,
          :position_mapping,
          :module,
          :strategy_id,
          :formula_version
        ] do
      assert {:error, %{kind: :validation}} =
               Valuation.evaluate_managed(Map.put(s, key, %{}), {:version, v.id})
    end

    for invalid <- [nil, [], Map.delete(s, :player_id), Map.put(s, :week_start, "bad")] do
      assert {:error, %{kind: :validation}} = Valuation.evaluate_managed(invalid, :active)
    end

    assert {:error, %{kind: :no_active_configuration}} = Valuation.evaluate_managed(s, :active)
    assert {:error, %{kind: :validation}} = Valuation.evaluate_managed(s, {:version, "bad"})
    assert {:error, %{kind: :validation}} = Valuation.evaluate_managed(s, :default)

    assert {:error, %{kind: :not_found}} =
             Valuation.evaluate_managed(s, {:version, Ecto.UUID.generate()})

    assert {:error, %{kind: :no_recorded_performances}} =
             Valuation.evaluate_managed(s, {:version, v.id})

    assert {:error, %{kind: :not_found}} =
             Valuation.evaluate_managed(%{s | player_id: Ecto.UUID.generate()}, {:version, v.id})

    u =
      Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
        strategy_id: "retired",
        formula_version: "1",
        rules: v.rules
      })

    assert {:error, %{kind: :unsupported_strategy}} =
             Valuation.evaluate_managed(s, {:version, u.id})

    assert {:ok, []} = Configurations.history()
  end

  test "unmapped historical position and unknown required zero-weight metric are inherited outcomes" do
    f = ValuationCase.fixture()
    ValuationCase.record(f, "unknown", %{goals: 1, saves: nil})
    {:ok, p} = Catalog.create_position(CatalogCase.position_attrs())
    {:ok, missing} = Configurations.create(rules(p.id))

    assert {:error, %{kind: :validation, reason: :missing_position_mapping}} =
             Valuation.evaluate_managed(subject(f), {:version, missing.id})

    for strategy <- ["balanced", "position_aware"] do
      {:ok, v} =
        Configurations.create(
          rules(f.position.id, strategy, %{goals: 2, saves: 0}, %{goals: 2, saves: 1})
        )

      assert {:error, %{kind: :insufficient_data}} =
               Valuation.evaluate_managed(subject(f), {:version, v.id})
    end

    assert {:ok, []} = Configurations.history()
  end
end
