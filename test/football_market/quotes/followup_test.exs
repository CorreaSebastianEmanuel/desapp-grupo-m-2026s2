defmodule FootballMarket.Quotes.FollowupTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  test "one quote-keyed pending event survives duplicate delivery and matching acknowledgement",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert event.calculation_id == calculation.id
    assert event.idempotency_key == "quote-evaluation:" <> event.quote_id

    assert {:ok, claim} = Quotes.claim_evaluation(event.id)
    assert claim.key == event.idempotency_key
    receipt = "fixture-consumed-" <> event.quote_id
    assert :ok = Quotes.acknowledge_evaluation(event.id, claim.fence, receipt)
    assert :ok = Quotes.acknowledge_evaluation(event.id, claim.fence, receipt)
    assert {:ok, []} = Quotes.pending_evaluations()

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[1]]
  end

  test "pending follow-up event cannot be deleted", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()

    error =
      assert_raise Postgrex.Error, fn ->
        Repo.query!("DELETE FROM quote_evaluation_requests WHERE id=$1", [
          Ecto.UUID.dump!(event.id)
        ])
      end

    assert error.postgres.code == :check_violation
    assert error.postgres.constraint == "quote_evaluation_write_once"

    assert {:ok, [retained]} = Quotes.pending_evaluations()
    assert retained.id == event.id
  end

  test "acknowledgement blocked on event lock rejects a lease that expires before acquisition",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert {:ok, %{fence: fence, event: claimed}} = Quotes.claim_evaluation(event.id, 3)
    parent = self()
    ref = make_ref()

    locker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.transaction(fn ->
            Repo.query!("SELECT id FROM quote_evaluation_requests WHERE id=$1 FOR UPDATE", [
              Ecto.UUID.dump!(event.id)
            ])

            send(parent, {ref, :locked})

            receive do
              {^ref, :release} -> :ok
            after
              10_000 -> raise "event lock timeout"
            end
          end)
        end)
      end)

    assert_receive {^ref, :locked}, 5_000
    {:ok, client} = ValuationConfigurationCase.client(f.namespace.schema)

    worker =
      Task.async(fn ->
        Repo.put_dynamic_repo(client)

        Repo.checkout(fn ->
          [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
          send(parent, {ref, :backend, backend})
          Quotes.acknowledge_evaluation(event.id, fence, "expired-consumer")
        end)
      end)

    try do
      assert_receive {^ref, :backend, backend}, 5_000
      await_blocked(backend, 500)

      assert Repo.query!(
               "SELECT xact_start < $2 FROM pg_stat_activity WHERE pid=$1",
               [backend, claimed.lease_until]
             ).rows == [[true]]

      Repo.query!(
        "SELECT pg_sleep(GREATEST(0, EXTRACT(EPOCH FROM ($1::timestamptz - clock_timestamp()))) + 0.05)",
        [claimed.lease_until]
      )

      assert Repo.query!("SELECT clock_timestamp() > $1", [claimed.lease_until]).rows == [[true]]

      assert Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [backend]).rows == [
               [true]
             ]

      send(locker.pid, {ref, :release})
      assert {:ok, :ok} = Task.await(locker, 5_000)
      assert {:error, :stale_fence} = Task.await(worker, 5_000)

      assert Repo.query!(
               "SELECT state, consumer_receipt FROM quote_evaluation_requests WHERE id=$1",
               [Ecto.UUID.dump!(event.id)]
             ).rows == [["leased", nil]]

      assert Repo.query!(
               "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1",
               [Ecto.UUID.dump!(event.id)]
             ).rows == [[0]]

      assert {:ok, next} = Quotes.claim_evaluation(event.id, 30)
      assert next.fence > fence
      assert :ok = Quotes.acknowledge_evaluation(event.id, next.fence, "recovered-consumer")
      assert :ok = Quotes.acknowledge_evaluation(event.id, next.fence, "recovered-consumer")
    after
      if Process.alive?(worker.pid), do: Task.shutdown(worker, :brutal_kill)
      Supervisor.stop(client)
      if Process.alive?(locker.pid), do: send(locker.pid, {ref, :release})
    end
  end

  test "quote and event-ID wake commit together or enqueue failure rolls everything back", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    before = Repo.aggregate(FootballMarket.Market.Quote, :count)
    FootballMarket.OrderEvaluationCase.fail_jobs!()
    assert {:error, _} = Quotes.request(f.subject, :active, f.mapping.id)
    FootballMarket.OrderEvaluationCase.repair_jobs!()
    assert Repo.aggregate(FootballMarket.Market.Quote, :count) == before
    assert {:ok, []} = Quotes.pending_evaluations()
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id, Ecto.UUID.generate())
    assert {:ok, [event]} = Quotes.pending_evaluations()

    assert [%{args: %{"source" => "quote", "event_id" => id}}] =
             FootballMarket.OrderEvaluationCase.jobs()

    assert id == event.id
  end

  test "fenced acceptance plus wake is atomic; repeat receipt has one effective delivery", f do
    alias FootballMarket.Market.OrderEvaluation
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    before = length(FootballMarket.OrderEvaluationCase.jobs())
    FootballMarket.OrderEvaluationCase.fail_jobs!()
    assert {:error, _} = OrderEvaluation.accept_event(event.id)
    FootballMarket.OrderEvaluationCase.repair_jobs!()
    stored = Repo.get!(FootballMarket.Quotes.Evaluation, event.id)
    assert stored.state == "pending" and stored.lease_fence == 0
    assert {:ok, :ok} = OrderEvaluation.accept_event(event.id)
    assert {:ok, :ok} = OrderEvaluation.accept_event(event.id)
    assert length(FootballMarket.OrderEvaluationCase.jobs()) == before + 1
    stored = Repo.get!(FootballMarket.Quotes.Evaluation, event.id)
    assert stored.consumer_receipt == "conditional-evaluation:" <> event.id
    assert stored.state == "acknowledged"

    assert {:error, :receipt_conflict} =
             Quotes.acknowledge_evaluation(event.id, stored.lease_fence, "another-consumer")
  end

  test "recovery accepts an expired fenced event and acknowledged lost jobs remain repairable",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert {:ok, claim} = Quotes.claim_evaluation(event.id, 1)

    Repo.query!(
      "UPDATE quote_evaluation_requests SET lease_until=clock_timestamp()-interval '1 second' WHERE id=$1",
      [Ecto.UUID.dump!(event.id)]
    )

    assert :ok = FootballMarket.Market.OrderEvaluation.recover(nil)
    stored = Repo.get!(FootballMarket.Quotes.Evaluation, event.id)
    assert stored.state == "acknowledged" and stored.lease_fence > claim.fence

    assert {:error, :receipt_conflict} =
             Quotes.acknowledge_evaluation(event.id, claim.fence, "stale")

    Repo.query!("DELETE FROM oban_jobs")
    assert :ok = FootballMarket.Market.OrderEvaluation.recover(nil)
    assert [%{args: %{"source" => "continuation"}}] = FootballMarket.OrderEvaluationCase.jobs()
  end

  test "equal-time event pages persist a stable continuation and consume all events", f do
    now = DateTime.utc_now()
    for _ <- 1..101, do: QuotesCase.dated_quote(f, now)
    assert :ok = FootballMarket.Market.OrderEvaluation.recover(nil)

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_requests WHERE state='acknowledged'"
           ).rows == [[100]]

    [[args]] =
      Repo.query!(
        "SELECT args FROM oban_jobs WHERE worker='FootballMarket.Workers.ConditionalOrderRecovery'"
      ).rows

    assert %{"after" => id} = args
    assert {:ok, _} = Ecto.UUID.cast(id)
    assert :ok = FootballMarket.Workers.ConditionalOrderRecovery.perform(%Oban.Job{args: args})

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_requests WHERE state='acknowledged'"
           ).rows == [[101]]
  end

  defp await_blocked(_backend, 0), do: flunk("acknowledgement did not block on the event lock")

  defp await_blocked(backend, remaining) do
    if Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [backend]).rows == [[true]] do
      :ok
    else
      Process.sleep(10)
      await_blocked(backend, remaining - 1)
    end
  end

  test "a redelivered event produces one effective consumer action keyed by quote UUID", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()

    Repo.query!(
      """
      CREATE TABLE fake_effective_evaluations (
        quote_id uuid PRIMARY KEY,
        applied_count integer NOT NULL DEFAULT 1
      )
      """,
      []
    )

    Repo.query!("CREATE TABLE fake_consumer_receipts (quote_id uuid PRIMARY KEY)")

    consume = fn event ->
      Repo.query!(
        """
        WITH receipt AS (
          INSERT INTO fake_consumer_receipts (quote_id) VALUES ($1)
          ON CONFLICT (quote_id) DO NOTHING RETURNING quote_id
        )
        INSERT INTO fake_effective_evaluations (quote_id) SELECT quote_id FROM receipt
        ON CONFLICT (quote_id) DO UPDATE
          SET applied_count = fake_effective_evaluations.applied_count + 1
        """,
        [Ecto.UUID.dump!(event.quote_id)]
      )
    end

    assert {:ok, first} = Quotes.claim_evaluation(event.id, 1)
    consume.(event)

    # Simulate a consumer that committed its idempotent work but whose
    # acknowledgement was lost, so the same quote key is delivered again.
    expired = DateTime.add(DateTime.utc_now(), -1, :second) |> DateTime.truncate(:microsecond)

    Repo.query!("UPDATE quote_evaluation_requests SET lease_until=$1 WHERE id=$2", [
      expired,
      Ecto.UUID.dump!(event.id)
    ])

    assert {:ok, second} = Quotes.claim_evaluation(event.id, 30)
    assert second.key == first.key
    assert second.event.quote_id == event.quote_id
    consume.(event)

    assert Repo.query!(
             "SELECT count(*), sum(applied_count) FROM fake_effective_evaluations WHERE quote_id=$1",
             [
               Ecto.UUID.dump!(event.quote_id)
             ]
           ).rows == [[1, 1]]

    assert {:error, :stale_fence} =
             Quotes.acknowledge_evaluation(event.id, first.fence, "late-ack")

    assert :ok = Quotes.acknowledge_evaluation(event.id, second.fence, "deduplicated-consumer")

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[2]]
  end
end
