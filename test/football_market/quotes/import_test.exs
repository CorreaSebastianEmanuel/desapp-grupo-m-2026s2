defmodule FootballMarket.Quotes.ImportTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
  alias FootballMarket.Valuation.CalculationRequests

  test "accepted changed facts pin complete immutable weekly membership before dispatch" do
    scope = Fixtures.scope(2085)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    delivery = Case.delivery_context!(scope)

    assert {:ok, accepted} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: delivery]
             )

    intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)

    assert [[snapshot_id, schema_version, membership, digest]] =
             Repo.query!(
               "SELECT id, schema_version, cardinality(membership), digest FROM quote_import_scope_snapshots WHERE intent_id=$1",
               [Ecto.UUID.dump!(intent.id)]
             ).rows

    assert schema_version == 1
    assert membership == 1
    assert is_binary(digest) and byte_size(digest) == 64

    assert [[1]] =
             Repo.query!(
               "SELECT count(*) FROM quote_import_snapshot_facts WHERE snapshot_id=$1",
               [snapshot_id]
             ).rows

    replay_delivery = Case.delivery_context!(scope)

    assert {:ok, replayed} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: replay_delivery]
             )

    assert replayed.status == :replay

    assert Repo.query!("SELECT count(*) FROM quote_import_scope_snapshots WHERE intent_id=$1", [
             Ecto.UUID.dump!(intent.id)
           ]).rows == [[1]]
  end

  test "two accepted imports before dispatch retain multi-player and multi-week memberships" do
    scope = Fixtures.scope(2086)
    catalog = FootballMarket.IngestionFixtures.candidate("PL", scope.start_year)
    second_player = %{hd(catalog.facts.players) | ref: "player-b", display_name: "Blair"}
    catalog = put_in(catalog.facts.players, catalog.facts.players ++ [second_player])

    catalog = %{
      catalog
      | bindings: catalog.bindings ++ [%{kind: :player, ref: "player-b", source_id: "player-B"}]
    }

    FootballMarket.IngestionFixtures.positions!()

    assert {:ok, _} =
             FootballMarket.Catalog.Ingestion.import_catalog(
               Map.take(scope, [:league_code, :start_year, :end_year]),
               FootballMarket.IngestionFixtures.options(catalog)
             )

    request = Fixtures.request(scope)
    match_scope = Map.take(request.scope, [:league_code, :start_year, :end_year])

    matches = [
      %{
        ref: "match-a",
        scope: match_scope,
        season_ref: "season-ref",
        status: :completed,
        kickoff_at: ~U[2026-01-01 12:00:00Z],
        home_team_ref: "team-a",
        away_team_ref: "team-b"
      },
      %{
        ref: "match-b",
        scope: match_scope,
        season_ref: "season-ref",
        status: :completed,
        kickoff_at: ~U[2026-01-12 12:00:00Z],
        home_team_ref: "team-a",
        away_team_ref: "team-b"
      }
    ]

    performances = [
      %{
        ref: "performance-a1",
        match_ref: "match-a",
        player_ref: "player-a",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 1, assists: nil}
      },
      %{
        ref: "performance-b1",
        match_ref: "match-a",
        player_ref: "player-b",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 2, assists: nil}
      },
      %{
        ref: "performance-a2",
        match_ref: "match-b",
        player_ref: "player-a",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 3, assists: nil}
      },
      %{
        ref: "performance-b2",
        match_ref: "match-b",
        player_ref: "player-b",
        team_ref: "team-a",
        position_ref: "GK",
        minutes_played: 90,
        counts: %{goals: 4, assists: nil}
      }
    ]

    first_candidate = performances_candidate(catalog, request, matches, performances)

    assert {:ok, first} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(first_candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    first_intent = Repo.get!(CalculationIntent, first.calculation_intent_id)

    second_match = %{hd(matches) | ref: "match-a-late", kickoff_at: ~U[2026-01-02 12:00:00Z]}

    second_performance = %{
      hd(performances)
      | ref: "performance-a1-late",
        match_ref: "match-a-late",
        counts: %{goals: 5, assists: nil}
    }

    second_candidate =
      performances_candidate(
        catalog,
        request,
        matches ++ [second_match],
        performances ++ [second_performance]
      )

    assert {:ok, second} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(second_candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    second_intent = Repo.get!(CalculationIntent, second.calculation_intent_id)

    # Both accepted intents are linked before either dispatch job runs. The
    # first snapshot remains a complete four-scope membership; the second
    # captures the late fact only in its affected player/week scope.
    assert {:ok, _} =
             CalculationRequests.accept(
               first_intent.id,
               first_intent.accepted_check_id,
               first_intent.changed_performance_ids
             )

    assert {:ok, _} =
             CalculationRequests.accept(
               second_intent.id,
               second_intent.accepted_check_id,
               second_intent.changed_performance_ids
             )

    assert Repo.query!(
             """
             SELECT count(*), count(DISTINCT player_id), count(DISTINCT week_start)
             FROM quote_import_scope_snapshots WHERE intent_id=$1
             """,
             [Ecto.UUID.dump!(first_intent.id)]
           ).rows == [[4, 2, 2]]

    assert Repo.query!(
             """
             SELECT count(*), max(cardinality(membership))
             FROM quote_import_scope_snapshots WHERE intent_id=$1
             """,
             [Ecto.UUID.dump!(second_intent.id)]
           ).rows == [[1, 2]]

    # One durable pending request per pinned scope, linked before any worker runs.
    assert Repo.query!(
             """
             SELECT count(*), count(*) FILTER (WHERE state = 'pending')
             FROM quote_calculation_requests WHERE intent_id IN ($1, $2)
             """,
             [
               Ecto.UUID.dump!(first_intent.id),
               Ecto.UUID.dump!(second_intent.id)
             ]
           ).rows == [[5, 5]]

    old_closing = Application.get_env(:football_market, FootballMarket.Quotes.Closing, [])

    Application.put_env(:football_market, FootballMarket.Quotes.Closing,
      default_recurrence: "* * * * *",
      recurrences: %{}
    )

    on_exit(fn ->
      Application.put_env(:football_market, FootballMarket.Quotes.Closing, old_closing)
    end)

    close_time = DateTime.add(DateTime.utc_now(), 120, :second)

    assert {:ok, %{imports: 5, ttl: 0, enqueued: 5}} =
             FootballMarket.Quotes.Closing.admit_due(close_time)

    assert {:ok, %{imports: 0, ttl: 0, enqueued: 5}} =
             FootballMarket.Quotes.Closing.admit_due(close_time)

    assert Repo.query!(
             "SELECT count(*), count(DISTINCT admitted_at) FROM quote_calculation_requests WHERE intent_id IN ($1, $2) AND admitted_at IS NOT NULL",
             [Ecto.UUID.dump!(first_intent.id), Ecto.UUID.dump!(second_intent.id)]
           ).rows == [[5, 1]]
  end

  test "legacy intent without original snapshots records unreproducible instead of today's membership" do
    scope = Fixtures.scope(2087)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))

    assert {:ok, accepted} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)

    # Reproduce a pre-feature acceptance in the transaction-owned test schema:
    # the accepted facts/intent exist, but no historical membership was saved.
    original_scope =
      Repo.query!(
        "SELECT week_start, week_end FROM quote_import_scope_snapshots WHERE intent_id=$1",
        [Ecto.UUID.dump!(intent.id)]
      ).rows

    Repo.query!(
      "ALTER TABLE quote_import_snapshot_facts DISABLE TRIGGER quote_import_snapshot_facts_immutable"
    )

    Repo.query!(
      "ALTER TABLE quote_import_scope_snapshots DISABLE TRIGGER quote_import_scope_snapshots_immutable"
    )

    try do
      Repo.query!(
        "DELETE FROM quote_import_snapshot_facts WHERE snapshot_id IN (SELECT id FROM quote_import_scope_snapshots WHERE intent_id=$1)",
        [Ecto.UUID.dump!(intent.id)]
      )

      Repo.query!("DELETE FROM quote_import_scope_snapshots WHERE intent_id=$1", [
        Ecto.UUID.dump!(intent.id)
      ])
    after
      Repo.query!(
        "ALTER TABLE quote_import_snapshot_facts ENABLE TRIGGER quote_import_snapshot_facts_immutable"
      )

      Repo.query!(
        "ALTER TABLE quote_import_scope_snapshots ENABLE TRIGGER quote_import_scope_snapshots_immutable"
      )
    end

    before = FootballMarket.QuotesCase.protected_snapshot()
    # Ecto stores UTC match instants as timestamp without time zone. Scope
    # recovery must ignore a connection's display time zone.
    Repo.query!("SET LOCAL TIME ZONE 'Pacific/Auckland'")

    for _ <- 1..2 do
      assert {:ok, _} =
               CalculationRequests.accept(
                 intent.id,
                 intent.accepted_check_id,
                 intent.changed_performance_ids
               )
    end

    assert Repo.query!(
             "SELECT state, reason, snapshot_id, configuration_version_id, mapping_id FROM quote_calculation_requests WHERE intent_id=$1",
             [Ecto.UUID.dump!(intent.id)]
           ).rows == [["unreproducible", "original_unavailable", nil, nil, nil]]

    assert Repo.query!(
             "SELECT week_start, week_end FROM quote_calculation_requests WHERE intent_id=$1",
             [Ecto.UUID.dump!(intent.id)]
           ).rows == original_scope

    assert Repo.query!("SELECT count(*) FROM quote_import_scope_snapshots WHERE intent_id=$1", [
             Ecto.UUID.dump!(intent.id)
           ]).rows == [[0]]

    assert FootballMarket.QuotesCase.protected_snapshot() == before
  end

  defp performances_candidate(catalog, request, matches, performances) do
    %{
      operation: :performances,
      scope: request.scope,
      facts: Map.merge(catalog.facts, %{matches: matches, performances: performances}),
      bindings:
        catalog.bindings ++ Enum.map(matches, &%{kind: :match, ref: &1.ref, source_id: &1.ref}),
      completeness: %{
        version: 1,
        scope: request.scope,
        full_scope: true,
        terminal_witness: "test-terminal-v1",
        eligible_match_identities: Enum.map(matches, & &1.ref),
        detail_coverage: Enum.map(matches, & &1.ref),
        assessment_revision: "test-assessment-v1",
        assessment_reference: "test-fixture-source-v1",
        complete_empty: false
      }
    }
  end
end
