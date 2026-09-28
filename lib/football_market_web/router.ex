defmodule FootballMarketWeb.Router do
  use FootballMarketWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FootballMarketWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api_public do
    plug :accepts, ["json"]
  end

  pipeline :api_protected do
    plug :accepts, ["json"]
    plug FootballMarketWeb.Plugs.AuthenticateAPI
  end

  scope "/", FootballMarketWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", FootballMarketWeb do
    pipe_through :api_protected

    get "/players", PlayerController, :index, metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id", PlayerController, :show,
      metadata: %{authentication_policy: :api_protected}
  end
end
