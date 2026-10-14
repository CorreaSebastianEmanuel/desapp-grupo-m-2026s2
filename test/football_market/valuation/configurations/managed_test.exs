defmodule FootballMarket.Valuation.Configurations.ManagedTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Repo, Valuation, ValuationCase, Catalog, CatalogCase}
  alias FootballMarket.Valuation.Configurations

  test "managed scores retain UUID, full formula evidence and approved role caps" do
    private_schema()
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1})
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "balanced", %{goals: 4}))
    {:ok, _} = Configurations.activate(b.id, nil)
    assert {:ok, x} = Valuation.evaluate_managed(subject(f), {:version, a.id})
    assert x.score == "1.000000" and x.configuration_version_id == a.id
    assert x.strategy_id == "balanced" and x.formula_version == "1"
    assert x.descriptor.configuration_version_id == a.id
    assert x.descriptor.evidence.strategy.config == canonical(a.config)
    assert x.descriptor.evidence.request.references == a.references
    assert x.descriptor.evidence.request.requirements == a.requirements
    assert x.descriptor.evidence.request.position_mapping == a.position_mapping
    assert {:ok, y} = Valuation.evaluate_managed(subject(f), :active)
    assert y.score == "2.000000" and y.configuration_version_id == b.id
    assert {:ok, ^b} = Configurations.active()
    g = ValuationCase.fixture("PD", 2024)
    {:ok, forward} = Catalog.create_position(CatalogCase.position_attrs())
    record(g, "def", %{goals: 2})
    record(g, "fwd", %{goals: 2, position_id: forward.id})
    p = rules(g.position.id, "position_aware")

    {:ok, split} =
      Configurations.create(%{
        p
        | position_mapping: [{g.position.id, :defender}, {forward.id, :forward}]
      })

    {:ok, concentrated} =
      Configurations.create(%{
        p
        | position_mapping: [{g.position.id, :defender}, {forward.id, :defender}]
      })

    assert {:ok, %{score: "4.000000"}} =
             Valuation.evaluate_managed(subject(g), {:version, split.id})

    assert {:ok, %{score: "2.000000"}} =
             Valuation.evaluate_managed(subject(g), {:version, concentrated.id})
  end

  test "controlled activation after version resolution cannot change in-flight rules" do
    c = private_schema()
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1})
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "balanced", %{goals: 4}))
    {:ok, _} = Configurations.activate(a.id, nil)
    owner = self()
    barrier = make_ref()

    locker =
      Task.async(fn ->
        in_client(c.schema, fn ->
          Repo.transaction(fn ->
            Repo.query!("LOCK TABLE players IN ACCESS EXCLUSIVE MODE")
            send(owner, {barrier, :locked})

            receive do
              {^barrier, :release} -> :ok
            after
              10_000 -> raise "football-read barrier timed out"
            end
          end)
        end)
      end)

    assert_receive {^barrier, :locked}, 5000

    worker =
      Task.async(fn ->
        receive do
          {^barrier, :start} ->
            in_client(c.schema, fn -> Valuation.evaluate_managed(subject(f), :active) end)
        after
          5000 -> raise "worker start barrier timed out"
        end
      end)

    module = FootballMarket.Valuation.Configurations.Store
    :erlang.trace_pattern({module, :active, 0}, [{:_, [], [{:return_trace}]}], [:local])
    :erlang.trace(worker.pid, true, [:call, {:tracer, owner}])

    try do
      send(worker.pid, {barrier, :start})
      pid = worker.pid
      assert_receive {:trace, ^pid, :return_from, {^module, :active, 0}, {:ok, %{id: id}}}, 5000
      assert id == a.id
      assert {:ok, _} = Configurations.activate(b.id, a.id)
      send(locker.pid, {barrier, :release})
      assert {:ok, :ok} = Task.await(locker, 10_000)
      assert {:ok, first} = Task.await(worker, 10_000)
      assert first.score == "1.000000" and first.configuration_version_id == a.id
      assert first.descriptor.evidence.strategy.config == canonical(a.config)
      assert {:ok, next} = Valuation.evaluate_managed(subject(f), :active)
      assert next.score == "2.000000" and next.configuration_version_id == b.id
    after
      :erlang.trace_pattern({module, :active, 0}, false, [:local])
      send(locker.pid, {barrier, :release})
    end
  end
end
