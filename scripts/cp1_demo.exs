# Executed only by the guarded harness; every stream remains private.
defmodule CP1Demo do
  import Ecto.Query
  alias FootballMarket.{Accounts, Repo}
  alias FootballMarket.Catalog.{League, Season, Team, Position, Player, DevelopmentSeed}

  def check(true), do: :ok
  def check(_), do: raise("demo-observation-failed")

  def counts! do
    counts = %{
      leagues: Repo.aggregate(League, :count),
      seasons: Repo.aggregate(Season, :count),
      teams: Repo.aggregate(Team, :count),
      positions: Repo.aggregate(Position, :count),
      players: Repo.aggregate(Player, :count),
      total: 44
    }

    check(counts == %{leagues: 5, seasons: 5, teams: 10, positions: 4, players: 20, total: 44})
    players = Repo.all(from p in Player, preload: [:position, team: [season: :league]])
    check(Enum.all?(players, &(&1.season_id == &1.team.season_id)))

    check(
      Enum.all?(Enum.group_by(players, & &1.season_id), fn {_, ps} ->
        length(ps) == 4 and Enum.sort(Enum.map(ps, & &1.position.code)) == ~w(DEF FWD GK MID)
      end)
    )

    check(Enum.all?(Enum.group_by(players, & &1.team_id), fn {_, ps} -> length(ps) == 2 end))
    check(length(Enum.uniq_by(players, & &1.team.season.league.id)) == 5)
    counts
  end

  def get(base, path, headers, status) do
    {:ok, {{_, actual, _}, _, body}} =
      :httpc.request(
        :get,
        {String.to_charlist(base <> path),
         Enum.map(headers, fn {k, v} -> {String.to_charlist(k), String.to_charlist(v)} end)},
        [timeout: 15_000],
        body_format: :binary
      )

    check(actual == status)
    body
  end

  def json(base, path, headers, status), do: base |> get(path, headers, status) |> Jason.decode!()

  def run do
    Logger.configure(level: :error)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, :auto)
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, %{total: 44}} = DevelopmentSeed.run()
    first = counts!()
    {:ok, %{total: 44, created: 0, reused: 44}} = DevelopmentSeed.run()
    second = counts!()
    Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)
    owner = Ecto.Adapters.SQL.Sandbox.start_owner!(Repo, shared: true)

    attrs = %{
      email: "cp1-#{Ecto.UUID.generate()}@example.test",
      password: Base.url_encode64(:crypto.strong_rand_bytes(24))
    }

    {:ok, user} = Accounts.register_user(attrs)
    {:error, _} = Accounts.register_user(attrs)
    {:ok, %{access_token: jwt}} = Accounts.login(attrs)
    {:ok, _} = Accounts.validate_access_token(jwt)

    {:error, :authentication_failed} =
      Accounts.login(%{attrs | password: "invalid-demo-credential"})

    {:ok, key} = Accounts.issue_api_key(user.id)
    {:ok, %{account_id: account_id}} = Accounts.identify_api_key(key.secret)
    check(account_id == user.id)
    stored = Repo.get!(FootballMarket.Accounts.ApiKey, key.id)
    check(not Map.has_key?(stored, :secret))
    {base, server} = FootballMarket.OpenAPICase.start_server!()

    try do
      jwt_headers = [{"authorization", "Bearer " <> jwt}]
      key_headers = [{"x-api-key", key.secret}]
      denied = %{"error" => %{"code" => "unauthenticated"}}
      check(json(base, "/api/players", [], 401) == denied)
      check(json(base, "/api/players", [{"authorization", "Bearer invalid"}], 401) == denied)
      check(json(base, "/api/players", [{"x-api-key", "invalid"}], 401) == denied)
      list = json(base, "/api/players?page_size=25", jwt_headers, 200)
      check(length(list["data"]) == 20)
      check(json(base, "/api/players?page_size=25", key_headers, 200) == list)
      player = hd(list["data"])
      detail = json(base, "/api/players/" <> player["id"], key_headers, 200)
      check(detail["data"]["id"] == player["id"])
      page = json(base, "/api/players?page_size=1", jwt_headers, 200)
      check(page["pagination"]["has_more"] == true and length(page["data"]) == 1)
      cursor = page["pagination"]["next_cursor"] |> URI.encode_www_form()
      next = json(base, "/api/players?page_size=1&cursor=" <> cursor, jwt_headers, 200)
      check(length(next["data"]) == 1 and hd(next["data"])["id"] != hd(page["data"])["id"])
      filters = [{"league_id", "league"}, {"team_id", "team"}, {"position_id", "position"}]

      for {param, field} <- filters do
        body = json(base, "/api/players?#{param}=#{player[field]["id"]}", jwt_headers, 200)

        check(
          body["data"] != [] and
            Enum.all?(body["data"], &(&1[field]["id"] == player[field]["id"]))
        )
      end

      for league <- Enum.uniq_by(list["data"], & &1["league"]["id"]) do
        body = json(base, "/api/players?league_id=#{league["league"]["id"]}", jwt_headers, 200)
        check(length(body["data"]) == 4)
      end

      combined =
        Enum.map_join(filters, "&", fn {param, field} -> "#{param}=#{player[field]["id"]}" end)

      check(json(base, "/api/players?" <> combined, jwt_headers, 200)["data"] == [player])

      check(
        json(base, "/api/players?team_id=#{Ecto.UUID.generate()}", jwt_headers, 200)["data"] == []
      )

      check(
        json(base, "/api/players?league_id=invalid", jwt_headers, 400) == %{
          "error" => %{"code" => "invalid_league_id"}
        }
      )

      check(String.starts_with?(json(base, "/openapi.json", [], 200)["openapi"], "3."))
      check(String.contains?(get(base, "/docs", [], 200), "credential-mode"))

      {output, status} =
        System.cmd("node", ["tools/openapi/browser.mjs", base],
          env: [
            {"OPENAPI_TEST_JWT", jwt},
            {"OPENAPI_TEST_KEY", key.secret},
            {"OPENAPI_TEST_PLAYER_ID", player["id"]},
            {"OPENAPI_EXPECTED_LIST", Jason.encode!(list)},
            {"OPENAPI_EXPECTED_DETAIL", Jason.encode!(detail)}
          ],
          stderr_to_stdout: true
        )

      check(
        status == 0 and
          output == "CP1_BROWSER_RECEIPT status=complete behavior=published-contract\n"
      )

      :ok = Accounts.revoke_api_key(user.id, key.id)
      {:error, :invalid_key} = Accounts.identify_api_key(key.secret)
      check(json(base, "/api/players", key_headers, 401) == denied)
      check(counts!() == second)
      File.write!(System.fetch_env!("CP1_DEMO_OBSERVATIONS"), Jason.encode!([first, second]))
    after
      Supervisor.stop(server)
      Ecto.Adapters.SQL.Sandbox.stop_owner(owner)
    end
  end
end

try do
  CP1Demo.run()
rescue
  _ ->
    line =
      Enum.find_value(__STACKTRACE__, 0, fn {_, _, _, location} ->
        if to_string(location[:file] || "") == "scripts/cp1_demo.exs", do: location[:line]
      end)

    IO.puts(:stderr, "CP1_DEMO_FAILURE line=#{line}")
    System.halt(1)
end
