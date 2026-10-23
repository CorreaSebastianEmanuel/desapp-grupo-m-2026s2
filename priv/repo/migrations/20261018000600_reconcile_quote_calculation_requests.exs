defmodule FootballMarket.Repo.Migrations.ReconcileQuoteCalculationRequests do
  use Ecto.Migration

  def change do
    execute(
      """
      ALTER TABLE quote_calculation_requests
      ADD COLUMN IF NOT EXISTS attempt_count integer NOT NULL DEFAULT 0,
      ADD COLUMN IF NOT EXISTS lease_fence bigint NOT NULL DEFAULT 0,
      ADD COLUMN IF NOT EXISTS lease_until timestamptz(6) NULL,
      ADD COLUMN IF NOT EXISTS next_attempt_at timestamptz(6) NULL,
      ADD COLUMN IF NOT EXISTS reason text NULL
      """,
      "SELECT 1"
    )

    execute(
      """
      DO $$ BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint
          WHERE conname = 'quote_calculation_request_attempts'
        ) THEN
          ALTER TABLE quote_calculation_requests ADD CONSTRAINT quote_calculation_request_attempts
            CHECK (attempt_count BETWEEN 0 AND 3 AND lease_fence >= 0);
        END IF;
      END $$;
      """,
      "SELECT 1"
    )
  end
end
