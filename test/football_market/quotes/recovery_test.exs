defmodule FootballMarket.Quotes.RecoveryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.Quotes.{CalculationRequest, Recovery}
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    old = Application.get_env(:football_market, FootballMarket.Synchronization)

    %{schema: schema, repo: client} = namespace = ValuationConfigurationCase.private_schema()

    start_supervised(
      {Oban,
       name: FootballMarket.Quotes.TestOban,
       repo: Repo,
       prefix: schema,
       testing: :manual,
       queues: [],
       plugins: [],
       get_dynamic_repo: fn -> client end}
    )

    # Route production inserts through the isolated Oban instance so job rows
    # stay inside the private schema instead of the shared public oban_jobs.
    Application.put_env(
      :football_market,
      FootballMarket.Synchronization,
      Keyword.merge(old || [], oban_name: FootballMarket.Quotes.TestOban)
    )

    on_exit(fn ->
      Application.put_env(:football_market, FootballMarket.Synchronization, old)
    end)

    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  defp dt!(value) when is_binary(value) do
    {:ok, dt, _} = DateTime.from_iso8601(value)
    usec6(dt)
  end

  defp dt!(value) when is_struct(value, DateTime), do: usec6(value)

  defp dt!(value), do: value

  defp usec6(dt) do
    dt = DateTime.truncate(dt, :microsecond)
    {micros, _} = dt.microsecond
    %{dt | microsecond: {micros, 6}}
  end

  test "due retrying calculations are re-enqueued while future backoffs remain untouched", f do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    due =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 1,
        lease_fence: 1,
        next_attempt_at: DateTime.add(now, -1, :second),
        inserted_at: now
      })

    future =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 1,
        lease_fence: 1,
        next_attempt_at: DateTime.add(now, 60, :second),
        inserted_at: now
      })

    second_backoff =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 2,
        lease_fence: 2,
        next_attempt_at: DateTime.add(now, 300, :second),
        inserted_at: now
      })

    assert {:ok, 1} = Recovery.recover_pending()

    assert %{success: 1} =
             Oban.drain_queue(FootballMarket.Quotes.TestOban, queue: :quote_calculation)

    assert Repo.get!(CalculationRequest, due.id).state == "validation_failed"
    assert %{reason: "configuration_unavailable"} = Repo.get!(CalculationRequest, due.id)
    assert Repo.get!(CalculationRequest, future.id).state == "retrying"
    assert Repo.get!(CalculationRequest, second_backoff.id).state == "retrying"
  end

  test "a request with three reserved attempts exhausts without financial writes", f do
    before = QuotesCase.protected_snapshot()
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    request =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "running",
        attempt_count: 3,
        lease_fence: 3,
        lease_until: DateTime.add(now, -1, :second),
        inserted_at: now
      })

    assert :ok = Quotes.process_import_request(request.id)

    assert Repo.get!(CalculationRequest, request.id).state == "exhausted"

    assert Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
             Ecto.UUID.dump!(f.player.id)
           ]).rows == [[1]]

    assert Repo.query!("SELECT count(*) FROM quote_evaluation_requests").rows == [[0]]
    assert QuotesCase.protected_snapshot() == before
  end

  test "expired delivery lease is recovered with a higher fence and stale acknowledgement fails",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    {:ok, [event]} = Quotes.pending_evaluations()
    {:ok, first} = Quotes.claim_evaluation(event.id, 1)

    expired = DateTime.add(DateTime.utc_now(), -1, :second) |> DateTime.truncate(:microsecond)

    Repo.query!("UPDATE quote_evaluation_requests SET lease_until=$1 WHERE id=$2", [
      expired,
      Ecto.UUID.dump!(event.id)
    ])

    assert {:ok, [recoverable]} = Quotes.pending_evaluations()
    assert recoverable.id == event.id
    {:ok, second} = Quotes.claim_evaluation(event.id, 30)
    assert second.fence > first.fence

    assert {:error, :stale_fence} =
             Quotes.acknowledge_evaluation(event.id, first.fence, "old-consumer-receipt")

    assert :ok = Quotes.acknowledge_evaluation(event.id, second.fence, "consumer-receipt")

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1 AND status='expired'",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[1]]
  end

  test "explicit recovery recovers a pre-commit persistence failure through the worker", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()

    # Inject a durable pre-commit failure that aborts only the quote
    # calculation persistence inside this isolated schema.
    Repo.query!(
      "CREATE FUNCTION schema_b2_guard() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'b2 injected persisted-failure'; END; $$",
      []
    )

    Repo.query!(
      "CREATE TRIGGER b2_guard BEFORE INSERT ON quote_calculations FOR EACH ROW EXECUTE FUNCTION schema_b2_guard()",
      []
    )

    assert {:error, _} = Quotes.request(f.subject, :active, f.mapping.id, request_id)

    # The admitted explicit request survives durably with its retained facts.
    assert {:ok, pending} = Quotes.get_request(request_id)
    assert pending.state == "pending"
    assert pending.mapping_id == f.mapping.id
    assert pending.explicit_membership == [f.performance.id]
    assert Map.has_key?(pending.explicit_fact_material, "facts")

    Repo.query!("DROP TRIGGER b2_guard ON quote_calculations", [])
    Repo.query!("DROP FUNCTION schema_b2_guard()", [])

    # The scheduled worker path recovers the explicit request from its own
    # retained fact material without any import snapshot.
    assert :ok =
             FootballMarket.Workers.QuoteCalculation.perform(%Oban.Job{
               args: %{"request_id" => request_id}
             })

    assert {:ok, recovered} = Quotes.get_request(request_id)
    assert recovered.state == "successful"
    assert recovered.calculation_id != nil

    assert Repo.query!(
             "SELECT count(*) FROM quote_calculations WHERE id=$1 AND status='successful'",
             [Ecto.UUID.dump!(recovered.calculation_id)]
           ).rows == [[1]]

    # The immutable quote and follow-up remain present once, financially intact.
    assert Repo.query!("SELECT count(*) FROM market_quotes WHERE calculation_id=$1", [
             Ecto.UUID.dump!(recovered.calculation_id)
           ]).rows == [[1]]

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1",
             [Ecto.UUID.dump!(recovered.calculation_id)]
           ).rows == [[1]]
  end

  test "temporary persistence failures follow the 60 and 300 second schedule then recover", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()

    Repo.query!(
      "CREATE FUNCTION retry_guard() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'retry schedule injection'; END; $$",
      []
    )

    Repo.query!(
      "CREATE TRIGGER retry_guard BEFORE INSERT ON quote_calculations FOR EACH ROW EXECUTE FUNCTION retry_guard()",
      []
    )

    assert {:error, :temporarily_unavailable} =
             Quotes.request(f.subject, :active, f.mapping.id, request_id)

    # The explicit request and its immutable fact material are durable even
    # though confirmation rolled back.
    assert {:ok, %{state: "pending", explicit_membership: [performance_id]}} =
             Quotes.get_request(request_id)

    assert performance_id == f.performance.id
    assert :ok = Quotes.process_import_request(request_id)

    first = Repo.get!(CalculationRequest, request_id)
    assert first.state == "retrying"
    assert first.attempt_count == 1
    assert DateTime.diff(first.next_attempt_at, DateTime.utc_now()) in 55..60
    assert :ok = Quotes.process_import_request(request_id)
    assert Repo.get!(CalculationRequest, request_id).attempt_count == 1

    Repo.query!("UPDATE quote_calculation_requests SET next_attempt_at=now() WHERE id=$1", [
      Ecto.UUID.dump!(request_id)
    ])

    assert :ok = Quotes.process_import_request(request_id)

    second = Repo.get!(CalculationRequest, request_id)
    assert second.state == "retrying"
    assert second.attempt_count == 2
    assert DateTime.diff(second.next_attempt_at, DateTime.utc_now()) in 295..300
    assert :ok = Quotes.process_import_request(request_id)
    assert Repo.get!(CalculationRequest, request_id).attempt_count == 2

    Repo.query!("UPDATE quote_calculation_requests SET next_attempt_at=now() WHERE id=$1", [
      Ecto.UUID.dump!(request_id)
    ])

    Repo.query!("DROP TRIGGER retry_guard ON quote_calculations", [])
    Repo.query!("DROP FUNCTION retry_guard()", [])

    assert :ok = Quotes.process_import_request(request_id)
    assert Repo.get!(CalculationRequest, request_id).state == "successful"

    assert Repo.query!("SELECT count(*) FROM quote_calculation_attempts WHERE request_id=$1", [
             Ecto.UUID.dump!(request_id)
           ]).rows == [[3]]
  end

  test "three interrupted workers retain the binding and exhaust without financial effects", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()

    Repo.query!(
      "CREATE FUNCTION interrupt_guard() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'interruption fixture'; END; $$"
    )

    Repo.query!(
      "CREATE TRIGGER interrupt_guard BEFORE INSERT ON quote_calculations FOR EACH ROW EXECUTE FUNCTION interrupt_guard()"
    )

    assert {:error, :temporarily_unavailable} =
             Quotes.request(f.subject, :active, f.mapping.id, request_id)

    Repo.query!("DROP TRIGGER interrupt_guard ON quote_calculations")
    Repo.query!("DROP FUNCTION interrupt_guard()")

    {:ok, replacement} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{goals: 4})
      )

    assert {:ok, _} = Configurations.activate(replacement.id, f.configuration.id)
    before = QuotesCase.protected_snapshot()

    for attempt <- 1..3 do
      interrupt_claimed_worker(f, request_id, attempt)
      assert {:ok, request} = Quotes.get_request(request_id)
      assert request.state == "running"
      assert request.attempt_count == attempt
      assert request.configuration_version_id == f.configuration.id
      assert request.mapping_id == f.mapping.id

      Repo.query!(
        "UPDATE quote_calculation_requests SET lease_until=now()-interval '1 second' WHERE id=$1",
        [Ecto.UUID.dump!(request_id)]
      )
    end

    assert {:ok, 1} = Recovery.recover_pending()

    assert %{success: 1} =
             Oban.drain_queue(FootballMarket.Quotes.TestOban, queue: :quote_calculation)

    assert {:ok, %{state: "exhausted", attempt_count: 3, reason: "retry_exhausted"}} =
             Quotes.get_request(request_id)

    assert Repo.query!(
             "SELECT attempt_number, status FROM quote_calculation_attempts WHERE request_id=$1 ORDER BY attempt_number",
             [Ecto.UUID.dump!(request_id)]
           ).rows == [[1, "interrupted"], [2, "interrupted"], [3, "interrupted"]]

    assert QuotesCase.protected_snapshot() == before
  end

  defp interrupt_claimed_worker(f, request_id, attempt) do
    parent = self()
    ref = make_ref()

    locker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.transaction(fn ->
            Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [
              Ecto.UUID.dump!(f.player.id)
            ])

            send(parent, {ref, :locked})

            receive do
              {^ref, :release} -> :ok
            after
              10_000 -> raise "player lock release timed out"
            end
          end)
        end)
      end)

    assert_receive {^ref, :locked}, 5_000

    {:ok, worker_client} = ValuationConfigurationCase.client(f.namespace.schema)

    worker =
      Task.async(fn ->
        Repo.put_dynamic_repo(worker_client)

        Repo.checkout(fn ->
          [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
          send(parent, {ref, :worker, backend})

          FootballMarket.Workers.QuoteCalculation.perform(%Oban.Job{
            args: %{"request_id" => request_id}
          })
        end)
      end)

    try do
      assert_receive {^ref, :worker, backend}, 5_000
      await_blocked(backend, 500)
      assert Repo.get!(CalculationRequest, request_id).attempt_count == attempt
      assert Task.shutdown(worker, :brutal_kill) == nil
      refute Process.alive?(worker.pid)
    after
      if Process.alive?(worker.pid), do: Task.shutdown(worker, :brutal_kill)
      Supervisor.stop(worker_client)
      send(locker.pid, {ref, :release})
      Task.await(locker, 5_000)
    end
  end

  defp await_blocked(_backend, 0), do: flunk("worker did not reach confirmation lock")

  defp await_blocked(backend, attempts) do
    case Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [backend]).rows do
      [[true]] ->
        :ok

      _ ->
        Process.sleep(10)
        await_blocked(backend, attempts - 1)
    end
  end
end
