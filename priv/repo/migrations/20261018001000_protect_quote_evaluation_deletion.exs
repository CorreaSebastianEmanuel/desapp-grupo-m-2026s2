defmodule FootballMarket.Repo.Migrations.ProtectQuoteEvaluationDeletion do
  use Ecto.Migration

  def up do
    execute("""
    CREATE FUNCTION quote_evaluation_delete_guard() RETURNS trigger LANGUAGE plpgsql AS $$
    BEGIN
      RAISE EXCEPTION 'quote evaluation request is append-only'
        USING ERRCODE='23514', CONSTRAINT='quote_evaluation_write_once';
    END $$
    """)

    execute("""
    CREATE TRIGGER quote_evaluation_no_delete
    BEFORE DELETE ON quote_evaluation_requests
    FOR EACH ROW EXECUTE FUNCTION quote_evaluation_delete_guard()
    """)
  end

  def down, do: raise("quote evaluation deletion protection is forward-only")
end
