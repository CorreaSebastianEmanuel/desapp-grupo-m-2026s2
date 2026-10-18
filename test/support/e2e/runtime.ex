defmodule FootballMarket.E2E.Runtime do
  @moduledoc "Test-only owned-schema lifecycle. Invoke only in a disposable test BEAM."
  alias FootballMarket.{Repo, Synchronization}

  def validate_database!(database, partition) do
    if database != "football_market_test" <> partition,
      do: raise(ArgumentError, "unsafe e2e database")

    :ok
  end

  def schema, do: "e2e_" <> String.replace(Ecto.UUID.generate(), "-", "")

  defp register_schema!(schema) do
    if path = System.get_env("PROFILE_RESOURCES") do
      nonce = System.fetch_env!("PROFILE_RESOURCE_NONCE")
      previous = if File.exists?(path), do: path |> File.read!() |> Jason.decode!(), else: []

      record = %{
        schema: schema,
        nonce: nonce,
        database: Repo.config()[:database],
        partition: System.get_env("MIX_TEST_PARTITION", "")
      }

      temporary = path <> ".pending"
      File.write!(temporary, Jason.encode!(previous ++ [record]), [:exclusive])
      File.chmod!(temporary, 0o600)
      File.rename!(temporary, path)
    end
  end

  def cleanup_registered! do
    if Mix.env() != :test, do: raise("e2e test environment required")
    path = System.fetch_env!("PROFILE_RESOURCES")
    nonce = System.fetch_env!("PROFILE_RESOURCE_NONCE")
    partition = System.get_env("MIX_TEST_PARTITION", "")
    config = Application.fetch_env!(:football_market, Repo)
    validate_database!(config[:database], partition)
    records = path |> File.read!() |> Jason.decode!()
    unless is_list(records), do: raise("invalid resource registry")

    Enum.each(records, fn record ->
      owned_schema!(record["schema"])

      unless record["nonce"] == nonce and record["partition"] == partition and
               record["database"] == config[:database],
             do: raise("invalid resource owner")
    end)

    {:ok, _} = Application.ensure_all_started(:ecto_sql)
    {:ok, _} = Application.ensure_all_started(:postgrex)

    {:ok, repo} =
      Repo.start_link(
        Keyword.merge(config,
          pool: DBConnection.ConnectionPool,
          pool_size: 1,
          connect_timeout: 5_000
        )
      )

    try do
      Enum.each(records, fn record ->
        Ecto.Adapters.SQL.query!(
          Repo,
          "DROP SCHEMA IF EXISTS " <> record["schema"] <> " CASCADE",
          [],
          timeout: 5_000
        )
      end)
    after
      Supervisor.stop(repo)
    end
  end

  def configuration(schema, port) do
    owned_schema!(schema)
    repo = Application.fetch_env!(:football_market, Repo)
    endpoint = Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)

    %{
      repo:
        Keyword.merge(repo, pool: DBConnection.ConnectionPool, parameters: [search_path: schema]),
      oban: [
        repo: Repo,
        prefix: schema,
        testing: :disabled,
        queues: [catalog_sync: 1],
        plugins: []
      ],
      sync: [enabled: true, automatic: false, sources: %{}, schedules: []],
      endpoint: Keyword.merge(endpoint, server: true, http: [ip: {127, 0, 0, 1}, port: port])
    }
  end

  def drop_schema!(schema) do
    owned_schema!(schema)

    outside_sandbox(fn ->
      Ecto.Adapters.SQL.query!(Repo, "DROP SCHEMA IF EXISTS " <> schema <> " CASCADE", [])
    end)

    :ok
  end

  defp outside_sandbox(fun) do
    if Repo.config()[:pool] == Ecto.Adapters.SQL.Sandbox,
      do: Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fun),
      else: fun.()
  end

  defp owned_schema!(schema) do
    unless is_binary(schema) and Regex.match?(~r/^e2e_[a-f0-9]{32}$/, schema),
      do: raise(ArgumentError, "unsafe e2e schema")
  end

  def await!(probe, milliseconds \\ 30_000) do
    poll!(probe, System.monotonic_time(:millisecond) + milliseconds)
  end

  defp poll!(probe, deadline) do
    result = probe.()
    if System.monotonic_time(:millisecond) > deadline, do: raise("e2e deadline")

    case result do
      {:ok, value} ->
        value

      {:error, _} ->
        raise "e2e terminal failure"

      :pending ->
        if System.monotonic_time(:millisecond) >= deadline, do: raise("e2e deadline")
        Process.sleep(min(25, max(1, deadline - System.monotonic_time(:millisecond))))
        poll!(probe, deadline)
    end
  end

  def with_runtime!(scenario) do
    if Mix.env() != :test, do: raise("e2e test environment required")
    validate_database!(Repo.config()[:database], System.get_env("MIX_TEST_PARTITION", ""))
    %{rows: [[1]]} = outside_sandbox(fn -> Ecto.Adapters.SQL.query!(Repo, "SELECT 1", []) end)
    redis = Application.fetch_env!(:football_market, :redis)
    {:ok, connection} = Redix.start_link(Keyword.put(redis, :sync_connect, true))

    try do
      {:ok, "PONG"} = Redix.command(connection, ["PING"], timeout: 5_000)
    after
      GenServer.stop(connection)
    end

    unless File.regular?("priv/static/assets/js/app.js"), do: raise("e2e assets unavailable")
    owned = schema()
    register_schema!(owned)
    outside_sandbox(fn -> Ecto.Adapters.SQL.query!(Repo, "CREATE SCHEMA " <> owned, []) end)
    endpoint = FootballMarketWeb.Endpoint
    keys = [Repo, Oban, Synchronization, endpoint, :browser_clock]
    original = Map.new(keys, &{&1, Application.get_env(:football_market, &1)})
    {:ok, socket} = :gen_tcp.listen(0, ip: {127, 0, 0, 1}, active: false)
    {:ok, port} = :inet.port(socket)
    :gen_tcp.close(socket)

    try do
      :ok = Application.stop(:football_market)
      config = configuration(owned, port)
      Application.put_env(:football_market, Repo, config.repo)
      Application.put_env(:football_market, Oban, config.oban)
      Application.put_env(:football_market, Synchronization, config.sync)
      Application.put_env(:football_market, endpoint, config.endpoint)
      {:ok, repo} = Repo.start_link()

      try do
        compiler = Code.compiler_options(ignore_module_conflict: true)

        try do
          Ecto.Migrator.run(Repo, :up, all: true, prefix: owned, log: false)
        after
          Code.compiler_options(compiler)
        end
      after
        Supervisor.stop(repo)
      end

      {:ok, _} = Application.ensure_all_started(:football_market)
      {:ok, _} = Application.ensure_all_started(:inets)
      base = "http://127.0.0.1:#{port}"

      await!(fn ->
        case get(base <> "/sign-in") do
          {200, _, _} -> {:ok, :ready}
          _ -> :pending
        end
      end)

      scenario.(base)
    after
      Application.stop(:football_market)

      Enum.each(original, fn
        {key, nil} -> Application.delete_env(:football_market, key)
        {key, value} -> Application.put_env(:football_market, key, value)
      end)

      {:ok, _} = Application.ensure_all_started(:football_market)
      drop_schema!(owned)
    end
  end

  def get(url, jwt \\ nil) do
    headers = if jwt, do: [{~c"authorization", String.to_charlist("Bearer " <> jwt)}], else: []

    case :httpc.request(
           :get,
           {String.to_charlist(url), headers},
           [timeout: 5_000, autoredirect: false],
           body_format: :binary
         ) do
      {:ok, {{_, status, _}, response_headers, body}} -> {status, response_headers, body}
      _ -> {:unavailable, [], ""}
    end
  end
end
