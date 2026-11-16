defmodule FootballMarket.Quotes.InitialTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo, Statistics, ValuationConfigurationCase}
  alias FootballMarket.Quotes.{CalculationRequest, Closing, Recovery, Store}
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
  alias FootballMarket.Valuation.{CalculationRequests, Configurations}

  setup do
    previous_mapping = Application.fetch_env(:football_market, :quote_mapping_id)
    Application.delete_env(:football_market, :quote_mapping_id)
    restore = FootballMarket.IngestionFixtures.setup_primary_account!()

    on_exit(fn ->
      restore.()

      case previous_mapping do
        {:ok, mapping} -> Application.put_env(:football_market, :quote_mapping_id, mapping)
        :error -> Application.delete_env(:football_market, :quote_mapping_id)
      end
    end)

    namespace = ValuationConfigurationCase.private_schema()
    scope = Fixtures.scope(2088)
    Case.seed_catalog!(scope)
    player = Repo.one!(FootballMarket.Catalog.Player)

    {:ok, configuration} =
      Configurations.create(ValuationConfigurationCase.rules(player.position_id))

    {:ok, mapping} = Quotes.Mappings.save("initial", "1", Decimal.new("1.25"))
    Application.put_env(:football_market, :quote_mapping_id, mapping.id)

    %{
      namespace: namespace,
      scope: scope,
      player: player,
      configuration: configuration,
      mapping: mapping
    }
  end

  test "accepted statistics publish the first positive quote asynchronously before close", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request = accept!(f)
    assert request.admitted_at == nil
    assert performance_quotes(f) == []
    assert Enum.map(Repo.all(FootballMarket.Market.Quote), & &1.rule_id) == ["initial_issuance"]

    assert {:ok, 1} = Recovery.recover_pending()
    assert %{success: 1} = drain()
    current = Repo.get!(CalculationRequest, request.id)
    assert current.state == "successful"
    assert current.initial_only
    assert current.admitted_at == nil
    assert current.configuration_version_id == f.configuration.id
    assert current.mapping_id == f.mapping.id
    assert [quote] = performance_quotes(f)
    assert Decimal.equal?(quote.unit_price, Decimal.new("2.50"))
    assert quote.performance_sequence == 1
    assert quote.configuration_version_id == f.configuration.id
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert event.quote_id == quote.id
    calculation = Repo.get!(Quotes.Calculation, quote.calculation_id)
    assert calculation.evidence["facts"] != []
    assert calculation.evidence["score"] == Decimal.to_string(calculation.score)
    assert {:ok, replay} = Quotes.replay(quote.calculation_id)
    assert replay.outcome.status == "successful"
    assert Decimal.equal?(replay.outcome.price, quote.unit_price)

    assert :ok = Quotes.process_import_request(request.id)
    assert {:ok, 0} = Recovery.recover_pending()
    assert performance_quotes(f) == [quote]
  end

  test "later accepted changes remain pending until nightly admission", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    first = accept!(f)
    assert {:ok, 1} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(first.id)
    second = accept!(f, 2)
    assert {:ok, 0} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(second.id)
    assert Repo.get!(CalculationRequest, second.id).attempt_count == 0
    assert length(performance_quotes(f)) == 1

    assert {:ok, %{imports: 1}} = Closing.admit_now()
    assert :ok = Quotes.process_import_request(second.id)
    assert length(performance_quotes(f)) == 2
    assert Repo.get!(CalculationRequest, second.id).state == "successful"
  end

  test "missing strategy or mapping stays pending and recovery admits it after configuration",
       f do
    Application.delete_env(:football_market, :quote_mapping_id)
    request = accept!(f)
    assert {:ok, 0} = Recovery.recover_pending()
    assert Repo.get!(CalculationRequest, request.id).attempt_count == 0
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    Application.put_env(:football_market, :quote_mapping_id, Ecto.UUID.generate())
    assert {:ok, 0} = Recovery.recover_pending()
    assert performance_quotes(f) == []
    Application.put_env(:football_market, :quote_mapping_id, f.mapping.id)
    assert {:ok, 1} = Recovery.recover_pending()
    assert %{success: 1} = drain()
    assert Repo.get!(CalculationRequest, request.id).mapping_id == f.mapping.id
    assert length(performance_quotes(f)) == 1
  end

  test "missing metrics and nonpositive results retain explicit no-quote outcomes", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)

    for {index, goals, reason} <- [{1, nil, "insufficient_data"}, {8, 0, "nonpositive_score"}] do
      request = accept!(f, index, goals)
      before = FootballMarket.QuotesCase.protected_snapshot()
      assert {:ok, 1} = Recovery.recover_pending()
      assert :ok = Quotes.process_import_request(request.id)
      current = Repo.get!(CalculationRequest, request.id)
      assert current.state == "no_quote"
      assert current.reason == reason
      calculation = Repo.get!(Quotes.Calculation, current.calculation_id)

      if is_nil(goals) do
        assert calculation.score == nil
        refute Map.has_key?(calculation.evidence, "score")
      else
        assert Decimal.equal?(calculation.score, Decimal.new(0))
        assert calculation.evidence["score"] == Decimal.to_string(calculation.score)
      end

      assert {:ok, replay} = Quotes.replay(calculation.id)
      assert replay.outcome.reason == reason
      assert FootballMarket.QuotesCase.protected_snapshot() == before
      assert performance_quotes(f) == []
    end

    {:ok, tiny_mapping} = Quotes.Mappings.save("initial-tiny", "1", Decimal.new("0.00000001"))
    Application.put_env(:football_market, :quote_mapping_id, tiny_mapping.id)
    rounded = accept!(f, 15)
    assert {:ok, 1} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(rounded.id)

    assert %{state: "no_quote", reason: "nonpositive_converted_result", calculation_id: id} =
             Repo.get!(CalculationRequest, rounded.id)

    calculation = Repo.get!(Quotes.Calculation, id)
    assert Decimal.positive?(calculation.score)
    assert calculation.evidence["score"] == Decimal.to_string(calculation.score)
    assert {:ok, replay} = Quotes.replay(id)
    assert replay.outcome.reason == "nonpositive_converted_result"
    assert performance_quotes(f) == []

    Application.put_env(:football_market, :quote_mapping_id, f.mapping.id)
    positive = accept!(f, 22)
    assert {:ok, 1} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(positive.id)
    assert length(performance_quotes(f)) == 1
  end

  test "different initial snapshots on separate connections publish only one daytime quote", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    first = accept!(f)
    second = accept!(f, 2)
    assert {:ok, 2} = Recovery.recover_pending()
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
              10_000 -> raise "player release timeout"
            end
          end)
        end)
      end)

    assert_receive :locked, 5_000

    workers =
      Enum.map([first, second], fn request ->
        Task.async(fn ->
          ValuationConfigurationCase.in_client(f.namespace.schema, fn ->
            Repo.checkout(fn ->
              [[backend]] = Repo.query!("SELECT pg_backend_pid()").rows
              send(owner, {:backend, backend})
              Quotes.process_import_request(request.id)
            end)
          end)
        end)
      end)

    for _ <- workers do
      assert_receive {:backend, backend}, 5_000
      await_blocked(backend, 500)
    end

    send(locker.pid, :release)
    assert {:ok, :ok} = Task.await(locker, 5_000)
    assert Enum.map(workers, &Task.await(&1, 5_000)) == [:ok, :ok]
    assert [quote] = performance_quotes(f)
    assert {:ok, [_event]} = Quotes.pending_evaluations()
    requests = Enum.map([first, second], &Repo.get!(CalculationRequest, &1.id))
    assert Enum.sort(Enum.map(requests, & &1.state)) == ["pending", "successful"]
    pending = Enum.find(requests, &(&1.state == "pending"))
    assert pending.attempt_count == 0
    refute pending.initial_only
    assert {:ok, 0} = Recovery.recover_pending()
    assert performance_quotes(f) == [quote]
    assert {:ok, %{imports: 1}} = Closing.admit_now()
    assert :ok = Quotes.process_import_request(pending.id)
    assert length(performance_quotes(f)) == 2
  end

  test "nightly admission overlapping initial confirmation preserves close authority", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    first = accept!(f)
    second = accept!(f, 2)
    assert {:ok, 2} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(first.id)
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
              10_000 -> raise "player release timeout"
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
            Quotes.process_import_request(second.id)
          end)
        end)
      end)

    assert_receive {:backend, backend}, 5_000
    await_blocked(backend, 500)
    assert Repo.get!(CalculationRequest, second.id).state == "running"
    assert {:ok, %{imports: 1}} = Closing.admit_now()
    send(locker.pid, :release)
    assert {:ok, :ok} = Task.await(locker, 5_000)
    assert :ok = Task.await(worker, 5_000)
    assert Repo.get!(CalculationRequest, second.id).admitted_at
    assert length(performance_quotes(f)) == 2
  end

  test "initial retry retains selected configuration and never duplicates confirmation", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request = accept!(f)
    assert {:ok, 1} = Recovery.recover_pending()

    Repo.query!(
      "CREATE FUNCTION initial_retry_guard() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'retry'; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER initial_retry_guard BEFORE INSERT ON quote_calculations FOR EACH ROW EXECUTE FUNCTION initial_retry_guard()"
    )

    assert :ok = Quotes.process_import_request(request.id)

    assert %{state: "retrying", configuration_version_id: id} =
             Repo.get!(CalculationRequest, request.id)

    assert id == f.configuration.id

    {:ok, replacement} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.player.position_id, "balanced", %{goals: 4})
      )

    assert {:ok, _} = Configurations.activate(replacement.id, f.configuration.id)
    Repo.query!("DROP TRIGGER initial_retry_guard ON quote_calculations")
    Repo.query!("DROP FUNCTION initial_retry_guard()")

    Repo.query!("UPDATE quote_calculation_requests SET next_attempt_at=now() WHERE id=$1", [
      Ecto.UUID.dump!(request.id)
    ])

    assert {:ok, 1} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(request.id)
    assert :ok = Quotes.process_import_request(request.id)
    assert [quote] = performance_quotes(f)
    assert quote.configuration_version_id == f.configuration.id
    assert Decimal.equal?(quote.unit_price, Decimal.new("2.50"))
  end

  test "recovery after confirmation reuses its quote when request completion was interrupted",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request = accept!(f)
    assert {:ok, 1} = Recovery.recover_pending()

    Repo.query!("""
    CREATE FUNCTION initial_finish_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      IF NEW.state = 'successful' THEN RAISE EXCEPTION 'completion interrupted'; END IF;
      RETURN NEW;
    END $$
    """)

    Repo.query!(
      "CREATE TRIGGER initial_finish_guard BEFORE UPDATE ON quote_calculation_requests FOR EACH ROW EXECUTE FUNCTION initial_finish_guard()"
    )

    assert {:error, :calculation_unavailable} = Quotes.process_import_request(request.id)
    assert [quote] = performance_quotes(f)
    assert Repo.get!(CalculationRequest, request.id).state == "running"
    Repo.query!("DROP TRIGGER initial_finish_guard ON quote_calculation_requests")
    Repo.query!("DROP FUNCTION initial_finish_guard()")

    Repo.query!(
      "UPDATE quote_calculation_requests SET lease_until=now()-interval '1 second' WHERE id=$1",
      [Ecto.UUID.dump!(request.id)]
    )

    assert {:ok, 1} = Recovery.recover_pending()
    assert :ok = Quotes.process_import_request(request.id)
    assert Repo.get!(CalculationRequest, request.id).state == "successful"
    assert performance_quotes(f) == [quote]
    assert {:ok, [_event]} = Quotes.pending_evaluations()
  end

  defp accept!(f, index \\ 1, goals \\ 2) do
    candidate = Case.candidate(Fixtures.request(f.scope))

    match = %{
      hd(candidate.facts.matches)
      | ref: "match-#{index}",
        kickoff_at: DateTime.add(~U[2026-01-01 12:00:00Z], (index - 1) * 86_400, :second)
    }

    performance = %{
      hd(candidate.facts.performances)
      | ref: "performance-#{index}",
        match_ref: match.ref,
        counts: %{goals: goals, assists: nil}
    }

    candidate =
      Case.candidate(Fixtures.request(f.scope), matches: [match], performances: [performance])

    assert {:ok, accepted} =
             Statistics.Ingestion.import_scope(
               f.scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(f.scope)]
             )

    intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)

    assert {:ok, _} =
             CalculationRequests.accept(
               intent.id,
               intent.accepted_check_id,
               intent.changed_performance_ids
             )

    Repo.get_by!(CalculationRequest, intent_id: intent.id)
  end

  defp performance_quotes(f) do
    Repo.all(
      from q in FootballMarket.Market.Quote,
        where: q.player_id == ^f.player.id and not is_nil(q.calculation_id),
        order_by: q.performance_sequence
    )
  end

  defp drain do
    name =
      Application.fetch_env!(:football_market, FootballMarket.Synchronization)
      |> Keyword.fetch!(:oban_name)

    Oban.drain_queue(name, queue: :quote_calculation)
  end

  defp await_blocked(_backend, 0), do: flunk("initial worker did not reach player lock")

  defp await_blocked(backend, remaining) do
    if Repo.query!("SELECT cardinality(pg_blocking_pids($1)) > 0", [backend]).rows == [[true]] do
      :ok
    else
      Process.sleep(10)
      await_blocked(backend, remaining - 1)
    end
  end
end
