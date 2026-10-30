defmodule FootballMarket.Quotes.LifecycleTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, Quotes, QuotesCase, ValuationConfigurationCase}
  alias FootballMarket.Quotes.{CalculationRequest, EvidenceCodec, Store}
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  test "malformed mapping identity is a mapping admission failure", f do
    id = Ecto.UUID.generate()
    assert {:error, :mapping_unavailable} = Quotes.request(f.subject, :active, "invalid", id)
    assert {:ok, %{reason: "mapping_unavailable"}} = Quotes.get_request(id)
  end

  test "insufficient-data identity uses canonical membership ordering", f do
    {match, performance} =
      FootballMarket.ValuationCase.record(f.base, "second-#{Ecto.UUID.generate()}")

    facts = [
      FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match),
      FootballMarket.Valuation.StatisticsReader.snapshot(performance, match)
    ]

    {:ok, config} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{saves: 1}, %{saves: 1})
      )

    {:ok, %{calculation: first}} =
      Quotes.request_membership(
        f.subject,
        {:version, config.id},
        f.mapping.id,
        facts,
        Ecto.UUID.generate()
      )

    {:ok, %{calculation: second}} =
      Quotes.request_membership(
        f.subject,
        {:version, config.id},
        f.mapping.id,
        Enum.reverse(facts),
        Ecto.UUID.generate()
      )

    assert first.status == "no_quote"
    assert first.reason == "insufficient_data"
    assert first.id == second.id
  end

  test "each TTL close has a distinct calculation identity and retries reuse it", f do
    facts = [FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)]

    request = fn key ->
      Quotes.request_membership(
        f.subject,
        {:version, f.configuration.id},
        f.mapping.id,
        facts,
        Ecto.UUID.generate(),
        nil,
        %{"admission_key" => key}
      )
    end

    assert {:ok, %{calculation: first}} = request.("ttl-cycle-1")
    assert {:ok, %{calculation: retry}} = request.("ttl-cycle-1")
    assert {:ok, %{calculation: next_close}} = request.("ttl-cycle-2")

    assert first.id == retry.id
    assert next_close.id != first.id
  end

  test "duplicate missing mapping admissions are idempotent under concurrency", f do
    Repo.query!(
      "CREATE FUNCTION slow_admission() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_sleep(0.3); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER slow_admission BEFORE INSERT ON quote_calculation_requests FOR EACH ROW EXECUTE FUNCTION slow_admission()"
    )

    request = Ecto.UUID.generate()
    missing = Ecto.UUID.generate()

    tasks =
      for _ <- 1..2 do
        Task.async(fn ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Quotes.request(f.subject, :active, missing, request)
          end)
        end)
      end

    assert Enum.map(tasks, &Task.await(&1, 5000)) == [
             error: :mapping_unavailable,
             error: :mapping_unavailable
           ]
  end

  test "lease claim starts its duration after acquiring the row lock", f do
    {:ok, _} = Configurations.activate(f.configuration.id, nil)
    {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    {:ok, [event]} = Quotes.pending_evaluations()
    owner = self()

    locker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.transaction(fn ->
            Repo.query!("SELECT id FROM quote_evaluation_requests WHERE id=$1 FOR UPDATE", [
              Ecto.UUID.dump!(event.id)
            ])

            send(owner, :locked)

            receive do
              :release -> :ok
            after
              5000 -> raise "release timed out"
            end
          end)
        end)
      end)

    assert_receive :locked, 5000

    worker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.checkout(fn ->
            [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
            send(owner, {:backend, backend})
            Quotes.claim_evaluation(event.id, 1)
          end)
        end)
      end)

    assert_receive {:backend, backend}, 5000
    await_blocked(backend, 200)
    Repo.query!("SELECT pg_sleep(1.1)")
    released_at = FootballMarket.Quotes.Store.database_clock_now!()
    send(locker.pid, :release)
    assert {:ok, :ok} = Task.await(locker, 5000)
    assert {:ok, %{event: claimed}} = Task.await(worker, 5000)
    assert DateTime.compare(claimed.lease_started_at, released_at) in [:eq, :gt]
    assert DateTime.diff(claimed.lease_until, claimed.lease_started_at, :second) == 1
  end

  test "concurrent configuration failures retain one terminal admission", f do
    Repo.query!("""
    CREATE FUNCTION slow_configuration_admission() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN PERFORM pg_sleep(0.3); RETURN NEW; END $$
    """)

    Repo.query!("""
    CREATE TRIGGER slow_configuration_admission BEFORE INSERT ON quote_calculation_requests
    FOR EACH ROW EXECUTE FUNCTION slow_configuration_admission()
    """)

    request_id = Ecto.UUID.generate()

    tasks =
      for _ <- 1..2 do
        Task.async(fn ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Quotes.request(f.subject, :active, f.mapping.id, request_id)
          end)
        end)
      end

    assert Enum.map(tasks, &Task.await(&1, 5_000)) ==
             [error: :configuration_unavailable, error: :configuration_unavailable]

    assert {:ok, request} = Quotes.get_request(request_id)
    assert request.state == "validation_failed"
    assert request.reason == "configuration_unavailable"
    assert Repo.aggregate(FootballMarket.Quotes.CalculationRequest, :count) == 1
  end

  test "expired worker cannot steal binding from a newly claimed worker", f do
    {:ok, _} = Configurations.activate(f.configuration.id, nil)

    {:ok, newer} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{goals: 4})
      )

    fact = FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)

    request =
      Repo.insert!(%FootballMarket.Quotes.CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: ~U[2026-10-05 00:00:00.000000Z],
        week_end: ~U[2026-10-12 00:00:00.000000Z],
        selector: "active",
        mapping_id: f.mapping.id,
        explicit_membership: [fact.performance_id],
        explicit_fact_material: %{
          "facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts([fact])
        },
        state: "pending",
        inserted_at: DateTime.utc_now()
      })

    handler = "quote-binding-#{Ecto.UUID.generate()}"

    :telemetry.attach(
      handler,
      [:football_market, :repo, :query],
      &__MODULE__.pause_binding/4,
      self()
    )

    on_exit(fn -> :telemetry.detach(handler) end)

    worker = fn ->
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Process.put(:quote_binding_barrier, true)
          Quotes.process_import_request(request.id)
        end)
      end)
    end

    first = worker.()
    assert_receive {:binding_lookup, first_pid}, 5000
    assert first_pid == first.pid

    Repo.query!(
      "UPDATE quote_calculation_requests SET lease_until=now()-interval '1 second' WHERE id=$1",
      [Ecto.UUID.dump!(request.id)]
    )

    {:ok, _} = Configurations.activate(newer.id, f.configuration.id)
    second = worker.()
    assert_receive {:binding_lookup, second_pid}, 5000
    assert second_pid == second.pid
    send(first.pid, :binding_continue)
    assert {:error, :stale_worker} = Task.await(first, 5000)
    send(second.pid, :binding_continue)
    result = Task.await(second, 5000)
    current = Repo.get!(FootballMarket.Quotes.CalculationRequest, request.id)

    assert {result, current.state, current.configuration_version_id} ==
             {:ok, "successful", newer.id}
  end

  test "a worker waiting on request lock reclaims a lease that expires during the wait", f do
    fact = FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)
    now = Store.database_clock_now!()

    request =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: ~U[2026-10-05 00:00:00.000000Z],
        week_end: ~U[2026-10-12 00:00:00.000000Z],
        selector: "active",
        mapping_id: f.mapping.id,
        configuration_version_id: f.configuration.id,
        explicit_membership: [fact.performance_id],
        explicit_fact_material: %{"facts" => EvidenceCodec.encode_facts([fact])},
        state: "running",
        attempt_count: 1,
        lease_fence: 1,
        lease_until: DateTime.add(now, 500_000, :microsecond),
        inserted_at: now
      })

    owner = self()

    locker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.transaction(fn ->
            Repo.query!("SELECT id FROM quote_calculation_requests WHERE id=$1 FOR UPDATE", [
              Ecto.UUID.dump!(request.id)
            ])

            send(owner, :locked)

            receive do
              :release -> :ok
            after
              5000 -> raise "lock release timeout"
            end
          end)
        end)
      end)

    assert_receive :locked, 5000

    worker =
      Task.async(fn ->
        ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
          Repo.checkout(fn ->
            [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
            send(owner, {:backend, backend})
            Quotes.process_import_request(request.id)
          end)
        end)
      end)

    assert_receive {:backend, backend}, 5000
    await_blocked(backend, 200)
    Repo.query!("SELECT pg_sleep(0.6)")
    send(locker.pid, :release)
    assert {:ok, :ok} = Task.await(locker, 5000)
    assert :ok = Task.await(worker, 5000)
    current = Repo.get!(CalculationRequest, request.id)
    assert {current.state, current.attempt_count, current.lease_fence} == {"successful", 2, 2}
  end

  test "scored and empty calculation times are sampled after acquiring the player lock", f do
    fact = FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)

    for {facts, status} <- [{[fact], "successful"}, {[], "no_quote"}] do
      owner = self()

      locker =
        Task.async(fn ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Repo.transaction(fn ->
              Store.lock_player!(f.player.id)
              send(owner, :locked)

              receive do
                :release -> :ok
              after
                5_000 -> raise "player lock release timeout"
              end
            end)
          end)
        end)

      assert_receive :locked, 5_000

      worker =
        Task.async(fn ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Repo.checkout(fn ->
              [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
              send(owner, {:backend, backend})

              Quotes.request_membership(
                f.subject,
                {:version, f.configuration.id},
                f.mapping.id,
                facts,
                Ecto.UUID.generate()
              )
            end)
          end)
        end)

      assert_receive {:backend, backend}, 5_000
      await_blocked(backend, 200)
      Repo.query!("SELECT pg_sleep(0.2)")
      released_at = Store.database_clock_now!()
      send(locker.pid, :release)
      assert {:ok, :ok} = Task.await(locker, 5_000)
      assert {:ok, %{calculation: calculation}} = Task.await(worker, 5_000)
      assert calculation.status == status
      assert DateTime.compare(calculation.effective_at, released_at) in [:eq, :gt]

      if status == "successful" do
        quote = Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
        event = Repo.get_by!(FootballMarket.Quotes.Evaluation, calculation_id: calculation.id)
        assert quote.effective_at == calculation.effective_at
        assert event.inserted_at == calculation.effective_at
      end
    end
  end

  def pause_binding(_event, _measure, metadata, owner) do
    if Process.get(:quote_binding_barrier) &&
         String.contains?(metadata.query, ~s(LEFT OUTER JOIN "valuation_configuration_versions")) do
      Process.delete(:quote_binding_barrier)
      send(owner, {:binding_lookup, self()})

      receive do
        :binding_continue -> :ok
      after
        5000 -> raise "binding pause timeout"
      end
    end
  end

  defp await_blocked(_backend, 0), do: flunk("worker never blocked")

  defp await_blocked(backend, n) do
    if Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [backend]).rows == [[true]] do
      :ok
    else
      Process.sleep(10)
      await_blocked(backend, n - 1)
    end
  end
end
