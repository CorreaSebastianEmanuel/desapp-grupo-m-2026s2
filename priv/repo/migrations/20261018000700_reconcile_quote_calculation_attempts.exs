defmodule FootballMarket.Repo.Migrations.ReconcileQuoteCalculationAttempts do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TABLE IF NOT EXISTS quote_calculation_attempts (
        id uuid PRIMARY KEY,
        request_id uuid NOT NULL REFERENCES quote_calculation_requests(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
        attempt_number integer NOT NULL,
        fence bigint NOT NULL,
        started_at timestamptz(6) NOT NULL,
        finished_at timestamptz(6) NOT NULL,
        status text NOT NULL,
        reason text NULL
      )
      """,
      "SELECT 1"
    )

    execute(
      "CREATE UNIQUE INDEX IF NOT EXISTS quote_calculation_attempt_unique ON quote_calculation_attempts (request_id, attempt_number)",
      "SELECT 1"
    )

    execute(
      """
      DO $$ BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint
          WHERE conname = 'quote_calculation_attempt_state'
        ) THEN
          ALTER TABLE quote_calculation_attempts ADD CONSTRAINT quote_calculation_attempt_state
            CHECK (attempt_number BETWEEN 1 AND 3 AND status IN ('successful','no_quote','validation_failed','unsupported_strategy','unreproducible','retryable','interrupted','exhausted'));
        END IF;
      END $$;
      """,
      "SELECT 1"
    )

    execute(
      """
      DO $$ BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_trigger
          WHERE tgrelid = 'quote_calculation_attempts'::regclass
            AND tgname = 'quote_calculation_attempts_immutable'
            AND NOT tgisinternal
        ) THEN
          EXECUTE 'CREATE TRIGGER quote_calculation_attempts_immutable BEFORE UPDATE OR DELETE ON quote_calculation_attempts FOR EACH ROW EXECUTE FUNCTION quote_calculation_immutable()';
        END IF;
        IF NOT EXISTS (
          SELECT 1 FROM pg_trigger
          WHERE tgrelid = 'quote_calculation_attempts'::regclass
            AND tgname = 'quote_calculation_attempts_no_truncate'
            AND NOT tgisinternal
        ) THEN
          EXECUTE 'CREATE TRIGGER quote_calculation_attempts_no_truncate BEFORE TRUNCATE ON quote_calculation_attempts FOR EACH STATEMENT EXECUTE FUNCTION quote_calculation_immutable()';
        END IF;
      END $$;
      """,
      "SELECT 1"
    )
  end
end
