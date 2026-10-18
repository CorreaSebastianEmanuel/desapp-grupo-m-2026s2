defmodule FootballMarket.Statistics.Ingestion.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Performance
  alias FootballMarket.Statistics.Ingestion

  alias FootballMarket.Statistics.Ingestion.{
    Check,
    FactProvenance,
    FactObservation,
    MatchBinding,
    ScopeCheck
  }

  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "later retrieval of identical immutable material appends observations without replacing first provenance" do
    scope = Fixtures.scope(2150)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    first_context = Case.delivery_context!(scope)

    assert {:ok, first} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: first_context]
             )

    initial_provenance = Repo.all(from p in FactProvenance, where: p.run_id == ^first.run_id)

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    later_context = Case.delivery_context!(scope)

    later_runtime =
      {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-17 12:00:00.000000Z]}}

    assert {:ok, later} =
             Ingestion.import_scope(
               scope,
               Keyword.put(
                 Case.provider_options(candidate),
                 :runtime,
                 later_runtime
               ) ++ [delivery_context: later_context]
             )

    assert later.status == :accepted_unchanged
    assert first.check_id != later.check_id
    scope_id = Repo.one!(from c in Check, where: c.id == ^first.check_id, select: c.scope_id)
    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 2

    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id == ^first.run_id), :count) ==
             2

    assert Repo.aggregate(
             from(o in FactObservation, where: o.check_id in [^first.check_id, ^later.check_id]),
             :count
           ) == 4

    assert Repo.all(from p in FactProvenance, where: p.run_id == ^first.run_id) ==
             initial_provenance

    assert Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count) == 1
    performance = Repo.one!(from(p in Performance, where: p.season_id == ^season_id))
    assert performance.goals == 0
  end

  test "a retargeted match mapping cannot bypass binding conflicts on replay or unchanged import" do
    scope = Fixtures.scope(2151)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))

    assert {:ok, accepted} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    binding = Repo.get_by!(MatchBinding, source_id: "match-1", provider: "synthetic-a")
    original_match = Repo.get!(FootballMarket.Statistics.Match, binding.match_id)

    assert {:ok, alternate_match} =
             FootballMarket.Statistics.record_match(%{
               match_identity: "legacy-alternate-match",
               kickoff_at: original_match.kickoff_at,
               season_id: original_match.season_id,
               home_team_id: original_match.home_team_id,
               away_team_id: original_match.away_team_id
             })

    mapping =
      FootballMarket.IngestionFixtures.mapping(
        :match,
        "match-1",
        alternate_match.id,
        "synthetic-a",
        scope.league_code,
        scope.start_year
      )

    scope_check = Repo.get_by!(ScopeCheck, season_id: original_match.season_id)

    for instant <- [~U[2026-10-16 12:00:00Z], ~U[2026-10-17 12:00:00Z]] do
      provider_options =
        Case.provider_options(candidate)
        |> Keyword.put(:runtime, {FootballMarket.IngestionFixtureRuntime, %{instant: instant}})

      assert {:error, %{status: :immutable_conflict}} =
               Ingestion.import_scope(
                 scope,
                 provider_options ++
                   [
                     mappings: [mapping],
                     delivery_context: Case.delivery_context!(scope)
                   ]
               )

      assert Repo.get!(MatchBinding, binding.id).match_id == original_match.id
      assert Repo.get!(ScopeCheck, scope_check.id).last_accepted_check_id == accepted.check_id
      assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_check.id), :count) == 1
    end
  end
end
