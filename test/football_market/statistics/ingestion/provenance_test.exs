defmodule FootballMarket.Statistics.Ingestion.ProvenanceTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  import Ecto.Query
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion.{FactProvenance, FactObservation}
  alias FootballMarket.Statistics.Ingestion.{Check, ScopeCheck, CalculationIntent}
  alias FootballMarket.Statistics.{Match, Performance}
  alias FootballMarket.Catalog.Season
  alias FootballMarket.Synchronization.DeliveryReceipt
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "first accepted fact provenance is provider-qualified and later checks append observations" do
    scope = Fixtures.scope(2130)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    first_context = Case.delivery_context!(scope)

    assert {:ok, first} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: first_context]
             )

    first_provenance =
      Repo.one!(
        from p in FactProvenance,
          where: p.run_id == ^first.run_id and not is_nil(p.performance_id)
      )

    assert first_provenance.provider == "synthetic-a"
    assert first_provenance.source_identity["kind"] == "performance"
    assert first_provenance.source_identity["player_source_id"] == "player-A"
    assert first_provenance.run_id == first.run_id
    first_material = first_provenance.source_material

    second_context = Case.delivery_context!(scope)

    assert {:ok, second} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: second_context]
             )

    assert second.status == :replay
    assert Repo.get!(FactProvenance, first_provenance.id).source_material == first_material

    assert Repo.aggregate(
             from(o in FactObservation, where: o.check_id in [^first.check_id, ^second.check_id]),
             :count
           ) == 4
  end

  test "unadmitted fixture references fail safely without retaining arbitrary diagnostics" do
    scope = Fixtures.scope(2131)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope), fixture_id: "../../secrets")
    context = Case.delivery_context!(scope)

    run_id =
      Repo.get!(FootballMarket.Synchronization.DeliveryReceipt, context.receipt_id).run_id

    assert {:error, outcome} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    assert outcome.status == :invalid_incomplete
    refute Map.has_key?(outcome, :raw_payload)
    season_id = Repo.one!(from(s in Season, where: s.start_year == ^scope.start_year)).id
    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id == ^run_id), :count) == 0
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 0
    assert Repo.aggregate(from(s in ScopeCheck, where: s.season_id == ^season_id), :count) == 0

    assert Repo.aggregate(
             from(i in CalculationIntent,
               where:
                 i.accepted_check_id in subquery(
                   from c in Check, where: c.run_id == ^run_id, select: c.id
                 )
             ),
             :count
           ) == 0

    assert Repo.aggregate(from(m in Match, where: m.season_id == ^season_id), :count) == 0
    assert Repo.aggregate(from(p in Performance, where: p.season_id == ^season_id), :count) == 0
    assert Repo.get!(DeliveryReceipt, context.receipt_id).state == "prepared"
  end
end
