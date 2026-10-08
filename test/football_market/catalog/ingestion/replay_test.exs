defmodule FootballMarket.Catalog.Ingestion.ReplayTest do
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

  test "ten replays preserve acceptance, rows, timestamps and binding evidence" do
    assert {:ok, first} = Ingestion.import_catalog(request(), options())
    before = snapshot()

    for _ <- 1..10 do
      assert {:ok, replay} = Ingestion.import_catalog(request(), options())
      assert replay.status == :replay
      assert replay.acceptance_reference == first.acceptance_reference
      assert replay.counts == first.counts
      assert replay.new_bindings_count == 5
      assert replay.applied_new_bindings_count == 0

      assert Enum.all?(replay.applied_counts, fn {_, values} ->
               Enum.all?(values, fn {_, n} -> n == 0 end)
             end)
    end

    assert snapshot() == before
    assert Repo.aggregate(Observation, :count) == 1
    assert Repo.aggregate(SourceBinding, :count) == 5
  end

  test "later identical facts add observation only and old replay cannot restore a transfer" do
    assert {:ok, first} = Ingestion.import_catalog(request(), options())
    before = snapshot()

    assert {:ok, same} =
             Ingestion.import_catalog(
               request(),
               options(candidate(), ~U[2026-10-07 12:00:00.000000Z])
             )

    assert same.status == :accepted_unchanged
    assert same.counts["player"] == %{"created" => 0, "updated" => 0, "unchanged" => 1}
    assert snapshot() == before
    c = candidate()
    transfer = %{c | facts: %{c.facts | players: [%{hd(c.facts.players) | team_ref: "team-b"}]}}

    assert {:ok, _} =
             Ingestion.import_catalog(
               request(),
               options(transfer, ~U[2026-10-08 12:00:00.000000Z])
             )

    moved = snapshot()
    assert {:ok, old} = Ingestion.import_catalog(request(), options())
    assert old.acceptance_reference == first.acceptance_reference
    assert snapshot() == moved
  end

  test "result-local reference bijections replay and lost replies are recoverable" do
    assert {:ok, first} = Ingestion.import_catalog(request(), options())
    original = {snapshot(), acceptance_snapshot()}
    assert {:ok, same} = Ingestion.import_catalog(request(), options(rereference(candidate())))
    assert same.status == :replay
    assert same.acceptance_reference == first.acceptance_reference
    assert {snapshot(), acceptance_snapshot()} == original
    # Discard a committed result, as if its reply was lost, then retry the delivery.
    _ = Ingestion.import_catalog(request(), options(candidate(), ~U[2026-10-07 12:00:00.000000Z]))

    assert {:ok, recovered} =
             Ingestion.import_catalog(
               request(),
               options(candidate(), ~U[2026-10-07 12:00:00.000000Z])
             )

    assert recovered.status == :replay
    assert Repo.aggregate(Observation, :count) == 2
  end

  test "digest lookup still verifies full equality and accepted evidence is immutable" do
    assert {:ok, first} = Ingestion.import_catalog(request(), options())
    o = Repo.get!(Observation, first.acceptance_reference)
    refute Observation.changeset(o, %{counts: o.counts}).valid?
    c = %{candidate() | fixture_id: "collision-probe"}

    assert {:ok, result} =
             FootballMarket.Providers.catalog(
               request(),
               options(c) ++ [positions: %{"GK" => "Goalkeeper"}]
             )

    encoded = FootballMarket.Catalog.Ingestion.Canonical.encode(result)
    # Simulate a digest collision without using the production equality decision as oracle.
    Repo.update_all(from(ob in Observation, where: ob.id == ^o.id),
      set: [delivery_digest: encoded.digest]
    )

    before = {snapshot(), acceptance_snapshot()}
    assert {:error, conflict} = Ingestion.import_catalog(request(), options(c))
    assert conflict.status == :reconciliation_conflict
    assert conflict.reason == :delivery_digest_collision
    assert {snapshot(), acceptance_snapshot()} == before
  end
end
