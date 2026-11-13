defmodule FootballMarket.Statistics.Ingestion.EnrichmentTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, Statistics, Quotes, Valuation}
  alias FootballMarket.Statistics.{Enrichment, Performance}
  alias FootballMarket.Statistics.Ingestion.{CalculationIntent, FactProvenance}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "additive evidence is immutable idempotent and preserves original and enriched calculation replay" do
    FootballMarket.ValuationConfigurationCase.private_schema()
    scope = Fixtures.scope(2191)
    Case.seed_catalog!(scope)
    base = Case.candidate(Fixtures.request(scope))
    [fact] = base.facts.performances
    base = put_in(base, [:facts, :performances], [%{fact | counts: %{goals: 1, assists: nil}}])
    assert {:ok, first} = import_candidate(scope, base)
    original = Repo.one!(Performance)
    provenance = Repo.all(FactProvenance)
    match = Repo.get!(Statistics.Match, original.match_id)
    original_fact = Valuation.StatisticsReader.snapshot(original, match)

    subject = %{
      player_id: original.player_id,
      season_id: original.season_id,
      week_start: "2025-12-29T00:00:00Z",
      week_end: "2026-01-05T00:00:00Z"
    }

    {:ok, configuration} =
      Valuation.Configurations.create(%{
        strategy_id: "balanced",
        formula_version: "1",
        config: %{weights: %{goals: 2, assists: 3}},
        references: %{goals: 2, assists: 2},
        position_mapping: [{original.position_id, :goalkeeper}]
      })

    {:ok, mapping} = Quotes.save_mapping("enrichment", "1", Decimal.new("1"))
    assert {:ok, before} = Quotes.request(subject, {:version, configuration.id}, mapping.id)
    assert before.calculation.reason == "insufficient_data"
    quotes_before = Repo.all(FootballMarket.Market.Quote)

    enriched =
      put_in(base, [:facts, :performances], [
        %{fact | counts: %{goals: 1, assists: 1, shots_on_target: 0}}
      ])

    assert {:ok, accepted} = import_candidate(scope, enriched)
    assert accepted.status == :accepted_changes
    refute accepted.calculation_intent_id == first.calculation_intent_id
    assert Repo.get!(Performance, original.id) == original
    assert Repo.all(FactProvenance) == provenance
    assert Repo.all(FootballMarket.Market.Quote) == quotes_before
    assert [%Enrichment{check_id: check_id, revision: 1}] = Repo.all(Enrichment)
    assert check_id == accepted.check_id
    intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)
    assert intent.changed_performance_ids == [original.id]
    assert {:ok, [[_, _, _, _, _, _, [material], _]]} = Quotes.Membership.snapshots(intent.id)
    assert material["assists"] == 1
    assert material["shots_on_target"] == 0
    assert {:ok, [current]} = Statistics.list_player_history(original.player_id)
    assert current.assists == 1
    assert current.shots_on_target == 0
    assert {:ok, [^original_fact]} = Valuation.StatisticsReader.originals([original_fact])
    current_fact = Valuation.StatisticsReader.snapshot(current, match)
    assert {:ok, [^current_fact]} = Valuation.StatisticsReader.originals([current_fact])
    forged = put_in(current_fact.metrics.assists, 9)

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.StatisticsReader.originals([forged])

    omitted = put_in(current_fact.metrics.shots_on_target, nil)

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.StatisticsReader.originals([omitted])

    assert {:ok, after_enrichment} =
             Quotes.request(subject, {:version, configuration.id}, mapping.id)

    assert after_enrichment.calculation.status == "successful"
    refute after_enrichment.calculation.id == before.calculation.id
    assert Decimal.equal?(after_enrichment.calculation.unit_price, "2.50")
    assert {:ok, replay} = Quotes.replay(before.calculation.id)
    assert replay.calculation == before.calculation
    assert {:ok, replay} = Quotes.replay(after_enrichment.calculation.id)

    assert Map.delete(Map.from_struct(replay.calculation), :__meta__) ==
             Map.delete(Map.from_struct(after_enrichment.calculation), :__meta__)

    assert {:ok, repeated} = import_candidate(scope, enriched)
    assert repeated.status in [:replay, :accepted_unchanged]
    assert Repo.aggregate(Enrichment, :count) == 1
    assert {:ok, omitted_import} = import_candidate(scope, base)
    assert omitted_import.status in [:replay, :accepted_unchanged]
    assert {:ok, [current]} = Statistics.list_player_history(original.player_id)
    assert current.assists == 1

    conflicting =
      put_in(enriched, [:facts, :performances], [%{fact | counts: %{goals: 2, assists: 1}}])

    assert {:error, %{status: :immutable_conflict}} = import_candidate(scope, conflicting)
    assert Repo.aggregate(Enrichment, :count) == 1
    assert Repo.get!(Performance, original.id) == original

    second_enrichment =
      put_in(enriched, [:facts, :performances], [
        %{fact | counts: %{goals: 1, assists: 1, shots_on_target: 0, tackles: 2}}
      ])

    assert {:ok, second} = import_candidate(scope, second_enrichment)
    assert second.status == :accepted_changes
    assert Repo.aggregate(Enrichment, :count) == 2
    assert {:ok, [^current_fact]} = Valuation.StatisticsReader.originals([current_fact])
    assert {:ok, replay} = Quotes.replay(after_enrichment.calculation.id)
    assert replay.calculation.id == after_enrichment.calculation.id
    assert {:ok, [latest]} = Statistics.list_player_history(original.player_id)
    assert latest.tackles == 2
    retained = Repo.get_by!(Enrichment, performance_id: original.id, revision: 2)

    for values <- [
          Map.put(retained.values, "goals", 2),
          Map.put(retained.values, "assists", nil),
          Map.put(retained.values, "saves", -1),
          Map.put(retained.values, "saves", "0"),
          Map.put(retained.values, "saves", 0.5),
          retained.values
        ] do
      assert_raise Postgrex.Error, fn ->
        Repo.insert!(%Enrichment{
          performance_id: original.id,
          check_id: accepted.check_id,
          revision: 3,
          values: values
        })
      end
    end

    assert_raise Postgrex.Error, fn -> Repo.update_all(Enrichment, set: [values: %{}]) end
  end

  defp import_candidate(scope, candidate),
    do:
      Statistics.Ingestion.import_scope(
        scope,
        Case.provider_options(candidate) ++ [delivery_context: Case.delivery_context!(scope)]
      )
end
