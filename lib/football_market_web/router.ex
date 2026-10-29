defmodule FootballMarketWeb.Router do
  use FootballMarketWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FootballMarketWeb.Layouts, :root}
    plug FootballMarketWeb.Plugs.BrowserOrigin
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
    get "/docs", ApiDocsController, :index
  end

  scope "/", FootballMarketWeb do
    pipe_through :browser
    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    get "/register", SessionController, :new_registration
    post "/register", SessionController, :create_registration
    post "/sign-out", SessionController, :delete
  end

  pipeline :workspace do
    plug FootballMarketWeb.Plugs.BrowserAuth
  end

  scope "/", FootballMarketWeb do
    pipe_through [:browser, :workspace]

    live_session :workspace,
      session: {FootballMarketWeb.Plugs.BrowserAuth, :live_session, []},
      on_mount: [{FootballMarketWeb.Live.BrowserAuth, :workspace}] do
      live "/portfolio", WorkspaceLive, :portfolio
      live "/players", WorkspaceLive, :players
      live "/conditional-orders", WorkspaceLive, :conditional_orders
    end
  end

  scope "/api", FootballMarketWeb do
    pipe_through :api_protected

    post "/conditional-orders", ConditionalOrderController, :create,
      metadata: %{authentication_policy: :api_protected}

    get "/conditional-orders", ConditionalOrderController, :index,
      metadata: %{authentication_policy: :api_protected}

    post "/conditional-orders/:id/cancel", ConditionalOrderController, :cancel,
      metadata: %{authentication_policy: :api_protected}

    get "/conditional-orders/:id", ConditionalOrderController, :show,
      metadata: %{authentication_policy: :api_protected}

    get "/portfolio/allocation", PortfolioController, :allocation,
      metadata: %{authentication_policy: :api_protected}

    get "/portfolio/history", PortfolioController, :history,
      metadata: %{authentication_policy: :api_protected}

    get "/ranking", RankingController, :index, metadata: %{authentication_policy: :api_protected}

    get "/transactions", TransactionController, :index,
      metadata: %{authentication_policy: :api_protected}

    post "/purchases", PurchaseController, :create,
      metadata: %{authentication_policy: :api_protected}

    post "/sales", SaleController, :create, metadata: %{authentication_policy: :api_protected}

    get "/players", PlayerController, :index, metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id/quotes/current", QuoteController, :current,
      metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id/quotes/history", QuoteController, :history,
      metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id/quotes/at", QuoteController, :at,
      metadata: %{authentication_policy: :api_protected}

    get "/players/:player_id", PlayerController, :show,
      metadata: %{authentication_policy: :api_protected}
  end
end
