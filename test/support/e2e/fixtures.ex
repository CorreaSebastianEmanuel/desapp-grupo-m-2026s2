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
      Task.async(fn ->
        Runtime.await!(fn ->
          if File.exists?(Path.join(dir, "expire")), do: {:ok, :requested}, else: :pending
        end)

        :persistent_term.put(
          {FootballMarket.BrowserTestClock, :now},
          DateTime.add(clock, 901, :second)
        )

        File.write!(Path.join(dir, "expired"), "ready")
      end)

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

    Enum.reduce(1..2, nil, fn _, previous_identity ->
      assert {:ok, admitted} =
               Synchronization.request_catalog(FootballMarket.Synchronization.Fixtures.scope(),
                 source_ref: "e2e-fixture"
               )

      assert_receive {^gate, worker, _backend}, 10_000
      assert {:ok, run} = Synchronization.get_run(admitted.run_id)
      refute run.state in ["succeeded", "failed"]
      FootballMarket.E2E.FixtureAdapter.release(worker, gate)

      Runtime.await!(fn ->
        case Synchronization.get_run(admitted.run_id) do
          {:ok, %{state: "succeeded"} = done} -> {:ok, done}
          {:ok, %{state: state}} when state in ["failed", "cancelled"] -> {:error, state}
          _ -> :pending
        end
      end)

      Runtime.await!(fn ->
        pending =
          Repo.aggregate(
            from(j in Oban.Job, where: j.queue == "catalog_sync" and j.state != "completed"),
            :count
          )

        if pending == 0, do: {:ok, :completed}, else: :pending
      end)

      {200, headers, body} = Runtime.get(base <> "/api/players?page_size=1", jwt)
      assert header(headers, ~c"content-type") =~ "application/json"
      data = Jason.decode!(body)

      assert [
               %{
                 "display_name" => "Alex",
                 "season" => %{"start_year" => 2090, "end_year" => 2091},
                 "league" => %{"code" => "PL"},
                 "team" => %{"short_code" => "ALP"},
                 "position" => %{"code" => "GK"}
               }
             ] = data["data"]

      assert data["pagination"]["next_cursor"] == nil
      assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == 1
      assert immutable == snapshot(Map.keys(immutable))
      record = hd(data["data"])
      assert {:ok, _} = Ecto.UUID.cast(record["id"])
      assert is_binary(record["catalog_identity"]) and record["catalog_identity"] != ""
      identity = {record["id"], record["catalog_identity"], record["season"]}
      if previous_identity, do: assert(identity == previous_identity)
      identity
    end)

    before_rejections =
      snapshot(
        ~w(leagues seasons teams positions players catalog_ingestion_scopes catalog_source_bindings catalog_ingestion_observations catalog_ingestion_observation_bindings synchronization_runs oban_jobs)
      )

    for scope <- [%{}, %{league_code: "UNKNOWN", start_year: 2090, end_year: 2091}] do
      assert {:error, %{category: :invalid_request}} =
               Synchronization.request_catalog(scope, source_ref: "e2e-fixture")
    end

    for {suffix, token, status, code} <- [
          {"", nil, 401, "unauthenticated"},
          {"?page_size=invalid", jwt, 400, "invalid_page_size"}
        ] do
      {actual, headers, body} = Runtime.get(base <> "/api/players" <> suffix, token)
      assert actual == status
      assert header(headers, ~c"content-type") =~ "application/json"
      assert Jason.decode!(body)["error"]["code"] == code

      if status == 401,
        do: assert(header(headers, ~c"www-authenticate") == "Bearer realm=\"api\"")
    end

    assert snapshot(Map.keys(before_rejections)) == before_rejections
    assert immutable == snapshot(Map.keys(immutable))
    :ok
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
