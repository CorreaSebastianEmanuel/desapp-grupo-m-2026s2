ExUnit.start()
ExUnit.configure(exclude: [performance: true])

Code.ensure_loaded!(FootballMarket.AccountsCase)
Code.ensure_loaded!(FootballMarketWeb.APIAuthenticationProbe.Router)
