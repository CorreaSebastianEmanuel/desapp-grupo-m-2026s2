defmodule FootballMarket.QA018AdversarialTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog.{Player, Team}
  alias FootballMarket.Catalog.Ingestion

  setup do
    positions!()
    :ok
  end

  test "equal instant with changed football facts or provider never publishes" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    c = candidate()
    changed = %{c | facts: %{c.facts | players: [%{hd(c.facts.players) | display_name: "Different"}]}}
    before = {snapshot(), acceptance_snapshot()}
    for opts <- [options(changed), Keyword.put(options(), :provider, {FootballMarket.IngestionReplacementAdapter, c})] do
      assert {:error, o} = Ingestion.import_catalog(request(), opts)
      assert o.status == :reconciliation_conflict
      assert o.reason == :equal_retrieval_different_delivery
      assert {snapshot(), acceptance_snapshot()} == before
    end
  end

  test "case-sensitive player IDs and same ID across entity kinds remain independent" do
    c = candidate()
    extra = %{hd(c.facts.players) | ref: "second-player"}
    input = %{c | facts: %{c.facts | players: c.facts.players ++ [extra]}, bindings: Enum.map(c.bindings, fn b -> if b.kind == :player, do: %{b | source_id: "team-A"}, else: b end) ++ [%{kind: :player, ref: "second-player", source_id: "TEAM-A"}]}
    assert {:ok, o} = Ingestion.import_catalog(request(), options(input))
    assert o.counts["player"]["created"] == 2
    assert Repo.aggregate(Player, :count) == 2
    assert Repo.aggregate(Team, :count) == 2
    rows = Repo.all(Player)
    assert length(Enum.uniq(Enum.map(rows, & &1.catalog_identity))) == 2
    refute Enum.any?(rows, &(&1.catalog_identity in ["team-A", "TEAM-A"]))
  end

  test "source-ID changes cannot collapse a bound team and explicit mappings cannot collapse players" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    c = candidate()
    renamed = %{c | bindings: Enum.map(c.bindings, fn b -> if b.kind == :team and b.ref == "team-a", do: %{b | source_id: "new-team-id"}, else: b end)}
    before = {snapshot(), acceptance_snapshot()}
    assert {:error, conflict} = Ingestion.import_catalog(request(), options(renamed, ~U[2026-10-07 12:00:00Z]))
    assert conflict.status == :reconciliation_conflict
    assert {snapshot(), acceptance_snapshot()} == before
    [player] = Repo.all(Player)
    other = %{hd(c.facts.players) | ref: "second"}
    doubled = %{c | facts: %{c.facts | players: c.facts.players ++ [other]}, bindings: c.bindings ++ [%{kind: :player, ref: "second", source_id: "other-id"}]}
    maps = [mapping(:player, "player-A", player.id, "synthetic-b"), mapping(:player, "other-id", player.id, "synthetic-b")]
    opts = options(doubled, ~U[2026-10-07 12:00:00Z]) |> Keyword.put(:provider, {FootballMarket.IngestionReplacementAdapter, doubled}) |> Keyword.put(:mappings, maps)
    assert {:error, conflict} = Ingestion.import_catalog(request(), opts)
    assert conflict.status == :reconciliation_conflict
    assert {snapshot(), acceptance_snapshot()} == before
  end

  test "all provider failures preserve an already accepted catalog and observation" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    before = {snapshot(), acceptance_snapshot()}
    for category <- FootballMarket.Providers.Error.categories() do
      assert {:error, failure} = Ingestion.import_catalog(request(), options({:error, %{category: category}}))
      assert failure.provider_error.category == category
      assert {snapshot(), acceptance_snapshot()} == before
    end
  end

  test "unknown league and conflicting canonical league and position names cannot publish" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    c = candidate()
    before = {snapshot(), acceptance_snapshot()}
    for input <- [
      %{c | facts: %{c.facts | league: %{c.facts.league | name: "Wrong league"}}},
      %{c | facts: %{c.facts | positions: [%{hd(c.facts.positions) | name: "Wrong position"}]}}
    ] do
      assert {:error, _} = Ingestion.import_catalog(request(), options(input, ~U[2026-10-07 12:00:00Z]))
      assert {snapshot(), acceptance_snapshot()} == before
    end
    assert {:error, _} = Ingestion.import_catalog(request("UNKNOWN"), options())
    assert {snapshot(), acceptance_snapshot()} == before
  end

  test "empty first import accepts scope only with zero team and player writes" do
    c = candidate()
    empty = %{c | facts: %{c.facts | teams: [], players: []}, bindings: Enum.filter(c.bindings, &(&1.kind in [:league, :season]))}
    assert {:ok, o} = Ingestion.import_catalog(request(), options(empty))
    assert o.status == :accepted_with_changes
    assert o.new_bindings_count == 2
    assert o.counts["player"] == %{"created" => 0, "updated" => 0, "unchanged" => 0}
    assert Repo.aggregate(Player, :count) == 0
    assert Repo.aggregate(Team, :count) == 0
  end
end
