defmodule FootballMarket.Valuation.Configurations.ActivationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.ValuationCase
  alias FootballMarket.Valuation.Configurations

  test "explicit expectation, cross-formula switch/restore and stale before no-op" do
    f = ValuationCase.fixture()
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "position_aware"))
    assert {:error, %{kind: :validation}} = Configurations.activate(a.id, :missing)
    assert {:ok, %{change: first}} = Configurations.activate(a.id, nil)
    assert first.previous_version_id == nil and first.new_version_id == a.id
    assert {:ok, %{change: nil}} = Configurations.activate(a.id, a.id)
    assert {:error, %{kind: :conflict}} = Configurations.activate(a.id, nil)
    assert {:error, %{kind: :not_found}} = Configurations.activate(Ecto.UUID.generate(), a.id)
    assert {:error, %{kind: :validation}} = Configurations.activate("bad", a.id)
    assert {:ok, %{change: second}} = Configurations.activate(b.id, a.id)
    assert second.previous_version_id == a.id and second.new_version_id == b.id
    assert {:ok, %{change: third}} = Configurations.activate(a.id, b.id)
    assert third.previous_version_id == b.id and third.new_version_id == a.id
    assert {:ok, ^a} = Configurations.active()
    assert {:ok, [^first, ^second, ^third]} = Configurations.history()
    assert first.change_order < second.change_order and second.change_order < third.change_order
    assert %DateTime{} = first.effective_at
    assert {:ok, _} = Configurations.create(rules(f.position.id))
    assert {:ok, [^first, ^second, ^third]} = Configurations.history()
    # Identity expectation intentionally permits an intervening A -> B -> A cycle.
    assert {:ok, _} = Configurations.activate(b.id, a.id)
  end

  test "unsupported stored formula remains inspectable, cannot be activated" do
    f = ValuationCase.fixture()
    {:ok, a} = Configurations.create(rules(f.position.id))

    unsupported =
      Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
        strategy_id: "balanced",
        formula_version: "retired",
        rules: a.rules
      })

    assert {:ok, %{version: v}} = Configurations.get(unsupported.id)
    assert v.formula_version == "retired"
    assert {:error, %{kind: :unsupported_strategy}} = Configurations.activate(v.id, nil)
    assert {:ok, []} = Configurations.history()
  end
end
