defmodule FootballMarket.OpenAPICase do
  import FootballMarket.AccountsCase
  import FootballMarket.CatalogCase

  def fixture! do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, jwt} = FootballMarket.Accounts.Authentication.issue(user.id)
    {:ok, api_key} = FootballMarket.Accounts.issue_api_key(user.id)
    %{players: [player]} = insert_catalog!(["OpenAPI Example Player"])
    %{jwt: jwt, api_key: api_key.secret, player: player}
  end

  def document!, do: "priv/static/openapi.json" |> File.read!() |> Jason.decode!()

  def start_server! do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, {:ip, {127, 0, 0, 1}}, {:active, false}])
    {:ok, port} = :inet.port(socket)
    :ok = :gen_tcp.close(socket)

    {:ok, pid} =
      Bandit.start_link(
        plug: FootballMarketWeb.Endpoint,
        scheme: :http,
        ip: {127, 0, 0, 1},
        port: port,
        startup_log: false
      )

    {"http://127.0.0.1:#{port}", pid}
  end
end
