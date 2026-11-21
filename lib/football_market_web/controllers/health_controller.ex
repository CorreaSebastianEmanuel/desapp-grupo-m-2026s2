defmodule FootballMarketWeb.HealthController do
  use FootballMarketWeb, :controller

  alias FootballMarket.Infrastructure.Health

  def live(conn, _params) do
    json(conn, %{status: "live"})
  end

  def ready(conn, _params) do
    conn |> respond_ready(Health.readiness())
  end

  def respond_ready(conn, result) do
    body = %{
      status: Atom.to_string(result.status),
      dependencies:
        Map.new(result.dependencies, fn {name, status} -> {name, Atom.to_string(status)} end)
    }

    conn
    |> put_status(if(result.status == :ready, do: :ok, else: :service_unavailable))
    |> json(body)
  end
end
