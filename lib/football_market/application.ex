defmodule FootballMarket.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = FootballMarket.Observability.attach()

    children = [
      FootballMarket.Repo,
      {Oban, Application.fetch_env!(:football_market, Oban)},
      FootballMarketWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:football_market, :dns_cluster_query) || :ignore},
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
