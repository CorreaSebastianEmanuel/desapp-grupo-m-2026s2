defmodule FootballMarket.Synchronization.RuntimeProbe do
  @moduledoc "Owned-schema, real HTTP and disposable BEAM acceptance probe."
  import ExUnit.Assertions
  alias FootballMarket.{Repo, Synchronization}
  alias FootballMarket.Synchronization.{Fixtures, Run, Store, ExecutionGuard}

  def run! do
    assert Mix.env() == :test

    assert Repo.config()[:database] ==
             "football_market_test" <> System.get_env("MIX_TEST_PARTITION", "")

    %{rows: [[1]]} = Ecto.Adapters.SQL.query!(Repo, "SELECT 1", [])
    schema = "sync_runtime_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Ecto.Adapters.SQL.query!(Repo, "CREATE SCHEMA " <> schema, [])
    original_repo = Application.fetch_env!(:football_market, Repo)
    original_oban = Application.fetch_env!(:football_market, Oban)
    original_sync = Application.fetch_env!(:football_market, Synchronization)
    original_redis = Application.fetch_env!(:football_market, :redis)

    try do
      :ok = Application.stop(:football_market)
      isolated_config(schema)
      {:ok, repo} = Repo.start_link()

      try do
        Ecto.Migrator.run(Repo, :up, all: true, prefix: schema, log: false)
      after
        Supervisor.stop(repo)
      end

      {:ok, _} = Application.ensure_all_started(:football_market)
      {:ok, _} = Application.ensure_all_started(:inets)
      {:ok, fixture} = Repo.transaction(fn -> FootballMarket.OpenAPICase.fixture!() end)
      FootballMarket.IngestionFixtures.positions!()

      sources = %{
        "fixture" => Fixtures.source(),
        "notify" => %{
          Fixtures.source()
          | provider:
              {FootballMarket.IngestionFixtureAdapter,
               {:notify, self(), FootballMarket.IngestionFixtures.candidate("PL", 2090)}}
        },
        "denied" => %{
          Fixtures.source()
          | provider:
              {FootballMarket.Synchronization.ScriptAdapter,
               %{owner: self(), outcome: {:error, %{category: :authentication_failed}}}}
        }
      }

      Application.put_env(:football_market, Synchronization, sources: sources, automatic: false)
      financial = snapshot()

      assert {:ok, queued} =
               Synchronization.request_catalog(Fixtures.scope(), source_ref: "notify")

      with_http(fixture)
      refute_receive :source_called, 0
      refute_receive :synchronization_provider_called, 0

      assert Oban.drain_queue(queue: :catalog_sync, with_scheduled: true, with_limit: 1).success ==
               1

      assert_receive :source_called, 1000
      assert {:ok, %{state: "succeeded"}} = Synchronization.get_run(queued.run_id)

      assert {:ok, denied} =
               Synchronization.request_catalog(Fixtures.scope(), source_ref: "denied")

      assert Oban.drain_queue(queue: :catalog_sync, with_scheduled: true, with_limit: 1).success ==
               1

      assert_receive :synchronization_provider_called, 1000
      assert {:ok, %{state: "failed"}} = Synchronization.get_run(denied.run_id)
      with_http(fixture)
      refute_receive :source_called, 0
      refute_receive :synchronization_provider_called, 0
      assert snapshot() == financial

      set_clock(~U[2026-10-15 12:00:00.000000Z])
      sources = Map.put(sources, "scheduled", Fixtures.source(2092))

      Application.put_env(:football_market, Synchronization,
        sources: sources,
        automatic: false,
        test_now: ~U[2026-10-15 12:00:00.000000Z]
      )

      definition = %{enabled: true, scope: Fixtures.scope(2092), source_ref: "scheduled"}

      {:ok, schedule} =
        FootballMarket.Synchronization.Scheduler.configure("runtime-daily", definition)

      assert {:ok, [_]} =
               FootballMarket.Synchronization.Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])

      assert {:ok, pending} =
               Synchronization.request_catalog(Fixtures.scope(2091), source_ref: "fixture")

      :ok = Application.stop(:football_market)
      Application.put_env(:football_market, :redis, host: "127.0.0.1", port: 1)
      {:ok, _} = Application.ensure_all_started(:football_market)
      assert {:ok, %{state: "queued"}} = Synchronization.get_run(pending.run_id)

      {:ok, restarted_schedule} =
        FootballMarket.Synchronization.Scheduler.configure("runtime-daily", definition)

      assert restarted_schedule.generation == schedule.generation

      assert {:ok, []} =
               FootballMarket.Synchronization.Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])

      with_http(fixture)
      # Actual disposable BEAM termination leaves a committed begun attempt.
      crash_child!(schema, pending.run_id, "before")
      assert {:ok, %{state: "executing"}} = Synchronization.get_run(pending.run_id)
      set_clock(~U[2026-10-15 12:00:10.000000Z])
      assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick()
      assert {:ok, interrupted} = Synchronization.get_run(pending.run_id)
      assert interrupted.state == "retry_wait"
      assert interrupted.next_retry_at == ~U[2026-10-15 12:01:10.000000Z]
      assert hd(interrupted.attempts).status == "interrupted"

      # On attempt three a confirmed receipt finalizes without a fourth retrieval.
      assert {:ok, final} =
               Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

      fail_attempt!(final.run_id, ~U[2026-10-15 12:00:00.000000Z])
      fail_attempt!(final.run_id, ~U[2026-10-15 12:01:00.000000Z])
      crash_child!(schema, final.run_id, "after")
      set_clock(~U[2026-10-15 12:06:10.000000Z])
      assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick()
      assert {:ok, recovered} = Synchronization.get_run(final.run_id)
      assert recovered.state == "succeeded"
      assert length(recovered.attempts) == 3
      assert recovered.outcome["status"] == "replay"
      assert snapshot() == financial
      with_http(fixture)
      isolated_redis!(final.run_id)

      IO.puts(
        "TASK019_RUNTIME_PASS postgres=http_ready auth=200/401/404 restart=durable beam_crash=confirmed redis=absent/cleared/reconnected"
      )
    after
      Application.stop(:football_market)
      Application.put_env(:football_market, Repo, original_repo)
      Application.put_env(:football_market, Oban, original_oban)
      Application.put_env(:football_market, Synchronization, original_sync)
      Application.put_env(:football_market, :redis, original_redis)
      {:ok, _} = Application.ensure_all_started(:football_market)
      Ecto.Adapters.SQL.query!(Repo, "DROP SCHEMA " <> schema <> " CASCADE", [])
    end
  end

  def crash(schema, run_id, mode) do
    assert String.match?(schema, ~r/^sync_runtime_[a-f0-9]+$/)
    isolated_config(schema)
    {:ok, _} = Application.ensure_all_started(:football_market)
    Process.put(:synchronization_now, ~U[2026-10-15 12:06:00.000000Z])
    run = Repo.get!(Run, run_id)

    if mode == "before" do
      {:ok, _guard} = ExecutionGuard.acquire(Store.scope(run))
      {:ok, {_, _, _}} = Store.claim(run.id, run.delivery_id, ~U[2026-10-15 12:00:00.000000Z])
    else
      Process.put(:synchronization_failpoint, :during_completion)
      execute(run.id)
      assert Repo.get!(Run, run.id).state == "executing"
    end

    System.halt(17)
  end

  defp isolated_config(schema) do
    repo = Application.fetch_env!(:football_market, Repo)

    Application.put_env(
      :football_market,
      Repo,
      Keyword.merge(repo, parameters: [search_path: schema])
    )

    Application.put_env(:football_market, Oban,
      repo: Repo,
      prefix: schema,
      testing: :manual,
      queues: [catalog_sync: 1],
      plugins: []
    )

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()},
      automatic: false
    )
  end

  defp crash_child!(schema, run_id, mode) do
    expression =
      "FootballMarket.Synchronization.RuntimeProbe.crash(#{inspect(schema)}, #{inspect(run_id)}, #{inspect(mode)})"

    FootballMarket.Synchronization.Case.disposable_beam!(expression)
  end

  defp set_clock(now) do
    config = Application.fetch_env!(:football_market, Synchronization)
    Application.put_env(:football_market, Synchronization, Keyword.put(config, :test_now, now))
  end

  defp fail_attempt!(id, now) do
    run = Repo.get!(Run, id)
    {:ok, {_, _, _}} = Store.claim(run.id, run.delivery_id, now)

    outcome =
      FootballMarket.Catalog.Ingestion.Outcome.failure(
        :persistence_failure,
        Store.scope(run),
        :publication_failed
      )

    {:ok, _} = Store.complete(run.id, run.delivery_id, outcome, now)
  end

  defp execute(id) do
    run = Repo.get!(Run, id)

    :ok =
      FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
        args: %{"run_id" => id, "delivery_id" => run.delivery_id}
      })
  end

  defp with_http(fixture) do
    {base, listener} = FootballMarket.OpenAPICase.start_server!()

    try do
      ready!(base, 50)

      for path <- ["/api/players", "/api/players/" <> fixture.player.id] do
        {status, headers, body} = get(base <> path, fixture.jwt)
        assert status == 200

        assert List.keyfind(headers, ~c"content-type", 0) |> elem(1) |> to_string() =~
                 "application/json"

        decoded = Jason.decode!(body)
        assert body =~ fixture.player.id
        assert Map.has_key?(decoded, "data")
        {denied, denied_headers, denied_body} = get(base <> path, nil)
        assert denied == 401
        assert List.keyfind(denied_headers, ~c"www-authenticate", 0)
        assert Jason.decode!(denied_body)["error"]["code"] == "unauthenticated"

        assert List.keyfind(denied_headers, ~c"content-type", 0) |> elem(1) |> to_string() =~
                 "application/json"
      end

      {404, missing_headers, missing} =
        get(base <> "/api/players/" <> Ecto.UUID.generate(), fixture.jwt)

      assert Jason.decode!(missing)["error"]["code"] == "player_not_found"

      assert List.keyfind(missing_headers, ~c"content-type", 0) |> elem(1) |> to_string() =~
               "application/json"
    after
      Supervisor.stop(listener)
    end
  end

  defp ready!(_base, 0), do: flunk("loopback HTTP listener unavailable")

  defp ready!(base, remaining) do
    case :httpc.request(:get, {String.to_charlist(base <> "/api/players"), []}, [timeout: 1000],
           body_format: :binary
         ) do
      {:ok, {{_, 401, _}, _, _}} ->
        :ok

      _ ->
        Process.sleep(100)
        ready!(base, remaining - 1)
    end
  end

  defp get(url, jwt) do
    headers = if jwt, do: [{~c"authorization", String.to_charlist("Bearer " <> jwt)}], else: []

    {:ok, {{_, status, _}, response_headers, body}} =
      :httpc.request(:get, {String.to_charlist(url), headers}, [timeout: 5000],
        body_format: :binary
      )

    {status, response_headers, body}
  end

  defp isolated_redis!(run_id) do
    [_, image] = Regex.run(~r/image: (redis:\S+)/, File.read!("compose.yaml"))

    {output, 0} =
      System.cmd(
        "docker",
        [
          "run",
          "--detach",
          "--rm",
          "--label",
          "football-market.task019.runtime",
          "--publish",
          "127.0.0.1::6379",
          image,
          "redis-server",
          "--save",
          "",
          "--appendonly",
          "no"
        ],
        stderr_to_stdout: true
      )

    container = String.trim(output)
    assert String.match?(container, ~r/^[a-f0-9]{64}$/)

    try do
      {mapping, 0} = System.cmd("docker", ["port", container, "6379/tcp"])
      port = mapping |> String.trim() |> String.split(":") |> List.last() |> String.to_integer()
      {:ok, redis} = connect_redis(port, 30)

      try do
        Application.put_env(:football_market, :redis, host: "127.0.0.1", port: port)
        {:ok, before} = Synchronization.get_run(run_id)
        assert Redix.command!(redis, ["SET", "probe-owned-cache", "discardable"]) == "OK"
        assert Redix.command!(redis, ["FLUSHDB"]) == "OK"
        assert {:ok, ^before} = Synchronization.get_run(run_id)
      after
        GenServer.stop(redis)
      end

      {:ok, reconnected} = connect_redis(port, 30)

      try do
        assert Redix.command!(reconnected, ["PING"]) == "PONG"
        assert {:ok, %{state: "succeeded", attempts: attempts}} = Synchronization.get_run(run_id)
        assert length(attempts) == 3
      after
        GenServer.stop(reconnected)
      end
    after
      {_, 0} = System.cmd("docker", ["stop", "--time", "1", container], stderr_to_stdout: true)
    end
  end

  defp connect_redis(_port, 0), do: flunk("owned isolated Redis unavailable")

  defp connect_redis(port, remaining) do
    case Redix.start_link(host: "127.0.0.1", port: port, sync_connect: true) do
      {:ok, redis} ->
        {:ok, redis}

      _ ->
        Process.sleep(100)
        connect_redis(port, remaining - 1)
    end
  end

  defp snapshot do
    for table <-
          ~w(market_initial_recipients market_quotes market_holdings market_issuances matches player_match_performances),
        into: %{} do
      {table,
       Ecto.Adapters.SQL.query!(
         Repo,
         "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text",
         []
       ).rows}
    end
  end
end
