defmodule FootballMarket.Synchronization.Case do
  @moduledoc "Owned committed rows and genuinely independent PostgreSQL backends."
  use ExUnit.CaseTemplate
  import ExUnit.Assertions

  using do
    quote do
      alias FootballMarket.{Repo, Synchronization}
      alias FootballMarket.Synchronization.Fixtures
      import Ecto.Query
    end
  end

  def race(count, fun, repo \\ nil) do
    parent = self()
    ref = make_ref()
    supervisor = ExUnit.Callbacks.start_supervised!(Task.Supervisor)

    tasks =
      for index <- 1..count do
        Task.Supervisor.async_nolink(supervisor, fn ->
          run_worker(index, parent, ref, fun, repo)
        end)
      end

    backends =
      for task <- tasks do
        receive do
          {^ref, pid, backend} when pid == task.pid -> backend
        after
          5000 -> raise "synchronization connection readiness timed out"
        end
      end

    if length(Enum.uniq(backends)) != count, do: raise("distinct backends required")
    for task <- tasks, do: send(task.pid, {ref, :go})
    Enum.map(tasks, &Task.await(&1, 15_000))
  end

  defp run_worker(index, parent, ref, fun, repo) do
    if repo, do: FootballMarket.Repo.put_dynamic_repo(repo)

    runner = fn ->
      %{rows: [[backend]]} = FootballMarket.Repo.query!("SELECT pg_backend_pid()", [])
      send(parent, {ref, self(), backend})
      await_race(ref, fun, index)
    end

    Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, runner)
  end

  defp await_race(ref, fun, index) do
    receive do
      {^ref, :go} -> if is_function(fun, 1), do: fun.(index), else: fun.()
    after
      5000 -> raise "synchronization race barrier timed out"
    end
  end

  def disposable_beam!(expression) do
    port =
      Port.open({:spawn_executable, System.find_executable("mix")}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        args: ["run", "--no-start", "-e", expression]
      ])

    await_crash(port, System.monotonic_time(:millisecond) + 30_000)
  end

  defp await_crash(port, deadline) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {^port, {:data, _}} ->
        await_crash(port, deadline)

      {^port, {:exit_status, status}} ->
        assert status == 17, "disposable BEAM did not reach its crash checkpoint"
    after
      remaining ->
        case Port.info(port, :os_pid) do
          {:os_pid, pid} -> System.cmd("/bin/kill", ["-KILL", Integer.to_string(pid)])
          _ -> :ok
        end

        if Port.info(port), do: Port.close(port)
        flunk("disposable BEAM exceeded bounded readiness")
    end
  end

  def with_store(fun) do
    alias FootballMarket.Repo
    schema = "sync_test_" <> String.replace(Ecto.UUID.generate(), "-", "")

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Repo.query!("CREATE SCHEMA " <> schema, [])
    end)

    options =
      Repo.config()
      |> Keyword.merge(
        name: nil,
        pool: Ecto.Adapters.SQL.Sandbox,
        pool_size: 20,
        parameters: [search_path: "public"]
      )

    {:ok, repo} = Repo.start_link(options)
    previous = Repo.get_dynamic_repo()
    Repo.put_dynamic_repo(repo)
    old = Application.get_env(:football_market, FootballMarket.Synchronization)

    try do
      for {version, file, module} <- [
            {20_261_015_000_000, "20261015000000_add_oban.exs",
             FootballMarket.Repo.Migrations.AddOban},
            {20_261_015_000_100, "20261015000100_create_synchronization_ledgers.exs",
             FootballMarket.Repo.Migrations.CreateSynchronizationLedgers},
            {20_261_015_000_200, "20261015000200_create_catalog_delivery_receipts.exs",
             FootballMarket.Repo.Migrations.CreateCatalogDeliveryReceipts},
            {20_261_016_000_300, "20261016000300_extend_synchronization_operations.exs",
             FootballMarket.Repo.Migrations.ExtendSynchronizationOperations},
            {20_261_026_000_100, "20261026000100_add_synchronization_correlation.exs",
             FootballMarket.Repo.Migrations.AddSynchronizationCorrelation}
          ] do
        Code.require_file("priv/repo/migrations/" <> file)
        Ecto.Migrator.up(Repo, version, module, prefix: schema, log: false)
      end

      Repo.put_dynamic_repo(previous)
      Supervisor.stop(repo)
      {:ok, store_repo} = Repo.start_link(Keyword.put(options, :parameters, search_path: schema))
      Process.put(:synchronization_owned_repo, store_repo)
      Repo.put_dynamic_repo(store_repo)

      {:ok, oban} =
        Oban.start_link(
          name: FootballMarket.Synchronization.TestOban,
          repo: Repo,
          prefix: schema,
          testing: :manual,
          queues: [],
          plugins: [],
          get_dynamic_repo: fn -> store_repo end
        )

      try do
        Application.put_env(:football_market, FootballMarket.Synchronization,
          sources: %{"fixture" => FootballMarket.Synchronization.Fixtures.source()},
          oban_name: FootballMarket.Synchronization.TestOban
        )

        fun.(store_repo)
      after
        Supervisor.stop(oban)
      end
    after
      Application.put_env(:football_market, FootballMarket.Synchronization, old)
      Repo.put_dynamic_repo(previous)
      if owned = Process.delete(:synchronization_owned_repo), do: Supervisor.stop(owned)
      if Process.alive?(repo), do: Supervisor.stop(repo)

      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Repo.query!("DROP SCHEMA " <> schema <> " CASCADE", [])
      end)
    end
  end
end
