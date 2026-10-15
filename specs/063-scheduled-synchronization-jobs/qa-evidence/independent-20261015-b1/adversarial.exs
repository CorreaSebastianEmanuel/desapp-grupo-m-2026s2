ExUnit.start(autorun: false)

defmodule IndependentTask019QA do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.Synchronization, as: Sync
  alias FootballMarket.Synchronization.{Fixtures, Run, Scheduler, Occurrence, Trigger}

  setup do
    old = Application.get_env(:football_market, Sync)
    on_exit(fn -> Application.put_env(:football_market, Sync, old) end)
    :ok
  end

  test "B1 rejects malformed and incomplete effective runtimes before all admission paths" do
    alias FootballMarket.Providers.ScrapingFixtureData, as: Data
    data = Data.case!("access-scoped")
    base = %{provider: {FootballMarket.Providers.Scraping, Data.state(data)}, fixture_path: "test/fixtures/scraping/documents.exs"}
    for runtime <- [:invalid_runtime_configuration, nil, {}, {NonexistentQARuntime, nil}, {__MODULE__, nil}, {FootballMarket.Providers.Runtime, nil, :extra}] do
      Application.put_env(:football_market, Sync, sources: %{"qa" => Map.put(base, :runtime, runtime)})
      for trigger <- [:manual, :initial] do
        assert {:error, %{category: :invalid_request}} = Sync.request_catalog(Data.request(data), source_ref: "qa", trigger: trigger)
      end
      assert {:error, :invalid_schedule} = Sync.configure_schedule("qa", %{enabled: true, scope: Data.request(data), source_ref: "qa"})
    end
    for schema <- [Run, Trigger, Occurrence, Oban.Job, FootballMarket.Catalog.Ingestion.Observation] do
      assert Repo.aggregate(schema, :count) == 0
    end
    refute_receive {:scraping_fetch, _, _}, 0
    for source <- [base, Map.put(base, :runtime, {FootballMarket.Providers.FixtureRuntime, %{}})] do
      Application.put_env(:football_market, Sync, sources: %{"qa" => source})
      assert {:ok, %{status: :queued}} = Sync.request_catalog(Data.request(data), source_ref: "qa")
      # Release this control run without invoking retrieval.
      Repo.update_all(Run, set: [state: "failed"])
    end
    IO.puts("QA_B1_PASS malformed=6 triggers=initial/manual/scheduled writes=0 valid_explicit/default=accepted live_calls=0")
  end

  test "persisted due input drift remains unhandled and original restoration admits once" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    good = Fixtures.source()
    Application.put_env(:football_market, Sync, sources: %{"qa" => good})
    {:ok, _} = Sync.configure_schedule("qa-due", %{enabled: true, scope: Fixtures.scope(), source_ref: "qa"})
    for source <- [Map.put(good, :runtime, :invalid_runtime_configuration), Map.put(good, :provider, {FootballMarket.IngestionFixtureAdapter, :changed})] do
      Application.put_env(:football_market, Sync, sources: %{"qa" => source})
      assert {:error, _} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
      assert Repo.aggregate(Run, :count) == 0
      assert Repo.aggregate(Oban.Job, :count) == 0
      assert Repo.aggregate(Occurrence, :count) == 0
    end
    Application.put_env(:football_market, Sync, sources: %{"qa" => good})
    assert {:ok, [_]} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    assert {:ok, []} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    IO.puts("QA_DUE_PASS invalid/drifted=rollback restoration=one_handled_occurrence")
  end

  test "ten actual scheduler/manual/initial admissions share one active scope" do
    FootballMarket.Synchronization.Case.with_store(fn repo ->
      Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
      {:ok, _} = Sync.configure_schedule("qa-race", %{enabled: true, scope: Fixtures.scope(), source_ref: "fixture", recurrence: "* * * * *"})
      results = FootballMarket.Synchronization.Case.race(10, fn index ->
        if index == 1 do
          Scheduler.tick(~U[2026-10-15 12:00:00.000000Z])
        else
          Sync.request_catalog(Fixtures.scope(), source_ref: "fixture", trigger: if(rem(index, 2) == 0, do: :initial, else: :manual))
        end
      end, repo)
      admitted = Enum.flat_map(results, fn
        {:ok, rows} when is_list(rows) -> rows
        {:ok, row} -> [row]
      end)
      assert length(admitted) == 10
      assert length(Enum.uniq_by(admitted, & &1.run_id)) == 1
      assert Enum.count(admitted, &(&1.disposition == :created)) == 1
      assert Repo.aggregate(Run, :count) == 1
      assert Repo.aggregate(Trigger, :count) == 10
      assert Repo.aggregate(Occurrence, :count) == 1
      IO.puts("QA_MIXED_RACE_PASS distinct_backends=10 actual_due_scheduler=1 initial/manual=9 runs=1 triggers=10 occurrences=1")
    end)
  end

  test "provider minimum delay is persisted and an early redelivery does not spend budget" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    FootballMarket.IngestionFixtures.positions!()
    {:ok, script} = Agent.start_link(fn -> [
      {:error, %{category: :rate_limited, retry_after_ms: 120_001}},
      {:ok, FootballMarket.IngestionFixtures.candidate("PL", 2090)}
    ] end)
    on_exit(fn -> if Process.alive?(script), do: Agent.stop(script) end)
    source = %{Fixtures.source() | provider: {FootballMarket.Synchronization.ScriptAdapter, %{owner: self(), script: script}}}
    Application.put_env(:football_market, Sync, sources: %{"qa" => source})
    {:ok, accepted} = Sync.request_catalog(Fixtures.scope(), source_ref: "qa")
    execute = fn ->
      run = Repo.get!(Run, accepted.run_id)
      FootballMarket.Workers.CatalogSync.perform(%Oban.Job{args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}})
    end
    assert :ok = execute.()
    assert_receive :synchronization_provider_called
    assert {:ok, %{state: "retry_wait", next_retry_at: ~U[2026-10-15 12:02:01.000000Z]}} = Sync.get_run(accepted.run_id)
    Process.put(:synchronization_now, ~U[2026-10-15 12:02:00.000000Z])
    assert :ok = execute.()
    refute_receive :synchronization_provider_called, 0
    assert {:ok, %{attempts: [_]}} = Sync.get_run(accepted.run_id)
    Process.put(:synchronization_now, ~U[2026-10-15 12:02:01.000000Z])
    assert :ok = execute.()
    assert_receive :synchronization_provider_called
    assert {:ok, %{state: "succeeded", attempts: [_, _]}} = Sync.get_run(accepted.run_id)
    IO.puts("QA_PROVIDER_WAIT_PASS guidance_ms=120001 deadline=12:02:01 early_attempts=1 terminal_attempts=2")
  end

  test "real HTTP catalog stays readable during queued and failed synchronization" do
    {:ok, _} = Application.ensure_all_started(:inets)
    fixture = FootballMarket.OpenAPICase.fixture!()
    source = %{Fixtures.source() | provider: {FootballMarket.Synchronization.ScriptAdapter, %{owner: self(), outcome: {:error, %{category: :authentication_failed}}}}}
    Application.put_env(:football_market, Sync, sources: %{"qa" => source})
    {:ok, accepted} = Sync.request_catalog(Fixtures.scope(), source_ref: "qa")
    {base, listener} = FootballMarket.OpenAPICase.start_server!()
    try do
      for phase <- [:queued, :failed] do
        if phase == :failed do
          run = Repo.get!(Run, accepted.run_id)
          assert :ok = FootballMarket.Workers.CatalogSync.perform(%Oban.Job{args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}})
          assert_receive :synchronization_provider_called
          assert {:ok, %{state: "failed", reason: "non_retryable"}} = Sync.get_run(run.id)
        end
        for path <- ["/api/players", "/api/players/" <> fixture.player.id] do
          {200, headers, body} = get(base <> path, fixture.jwt)
          assert headers["content-type"] =~ "application/json"
          assert body =~ fixture.player.id
          data = Jason.decode!(body)["data"]
          assert data
          player = if is_list(data), do: Enum.find(data, &(&1["id"] == fixture.player.id)), else: data
          assert player["id"] == fixture.player.id
          emit(phase, path, 200, headers, Map.take(player, ["id", "display_name"]))
          {401, denied_headers, denied_body} = get(base <> path, nil)
          assert denied_headers["www-authenticate"]
          assert Jason.decode!(denied_body)["error"]["code"] == "unauthenticated"
          emit(phase, path, 401, denied_headers, "error.code=unauthenticated")
        end
        {404, headers, body} = get(base <> "/api/players/" <> Ecto.UUID.generate(), fixture.jwt)
        assert Jason.decode!(body)["error"]["code"] == "player_not_found"
        emit(phase, "/api/players/:missing", 404, headers, "error.code=player_not_found")
        refute_receive :synchronization_provider_called, 0
        refute_receive {:scraping_fetch, _, _}, 0
      end
    after
      Supervisor.stop(listener)
    end
  end

  defp get(url, token) do
    headers = if token, do: [{~c"authorization", String.to_charlist("Bearer " <> token)}], else: []
    {:ok, {{_, status, _}, response_headers, body}} = :httpc.request(:get, {String.to_charlist(url), headers}, [timeout: 5000], body_format: :binary)
    {status, Map.new(response_headers, fn {k,v} -> {to_string(k), to_string(v)} end), body}
  end
  defp emit(phase, path, status, headers, evidence) do
    IO.puts(Jason.encode!(%{phase: phase, path: path, status: status, headers: Map.take(headers, ["content-type", "www-authenticate"]), response_evidence: evidence}))
  end
end

result = ExUnit.run()
if result.failures > 0, do: System.halt(1)
