defmodule FootballMarket.Infrastructure.Health do
  @moduledoc "Bounded dependency probes for public application health endpoints."

  alias Ecto.Adapters.SQL
  alias FootballMarket.{Infrastructure.Redis, Repo}

  @probe_timeout 500
  @redis_probe_timeout 3 * @probe_timeout

  def readiness(probes \\ default_probes()) when is_map(probes) do
    dependencies =
      Map.new([:postgresql, :redis, :oban], fn dependency ->
        {dependency, safe_probe(Map.get(probes, dependency, fn -> :unavailable end))}
      end)

    status =
      if dependencies.postgresql == :ready and dependencies.oban == :ready,
        do: :ready,
        else: :unavailable

    dependencies =
      if dependencies.redis == :unavailable,
        do: Map.put(dependencies, :redis, :degraded),
        else: dependencies

    %{status: status, dependencies: dependencies}
  end

  defp default_probes do
    %{
      postgresql: &postgresql_ready/0,
      redis: &redis_ready/0,
      oban: &oban_ready/0
    }
  end

  defp postgresql_ready do
    case SQL.query(Repo, "SELECT 1", [], timeout: @probe_timeout, pool_timeout: @probe_timeout) do
      {:ok, %{rows: [[1]]}} -> :ready
      _ -> :unavailable
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp redis_ready do
    # Redix links before synchronous startup can fail. Only the disposable probe owns that link.
    {worker, monitor} = spawn_monitor(fn -> exit({:redis_probe_result, check_redis()}) end)

    receive do
      {:DOWN, ^monitor, :process, ^worker, {:redis_probe_result, :ready}} -> :ready
      {:DOWN, ^monitor, :process, ^worker, _reason} -> :unavailable
    after
      @redis_probe_timeout ->
        Process.exit(worker, :kill)
        Process.demonitor(monitor, [:flush])
        :unavailable
    end
  end

  defp check_redis do
    with config when is_list(config) <- Application.get_env(:football_market, :redis),
         options = config |> Map.new() |> Map.put(:timeout, @probe_timeout),
         {:ok, client} <- Redis.start_link(options) do
      try do
        case Redis.ping(client, @probe_timeout) do
          {:ok, "PONG"} -> :ready
          _ -> :unavailable
        end
      after
        GenServer.stop(client, :normal, @probe_timeout)
      end
    else
      _ -> :unavailable
    end
  end

  defp oban_ready do
    name = Application.get_env(:football_market, Oban, []) |> Keyword.get(:name, Oban)
    if Oban.Registry.lookup(name), do: :ready, else: :unavailable
  rescue
    _ -> :unavailable
  end

  defp safe_probe(probe) when is_function(probe, 0) do
    case probe.() do
      :ready -> :ready
      _ -> :unavailable
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp safe_probe(_), do: :unavailable
end
