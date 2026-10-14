defmodule FootballMarket.Market.RollbackTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  test "US2 pre-commit failures at every write boundary leave no effects and retry once" do
    for {table, deferred, preceding} <- [
          {"market_quotes", false, "market_initial_recipients"},
          {"market_holdings", false, "market_quotes"},
          {"market_issuances", false, "market_holdings"},
          {"market_issuances", true, "market_issuances"}
        ] do
      ns = private_schema()
      f = Map.merge(ns, fixture())
      before = snapshot()
      Repo.query!("CREATE SEQUENCE #{f.schema}.test_fault_reached")

      Repo.query!("""
      CREATE FUNCTION #{f.schema}.test_fault() RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN
        IF (SELECT count(*) FROM #{f.schema}.#{preceding})<>1 THEN
          RAISE EXCEPTION 'wrong failure boundary';
        END IF;
        IF TG_WHEN='AFTER' AND
           ((SELECT count(*) FROM #{f.schema}.market_initial_recipients)<>1 OR
            (SELECT count(*) FROM #{f.schema}.market_quotes)<>1 OR
            (SELECT count(*) FROM #{f.schema}.market_holdings)<>1) THEN
          RAISE EXCEPTION 'incomplete final boundary';
        END IF;
        PERFORM nextval('#{f.schema}.test_fault_reached');
        RAISE EXCEPTION 'injected precommit failure' USING ERRCODE='23514', CONSTRAINT='test_fault';
      END $$
      """)

      if deferred do
        Repo.query!(
          "CREATE CONSTRAINT TRIGGER test_fault AFTER INSERT ON market_issuances DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION #{f.schema}.test_fault()"
        )
      else
        Repo.query!(
          "CREATE TRIGGER test_fault BEFORE INSERT ON #{table} FOR EACH ROW EXECUTE FUNCTION #{f.schema}.test_fault()"
        )
      end

      assert_error(Market.initialize_player(f.player.id), :storage_failure)

      assert Repo.query!("SELECT last_value, is_called FROM #{f.schema}.test_fault_reached").rows ==
               [[1, true]]

      assert snapshot() == before
      assert market_empty?()
      Repo.query!("DROP TRIGGER test_fault ON #{table}")
      assert {:ok, %{outcome: :issued, issuance: e}} = Market.initialize_player(f.player.id)

      assert {:ok, %{outcome: :already_completed, issuance: ^e}} =
               Market.initialize_player(f.player.id)
    end
  end

  test "lost acknowledgement after commit preserves durable issuance", _ do
    f = Map.merge(private_schema(), fixture())

    in_client(f.schema, fn ->
      assert {:ok, %{outcome: :issued}} = Market.initialize_player(f.player.id)
      :discard_response
    end)

    before = snapshot()
    assert {:ok, e} = Market.get_initial_issuance(f.player.id)

    assert {:ok, %{outcome: :already_completed, issuance: ^e}} =
             Market.initialize_player(f.player.id)

    assert snapshot() == before
  end
end
