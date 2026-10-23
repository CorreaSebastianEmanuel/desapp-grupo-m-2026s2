defmodule FootballMarket.Repo.Migrations.ReconcileQuoteRequestRequestedMapping do
  use Ecto.Migration

  # B1 (QA 2026-10-21): the admission FK is intentionally NULL for an
  # unavailable mapping, which erased the supplied mapping identity from the
  # persisted request. Keep that supplied UUID inspectable so identical
  # unavailable-mapping retries stay retained while a different mapping
  # identity conflicts under the same request id.
  def change do
    execute(
      "ALTER TABLE quote_calculation_requests ADD COLUMN IF NOT EXISTS requested_mapping_id uuid",
      "SELECT 1"
    )
  end
end
