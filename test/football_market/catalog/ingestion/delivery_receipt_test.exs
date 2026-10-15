defmodule FootballMarket.Catalog.Ingestion.DeliveryReceiptTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Ingestion.DeliveryReceipt
  alias FootballMarket.Synchronization.Run
  alias FootballMarket.IngestionFixtures, as: F

  setup do
    F.positions!()

    run =
      Repo.insert!(%Run{
        league_code: "PL",
        start_year: 2025,
        end_year: 2026,
        source_ref: "fixture",
        input: %{},
        input_digest: "test",
        policy: %{"attempt_limit" => 3},
        original_trigger: "manual",
        state: "queued",
        requested_at: DateTime.utc_now()
      })

    receipt =
      Repo.insert!(%DeliveryReceipt{
        run_id: run.id,
        fence: Ecto.UUID.generate(),
        league_code: "PL",
        start_year: 2025,
        end_year: 2026,
        state: "prepared"
      })

    %{receipt: receipt, context: %{receipt_id: receipt.id, fence: receipt.fence}}
  end

  test "acceptance and exact replay confirm a safe receipt atomically", %{
    receipt: receipt,
    context: context
  } do
    assert {:ok, accepted} =
             Ingestion.import_catalog(F.request(), F.options() ++ [delivery_context: context])

    confirmed = Repo.get!(DeliveryReceipt, receipt.id)
    assert confirmed.state == "confirmed"
    assert confirmed.outcome["acceptance_reference"] == accepted.acceptance_reference

    next =
      Repo.insert!(%DeliveryReceipt{
        run_id: receipt.run_id,
        fence: Ecto.UUID.generate(),
        league_code: "PL",
        start_year: 2025,
        end_year: 2026,
        state: "prepared"
      })

    assert {:ok, replay} =
             Ingestion.import_catalog(
               F.request(),
               F.options() ++ [delivery_context: %{receipt_id: next.id, fence: next.fence}]
             )

    assert replay.status == :replay
    assert Repo.get!(DeliveryReceipt, next.id).outcome["applied_new_bindings_count"] == 0
  end

  test "revoked fence rejects publication with no partial domain writes", %{
    receipt: receipt,
    context: context
  } do
    Repo.update!(Ecto.Changeset.change(receipt, state: "revoked"))
    before = F.snapshot()

    assert {:error, outcome} =
             Ingestion.import_catalog(F.request(), F.options() ++ [delivery_context: context])

    assert outcome.status == :reconciliation_conflict
    assert F.snapshot() == before
  end

  test "legacy import still works and publication rollback leaves receipt prepared", %{
    receipt: receipt,
    context: context
  } do
    F.publication_failpoint(:after_catalog)

    assert {:error, _} =
             Ingestion.import_catalog(F.request(), F.options() ++ [delivery_context: context])

    assert Repo.get!(DeliveryReceipt, receipt.id).state == "prepared"
    Process.delete(:catalog_ingestion_failpoint)
    assert {:ok, _} = Ingestion.import_catalog(F.request(), F.options())
  end

  test "scope mismatch and malformed contexts reject without publishing", %{
    receipt: receipt,
    context: context
  } do
    Repo.update!(Ecto.Changeset.change(receipt, start_year: 2099, end_year: 2100))

    for invalid <- [
          context,
          %{receipt_id: receipt.id, fence: Ecto.UUID.generate()},
          %{receipt_id: "invalid", fence: receipt.fence},
          %{unexpected: true}
        ] do
      assert {:error, outcome} =
               Ingestion.import_catalog(F.request(), F.options() ++ [delivery_context: invalid])

      assert outcome.status == :reconciliation_conflict
    end

    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end
end
