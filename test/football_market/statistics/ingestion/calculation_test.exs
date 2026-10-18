defmodule FootballMarket.Statistics.Ingestion.CalculationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics, Synchronization}
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.Statistics.Ingestion.Check
  alias FootballMarket.Valuation.CalculationRequest
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "accepted import creates a durable idempotent request without writing quotes" do
    scope = Fixtures.scope(2080)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    quote_count = Repo.aggregate(FootballMarket.Market.Quote, :count)

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)
    performance_ids = intent.changed_performance_ids

    assert {:ok, first} =
             FootballMarket.Valuation.CalculationRequests.accept(
               intent.id,
               intent.accepted_check_id,
               performance_ids
             )

    assert {:ok, second} =
             FootballMarket.Valuation.CalculationRequests.accept(
               intent.id,
               intent.accepted_check_id,
               performance_ids
             )

    assert first.id == second.id

    assert :ok =
             Oban.Testing.perform_job(
               FootballMarket.Workers.CalculationDispatch,
               %{"intent_id" => intent.id},
               []
             )

    assert Repo.get!(CalculationIntent, intent.id).state == "delivered"

    assert {:ok, delivered} =
             FootballMarket.Valuation.CalculationRequests.get(intent.id)

    assert delivered.id == first.id

    assert {:error, :calculation_request_conflict} =
             FootballMarket.Valuation.CalculationRequests.accept(
               intent.id,
               intent.accepted_check_id,
               [Ecto.UUID.generate()]
             )

    assert Repo.aggregate(FootballMarket.Market.Quote, :count) == quote_count

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    assert {:ok, history} =
             Statistics.list_player_history(
               Repo.one!(
                 from p in FootballMarket.Statistics.Performance,
                   where: p.season_id == ^season_id,
                   select: p.player_id
               )
             )

    assert length(history) == 1
  end

  test "dispatch accepts a persisted unordered multi-performance identity set after redelivery" do
    scope = Fixtures.scope(2083)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    base = hd(Case.candidate(request).facts.matches)

    matches =
      for index <- 1..8 do
        %{base | ref: "match-#{index}", kickoff_at: DateTime.add(base.kickoff_at, index, :day)}
      end

    base_performance = hd(Case.candidate(request).facts.performances)

    performances =
      for index <- 1..8 do
        %{base_performance | ref: "performance-#{index}", match_ref: "match-#{index}"}
      end

    candidate = Case.candidate(request, matches: matches, performances: performances)

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)

    canonical_ids = Enum.sort(intent.changed_performance_ids)
    assert length(canonical_ids) == 8
    unordered_ids = Enum.reverse(canonical_ids)
    assert unordered_ids != canonical_ids
    assert intent.changed_performance_ids == canonical_ids

    assert {:ok, request} =
             FootballMarket.Valuation.CalculationRequests.accept(
               intent.id,
               intent.accepted_check_id,
               unordered_ids
             )

    assert request.changed_performance_ids == canonical_ids

    assert :ok =
             Oban.Testing.perform_job(
               FootballMarket.Workers.CalculationDispatch,
               %{"intent_id" => intent.id},
               []
             )

    assert Repo.get!(CalculationIntent, intent.id).state == "delivered"
    assert {:ok, request} = FootballMarket.Valuation.CalculationRequests.get(intent.id)
    assert request.changed_performance_ids == canonical_ids
  end

  test "failed calculation delivery remains separate from the committed import" do
    scope = Fixtures.scope(2081)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             FootballMarket.Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)

    dynamic_repo = Repo.get_dynamic_repo()
    Repo.put_dynamic_repo(:unavailable_calculation_repo)

    try do
      assert {:error, :request_unavailable} =
               Oban.Testing.perform_job(
                 FootballMarket.Workers.CalculationDispatch,
                 %{"intent_id" => intent.id},
                 []
               )
    after
      Repo.put_dynamic_repo(dynamic_repo)
    end

    assert Repo.get!(CalculationIntent, intent.id).state == "pending"
    assert Repo.get(Check, outcome.check_id)

    assert Repo.aggregate(from(r in CalculationRequest, where: r.intent_id == ^intent.id), :count) ==
             0

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    assert Repo.aggregate(
             from(p in Statistics.Performance, where: p.season_id == ^season_id),
             :count
           ) == 1
  end

  test "Oban redelivers a calculation accepted before worker interruption" do
    timestamp = DateTime.utc_now()

    start_year =
      rem(DateTime.to_unix(timestamp) * 1_000 + elem(timestamp.microsecond, 0), 2_000_000_000)

    scope = Fixtures.scope(start_year)

    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)
    {:ok, dispatcher} = Synchronization.Dispatcher.start_link(automatic: false, name: nil)

    try do
      Application.put_env(
        :football_market,
        :task021_calculation_dispatch_failpoint,
        {self(), intent.id}
      )

      assert {:ok, _} = Synchronization.Dispatcher.tick(dispatcher)

      active_jobs =
        Repo.aggregate(
          from(j in Oban.Job,
            where:
              j.worker == "FootballMarket.Workers.CalculationDispatch" and
                j.state in ["available", "scheduled", "executing", "retryable"] and
                fragment("?->>'intent_id' = ?", j.args, ^intent.id)
          ),
          :count
        )

      assert active_jobs == 1
      assert {:ok, _} = Synchronization.Dispatcher.tick(dispatcher)

      assert Repo.aggregate(
               from(j in Oban.Job,
                 where:
                   j.worker == "FootballMarket.Workers.CalculationDispatch" and
                     j.state in ["available", "scheduled", "executing", "retryable"] and
                     fragment("?->>'intent_id' = ?", j.args, ^intent.id)
               ),
               :count
             ) == 1

      drain_until_acceptance!(intent.id, 25)

      assert Repo.get!(CalculationIntent, intent.id).state == "pending"

      assert Repo.aggregate(
               from(r in CalculationRequest, where: r.intent_id == ^intent.id),
               :count
             ) == 1

      assert {:ok, _} = Synchronization.Dispatcher.tick(dispatcher)
      drain_until_delivered!(intent.id, dispatcher, 25)

      assert Repo.aggregate(
               from(r in CalculationRequest, where: r.intent_id == ^intent.id),
               :count
             ) == 1

      assert {:ok, _request} = FootballMarket.Valuation.CalculationRequests.get(intent.id)
    after
      Application.delete_env(:football_market, :task021_calculation_dispatch_failpoint)
      GenServer.stop(dispatcher)
    end
  end

  test "a stale executing dispatch job cannot strand its calculation intent" do
    scope = Fixtures.scope(2084)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)

    assert {:ok, orphan} =
             Oban.insert(
               Oban,
               FootballMarket.Workers.CalculationDispatch.new(%{"intent_id" => intent.id})
             )

    stale_attempt =
      DateTime.add(DateTime.utc_now(), -301, :second) |> DateTime.truncate(:microsecond)

    Repo.update!(
      Ecto.Changeset.change(orphan,
        state: "executing",
        attempted_at: stale_attempt,
        attempted_by: ["terminated-node", "terminated-producer"]
      )
    )

    {:ok, dispatcher} = Synchronization.Dispatcher.start_link(automatic: false, name: nil)

    try do
      assert {:ok, _} = Synchronization.Dispatcher.tick(dispatcher)

      assert Repo.aggregate(
               from(j in Oban.Job,
                 where:
                   j.worker == "FootballMarket.Workers.CalculationDispatch" and
                     j.state == "available" and
                     fragment("?->>'intent_id' = ?", j.args, ^intent.id)
               ),
               :count
             ) == 1

      assert %{success: 1} = Oban.drain_queue(queue: :statistics_import, with_scheduled: true)
      assert Repo.get!(CalculationIntent, intent.id).state == "delivered"
      assert {:ok, _request} = FootballMarket.Valuation.CalculationRequests.get(intent.id)
    after
      GenServer.stop(dispatcher)
    end
  end

  test "transient calculation receiver failures exhaust only the bounded dispatch budget" do
    scope = Fixtures.scope(2082)
    Case.seed_catalog!(scope)
    quote_count = Repo.aggregate(FootballMarket.Market.Quote, :count)
    candidate = Case.candidate(Fixtures.request(scope))
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    intent = Repo.get!(CalculationIntent, outcome.calculation_intent_id)

    future = DateTime.add(DateTime.utc_now(), 60, :second) |> DateTime.truncate(:microsecond)
    Repo.update!(Ecto.Changeset.change(intent, next_attempt_at: future))

    assert :ok =
             Oban.Testing.perform_job(
               FootballMarket.Workers.CalculationDispatch,
               %{"intent_id" => intent.id},
               []
             )

    assert Repo.get!(CalculationIntent, intent.id).attempts == 0
    assert Repo.get!(CalculationIntent, intent.id).state == "pending"

    assert Repo.aggregate(from(r in CalculationRequest, where: r.intent_id == ^intent.id), :count) ==
             0

    Repo.update!(
      Ecto.Changeset.change(Repo.get!(CalculationIntent, intent.id), next_attempt_at: nil)
    )

    Repo.query!("""
    CREATE FUNCTION task021_reject_calculation_request() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      RAISE EXCEPTION 'controlled test receiver outage' USING ERRCODE = '40001';
    END $$
    """)

    Repo.query!("""
    CREATE TRIGGER task021_reject_calculation_request
    BEFORE INSERT ON valuation_calculation_requests
    FOR EACH ROW EXECUTE FUNCTION task021_reject_calculation_request()
    """)

    for attempt <- 1..3 do
      if attempt > 1 do
        due = DateTime.add(DateTime.utc_now(), -1, :second) |> DateTime.truncate(:microsecond)

        Repo.update!(
          Ecto.Changeset.change(Repo.get!(CalculationIntent, intent.id), next_attempt_at: due)
        )
      end

      assert {:error, :request_unavailable} =
               Oban.Testing.perform_job(
                 FootballMarket.Workers.CalculationDispatch,
                 %{"intent_id" => intent.id},
                 []
               )

      current = Repo.get!(CalculationIntent, intent.id)
      assert current.attempts == attempt
      assert current.state == if(attempt == 3, do: "failed", else: "pending")
    end

    assert :ok =
             Oban.Testing.perform_job(
               FootballMarket.Workers.CalculationDispatch,
               %{"intent_id" => intent.id},
               []
             )

    exhausted = Repo.get!(CalculationIntent, intent.id)
    assert exhausted.attempts == 3
    assert exhausted.state == "failed"

    assert Repo.get(Check, outcome.check_id)

    assert Repo.aggregate(from(r in CalculationRequest, where: r.intent_id == ^intent.id), :count) ==
             0

    assert Repo.aggregate(FootballMarket.Market.Quote, :count) == quote_count
  end

  defp drain_until_acceptance!(_intent_id, 0),
    do: flunk("Oban did not execute the targeted intent")

  defp drain_until_acceptance!(intent_id, remaining) do
    result = Oban.drain_queue(queue: :statistics_import, with_limit: 1, with_scheduled: true)
    assert Enum.sum(Map.values(result)) > 0

    receive do
      {:task021_calculation_request_accepted, ^intent_id, _worker} ->
        :ok

      {:task021_calculation_request_accepted, _other_id, _worker} ->
        drain_until_acceptance!(intent_id, remaining - 1)
    after
      0 ->
        drain_until_acceptance!(intent_id, remaining - 1)
    end
  end

  defp drain_until_delivered!(_intent_id, _dispatcher, 0),
    do: flunk("dispatcher did not recover the accepted calculation request")

  defp drain_until_delivered!(intent_id, dispatcher, remaining) do
    if Repo.get!(CalculationIntent, intent_id).state == "delivered" do
      :ok
    else
      assert {:ok, _} = Synchronization.Dispatcher.tick(dispatcher)
      _ = Oban.drain_queue(queue: :statistics_import, with_limit: 1, with_scheduled: true)
      drain_until_delivered!(intent_id, dispatcher, remaining - 1)
    end
  end
end
