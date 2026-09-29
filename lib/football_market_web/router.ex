defmodule FootballMarketWeb.Router do
  use FootballMarketWeb, :router

  import FootballMarketWeb.UserAuth,
    only: [
      fetch_current_user: 2,
      require_authenticated_user: 2,
      redirect_if_user_is_authenticated: 2
    ]

  alias FootballMarketWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FootballMarketWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
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

    get "/docs", ApiDocsController, :index
    delete "/users/log-out", UserSessionController, :delete

    live_session :public, on_mount: [{UserAuth, :mount_current_user}] do
      live "/", HomeLive
    end
  end

  scope "/", FootballMarketWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/users/log-in", UserSessionController, :create

    live_session :guest, on_mount: [{UserAuth, :redirect_if_authenticated}] do
      live "/users/log-in", UserLoginLive
      live "/users/register", UserRegistrationLive
    end
  end

  scope "/", FootballMarketWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated, on_mount: [{UserAuth, :require_authenticated}] do
      live "/players", PlayerLive.Index
      live "/players/:player_id", PlayerLive.Show
      live "/account", AccountLive
    end
  end

  scope "/api", FootballMarketWeb do
    pipe_through :api_protected

    get "/players", PlayerController, :index, metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id", PlayerController, :show,
      metadata: %{authentication_policy: :api_protected}
  end
end
