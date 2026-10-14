defmodule Task028IndependentFeedbackQA do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  test "explicit-prefix migration and guards preserve populated source financial history" do
    f = Map.merge(private_schema(), fixture())
    assert {:ok, %{issuance: original}} = Market.initialize_player(f.player.id)
    assert {:ok, _} = transfer(f, 20)
    later_quote(f.player, "7.15")
    before = snapshot()
    source_locks = Repo.query!("SELECT id FROM market_initialization_locks").rows
    assert source_locks == [[1]]
    target = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{target}")
    Repo.query!("CREATE TABLE #{target}.users(id uuid PRIMARY KEY)")
    Repo.query!("CREATE TABLE #{target}.players(id uuid PRIMARY KEY)")
    assert Repo.query!("SHOW search_path").rows == [[f.schema]]

    assert :ok == Ecto.Migrator.up(Repo, 20_261_014_000_000,
      FootballMarket.Repo.Migrations.CreateInitialPlayerIssuance,
      prefix: target, log: false)
    assert Repo.query!("SELECT id FROM #{target}.market_initialization_locks").rows == [[1]]
    assert Repo.query!("SHOW search_path").rows == [[f.schema]]
    assert snapshot() == before
    assert Repo.query!("SELECT id FROM market_initialization_locks").rows == source_locks

    # Same identity values in both namespaces make accidental source references
    # observable as recipient, supply, history or FK failures.
    Repo.query!("INSERT INTO #{target}.users VALUES($1)", [Ecto.UUID.dump!(f.owner.id)])
    Repo.query!("INSERT INTO #{target}.players VALUES($1)", [Ecto.UUID.dump!(f.player.id)])
    assert {:ok, _} = Repo.transaction(fn ->
      now = DateTime.utc_now()
      Repo.insert!(%FootballMarket.Market.InitialRecipient{id: 1, user_id: f.owner.id, fixed_at: now}, prefix: target)
      quote = Repo.insert!(%FootballMarket.Market.Quote{player_id: f.player.id,
        unit_price: Decimal.new(1), effective_at: now, inserted_at: now,
        rule_id: "initial_issuance", rule_version: "1"}, prefix: target)
      Repo.insert!(%FootballMarket.Market.Holding{player_id: f.player.id,
        user_id: f.owner.id, quantity: 100}, prefix: target)
      Repo.insert!(%FootballMarket.Market.Issuance{player_id: f.player.id,
        recipient_id: f.owner.id, quantity: 100, initial_unit_price: Decimal.new(1),
        initial_quote_id: quote.id, completed_at: now}, prefix: target)
    end)
    assert Repo.query!("SELECT quantity FROM #{target}.market_holdings").rows == [[100]]
    assert Repo.query!("SELECT count(*) FROM #{target}.market_issuances").rows == [[1]]
    assert_raise Postgrex.Error, fn -> Repo.query!("UPDATE #{target}.market_holdings SET quantity=101") end
    assert_raise Postgrex.Error, fn -> Repo.query!("UPDATE #{target}.market_quotes SET unit_price=2") end
    assert Repo.query!("SELECT quantity FROM #{target}.market_holdings").rows == [[100]]
    assert snapshot() == before
    assert {:ok, %{outcome: :already_completed, issuance: ^original}} = Market.initialize_player(f.player.id)
    IO.puts("QA_PREFIX_POPULATED_PASS source_history_preserved=true target_supply=100 search_path_preserved=true")
  end

  test "retry does not replenish an absent original-owner holding" do
    f = Map.merge(private_schema(), fixture())
    assert {:ok, %{issuance: original}} = Market.initialize_player(f.player.id)
    assert {:ok, _} = transfer(f, 100)
    Repo.query!("DELETE FROM market_holdings WHERE user_id=$1", [Ecto.UUID.dump!(f.owner.id)])
    before = snapshot()
    assert Repo.query!("SELECT count(*) FROM market_holdings WHERE user_id=$1", [Ecto.UUID.dump!(f.owner.id)]).rows == [[0]]
    assert {:ok, %{outcome: :already_completed, issuance: ^original}} = Market.initialize_player(f.player.id)
    assert snapshot() == before
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]
    IO.puts("QA_ABSENT_OWNER_PASS outcome=already_completed original_holding_rows=0 supply=100 snapshot_unchanged=true")
  end
end
