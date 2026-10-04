defmodule FootballMarket.CatalogConcurrencyCase do
  @moduledoc "Process-owned connections and fixture-scoped cleanup for Catalog races."
  import ExUnit.Assertions
  alias Ecto.Adapters.SQL.Sandbox
  alias FootballMarket.Repo

  def setup_race do
    {:ok, fixtures} = Agent.start(fn -> [] end)

    ExUnit.Callbacks.on_exit(fn ->
      try do
        Sandbox.unboxed_run(Repo, fn ->
          for row <- Agent.get(fixtures, & &1), do: Repo.delete!(row)
        end)
      after
        Agent.stop(fixtures)
      end
    end)

    %{fixtures: fixtures, supervisor: ExUnit.Callbacks.start_supervised!(Task.Supervisor)}
  end

  def own(context, row) do
    Agent.update(context.fixtures, &[row | &1])
    row
  end

  def race(context, fun) do
    parent = self()
    barrier = make_ref()

    tasks =
      for _ <- 1..2 do
        Task.Supervisor.async_nolink(context.supervisor, fn ->
          Sandbox.unboxed_run(Repo, fn ->
            %{rows: [[backend]]} = Ecto.Adapters.SQL.query!(Repo, "SELECT pg_backend_pid()", [])
            send(parent, {barrier, self(), backend})

            receive do
              {^barrier, :go} ->
                result = fun.()

                case result do
                  {:ok, row} -> own(context, row)
                  _ -> :ok
                end

                result
            after
              5000 -> raise "Catalog worker readiness barrier timed out"
            end
          end)
        end)
      end

    backends =
      for task <- tasks do
        worker = task.pid
        assert_receive {^barrier, ^worker, backend}, 5000
        backend
      end

    assert length(Enum.uniq(backends)) == 2, "Catalog race must use distinct backend connections"
    for task <- tasks, do: send(task.pid, {barrier, :go})
    # await propagates worker failures; the registered supervisor terminates unfinished workers.
    results = Enum.map(tasks, &Task.await(&1, 10_000))
    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %Ecto.Changeset{}}, &1)) == 1
    results
  end
end
