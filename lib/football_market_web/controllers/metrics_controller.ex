defmodule FootballMarketWeb.MetricsController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Observability.Metrics

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/plain; version=0.0.4; charset=utf-8")
    |> send_resp(200, Metrics.scrape())
  end
end
