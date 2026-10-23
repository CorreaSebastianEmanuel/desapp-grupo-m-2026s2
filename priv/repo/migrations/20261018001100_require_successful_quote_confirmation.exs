defmodule FootballMarket.Repo.Migrations.RequireSuccessfulQuoteConfirmation do
  use Ecto.Migration

  def up do
    execute("""
    CREATE FUNCTION quote_calculation_confirmation_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    DECLARE confirmation_count integer;
    BEGIN
      IF NEW.status <> 'successful' THEN RETURN NULL; END IF;

      SELECT count(*) INTO confirmation_count
      FROM market_quotes q
      JOIN quote_evaluation_requests e
        ON e.quote_id = q.id AND e.calculation_id = NEW.id AND e.player_id = NEW.player_id
      WHERE q.calculation_id = NEW.id
        AND q.player_id = NEW.player_id
        AND q.configuration_version_id = NEW.configuration_version_id
        AND q.mapping_id = NEW.mapping_id
        AND q.unit_price = NEW.unit_price
        AND q.effective_at = NEW.effective_at;

      IF confirmation_count <> 1 THEN
        RAISE EXCEPTION 'successful calculation requires exactly one matching quote and evaluation'
          USING ERRCODE='23514', CONSTRAINT='quote_calculation_confirmation_required';
      END IF;
      RETURN NULL;
    END $$
    """)

    execute("""
    CREATE CONSTRAINT TRIGGER quote_calculation_confirmation_required
    AFTER INSERT ON quote_calculations
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION quote_calculation_confirmation_guard()
    """)
  end

  def down, do: raise("successful quote confirmation protection is forward-only")
end
