# This is the sole CP1 coverage-scope authority. `mix.exs` derives its native
# `:ignore_modules` list from these exact application-owned source modules.
[
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts,
    rationale: "CP1 account facade"
  },
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts.ApiKey,
    rationale: "API-key value and verification"
  },
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts.AuthenticatedActor,
    rationale: "authenticated actor projection"
  },
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts.Authentication,
    rationale: "credential and JWT authentication"
  },
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts.PasswordCredential,
    rationale: "password credential verification"
  },
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts.User,
    rationale: "account persistence schema"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog,
    rationale: "catalog facade and filtering"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.League,
    rationale: "league identity"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.Player,
    rationale: "player persistence schema"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.PlayerCursor,
    rationale: "catalog cursor behavior"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.Position,
    rationale: "position identity"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.Season,
    rationale: "season identity"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog.Team,
    rationale: "team identity"
  },
  %{
    path: "lib/football_market_web/controllers/pages.ex",
    module: FootballMarketWeb.ApiDocsController,
    rationale: "published API document edge"
  },
  %{
    path: "lib/football_market_web/controllers/pages.ex",
    module: FootballMarketWeb.ApiDocsHTML,
    rationale: "published interactive documentation"
  },
  %{
    path: "lib/football_market_web/controllers/api_controller.ex",
    module: FootballMarketWeb.ApiController,
    rationale: "protected API HTTP edge and JSON responses"
  },
  %{
    path: "lib/football_market_web/auth.ex",
    module: FootballMarketWeb.Plugs.AuthenticateAPI,
    rationale: "protected-route authentication"
  },
  %{
    path: "lib/football_market_web/router.ex",
    module: FootballMarketWeb.Router,
    rationale: "published and protected route policy"
  }
]
