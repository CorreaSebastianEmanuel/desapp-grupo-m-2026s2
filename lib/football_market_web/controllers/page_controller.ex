defmodule FootballMarketWeb.PageController do
  use FootballMarketWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
