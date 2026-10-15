defmodule FootballMarket.Repo.Migrations.CreateCatalogDeliveryReceipts do
  use Ecto.Migration

  def change do
    create table(:catalog_delivery_receipts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :fence, :uuid, null: false

      add :run_id, references(:synchronization_runs, type: :uuid, on_delete: :restrict),
        null: false

      add :league_code, :text, null: false
      add :start_year, :integer, null: false
      add :end_year, :integer, null: false
      add :state, :text, null: false
      add :outcome, :map
      add :confirmed_at, :utc_datetime_usec
    end

    create constraint(:catalog_delivery_receipts, :catalog_delivery_receipt_state,
             check: "state IN ('prepared', 'confirmed', 'revoked')"
           )
  end
end
