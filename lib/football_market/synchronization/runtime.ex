defmodule FootballMarket.Synchronization.ExecutionGuard do
  @moduledoc "Monitored dedicated PostgreSQL session; no session locks enter a pool."
  use GenServer
  alias FootballMarket.Repo

  def acquire(scope, options \\ []) do
    config = Application.get_env(:football_market, FootballMarket.Synchronization, [])
    slots = Keyword.get(options, :slots, Keyword.get(config, :concurrency, 1))
    timeout = Keyword.get(options, :timeout, 30_000)
    GenServer.start(__MODULE__, {self(), scope, slots, timeout})
  end

  @impl true
  def init({owner, scope, slots, timeout}) when is_integer(slots) and slots > 0 do
    Process.flag(:trap_exit, true)

    connection_options =
      Repo.config()
      |> Keyword.take([:username, :password, :hostname, :port, :database, :ssl, :socket_options])
      |> Keyword.put(:show_sensitive_data_on_connection_error, false)

    case Postgrex.start_link(connection_options) do
      {:ok, connection} ->
        scope_key = key({:scope, scope})

        if lock(connection, scope_key) and
             Enum.any?(1..slots, &lock(connection, key({:slot, &1}))) do
          monitor = Process.monitor(owner)
          timer = Process.send_after(self(), :timeout, timeout)
          {:ok, %{connection: connection, owner: owner, monitor: monitor, timer: timer}}
        else
          GenServer.stop(connection)
          {:stop, :busy}
        end

      _ ->
        {:stop, :store_unavailable}
    end
  end

  def init(_), do: {:stop, :invalid_configuration}

  defp key(value) do
    <<key::signed-64, _::binary>> =
      :crypto.hash(
        :sha256,
        :erlang.term_to_binary({:synchronization_execution_v2, value}, [:deterministic])
      )

    key
  end

  defp lock(connection, key) do
    case Postgrex.query(connection, "SELECT pg_try_advisory_lock($1)", [key]) do
      {:ok, %{rows: [[true]]}} -> true
      _ -> false
    end
  end

  @impl true
  def handle_info({:DOWN, monitor, :process, _pid, _reason}, %{monitor: monitor} = state),
    do: {:stop, :normal, state}

  def handle_info({:EXIT, connection, _reason}, %{connection: connection} = state) do
    Process.exit(state.owner, :kill)
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    Process.exit(state.owner, :kill)
    {:stop, :normal, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  @impl true
  def terminate(_, state) do
    Process.cancel_timer(state.timer)
    if Process.alive?(state.connection), do: GenServer.stop(state.connection)
    :ok
  end
end

defmodule FootballMarket.Synchronization.Recovery do
  @moduledoc "Guard-coordinated orphan recovery with fenced confirmed publication evidence."
  import Ecto.Query
  alias FootballMarket.Observability.JobContext
  alias FootballMarket.Repo
  alias FootballMarket.Synchronization.{ExecutionGuard, Run, Store}
  alias FootballMarket.Workers.CatalogSync

  def reconcile(now) do
    runs =
      Repo.all(
        from r in Run,
          where: r.state in ["queued", "executing", "retry_wait"],
          order_by: r.requested_at
      )

    results = Enum.map(runs, &reconcile_run(&1, now))

    if Enum.any?(results, &match?({:error, _}, &1)), do: Store.unavailable(), else: {:ok, results}
  rescue
    _ -> Store.unavailable()
  end

  defp repair(run, now) do
    Repo.transaction(fn -> repair_locked(run, now) end)
  end

  defp reconcile_run(run, now) do
    case ExecutionGuard.acquire(Store.execution_scope(run)) do
      {:ok, guard} ->
        try do
          reconcile_guarded(run, now)
        after
          if Process.alive?(guard), do: GenServer.stop(guard)
        end

      {:error, :busy} ->
        :busy

      _ ->
        Store.unavailable()
    end
  end

  defp reconcile_guarded(run, now) do
    if run.state == "executing",
      do: Store.complete(run.id, run.delivery_id, {:error, :interrupted}, now),
      else: repair(run, now)
  end

  defp repair_locked(run, now) do
    current = Repo.one!(from r in Run, where: r.id == ^run.id, lock: "FOR UPDATE")
    job = Repo.get(Oban.Job, current.job_id)

    if current.state in ["queued", "retry_wait"] &&
         (is_nil(job) || job.state in ["completed", "discarded", "cancelled", "executing"]) do
      eligible = current.next_retry_at || now

      worker =
        if current.operation == "statistics",
          do: FootballMarket.Workers.StatisticsImport,
          else: CatalogSync

      job =
        %{"run_id" => current.id, "delivery_id" => current.delivery_id}
        |> worker.new(scheduled_at: eligible)
        |> JobContext.annotate(JobContext.for_run(current))
        |> Store.insert_job!()

      Repo.update!(Ecto.Changeset.change(current, job_id: job.id))
    end
  end
end
