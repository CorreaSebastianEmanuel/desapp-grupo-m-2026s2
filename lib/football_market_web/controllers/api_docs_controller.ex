defmodule FootballMarketWeb.ApiDocsController do
  use FootballMarketWeb, :controller

  def index(conn, _params), do: render(conn, :docs)
end
