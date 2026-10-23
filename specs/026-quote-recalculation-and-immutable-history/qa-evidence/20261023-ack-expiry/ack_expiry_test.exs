defmodule Task026QaAckExpiryTest do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.{Repo, Quotes, QuotesCase, ValuationConfigurationCase}
  alias FootballMarket.Valuation.Configurations
  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end
  test "ack blocked on event lock rejects lease that expires before lock acquisition", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert {:ok, %{fence: fence, event: claimed}} = Quotes.claim_evaluation(event.id, 3)
    parent = self()
    locker = Task.async(fn ->
      ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
        Repo.transaction(fn ->
          Repo.query!("SELECT id FROM quote_evaluation_requests WHERE id=$1 FOR UPDATE", [Ecto.UUID.dump!(event.id)])
          send(parent, :locked)
          receive do :release -> :ok after 10000 -> raise "lock timeout" end
        end)
      end)
    end)
    assert_receive :locked, 5000
    {:ok, client} = ValuationConfigurationCase.client(f.namespace.schema)
    worker = Task.async(fn ->
      Repo.put_dynamic_repo(client)
      Repo.checkout(fn ->
        [[pid]] = Repo.query!("SELECT pg_backend_pid()").rows
        send(parent, {:backend, pid})
        Quotes.acknowledge_evaluation(event.id, fence, "qa-expiry")
      end)
    end)
    try do
      assert_receive {:backend, pid}, 5000
      await_blocked(pid, 500)
      assert Repo.query!("SELECT xact_start < $2 FROM pg_stat_activity WHERE pid=$1", [pid, claimed.lease_until]).rows == [[true]]
      Repo.query!("SELECT pg_sleep(GREATEST(0, EXTRACT(EPOCH FROM ($1::timestamptz - clock_timestamp()))) + 0.05)", [claimed.lease_until])
      assert Repo.query!("SELECT clock_timestamp() > $1", [claimed.lease_until]).rows == [[true]]
      send(locker.pid, :release)
      Task.await(locker, 5000)
      assert Task.await(worker, 5000) == {:error, :stale_fence}
    after
      if Process.alive?(worker.pid), do: Task.shutdown(worker, :brutal_kill)
      Supervisor.stop(client)
      if Process.alive?(locker.pid), do: send(locker.pid, :release)
    end
  end
  defp await_blocked(_, 0), do: flunk("no blocking observed")
  defp await_blocked(pid, n) do
    if Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [pid]).rows == [[true]] do
      :ok
    else
      Process.sleep(10)
      await_blocked(pid, n-1)
    end
  end
end
