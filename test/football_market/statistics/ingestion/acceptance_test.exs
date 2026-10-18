defmodule FootballMarket.Statistics.Ingestion.AcceptanceTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion

  alias FootballMarket.Statistics.Ingestion.{
    Check,
    FactProvenance,
    CalculationIntent,
    ScopeCheck,
    FixtureArtifact
  }

  alias FootballMarket.Statistics.Performance
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "complete source result atomically accepts facts, lineage, check and calculation intent" do
    scope = Fixtures.scope()
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    candidate = Case.candidate(request)
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    assert outcome.status == :accepted_changes

    assert {:ok, match} =
             Statistics.get_match(season_id, "provider:v1:synthetic-a:match-1")

    stored_performance = Repo.one!(from p in Performance, where: p.match_id == ^match.id)
    assert {:ok, performance} = Statistics.get_performance(stored_performance.player_id, match.id)
    assert performance.goals == 0
    assert performance.assists == nil
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^outcome.run_id), :count) == 1

    assert Repo.aggregate(
             from(p in FactProvenance, where: p.run_id == ^outcome.run_id),
             :count
           ) == 2

    assert Repo.aggregate(
             from(i in CalculationIntent, where: i.accepted_check_id == ^outcome.check_id),
             :count
           ) == 1

    assert {:ok, check} = Ingestion.get_check(outcome.check_id)
    assert check.outcome == "accepted_changes"
    assert %ScopeCheck{last_accepted_check_id: check_id} = Repo.get!(ScopeCheck, check.scope_id)
    assert check_id == check.id
  end

  test "complete multi-match source accepts exact facts and check totals" do
    scope = Fixtures.scope(2026)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    candidate = Case.candidate(request)
    first_match = hd(candidate.facts.matches)

    second_match = %{
      first_match
      | ref: "match-2",
        kickoff_at: ~U[2026-02-01 12:00:00.000000Z]
    }

    first_performance = hd(candidate.facts.performances)

    second_performance = %{
      first_performance
      | ref: "performance-2",
        match_ref: "match-2",
        counts: %{goals: 2, assists: 1}
    }

    candidate = %{
      candidate
      | facts: %{
          candidate.facts
          | matches: [first_match, second_match],
            performances: [first_performance, second_performance]
        },
        completeness: %{
          candidate.completeness
          | eligible_match_identities: ["match-1", "match-2"],
            detail_coverage: ["match-1", "match-2"]
        },
        bindings:
          candidate.bindings ++
            [%{kind: :match, ref: "match-2", source_id: "match-2"}]
    }

    context = Case.delivery_context!(scope)

    assert {:ok, %{status: :accepted_changes} = outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    check = Repo.get!(Check, outcome.check_id)
    assert check.changed_matches == 2
    assert check.changed_performances == 2

    season =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year)

    assert Repo.aggregate(
             from(m in FootballMarket.Statistics.Match, where: m.season_id == ^season.id),
             :count
           ) == 2

    assert Repo.aggregate(from(p in Performance, where: p.season_id == ^season.id), :count) == 2

    assert Enum.sort(
             Repo.all(
               from p in Performance,
                 where: p.season_id == ^season.id,
                 select: {p.goals, p.assists}
             )
           ) ==
             [{0, nil}, {2, 1}]
  end

  test "trusted mapping adopts an exact legacy match with first source provenance" do
    scope = Fixtures.scope(2038)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    fact = hd(candidate.facts.matches)

    season =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year)

    home = Repo.get_by!(FootballMarket.Catalog.Team, season_id: season.id, code: "ALP")
    away = Repo.get_by!(FootballMarket.Catalog.Team, season_id: season.id, code: "BET")

    assert {:ok, legacy_match} =
             Statistics.record_match(%{
               match_identity: "legacy-unbound-match",
               kickoff_at: fact.kickoff_at,
               season_id: season.id,
               home_team_id: home.id,
               away_team_id: away.id
             })

    mapping =
      FootballMarket.IngestionFixtures.mapping(
        :match,
        fact.ref,
        legacy_match.id,
        "synthetic-a",
        scope.league_code,
        scope.start_year
      )

    assert {:ok, outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [mappings: [mapping], delivery_context: Case.delivery_context!(scope)]
             )

    assert outcome.status == :accepted_changes

    assert Repo.get!(FootballMarket.Statistics.Match, legacy_match.id).match_identity ==
             "legacy-unbound-match"

    provenance = Repo.one!(from p in FactProvenance, where: p.match_id == ^legacy_match.id)
    assert provenance.accepted_check_id == outcome.check_id
    assert provenance.source_identity["source_id"] == fact.ref
    assert provenance.run_id == Repo.get!(Check, outcome.check_id).run_id
  end

  test "an eligible match without provider performance detail does not synthesize a row" do
    scope = Fixtures.scope(2072)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope), performances: [])
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    assert outcome.status == :accepted_changes
    assert is_nil(outcome.calculation_intent_id)

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    assert Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count) == 0
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^outcome.run_id), :count) == 1
  end

  test "source replay is idempotent and changed immutable metric content rolls back" do
    scope = Fixtures.scope(2030)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    candidate = Case.candidate(request)
    first_context = Case.delivery_context!(scope)

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    assert {:ok, accepted} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: first_context]
             )

    before =
      {Repo.aggregate(
         from(m in FootballMarket.Statistics.Match, where: m.season_id == ^season_id),
         :count
       ), Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count)}

    replay_context = Case.delivery_context!(scope)

    assert {:ok, replay} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: replay_context]
             )

    assert replay.status == :replay
    assert replay.check_id != accepted.check_id

    scope_id = Repo.get!(Check, accepted.check_id).scope_id

    assert before ==
             {Repo.aggregate(
                from(m in FootballMarket.Statistics.Match, where: m.season_id == ^season_id),
                :count
              ), Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count)}

    conflict = put_in(candidate, [:facts, :performances, Access.at(0), :counts, :goals], 9)
    conflict_context = Case.delivery_context!(scope)

    assert {:error, %{status: :immutable_conflict}} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(conflict) ++ [delivery_context: conflict_context]
             )

    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 2

    catalog_season =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year)

    catalog_team =
      Repo.one!(
        from t in FootballMarket.Catalog.Team,
          where: t.season_id == ^catalog_season.id and t.code == "ALP"
      )

    catalog_position = Repo.get_by!(FootballMarket.Catalog.Position, code: "GK")

    {:ok, alternate_player} =
      FootballMarket.Catalog.create_player(%{
        team_id: catalog_team.id,
        position_id: catalog_position.id,
        catalog_identity: "alternate-player",
        display_name: "Alternate Alex"
      })

    retargeted = Case.delivery_context!(scope)

    assert {:error, %{status: :immutable_conflict}} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [
                   mappings: [
                     FootballMarket.IngestionFixtures.mapping(
                       :player,
                       "player-A",
                       alternate_player.id,
                       "synthetic-a",
                       "PL",
                       scope.start_year
                     )
                   ],
                   delivery_context: retargeted
                 ]
             )

    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 2

    {:ok, _forward} = FootballMarket.Catalog.create_position(%{code: "FW", name: "Forward"})

    changed_position = %{
      candidate
      | facts: %{
          candidate.facts
          | positions: candidate.facts.positions ++ [%{ref: "FW", code: "FW", name: "Forward"}],
            performances:
              List.update_at(candidate.facts.performances, 0, &%{&1 | position_ref: "FW"})
        }
    }

    position_context = Case.delivery_context!(scope)

    assert {:error, %{status: :immutable_conflict}} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(changed_position) ++
                 [delivery_context: position_context]
             )

    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 2

    changed_match =
      put_in(candidate, [:facts, :matches, Access.at(0), :kickoff_at], ~U[2026-01-02 12:00:00Z])

    changed_match_context = Case.delivery_context!(scope)

    assert {:error, %{status: :immutable_conflict}} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(changed_match) ++
                 [delivery_context: changed_match_context]
             )

    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 2

    assert before ==
             {Repo.aggregate(
                from(m in FootballMarket.Statistics.Match, where: m.season_id == ^season_id),
                :count
              ), Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count)}
  end

  test "changed participation is an immutable conflict and does not advance accepted state" do
    scope = Fixtures.scope(2037)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    starter = put_in(candidate, [:facts, :performances, Access.at(0), :participation], :starter)

    assert {:ok, accepted} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(starter) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    stored =
      Repo.one!(
        from p in Performance,
          join: s in FootballMarket.Catalog.Season,
          on: p.season_id == s.id,
          where: s.start_year == ^scope.start_year
      )

    assert stored.participation == "starter"
    accepted_check = Repo.get!(Check, accepted.check_id)

    original_provenance =
      Repo.one!(from p in FactProvenance, where: p.performance_id == ^stored.id)

    entrant =
      put_in(starter, [:facts, :performances, Access.at(0), :participation], :substitute_entered)

    assert {:error, %{status: :immutable_conflict}} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(entrant) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    assert Repo.get!(Performance, stored.id).participation == "starter"
    assert Repo.get!(Check, accepted.check_id) == accepted_check

    assert Repo.get_by!(ScopeCheck, id: accepted_check.scope_id).last_accepted_check_id ==
             accepted.check_id

    assert Repo.one!(from p in FactProvenance, where: p.performance_id == ^stored.id) ==
             original_provenance

    assert Repo.aggregate(
             from(c in Check, where: c.scope_id == ^accepted_check.scope_id),
             :count
           ) == 1
  end

  test "explicitly complete empty scope differs from missing completeness evidence" do
    scope = Fixtures.scope(2040)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    empty = Case.candidate(request, matches: [], performances: [])
    context = Case.delivery_context!(scope)

    assert {:ok, %{status: :accepted_empty} = outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(empty) ++ [delivery_context: context]
             )

    incomplete = %{Case.candidate(request) | completeness: nil}
    failed_context = Case.delivery_context!(scope)

    assert {:error, _} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(incomplete) ++ [delivery_context: failed_context]
             )

    scope_id = Repo.get!(Check, outcome.check_id).scope_id
    assert Repo.aggregate(from(c in Check, where: c.scope_id == ^scope_id), :count) == 1
  end

  test "sanitized fixture provenance records the admitted artifact fingerprint and non-live label" do
    scope = Fixtures.scope(2060)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope), fixture_id: "complete")
    context = Case.delivery_context!(scope)

    assert {:ok, outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    provenance =
      Repo.one!(
        from p in FactProvenance,
          where: p.run_id == ^outcome.run_id and not is_nil(p.fixture_artifact_id),
          limit: 1
      )

    assert {:ok, provenance} = Ingestion.get_fact_provenance(provenance.id)

    artifact = Repo.get!(FixtureArtifact, provenance.fixture_artifact_id)
    assert artifact.fixture_id == "complete"
    assert artifact.non_live
    assert artifact.origin == "Synthetic controlled provider fixture"
    assert artifact.synthetic_created_at == ~U[2026-10-16 00:00:00.000000Z]
    assert artifact.expected_case == "complete"
    assert artifact.artifact_path == "test/fixtures/statistics_ingestion/documents.exs"
    assert "complete-scope" in artifact.rule_ids
    assert artifact.sha256 =~ ~r/^[0-9a-f]{64}$/

    document_digest =
      artifact.artifact_path
      |> File.read!()
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    assert artifact.sha256 == document_digest

    check = Repo.get!(Check, outcome.check_id)

    content_digest =
      Jason.encode!(check.canonical_material)
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    assert check.canonical_digest == content_digest
    assert provenance.source_material == check.canonical_material
    assert check.canonical_material["facts"]["performances"] != []
    assert {:ok, _} = Ingestion.get_check(outcome.check_id)
  end
end
