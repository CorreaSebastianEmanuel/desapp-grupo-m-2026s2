ExUnit.start(seed: 0)

defmodule Task019IndependentAcceptance do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.{Repo, Synchronization}
  alias FootballMarket.Synchronization.{Fixtures, Run}

  setup do
    old = Application.fetch_env!(:football_market, Synchronization)
    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => Fixtures.source()})
    FootballMarket.IngestionFixtures.positions!()
    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
    :ok
  end

  test "real HTTP reads remain available with queued and denied synchronization" do
    {:ok, _} = Application.ensure_all_started(:inets)
    fixture = FootballMarket.OpenAPICase.fixture!()
    source = %{Fixtures.source() | provider: {FootballMarket.Synchronization.ScriptAdapter, %{owner: self(), outcome: {:error, %{category: :authentication_failed}}}}}
    Application.put_env(:football_market, Synchronization, sources: %{"denied" => source})
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "denied")
    {base, listener} = FootballMarket.OpenAPICase.start_server!()
    try do
      for phase <- [:queued, :failed] do
        if phase == :failed do
          execute(accepted.run_id)
          assert_receive :synchronization_provider_called
          assert {:ok, %{state: "failed"}} = Synchronization.get_run(accepted.run_id)
        end
        for {path, authorized, expected} <- [
          {"/api/players", true, 200},
          {"/api/players/" <> fixture.player.id, true, 200},
          {"/api/players", false, 401},
          {"/api/players/" <> fixture.player.id, false, 401},
          {"/api/players/" <> Ecto.UUID.generate(), true, 404}
        ] do
          request_headers = if authorized, do: [{~c"authorization", String.to_charlist("Bearer " <> fixture.jwt)}], else: []
          {:ok, {{_, status, _}, headers, body}} = :httpc.request(:get, {String.to_charlist(base <> path), request_headers}, [timeout: 5000], body_format: :binary)
          assert status == expected
          relevant = Map.new(headers, fn {k,v} -> {to_string(k), to_string(v)} end) |> Map.take(["content-type", "www-authenticate"])
          assert relevant["content-type"] =~ "application/json"
          if expected == 401, do: assert(relevant["www-authenticate"] =~ "Bearer")
          decoded = Jason.decode!(body)
          case expected do
            200 -> assert body =~ fixture.player.id
            401 -> assert decoded["error"]["code"] == "unauthenticated"
            404 -> assert decoded["error"]["code"] == "player_not_found"
          end
          IO.puts("QA_HTTP " <> Jason.encode!(%{phase: phase, path: path, status: status, headers: relevant, response: decoded}))
        end
        refute_receive :synchronization_provider_called, 0
      end
    after
      Supervisor.stop(listener)
    end
  end

  test "worker retains stale and reconciliation failures without retries or catalog changes" do
    run_source(Fixtures.source())
    before = FootballMarket.IngestionFixtures.snapshot()
    candidate = FootballMarket.IngestionFixtures.candidate("PL", 2090)
    stale = %{Fixtures.source() | runtime: {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-14 12:00:00.000000Z]}}}
    conflicting = %{Fixtures.source() | provider: {FootballMarket.IngestionFixtureAdapter, %{candidate | fixture_id: "qa-independent-conflict"}}}
    for {source, expected} <- [{stale, "stale_observation"}, {conflicting, "reconciliation_conflict"}] do
      id = run_source(source)
      assert {:ok, run} = Synchronization.get_run(id)
      assert run.state == "failed"
      assert run.reason == "non_retryable"
      assert run.outcome["status"] == expected
      assert length(run.attempts) == 1
      assert is_nil(run.next_retry_at)
      assert FootballMarket.IngestionFixtures.snapshot() == before
      IO.puts("QA_DOMAIN status=#{expected} attempts=1 next_retry=nil catalog_unchanged=true")
    end
  end

  test "malformed configured runtime is rejected before executable work" do
    data = FootballMarket.Providers.ScrapingFixtureData.case!("access-scoped")
    source = %{
      provider: {FootballMarket.Providers.Scraping, FootballMarket.Providers.ScrapingFixtureData.state(data)},
      fixture_path: "test/fixtures/scraping/documents.exs",
      runtime: :invalid_runtime_configuration
    }
    Application.put_env(:football_market, Synchronization, sources: %{"malformed" => source})
    actual = Synchronization.request_catalog(FootballMarket.Providers.ScrapingFixtureData.request(data), source_ref: "malformed")
    IO.puts("QA_INVALID_SOURCE " <> inspect(actual))
    IO.puts("QA_INVALID_SOURCE executable_jobs=" <> to_string(Repo.aggregate(Oban.Job, :count)))
    if match?({:ok, _}, actual) do
      {:ok, accepted} = actual
      execute(accepted.run_id)
      {:ok, run} = Synchronization.get_run(accepted.run_id)
      IO.puts("QA_INVALID_SOURCE execution=" <> inspect(%{state: run.state, reason: run.reason, attempts: length(run.attempts)}))
    end
    assert {:error, %{category: :invalid_request}} = actual
    assert Repo.aggregate(Oban.Job, :count) == 0
  end

  defp run_source(source) do
    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    execute(accepted.run_id)
    accepted.run_id
  end

  defp execute(id) do
    run = Repo.get!(Run, id)
    assert :ok = FootballMarket.Workers.CatalogSync.perform(%Oban.Job{args: %{"run_id" => id, "delivery_id" => run.delivery_id}})
  end
end
