defmodule RankingRuntimePlug do
  @moduledoc false
  def init(opts), do: opts

  def call(conn, _opts) do
    FootballMarket.Repo.put_dynamic_repo(
      Application.fetch_env!(:football_market, :ranking_runtime_repo)
    )

    FootballMarketWeb.Endpoint.call(conn, FootballMarketWeb.Endpoint.init([]))
  end
end

defmodule RankingRuntimeProviderSpy do
  @moduledoc false
  def provider_label, do: "ranking-runtime-spy"

  def read(_request, _context, _state),
    do: :ets.update_counter(:ranking_provider_calls, :count, 1)
end

defmodule RankingRuntimeAssertions do
  def assert!(true, _message), do: :ok
  def assert!(_, message), do: raise("ranking runtime assertion failed: #{message}")

  def request(port, path, token \\ nil) do
    headers = if token, do: [{'authorization', String.to_charlist("Bearer " <> token)}], else: []

    response =
      :httpc.request(
        :get,
        {String.to_charlist("http://localhost:#{port}" <> path), headers},
        [timeout: 3_000, connect_timeout: 2_000],
        []
      )

    {{_version, status, _reason}, response_headers, body} =
      case response do
        {:ok, result} -> result
        {:error, _reason} -> raise "ranking runtime HTTP request failed"
      end

    normalized =
      Map.new(response_headers, fn {key, value} ->
        {String.downcase(List.to_string(key)), List.to_string(value)}
      end)

    {status, normalized, Jason.decode!(body)}
  end

  def isolated_schema do
    alias FootballMarket.{Repo, ValuationConfigurationCase}
    schema = "valuation_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    original = Repo.get_dynamic_repo()
    Repo.query!("CREATE SCHEMA " <> schema)
    {:ok, repo} = ValuationConfigurationCase.client(schema)
    Repo.put_dynamic_repo(repo)

    try do
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up,
        all: true,
        prefix: schema,
        log: false
      )

      %{schema: schema, repo: repo, previous: original}
    rescue
      error ->
        if Process.alive?(repo), do: Supervisor.stop(repo)
        Repo.put_dynamic_repo(original)
        Repo.query!("DROP SCHEMA #{schema} CASCADE")
        reraise error, __STACKTRACE__
    end
  end

  def dispose_schema(%{schema: schema, repo: repo, previous: previous}) do
    alias FootballMarket.Repo
    Repo.put_dynamic_repo(previous)
    if Process.alive?(repo), do: Supervisor.stop(repo)
    Repo.query!("DROP SCHEMA #{schema} CASCADE")
  end

  def fixture(repo) do
    alias FootballMarket.{Accounts, Market, Quotes, Repo, Valuation, ValuationCase}
    alias FootballMarket.Valuation.Configurations

    Repo.put_dynamic_repo(repo)

    base = ValuationCase.fixture()

    {:ok, user} =
      Accounts.register_user(%{
        email: "ranking-runtime-#{System.unique_integer([:positive])}@example.test",
        password: "ranking-runtime-password"
      })

    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    {:ok, %{outcome: :issued}} = Market.initialize_player(hd(base.players).id)

    {match, _performance} =
      ValuationCase.record(base, "ranking-runtime-" <> Ecto.UUID.generate(), %{goals: 1})

    {:ok, configuration} =
      Configurations.create(FootballMarket.QuotesCase.rules(%{position: base.position}))

    {:ok, mapping} =
      Quotes.Mappings.save("ranking-runtime", Ecto.UUID.generate(), Decimal.new("1.25"))

    {:ok, _} = Configurations.activate(configuration.id, nil)

    subject = %{
      player_id: hd(base.players).id,
      season_id: base.season.id,
      week_start: "2026-10-05T00:00:00Z",
      week_end: "2026-10-12T00:00:00Z"
    }

    {:ok, %{calculation: calculation}} = Quotes.request(subject, :active, mapping.id)
    quote = Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
    {:ok, token} = Accounts.Authentication.issue(user.id)

    %{
      user: user,
      token: token,
      configuration: configuration,
      quote: quote,
      match: match,
      position: base.position,
      repo: repo
    }
  end

  def snapshot(repo) do
    FootballMarket.Repo.put_dynamic_repo(repo)
    FootballMarket.RankingCase.protected_snapshot()
  end
end

Application.ensure_all_started(:inets)
port = Enum.random(40_000..60_000)
Process.put(:ranking_runtime_schemas, [])
original_dynamic_repo = FootballMarket.Repo.get_dynamic_repo()
application_keys = [:ranking_runtime_repo, FootballMarket.Providers, :initial_issuance_recipients]
original_application = Map.new(application_keys, &{&1, Application.get_env(:football_market, &1, :__missing__)})

try do
  first = RankingRuntimeAssertions.isolated_schema()
  Process.put(:ranking_runtime_schemas, [first | Process.get(:ranking_runtime_schemas)])
  Application.put_env(:football_market, :ranking_runtime_repo, first.repo)
  fixture = RankingRuntimeAssertions.fixture(first.repo)

  # A second owned schema provides an authenticated no-active-configuration case.
  second = RankingRuntimeAssertions.isolated_schema()
  Process.put(:ranking_runtime_schemas, [second | Process.get(:ranking_runtime_schemas)])

  {:ok, absent_user} =
    FootballMarket.Accounts.register_user(%{
      email: "ranking-runtime-absent-#{System.unique_integer([:positive])}@example.test",
      password: "ranking-runtime-password"
    })

  {:ok, absent_token} = FootballMarket.Accounts.Authentication.issue(absent_user.id)

  {:ok, listener} = Bandit.start_link(plug: {RankingRuntimePlug, []}, scheme: :http, port: port)

  try do
    ready? =
      Enum.any?(1..50, fn _ ->
        case :gen_tcp.connect(~c"localhost", port, [], 100) do
          {:ok, socket} ->
            :gen_tcp.close(socket)
            true

          {:error, _} ->
            Process.sleep(100)
            false
        end
      end)

    RankingRuntimeAssertions.assert!(ready?, "listener readiness")

    Application.put_env(:football_market, :ranking_runtime_repo, first.repo)
    :ets.new(:ranking_provider_calls, [:named_table, :public, :set])
    :ets.insert(:ranking_provider_calls, {:count, 0})

    Application.put_env(:football_market, FootballMarket.Providers,
      provider: RankingRuntimeProviderSpy,
      positions: [:goalkeeper, :defender, :midfielder, :forward]
    )

    populated_snapshot = RankingRuntimeAssertions.snapshot(first.repo)

    {200, headers, populated} =
      RankingRuntimeAssertions.request(port, "/api/ranking", fixture.token)

    RankingRuntimeAssertions.assert!(
      String.starts_with?(headers["content-type"], "application/json"),
      "JSON content type"
    )

    RankingRuntimeAssertions.assert!(headers["cache-control"] == "no-store", "no-store response")

    RankingRuntimeAssertions.assert!(
      populated["configuration"]["configuration_version_id"] == fixture.configuration.id,
      "active configuration identity"
    )

    [entry] = populated["data"]
    RankingRuntimeAssertions.assert!(is_map(entry), "populated ranking")

    RankingRuntimeAssertions.assert!(
      entry["quote_id"] == fixture.quote.id,
      "selected quote identity"
    )

    RankingRuntimeAssertions.assert!(
      entry["player_id"] == fixture.quote.player_id,
      "selected player identity"
    )

    RankingRuntimeAssertions.assert!(
      entry["unit_price"] == "1.25" and entry["position"] == 1,
      "price and position"
    )

    RankingRuntimeAssertions.assert!(
      entry["effective_at"] == DateTime.to_iso8601(fixture.quote.effective_at),
      "effective time"
    )

    RankingRuntimeAssertions.assert!(
      RankingRuntimeAssertions.snapshot(first.repo) == populated_snapshot,
      "populated read has no persisted effects"
    )

    RankingRuntimeAssertions.assert!(
      :ets.lookup_element(:ranking_provider_calls, :count, 2) == 0,
      "provider independence"
    )

    {:ok, empty_configuration} =
      FootballMarket.Valuation.Configurations.create(
        FootballMarket.QuotesCase.rules(%{position: fixture.position})
      )

    {:ok, _} =
      FootballMarket.Valuation.Configurations.activate(
        empty_configuration.id,
        fixture.configuration.id
      )

    empty_snapshot = RankingRuntimeAssertions.snapshot(first.repo)

    {200, empty_headers, empty} =
      RankingRuntimeAssertions.request(port, "/api/ranking", fixture.token)

    RankingRuntimeAssertions.assert!(
      empty_headers["cache-control"] == "no-store",
      "empty no-store response"
    )

    RankingRuntimeAssertions.assert!(
      empty["configuration"]["configuration_version_id"] == empty_configuration.id and
        empty["data"] == [],
      "active empty response"
    )

    RankingRuntimeAssertions.assert!(
      RankingRuntimeAssertions.snapshot(first.repo) == empty_snapshot,
      "empty read has no persisted effects"
    )

    RankingRuntimeAssertions.assert!(
      :ets.lookup_element(:ranking_provider_calls, :count, 2) == 0,
      "empty read provider independence"
    )

    Application.put_env(:football_market, :ranking_runtime_repo, second.repo)

    {409, absent_headers, absent} =
      RankingRuntimeAssertions.request(port, "/api/ranking", absent_token)

    RankingRuntimeAssertions.assert!(
      absent_headers["cache-control"] == "no-store",
      "absent no-store response"
    )

    RankingRuntimeAssertions.assert!(
      absent == %{"error" => %{"code" => "no_active_configuration"}},
      "no-active response"
    )

    Application.put_env(:football_market, :ranking_runtime_repo, first.repo)
    FootballMarket.Repo.put_dynamic_repo(first.repo)
    FootballMarket.Repo.query!(
      "ALTER TABLE valuation_selection_locks RENAME TO valuation_selection_locks_unavailable"
    )

    {503, storage_headers, storage} =
      RankingRuntimeAssertions.request(port, "/api/ranking", fixture.token)

    RankingRuntimeAssertions.assert!(
      storage_headers["cache-control"] == "no-store",
      "storage no-store response"
    )

    RankingRuntimeAssertions.assert!(
      storage == %{"error" => %{"code" => "storage_unavailable"}},
      "safe storage failure"
    )

    {401, auth_headers, unauthorized} = RankingRuntimeAssertions.request(port, "/api/ranking")

    RankingRuntimeAssertions.assert!(
      String.starts_with?(auth_headers["content-type"], "application/json"),
      "401 JSON content type"
    )

    RankingRuntimeAssertions.assert!(
      unauthorized == %{"error" => %{"code" => "unauthenticated"}},
      "unauthenticated response"
    )

    {401, _, invalid} =
      RankingRuntimeAssertions.request(port, "/api/ranking", "invalid-runtime-token")

    RankingRuntimeAssertions.assert!(
      invalid == %{"error" => %{"code" => "unauthenticated"}},
      "invalid credential response"
    )

    IO.puts(
      "ranking runtime assertions passed: authenticated populated/empty, no-active, storage failure, and 401 over TCP"
    )
  after
    Supervisor.stop(listener)
  end
after
  Process.get(:ranking_runtime_schemas, [])
  |> Enum.each(&RankingRuntimeAssertions.dispose_schema/1)
  FootballMarket.Repo.put_dynamic_repo(original_dynamic_repo)

  Enum.each(original_application, fn
    {key, :__missing__} -> Application.delete_env(:football_market, key)
    {key, value} -> Application.put_env(:football_market, key, value)
  end)
end
