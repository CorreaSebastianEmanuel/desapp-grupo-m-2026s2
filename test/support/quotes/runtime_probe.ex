defmodule FootballMarket.Quotes.RuntimeProbe do
  @moduledoc false

  alias FootballMarket.Repo

  def await(assertion, timeout \\ 5_000) when is_function(assertion, 0) do
    deadline = System.monotonic_time(:millisecond) + timeout
    retry(assertion, deadline)
  end

  @doc """
  Creates a fully migrated owned store schema with its own connection so
  successive BEAM processes can replay a committed feature against it. The
  schema is kept until `destroy_store!/1` runs, mirroring the owned-store
  pattern of StatisticsIngestion.Case without its automatic teardown.
  """
  def owned_store! do
    schema = "statistics_ingestion_store_" <> String.replace(Ecto.UUID.generate(), "-", "")

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Repo.query!("CREATE SCHEMA " <> schema, [])
    end)

    {:ok, client} =
      Repo.start_link(
        name: nil,
        pool: DBConnection.ConnectionPool,
        pool_size: 6,
        parameters: [search_path: schema]
      )

    Process.unlink(client)
    previous = Repo.put_dynamic_repo(client)
    Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)
    Repo.put_dynamic_repo(previous)

    %{schema: schema, repo: client}
  end

  def destroy_store!(%{repo: pid, schema: schema}) do
    if Process.alive?(pid), do: Supervisor.stop(pid)

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Repo.query!("DROP SCHEMA IF EXISTS " <> schema <> " CASCADE", [])
    end)

    :ok
  end

  def fresh_beam!(code, env \\ []) when is_binary(code) do
    executable = System.find_executable("mix") || raise "mix executable unavailable"

    port =
      Port.open({:spawn_executable, executable}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        args: Enum.map(["run", "--no-compile", "-e", code], &String.to_charlist/1),
        env:
          Enum.map([{"MIX_ENV", "test"}, {"MIX_OS_CONCURRENCY_LOCK", "0"} | env], fn {key, value} ->
            {String.to_charlist(key), String.to_charlist(value)}
          end)
      ])

    receive_output(port, System.monotonic_time(:millisecond) + 30_000, [])
  end

  defp receive_output(port, deadline, output) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    receive do
      {^port, {:data, chunk}} ->
        receive_output(port, deadline, [chunk | output])

      {^port, {:exit_status, 0}} ->
        output |> Enum.reverse() |> IO.iodata_to_binary()

      {^port, {:exit_status, status}} ->
        rendered = output |> Enum.reverse() |> IO.iodata_to_binary()
        raise "fresh quote BEAM failed (#{status}): " <> String.slice(rendered, -2_000, 2_000)
    after
      remaining ->
        Port.close(port)
        raise "fresh quote BEAM timed out"
    end
  end

  defp retry(assertion, deadline) do
    case assertion.() do
      true ->
        :ok

      _ ->
        if System.monotonic_time(:millisecond) >= deadline do
          raise "quote runtime assertion timed out"
        else
          Process.sleep(25)
          retry(assertion, deadline)
        end
    end
  end
end
