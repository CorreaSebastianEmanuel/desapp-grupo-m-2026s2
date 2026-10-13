defmodule FootballMarket.Valuation.Configurations.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Repo, ValuationCase}
  alias FootballMarket.Valuation.Configurations

  test "distinct committed backends serialize both first activation and competing targets" do
    c = private_schema()
    f = ValuationCase.fixture()

    [a, b, d] =
      for weight <- [1, 2, 3] do
        {:ok, v} = Configurations.create(rules(f.position.id, "balanced", %{goals: weight}))
        v
      end

    for {targets, expected} <- [{[a.id, b.id], nil}, {[b.id, d.id], a.id}] do
      if expected do
        {:ok, active} = Configurations.active()
        {:ok, _} = Configurations.activate(a.id, active.id)
      end

      parent = self()
      barrier = make_ref()

      workers =
        for target <- targets do
          Task.async(fn ->
            in_client(c.schema, fn ->
              %{rows: [[backend]]} = Repo.query!("SELECT pg_backend_pid()")
              barrier(parent, barrier, backend)
              Configurations.activate(target, expected)
            end)
          end)
        end

      backends =
        for worker <- workers do
          pid = worker.pid
          assert_receive {^barrier, ^pid, backend}, 5000
          backend
        end

      assert length(Enum.uniq(backends)) == 2
      for worker <- workers, do: send(worker.pid, {barrier, :go})
      results = Enum.map(workers, &Task.await(&1, 10_000))
      assert Enum.count(results, &match?({:ok, _}, &1)) == 1
      assert Enum.count(results, &match?({:error, %{kind: :conflict}}, &1)) == 1
      assert {:ok, active} = Configurations.active()
      assert active.id in targets
      assert {:ok, changes} = Configurations.history()
      assert changes == Enum.sort_by(changes, & &1.change_order)
    end
  end

  test "reader sees committed old/new states and tied database times retain change order" do
    c = private_schema()
    f = ValuationCase.fixture()
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "position_aware"))
    {:ok, _} = Configurations.activate(a.id, nil)
    parent = self()
    barrier = make_ref()

    writer =
      Task.async(fn ->
        in_client(c.schema, fn ->
          Repo.transaction(fn ->
            assert {:ok, %{change: one}} = Configurations.activate(b.id, a.id)
            assert {:ok, %{change: two}} = Configurations.activate(a.id, b.id)
            assert {:ok, %{change: three}} = Configurations.activate(b.id, a.id)
            assert one.effective_at == two.effective_at and two.effective_at == three.effective_at
            assert one.change_order < two.change_order and two.change_order < three.change_order
            send(parent, {barrier, :uncommitted})

            receive do
              {^barrier, :commit} -> :ok
            after
              5000 -> raise "commit barrier timeout"
            end
          end)
        end)
      end)

    assert_receive {^barrier, :uncommitted}, 5000
    assert {:ok, ^a} = Configurations.active()
    assert {:ok, [_]} = Configurations.history()
    send(writer.pid, {barrier, :commit})
    assert {:ok, :ok} = Task.await(writer, 10_000)
    assert {:ok, ^b} = Configurations.active()
    assert {:ok, changes} = Configurations.history()
    assert length(changes) == 4
  end

  test "direct insertion guards serialize fresh READ COMMITTED snapshots too" do
    c = private_schema()
    f = ValuationCase.fixture()

    targets =
      for strategy <- ["balanced", "position_aware"] do
        {:ok, v} = Configurations.create(rules(f.position.id, strategy))
        v.id
      end

    owner = self()
    barrier = make_ref()

    workers =
      for target <- targets do
        Task.async(fn ->
          in_client(c.schema, fn ->
            %{rows: [[backend]]} = Repo.query!("SELECT pg_backend_pid()")
            barrier(owner, barrier, backend)

            Repo.query(
              "INSERT INTO valuation_selection_changes(previous_version_id,new_version_id) VALUES(NULL,$1)",
              [Ecto.UUID.dump!(target)]
            )
          end)
        end)
      end

    backends =
      for worker <- workers do
        pid = worker.pid
        assert_receive {^barrier, ^pid, backend}, 5000
        backend
      end

    assert length(Enum.uniq(backends)) == 2
    for worker <- workers, do: send(worker.pid, {barrier, :go})
    results = Enum.map(workers, &Task.await(&1, 10_000))
    assert Enum.count(results, &match?({:ok, _}, &1)) == 1

    assert Enum.count(
             results,
             &match?(
               {:error, %Postgrex.Error{postgres: %{constraint: "valuation_predecessor"}}},
               &1
             )
           ) == 1

    assert {:ok, [change]} = Configurations.history()
    assert change.previous_version_id == nil
    assert {:ok, %{id: selected}} = Configurations.active()
    assert selected == change.new_version_id
  end
end
