defmodule FootballMarket.E2E.Fixtures do
  @moduledoc false
  import ExUnit.Assertions
  import Ecto.Query
  alias FootballMarket.{Accounts, Repo, Synchronization}
  alias FootballMarket.E2E.Runtime

  def account! do
    email = "e2e@example.test"
    password = "local-e2e-password-123"
    {:ok, user} = Accounts.register_user(%{email: email, password: password})
    %{user: user, email: email, password: password}
  end

  def browser!(base, credentials) do
    dir = Path.join(System.tmp_dir!(), "e2e-ipc-" <> Ecto.UUID.generate())
    File.mkdir!(dir)
    File.chmod!(dir, 0o700)
    clock = DateTime.utc_now()
    :persistent_term.put({FootballMarket.BrowserTestClock, :now}, clock)

    Application.put_env(
      :football_market,
      :browser_clock,
      {FootballMarket.BrowserTestClock, :now, []}
    )

    watcher =
      Task.async(fn -> expire_browser_clock(dir, clock) end)

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/e2e_browser.mjs", base],
          env: [
            {"E2E_EMAIL", credentials.email},
            {"E2E_PASSWORD", credentials.password},
            {"E2E_IPC", dir}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, output
      assert output == "E2E_BROWSER status=complete\n"
      Task.await(watcher, 1_000)

      sessions =
        Repo.all(from s in Accounts.BrowserSession, where: s.user_id == ^credentials.user.id)

      assert Enum.any?(sessions, &(&1.state == "revoked"))

      assert Enum.any?(
               sessions,
               &(DateTime.compare(&1.expires_at, FootballMarket.BrowserTestClock.now()) != :gt)
             )

      :ok
    after
      Task.shutdown(watcher, :brutal_kill)
      File.rm_rf!(dir)
      :persistent_term.erase({FootballMarket.BrowserTestClock, :now})
    end
  end

  def market_browser!(base) do
    credentials = account!()
    f = FootballMarket.QuotesCase.fixture()
    {:ok, _} = FootballMarket.Valuation.Configurations.activate(f.configuration.id, nil)
    {:ok, _} = FootballMarket.Quotes.request(f.subject, :active, f.mapping.id)
    other = List.last(f.base.players)
    {:ok, _} = FootballMarket.Market.initialize_player(other.id)

    {:ok, _} =
      FootballMarket.Statistics.record_performance(
        FootballMarket.StatisticsCase.performance_attrs(f.base, f.match, %{
          player_id: other.id,
          team_id: f.base.away.id,
          goals: 2,
          minutes_played: 90
        })
      )

    {:ok, _} =
      FootballMarket.Quotes.request(%{f.subject | player_id: other.id}, :active, f.mapping.id)

    FootballMarket.PurchasesCase.fund(credentials.user, "100")
    FootballMarket.PurchasesCase.fund(f.user, "100")
    {:ok, ranking} = FootballMarket.Ranking.read()
    dir = Path.join(System.tmp_dir!(), "market-e2e-" <> Ecto.UUID.generate())
    File.mkdir!(dir)
    File.chmod!(dir, 0o700)

    watcher =
      Task.async(fn ->
        Runtime.await!(fn -> market_execution_signal(dir) end)

        assert :ok = Oban.start_queue(queue: :conditional_orders, limit: 1)
      end)

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/e2e_market.mjs", base],
          env: [
            {"E2E_EMAIL", credentials.email},
            {"E2E_PASSWORD", credentials.password},
            {"E2E_PLAYER", f.player.id},
            {"E2E_NAME", f.player.display_name},
            {"E2E_RANKING", Jason.encode!(Enum.map(ranking.entries, & &1.player_id))},
            {"E2E_STRATEGY", f.configuration.strategy_id},
            {"E2E_IPC", dir}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, output
      assert output == "E2E_MARKET status=complete\n"
      Task.await(watcher, 1_000)

      {:ok, positions} =
        FootballMarket.Market.portfolio(FootballMarket.PurchasesCase.actor(credentials.user))

      assert [%{player_id: id, quantity: 2}] = positions
      assert id == f.player.id
      :ok
    after
      Task.shutdown(watcher, :brutal_kill)
      File.rm_rf!(dir)
    end
  end

  defp market_execution_signal(dir) do
    if File.exists?(Path.join(dir, "execute")), do: {:ok, :ready}, else: :pending
  end

  defp expire_browser_clock(dir, clock) do
    wait_for_expiration_request(dir)

    :persistent_term.put(
      {FootballMarket.BrowserTestClock, :now},
      DateTime.add(clock, 901, :second)
    )

    File.write!(Path.join(dir, "expired"), "ready")
  end

  defp wait_for_expiration_request(dir) do
    Runtime.await!(fn ->
      if File.exists?(Path.join(dir, "expire")), do: {:ok, :requested}, else: :pending
    end)
  end

  def catalog!(base) do
    %{user: user} = account!()
    {:ok, jwt} = Accounts.Authentication.issue(user.id)
    FootballMarket.IngestionFixtures.positions!()
    gate = make_ref()
    source = FootballMarket.E2E.FixtureAdapter.source(self(), gate)

    Application.put_env(:football_market, Synchronization,
      enabled: true,
      automatic: false,
      sources: %{"e2e-fixture" => source}
    )

    immutable =
      snapshot(
        ~w(market_initial_recipients market_quotes market_holdings market_issuances matches player_match_performances)
      )

    identity =
      Enum.reduce(1..2, nil, fn _, previous_identity ->
        identity = catalog_identity(gate, base, jwt, immutable)
        if previous_identity, do: assert(identity == previous_identity)
        identity
      end)

    assert match?({_id, _catalog_identity, _season}, identity)

    before_rejections =
      snapshot(
        ~w(leagues seasons teams positions players catalog_ingestion_scopes catalog_source_bindings catalog_ingestion_observations catalog_ingestion_observation_bindings synchronization_runs oban_jobs)
      )

    assert_catalog_rejections()
    assert_player_http_errors(base, jwt)

    assert snapshot(Map.keys(before_rejections)) == before_rejections
    assert immutable == snapshot(Map.keys(immutable))
    :ok
  end

  defp catalog_identity(gate, base, jwt, immutable) do
    assert {:ok, admitted} =
             Synchronization.request_catalog(FootballMarket.Synchronization.Fixtures.scope(),
               source_ref: "e2e-fixture"
             )

    assert_receive {^gate, worker, _backend}, 10_000
    assert {:ok, run} = Synchronization.get_run(admitted.run_id)
    refute run.state in ["succeeded", "failed"]
    FootballMarket.E2E.FixtureAdapter.release(worker, gate)
    await_catalog_run(admitted.run_id)
    await_catalog_jobs()

    {200, headers, body} = Runtime.get(base <> "/api/players?page_size=1", jwt)
    assert header(headers, ~c"content-type") =~ "application/json"
    data = Jason.decode!(body)
    assert_expected_player(data["data"])
    assert data["pagination"]["next_cursor"] == nil
    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == 1
    assert immutable == snapshot(Map.keys(immutable))

    record = hd(data["data"])
    assert {:ok, _} = Ecto.UUID.cast(record["id"])
    assert is_binary(record["catalog_identity"]) and record["catalog_identity"] != ""
    {record["id"], record["catalog_identity"], record["season"]}
  end

  defp assert_expected_player(data) do
    assert [
             %{
               "display_name" => "Alex",
               "season" => %{"start_year" => 2090, "end_year" => 2091},
               "league" => %{"code" => "PL"},
               "team" => %{"short_code" => "ALP"},
               "position" => %{"code" => "GK"}
             }
           ] = data
  end

  defp await_catalog_run(run_id) do
    Runtime.await!(fn ->
      case Synchronization.get_run(run_id) do
        {:ok, %{state: "succeeded"} = done} -> {:ok, done}
        {:ok, %{state: state}} when state in ["failed", "cancelled"] -> {:error, state}
        _ -> :pending
      end
    end)
  end

  defp await_catalog_jobs do
    Runtime.await!(fn ->
      pending =
        Repo.aggregate(
          from(j in Oban.Job, where: j.queue == "catalog_sync" and j.state != "completed"),
          :count
        )

      if pending == 0, do: {:ok, :completed}, else: :pending
    end)
  end

  defp assert_catalog_rejections do
    for scope <- [%{}, %{league_code: "UNKNOWN", start_year: 2090, end_year: 2091}] do
      assert {:error, %{category: :invalid_request}} =
               Synchronization.request_catalog(scope, source_ref: "e2e-fixture")
    end
  end

  defp assert_player_http_errors(base, jwt) do
    assert_player_http_error(base, "", nil, 401, "unauthenticated")
    assert_player_http_error(base, "?page_size=invalid", jwt, 400, "invalid_page_size")
  end

  defp assert_player_http_error(base, suffix, token, status, code) do
    {actual, headers, body} = Runtime.get(base <> "/api/players" <> suffix, token)
    assert actual == status
    assert header(headers, ~c"content-type") =~ "application/json"
    assert Jason.decode!(body)["error"]["code"] == code

    if status == 401,
      do: assert(header(headers, ~c"www-authenticate") == "Bearer realm=\"api\"")
  end

  defp header(headers, key), do: headers |> List.keyfind(key, 0) |> elem(1) |> to_string()

  defp snapshot(tables) do
    Map.new(tables, fn table ->
      {table,
       Ecto.Adapters.SQL.query!(
         Repo,
         "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text",
         []
       ).rows}
    end)
  end
end
