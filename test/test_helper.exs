ExUnit.start()
ExUnit.configure(exclude: [performance: true])

case System.get_env("CP1_PROFILE") do
  "unit" ->
    ExUnit.configure(include: [:unit, :performance])

  "integration" ->
    ExUnit.configure(include: [:integration, :performance])

  _ ->
    :ok
end

Code.ensure_loaded!(FootballMarket.AccountsCase)
Code.ensure_loaded!(FootballMarketWeb.APIAuthenticationProbe.Router)
