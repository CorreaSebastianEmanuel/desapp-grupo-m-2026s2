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

    with {:ok, connection} <- Postgrex.start_link(connection_options) do
      scope_key = key({:scope, scope})

      if lock(connection, scope_key) and Enum.any?(1..slots, &lock(connection, key({:slot, &1}))) do
        monitor = Process.monitor(owner)
        timer = Process.send_after(self(), :timeout, timeout)
        {:ok, %{connection: connection, owner: owner, monitor: monitor, timer: timer}}
      else
        GenServer.stop(connection)
        {:stop, :busy}
      end
    else
      _ -> {:stop, :store_unavailable}
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
