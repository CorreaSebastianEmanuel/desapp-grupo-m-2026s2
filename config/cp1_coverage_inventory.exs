# This is the sole CP1 coverage-scope authority. `mix.exs` derives its native
# `:ignore_modules` list from these exact application-owned source modules.
[
  %{
    path: "lib/football_market/accounts.ex",
    module: FootballMarket.Accounts,
    rationale: "CP1 account facade"
  },
  %{
    path: "lib/football_market/accounts/api_key.ex",
    module: FootballMarket.Accounts.ApiKey,
    rationale: "API-key value and verification"
  },
  %{
    path: "lib/football_market/accounts/authenticated_actor.ex",
    module: FootballMarket.Accounts.AuthenticatedActor,
    rationale: "authenticated actor projection"
  },
  %{
    path: "lib/football_market/accounts/authentication.ex",
    module: FootballMarket.Accounts.Authentication,
    rationale: "credential and JWT authentication"
  },
  %{
    path: "lib/football_market/accounts/password_credential.ex",
    module: FootballMarket.Accounts.PasswordCredential,
    rationale: "password credential verification"
  },
  %{
    path: "lib/football_market/accounts/user.ex",
    module: FootballMarket.Accounts.User,
    rationale: "account persistence schema"
  },
  %{
    path: "lib/football_market/catalog.ex",
    module: FootballMarket.Catalog,
    rationale: "catalog facade"
  },
  %{
    path: "lib/football_market/catalog/league.ex",
    module: FootballMarket.Catalog.League,
    rationale: "league identity"
  },
  %{
    path: "lib/football_market/catalog/player.ex",
    module: FootballMarket.Catalog.Player,
    rationale: "player persistence schema"
  },
  %{
    path: "lib/football_market/catalog/player_cursor.ex",
    module: FootballMarket.Catalog.PlayerCursor,
    rationale: "catalog cursor behavior"
  },
  %{
    path: "lib/football_market/catalog/position.ex",
    module: FootballMarket.Catalog.Position,
    rationale: "position identity"
  },
  %{
    path: "lib/football_market/catalog/query.ex",
    module: FootballMarket.Catalog.Query,
    rationale: "catalog filtering"
  },
  %{
    path: "lib/football_market/catalog/season.ex",
    module: FootballMarket.Catalog.Season,
    rationale: "season identity"
  },
  %{
    path: "lib/football_market/catalog/team.ex",
    module: FootballMarket.Catalog.Team,
    rationale: "team identity"
  },
  %{
    path: "lib/football_market_web/controllers/api_docs_controller.ex",
    module: FootballMarketWeb.ApiDocsController,
    rationale: "published API document edge"
  },
  %{
    path: "lib/football_market_web/controllers/api_docs_html.ex",
    module: FootballMarketWeb.ApiDocsHTML,
    rationale: "published interactive documentation"
  },
  %{
    path: "lib/football_market_web/controllers/player_controller.ex",
    module: FootballMarketWeb.PlayerController,
    rationale: "protected catalog HTTP edge"
  },
  %{
    path: "lib/football_market_web/controllers/player_json.ex",
    module: FootballMarketWeb.PlayerJSON,
    rationale: "catalog response contract"
  },
  %{
    path: "lib/football_market_web/plugs/authenticate_api.ex",
    module: FootballMarketWeb.Plugs.AuthenticateAPI,
    rationale: "protected-route authentication"
  },
  %{
    path: "lib/football_market_web/router.ex",
    module: FootballMarketWeb.Router,
    rationale: "published and protected route policy"
  }
]
