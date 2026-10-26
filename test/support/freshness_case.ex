defmodule FootballMarket.FreshnessCase do
  @moduledoc false
  import ExUnit.Assertions
  import Ecto.Query
  alias FootballMarket.{Repo, Catalog, Synchronization}
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
  alias FootballMarket.Synchronization.Run

  def fixture do
    old_freshness = Application.get_env(:football_market, Freshness)
    old_sync = Application.get_env(:football_market, Synchronization)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(:football_market, Freshness, old_freshness)
      Application.put_env(:football_market, Synchronization, old_sync)
    end)

    scope = Fixtures.scope(2025)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    source = Case.source(candidate)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(old_sync, :sources, %{"freshness-fixture" => source})
    )

    options = [source_ref: "freshness-fixture"]

    Application.put_env(:football_market, Freshness,
      ttl_seconds: 86_400,
      cooldown_seconds: 3_600,
      refresh_options_by_scope: %{{"PL", 2025, 2026} => options}
    )

    player =
      Repo.one!(
        from p in FootballMarket.Catalog.Player,
          join: s in FootballMarket.Catalog.Season,
          on: s.id == p.season_id,
          where: s.start_year == 2025
      )

    {:ok, player} = Catalog.get_player_detail(player.id)
    %{player: player, scope: scope, candidate: candidate, source: source, options: options}
  end

  def perform!(f) do
    status = Freshness.for_player(f.player)
    run = Repo.get!(Run, status.refresh.run_id)
    assert :ok = FootballMarket.Workers.StatisticsImport.perform(Repo.get!(Oban.Job, run.job_id))
    run = Repo.get!(Run, run.id)
    assert run.state == "succeeded", "fixture import did not succeed: #{inspect(run.reason)}"
    run
  end

  def fail!(f, category \\ "timeout", wait_ms \\ nil) do
    status = Freshness.for_player(f.player)
    run = Repo.get!(Run, status.refresh.run_id)
    transient = category in ~w(timeout unavailable rate_limited)

    Repo.update!(
      Ecto.Changeset.change(run,
        state: "failed",
        reason: if(transient, do: "exhausted", else: "non_retryable"),
        outcome: %{
          "status" => "provider_failure",
          "category" => category,
          "retryable" => transient,
          "retry_after_ms" => wait_ms
        },
        finished_at: FootballMarket.Synchronization.Clock.now()
      )
    )
  end

  def config(key, value) do
    current = Application.get_env(:football_market, Freshness)
    Application.put_env(:football_market, Freshness, Keyword.put(current, key, value))
  end
end
