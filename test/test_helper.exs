# Mix has already captured its output option. Recursive test subprocesses must
# never inherit this invocation's private application-coverage staging directory.
for key <- [
      "APPLICATION_COVERAGE_DIR",
      "APPLICATION_COVERAGE_RUN_ID",
      "APPLICATION_COVERAGE_SNAPSHOT"
    ] do
  System.delete_env(key)
end

ExUnit.start()
ExUnit.configure(exclude: [performance: true, e2e: true])

case System.get_env("CP1_PROFILE") do
  "unit" ->
    ExUnit.configure(include: [:unit, :performance])

  "e2e" ->
    ExUnit.configure(include: [:e2e])

  "integration" ->
    ExUnit.configure(include: [:integration, :performance])

  _ ->
    :ok
end

Code.ensure_loaded!(FootballMarket.AccountsCase)
Code.ensure_loaded!(FootballMarketWeb.APIAuthenticationProbe.Router)
