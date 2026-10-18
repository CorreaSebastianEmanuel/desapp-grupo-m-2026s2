defmodule FootballMarket.Statistics.Ingestion.CompletenessTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion
  alias FootballMarket.Statistics.Ingestion.{Check, ScopeCheck}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
  alias FootballMarket.Catalog.Season

  test "unproven completeness fails before facts or last successful check can advance" do
    scope = Fixtures.scope(2070)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    candidate = put_in(Case.candidate(request), [:completeness, :full_scope], false)
    context = Case.delivery_context!(scope)

    run_id =
      Repo.get!(FootballMarket.Synchronization.DeliveryReceipt, context.receipt_id).run_id

    season_id = Repo.one!(from(s in Season, where: s.start_year == ^scope.start_year)).id

    assert {:error, _} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    assert Repo.aggregate(from(m in Statistics.Match, where: m.season_id == ^season_id), :count) ==
             0

    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 0
    assert Repo.aggregate(from(s in ScopeCheck, where: s.season_id == ^season_id), :count) == 0
  end

  test "a complete empty result requires an explicit empty witness" do
    scope = Fixtures.scope(2071)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    candidate = Case.candidate(request, matches: [], performances: [])
    candidate = put_in(candidate, [:completeness, :complete_empty], false)
    context = Case.delivery_context!(scope)

    run_id =
      Repo.get!(FootballMarket.Synchronization.DeliveryReceipt, context.receipt_id).run_id

    assert {:error, _} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 0
  end

  test "complete match identity and detail witnesses are order independent" do
    scope = Fixtures.scope(2072)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    base = Case.candidate(request)
    first_match = hd(base.facts.matches)

    second_match = %{
      first_match
      | ref: "match-2",
        kickoff_at: DateTime.add(first_match.kickoff_at, 1, :day)
    }

    first_performance = hd(base.facts.performances)

    candidate =
      Case.candidate(request,
        matches: [first_match, second_match],
        performances: [
          first_performance,
          %{first_performance | ref: "performance-2", match_ref: "match-2"}
        ]
      )

    candidate = put_in(candidate, [:completeness, :detail_coverage], ["match-2", "match-1"])

    assert {:ok, outcome} =
             Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++
                 [delivery_context: Case.delivery_context!(scope)]
             )

    assert outcome.status == :accepted_changes
    season_id = Repo.one!(from(s in Season, where: s.start_year == ^scope.start_year)).id

    assert Repo.aggregate(from(m in Statistics.Match, where: m.season_id == ^season_id), :count) ==
             2

    assert Repo.aggregate(
             from(p in Statistics.Performance, where: p.season_id == ^season_id),
             :count
           ) == 2
  end

  test "missing terminal, eligible identity or detail witness never advances acceptance" do
    scope = Fixtures.scope(2073)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    base = Case.candidate(request)

    candidates = [
      put_in(base, [:completeness, :terminal_witness], " "),
      put_in(base, [:completeness, :eligible_match_identities], []),
      put_in(base, [:completeness, :detail_coverage], [])
    ]

    for candidate <- candidates do
      context = Case.delivery_context!(scope)

      run_id =
        Repo.get!(FootballMarket.Synchronization.DeliveryReceipt, context.receipt_id).run_id

      assert {:error, _} =
               Ingestion.import_scope(
                 scope,
                 Case.provider_options(candidate) ++ [delivery_context: context]
               )

      assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 0
    end
  end
end
