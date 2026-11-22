defmodule FootballMarket.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = FootballMarket.Observability.attach()

    children =
      ranking_cache_redis_children() ++
        [
          FootballMarket.Repo,
          {Oban, Application.fetch_env!(:football_market, Oban)},
          FootballMarketWeb.Telemetry,
          {DNSCluster,
           query: Application.get_env(:football_market, :dns_cluster_query) || :ignore},
          {Phoenix.PubSub, name: FootballMarket.PubSub},
          FootballMarketWeb.Endpoint
        ]

    opts = [strategy: :one_for_one, name: FootballMarket.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _} = started ->
        enqueue_startup_jobs()
        started

      error ->
        error
    end
  end

  defp ranking_cache_redis_children do
    case Application.get_env(:football_market, :redis) do
      config when is_list(config) ->
        opts =
          config
          |> Keyword.take([:host, :port, :password, :database, :ssl])
          |> Keyword.put(:name, :ranking_cache_redis)
          |> Keyword.put(:sync_connect, false)

        [{Redix, opts}]

      _ ->
        # Redis is a disposable read optimization and must not prevent boot.
        []
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    FootballMarketWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @impl true
  def stop(_state), do: FootballMarket.Observability.detach()

  defp enqueue_startup_jobs do
    order_opts = Application.get_env(:football_market, FootballMarket.Market.OrderEvaluation, [])

    preload_opts =
      Application.get_env(:football_market, FootballMarket.Workers.StatisticsPreload, [])

    if Keyword.get(order_opts, :startup, true) do
      _ = FootballMarket.Market.OrderEvaluation.startup()
    end

    if Keyword.get(preload_opts, :startup, true) do
      _ = FootballMarket.Workers.StatisticsPreload.startup()
    end
  rescue
    _ -> :ok
  catch
    :exit, _ -> :ok
  end
end
