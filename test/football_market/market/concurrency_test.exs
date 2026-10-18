defmodule FootballMarket.Market.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Repo, Market}
  alias FootballMarket.Market.Store

  setup do
    ns = private_schema()
    Map.merge(ns, fixture())
  end

  defp contender(schema, owner, ref, fun) do
    Task.async(fn ->
      in_client(schema, fn ->
        Repo.checkout(fn ->
          barrier(owner, ref, backend())
          fun.()
        end)
      end)
    end)
  end

  defp queued(f, calls, table \\ "market_initialization_locks", locked \\ fn -> :ok end) do
    owner = self()
    ref = make_ref()

    {:ok, tasks} =
      Repo.transaction(fn ->
        blocker = backend()
        Repo.query!("SELECT id FROM #{table} FOR UPDATE")
        tasks = Enum.map(calls, &contender(f.schema, owner, ref, &1))

        pids =
          for task <- tasks do
            process = task.pid
            assert_receive {^ref, ^process, pid}, 10_000
            send(process, {ref, :go})
            blocked(pid)
            pid
          end

        assert length(Enum.uniq([blocker | pids])) == length(pids) + 1
        locked.()
        tasks
      end)

    Enum.map(tasks, &Task.await(&1, 20_000))
  end

  test "same-player concurrent requests have one issuance and same identity", f do
    results =
      queued(f, [
        fn -> Market.initialize_player(f.player.id) end,
        fn -> Market.initialize_player(f.player.id) end
      ])

    assert [{:ok, a}, {:ok, b}] = results
    assert Enum.sort([a.outcome, b.outcome]) == [:already_completed, :issued]
    assert a.issuance == b.issuance
    assert Repo.query!("SELECT count(*),sum(quantity) FROM market_issuances").rows == [[1, 100]]
    assert Repo.query!("SELECT count(*) FROM market_quotes").rows == [[1]]
  end

  test "conflicting captured designations for same and different first players", f do
    for player <- [f.player, f.other] do
      # Each case starts with a new isolated market, preserving all prior audit rows.
      ns = private_schema()
      local = Map.merge(ns, fixture())
      p = if player.id == f.player.id, do: local.player, else: local.other

      results =
        queued(local, [
          fn -> Store.initialize(%{player_id: local.player.id, recipient_id: local.owner.id}) end,
          fn -> Store.initialize(%{player_id: p.id, recipient_id: local.buyer.id}) end
        ])

      assert Enum.count(results, &match?({:ok, %{outcome: :issued}}, &1)) == 1
      assert Enum.count(results, &match?({:error, %{kind: :recipient_conflict}}, &1)) == 1

      assert Repo.query!("SELECT count(DISTINCT recipient_id),count(*) FROM market_issuances").rows ==
               [[1, 1]]
    end
  end

  test "retry waits for atomic transfer then preserves committed 80/20 snapshot", f do
    {:ok, %{issuance: original}} = Market.initialize_player(f.player.id)

    [result] =
      queued(f, [fn -> Market.initialize_player(f.player.id) end], "players", fn ->
        assert {:ok, _} = transfer(f, 20)
      end)

    assert {:ok, %{outcome: :already_completed, issuance: ^original}} = result

    assert Repo.query!("SELECT quantity FROM market_holdings ORDER BY quantity").rows == [
             [20],
             [80]
           ]

    before = snapshot()
    assert {:ok, %{outcome: :already_completed}} = Market.initialize_player(f.player.id)
    assert before == snapshot()
  end

  test "malformed performance quotes cannot precede initial issuance", f do
    invalid_performance_quote(f.player)
    assert {:ok, %{outcome: :issued}} = Market.initialize_player(f.player.id)
    assert Repo.query!("SELECT count(*) FROM market_quotes").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_issuances").rows == [[1]]
  end

  test "issuance-first lock order blocks direct quote insert and retains both facts", f do
    # Initialization is blocked on its player after acquiring its market anchor;
    # a later ordinary quote writer queues behind that player lock.
    owner = self()
    ref = make_ref()

    {:ok, {initial, quote_task}} =
      Repo.transaction(fn ->
        blocker = backend()

        Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [
          Ecto.UUID.dump!(f.player.id)
        ])

        initial = contender(f.schema, owner, ref, fn -> Market.initialize_player(f.player.id) end)
        assert_receive {^ref, p1, pid1}, 10_000
        send(p1, {ref, :go})
        blocked(pid1)

        quote_task =
          contender(f.schema, owner, ref, fn -> invalid_performance_quote(f.player, "3") end)

        assert_receive {^ref, p2, pid2}, 10_000
        send(p2, {ref, :go})
        blocked(pid2)
        assert length(Enum.uniq([blocker, pid1, pid2])) == 3
        {initial, quote_task}
      end)

    assert {:ok, %{outcome: :issued, issuance: e}} = Task.await(initial, 20_000)
    assert %Ecto.ConstraintError{} = Task.await(quote_task, 20_000)
    assert {:ok, ^e} = Market.get_initial_issuance(f.player.id)
    assert Repo.query!("SELECT count(*) FROM market_quotes").rows == [[1]]
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]
  end

  test "retry-first lock order blocks transfer until complete retained validation", f do
    {:ok, %{issuance: e}} = Market.initialize_player(f.player.id)
    owner = self()
    ref = make_ref()

    {:ok, {retry, writer}} =
      Repo.transaction(fn ->
        blocker = backend()
        Repo.query!("SELECT id FROM users WHERE id=$1 FOR UPDATE", [Ecto.UUID.dump!(f.owner.id)])
        retry = contender(f.schema, owner, ref, fn -> Market.initialize_player(f.player.id) end)
        assert_receive {^ref, p1, pid1}, 10_000
        send(p1, {ref, :go})
        blocked(pid1)
        writer = contender(f.schema, owner, ref, fn -> transfer(f, 20) end)
        assert_receive {^ref, p2, pid2}, 10_000
        send(p2, {ref, :go})
        blocked(pid2)
        assert length(Enum.uniq([blocker, pid1, pid2])) == 3
        {retry, writer}
      end)

    assert {:ok, %{outcome: :already_completed, issuance: ^e}} = Task.await(retry, 20_000)
    assert {:ok, _} = Task.await(writer, 20_000)

    assert Repo.query!("SELECT quantity FROM market_holdings ORDER BY quantity").rows == [
             [20],
             [80]
           ]

    assert {:ok, ^e} = Market.get_initial_issuance(f.player.id)
  end

  test "facade captures designation once while queued competing calls see its change", f do
    owner = self()
    ref = make_ref()

    {:ok, {first, second}} =
      Repo.transaction(fn ->
        blocker = backend()
        Repo.query!("SELECT id FROM market_initialization_locks FOR UPDATE")
        first = contender(f.schema, owner, ref, fn -> Market.initialize_player(f.player.id) end)
        assert_receive {^ref, p1, pid1}, 10_000
        send(p1, {ref, :go})
        blocked(pid1)
        Application.put_env(:football_market, :initial_issuance_recipients, [f.buyer.id])
        second = contender(f.schema, owner, ref, fn -> Market.initialize_player(f.other.id) end)
        assert_receive {^ref, p2, pid2}, 10_000
        send(p2, {ref, :go})
        blocked(pid2)
        assert length(Enum.uniq([blocker, pid1, pid2])) == 3
        {first, second}
      end)

    assert {:ok, %{outcome: :issued, issuance: %{recipient_id: recipient}}} =
             Task.await(first, 20_000)

    assert recipient == f.owner.id
    assert_error(Task.await(second, 20_000), :recipient_conflict)
    assert Repo.query!("SELECT count(*) FROM market_issuances").rows == [[1]]
  end
end
