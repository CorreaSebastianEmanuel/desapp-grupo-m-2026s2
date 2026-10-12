defmodule FootballMarket.Catalog.Ingestion.RetentionTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Ingestion.Observation
  alias FootballMarket.Catalog.Ingestion.SourceBinding

  setup do
    positions!()
    :ok
  end

  test "stale and equal-time differing facts preserve acceptance and catalog" do
    assert {:ok, first} = Ingestion.import_catalog(request(), options())
    before = snapshot()

    assert {:error, stale} =
             Ingestion.import_catalog(
               request(),
               options(candidate(), ~U[2026-10-05 12:00:00.000000Z])
             )

    assert stale.status == :stale_observation
    c = candidate()
    c = %{c | fixture_id: "different-fixture"}
    assert {:error, equal} = Ingestion.import_catalog(request(), options(c))
    assert equal.status == :reconciliation_conflict
    assert snapshot() == before
    assert Repo.aggregate(Observation, :count) == 1
    assert first.revision == 1
  end

  test "complete empty observation retains omitted players teams and source bindings" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    before = snapshot()
    c = candidate()

    empty = %{
      c
      | facts: %{c.facts | teams: [], players: []},
        bindings: Enum.filter(c.bindings, &(&1.kind in [:league, :season]))
    }

    assert {:ok, o} =
             Ingestion.import_catalog(request(), options(empty, ~U[2026-10-07 12:00:00.000000Z]))

    assert o.status == :accepted_unchanged
    assert o.counts["team"] == %{"created" => 0, "updated" => 0, "unchanged" => 0}
    assert snapshot() == before
    assert Repo.aggregate(SourceBinding, :count) == 5
    assert Repo.aggregate(Observation, :count) == 2
  end

  test "future accepted clock safely blocks older cross-provider observations without correction" do
    assert {:ok, _} =
             Ingestion.import_catalog(
               request(),
               options(candidate(), ~U[2030-10-06 12:00:00.000000Z])
             )

    before = {snapshot(), acceptance_snapshot()}

    replacement =
      options(candidate(), ~U[2026-10-07 12:00:00.000000Z])
      |> Keyword.put(:provider, {FootballMarket.IngestionReplacementAdapter, candidate()})

    assert {:error, o} = Ingestion.import_catalog(request(), replacement)
    assert o.status == :stale_observation
    assert {snapshot(), acceptance_snapshot()} == before
  end
end
