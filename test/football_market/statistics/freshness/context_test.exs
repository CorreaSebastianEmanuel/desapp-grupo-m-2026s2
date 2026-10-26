defmodule FootballMarket.Statistics.Freshness.ContextTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, FreshnessCase, Synchronization}
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.Statistics.Ingestion.{ScopeCheck, Check}
  alias FootballMarket.Synchronization.{Run, Trigger, Clock}

  setup do
    {:ok, FreshnessCase.fixture()}
  end

  test "never checked detail admits one durable job and repeated reads reuse it", f do
    protected = FootballMarket.QuotesCase.protected_snapshot()
    first = Freshness.for_player(f.player)
    assert FootballMarket.QuotesCase.protected_snapshot() == protected
    assert first.freshness == "never_checked"
    assert first.last_checked_at == nil
    assert first.scope.provider == "synthetic-a"
    assert first.scope.coverage == "league_season"
    assert first.source_mode == "fixture"
    assert first.refresh.state == "queued"

    assert Repo.get!(Oban.Job, Repo.get!(Run, first.refresh.run_id).job_id).worker ==
             "FootballMarket.Workers.StatisticsImport"

    for _ <- 1..5,
        do: assert(Freshness.for_player(f.player).refresh.run_id == first.refresh.run_id)

    assert Repo.aggregate(Run, :count) == 1
    assert Repo.aggregate(Trigger, :count) == 1
    assert Repo.aggregate(Check, :count) == 0
  end

  test "accepted complete checks set the TTL; exact expiry and TTL changes request refresh", f do
    FreshnessCase.perform!(f)
    row = ScopeCheck.find("synthetic-a", f.player.season_id)
    Process.put(:synchronization_now, DateTime.add(row.last_checked_at, 86_399, :second))
    fresh = Freshness.for_player(f.player)
    assert fresh.freshness == "fresh"
    assert fresh.refresh.state == "idle"
    assert fresh.last_checked_at == row.last_checked_at
    Process.put(:synchronization_now, fresh.expires_at)
    stale = Freshness.for_player(f.player)
    assert stale.freshness == "stale"
    assert stale.refresh.state == "queued"
    assert stale.last_checked_at == row.last_checked_at
    assert Repo.aggregate(Run, :count) == 2
    FreshnessCase.config(:ttl_seconds, 172_800)
    assert Freshness.for_player(f.player).freshness == "fresh"
  end

  test "a complete no-change check renews freshness without replacing prior pending valuation",
       f do
    first = FreshnessCase.perform!(f)
    before = Freshness.for_player(f.player)
    assert before.valuation.state == "pending"
    assert before.valuation.calculation_intent_id
    Process.put(:synchronization_now, DateTime.add(before.expires_at, 1, :second))
    second = FreshnessCase.perform!(f)
    Process.delete(:synchronization_now)
    after_check = Freshness.for_player(f.player)
    assert second.id != first.id
    assert DateTime.compare(after_check.last_checked_at, before.last_checked_at) == :gt
    assert after_check.valuation == before.valuation
    assert Repo.aggregate(Check, :count) == 2
    assert Repo.aggregate(FootballMarket.Statistics.Performance, :count) == 1
  end

  test "complete empty checks are fresh and need no valuation", f do
    candidate =
      FootballMarket.StatisticsIngestion.Case.candidate(
        FootballMarket.StatisticsIngestion.Fixtures.request(f.scope),
        matches: [],
        performances: []
      )

    source = FootballMarket.StatisticsIngestion.Case.source(candidate)
    sync = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :sources, %{"freshness-fixture" => source})
    )

    FreshnessCase.perform!(f)
    status = Freshness.for_player(f.player)
    assert status.freshness == "fresh"
    assert status.valuation.state == "not_requested"
    assert Repo.one!(Check).outcome == "accepted_empty"
  end

  test "active retries and executions are reused without advancing freshness", f do
    initial = Freshness.for_player(f.player)
    run = Repo.get!(Run, initial.refresh.run_id)

    for state <- ~w(executing retry_wait) do
      deadline = if state == "retry_wait", do: DateTime.add(Clock.now(), 60, :second)
      Repo.update!(Ecto.Changeset.change(run, state: state, next_retry_at: deadline))
      current = Freshness.for_player(f.player)
      assert current.refresh.state == state
      assert current.refresh.next_attempt_at == deadline
      assert current.last_checked_at == nil
    end

    assert Repo.aggregate(Run, :count) == 1
    assert Repo.aggregate(Trigger, :count) == 1
  end

  test "transient exhaustion observes cooldown, provider wait and exact eligibility", f do
    failed = FreshnessCase.fail!(f, "rate_limited", 7_200_000)
    Process.put(:synchronization_now, DateTime.add(failed.finished_at, 3_600, :second))
    current = Freshness.for_player(f.player)
    assert current.refresh.state == "cooldown"
    assert current.refresh.reason == "rate_limited"
    assert current.refresh.next_attempt_at == DateTime.add(failed.finished_at, 7_200, :second)
    assert current.last_checked_at == nil
    Process.put(:synchronization_now, current.refresh.next_attempt_at)
    assert Freshness.for_player(f.player).refresh.state == "queued"
    assert Repo.aggregate(Run, :count) == 2
  end

  test "default cooldown lasts exactly one hour", f do
    failed = FreshnessCase.fail!(f)
    Process.put(:synchronization_now, DateTime.add(failed.finished_at, 3_599, :second))
    status = Freshness.for_player(f.player)
    assert status.refresh.state == "cooldown"
    assert status.refresh.next_attempt_at == DateTime.add(failed.finished_at, 3_600, :second)
    Process.put(:synchronization_now, status.refresh.next_attempt_at)
    assert Freshness.for_player(f.player).refresh.state == "queued"
  end

  test "a trusted manual retry can recover a permanent failure with unchanged inputs", f do
    FreshnessCase.fail!(f, "access_refused")
    assert Freshness.for_player(f.player).refresh.state == "blocked"
    {:ok, admitted} = Synchronization.request_statistics(f.scope, f.options)
    run = Repo.get!(Run, admitted.run_id)
    FootballMarket.Workers.StatisticsImport.perform(Repo.get!(Oban.Job, run.job_id))
    current = Freshness.for_player(f.player)
    assert current.freshness == "fresh"
    assert current.refresh.state == "idle"
    Process.put(:synchronization_now, current.expires_at)
    assert Freshness.for_player(f.player).refresh.state == "queued"
  end

  test "permanent failures block reads from retrying but changed configured inputs recover", f do
    failed = FreshnessCase.fail!(f, "access_refused")
    Process.put(:synchronization_now, DateTime.add(failed.finished_at, 86_400, :second))
    assert Freshness.for_player(f.player).refresh.state == "blocked"
    assert Repo.aggregate(Run, :count) == 1

    FreshnessCase.config(
      :refresh_options_by_scope,
      %{{"PL", 2025, 2026} => f.options ++ [fixture_ref: "corrected-source"]}
    )

    assert Freshness.for_player(f.player).refresh.state == "queued"
    assert Repo.aggregate(Run, :count) == 2
  end

  test "a different active input is busy and does not borrow its run or provider freshness", f do
    {:ok, _} =
      Synchronization.request_statistics(f.scope, f.options ++ [fixture_ref: "operator-work"])

    current = Freshness.for_player(f.player)
    assert current.refresh.state == "busy"
    assert current.refresh.run_id == nil
    assert current.last_checked_at == nil
    assert Repo.aggregate(Run, :count) == 1
  end

  test "unconfigured and invalid configuration retain local status and enqueue nothing", f do
    FreshnessCase.config(:refresh_options_by_scope, %{})
    assert Freshness.for_player(f.player).refresh.state == "unconfigured"
    FreshnessCase.config(:ttl_seconds, 123)
    assert Freshness.for_player(f.player).ttl_seconds == 123
    FreshnessCase.config(:ttl_seconds, 0)
    bad = Freshness.for_player(f.player)
    assert bad.freshness == "unavailable"
    assert bad.refresh.reason == "invalid_configuration"
    assert Repo.aggregate(Run, :count) == 0
  end

  test "job insertion failure rolls back admission and retains local data", f do
    sync = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :oban_name, :MissingFreshnessOban)
    )

    current = Freshness.for_player(f.player)
    assert current.refresh.state == "unavailable"
    assert current.refresh.reason == "temporarily_unavailable"
    assert Repo.aggregate(Run, :count) == 0
    assert Repo.aggregate(Trigger, :count) == 0
    assert Repo.aggregate(FootballMarket.Synchronization.DeliveryReceipt, :count) == 0
    assert {:ok, _} = FootballMarket.Catalog.get_player_detail(f.player.id)
  end

  test "incomplete and conflicting imports retain the accepted check and immutable facts", f do
    FreshnessCase.perform!(f)
    before = Freshness.for_player(f.player)
    protected = FootballMarket.QuotesCase.protected_snapshot()
    Process.put(:synchronization_now, DateTime.add(before.expires_at, 1, :second))
    performance = hd(f.candidate.facts.performances)

    conflicting =
      put_in(f.candidate.facts.performances, [%{performance | counts: %{goals: 1, assists: nil}}])

    incomplete = put_in(f.candidate.completeness.full_scope, false)

    for candidate <- [conflicting, incomplete] do
      sync = Application.get_env(:football_market, Synchronization)
      source = FootballMarket.StatisticsIngestion.Case.source(candidate)

      Application.put_env(
        :football_market,
        Synchronization,
        Keyword.put(sync, :sources, %{"freshness-fixture" => source})
      )

      run = Repo.get!(Run, Freshness.for_player(f.player).refresh.run_id)
      FootballMarket.Workers.StatisticsImport.perform(Repo.get!(Oban.Job, run.job_id))
      assert Repo.get!(Run, run.id).state == "failed"
      current = Freshness.for_player(f.player)
      assert current.last_checked_at == before.last_checked_at
      assert current.refresh.state == "blocked"
      assert Repo.aggregate(Check, :count) == 1
      assert FootballMarket.QuotesCase.protected_snapshot() == protected
    end
  end

  test "another provider cannot make this scope fresh", f do
    FreshnessCase.perform!(f)
    sync = Application.get_env(:football_market, Synchronization)

    replacement = %{
      f.source
      | provider: {FootballMarket.IngestionReplacementAdapter, f.candidate}
    }

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :sources, %{"freshness-fixture" => replacement})
    )

    status = Freshness.for_player(f.player)
    assert status.last_checked_at == nil
    assert status.freshness == "never_checked"
    assert status.scope.provider != "synthetic-a"
    assert status.refresh.state == "queued"
  end

  test "a completed check in one season does not freshen another season", f do
    FreshnessCase.perform!(f)
    second_scope = FootballMarket.StatisticsIngestion.Fixtures.scope(2027)
    FootballMarket.StatisticsIngestion.Case.seed_catalog!(second_scope)

    second =
      Repo.one!(
        from p in FootballMarket.Catalog.Player,
          join: s in FootballMarket.Catalog.Season,
          on: s.id == p.season_id,
          where: s.start_year == 2027
      )

    {:ok, second} = FootballMarket.Catalog.get_player_detail(second.id)

    second_source =
      FootballMarket.StatisticsIngestion.Case.source(
        FootballMarket.StatisticsIngestion.Case.candidate(
          FootballMarket.StatisticsIngestion.Fixtures.request(second_scope)
        )
      )

    sync = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :sources, %{
        "freshness-fixture" => f.source,
        "season-two" => second_source
      })
    )

    FreshnessCase.config(
      :refresh_options_by_scope,
      %{{"PL", 2025, 2026} => f.options, {"PL", 2027, 2028} => [source_ref: "season-two"]}
    )

    current = Freshness.for_player(second)
    assert current.last_checked_at == nil
    assert current.freshness == "never_checked"
    assert current.refresh.state == "queued"
    assert Freshness.for_player(f.player).freshness == "fresh"
  end
end
