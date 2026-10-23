defmodule FootballMarket.Market.StorageTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  setup do
    ns = private_schema()
    Map.merge(ns, fixture())
  end

  @tag :prefix_regression
  test "issuance migration seeds its explicit prefix independently of search_path", source do
    target = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{target}")
    Repo.query!("CREATE TABLE #{target}.users(id uuid PRIMARY KEY)")
    Repo.query!("CREATE TABLE #{target}.players(id uuid PRIMARY KEY)")
    assert Repo.query!("SHOW search_path").rows == [[source.schema]]
    before = snapshot()
    locks_before = Repo.query!("SELECT id FROM #{source.schema}.market_initialization_locks").rows

    result =
      try do
        Ecto.Migrator.up(
          Repo,
          20_261_014_000_000,
          FootballMarket.Repo.Migrations.CreateInitialPlayerIssuance,
          prefix: target,
          log: false
        )
      rescue
        error in Postgrex.Error ->
          {:migration_error, error.postgres.code, error.postgres[:constraint]}
      end

    assert Repo.query!("SHOW search_path").rows == [[source.schema]]
    assert snapshot() == before

    assert Repo.query!("SELECT id FROM #{source.schema}.market_initialization_locks").rows ==
             locks_before

    assert result == :ok,
           "explicit-prefix seed resolved through another search_path: #{inspect(result)}"

    assert Repo.query!("SELECT id FROM #{target}.market_initialization_locks").rows == [[1]]
  end

  test "ordinary evidence mutation and truncate fail, retaining original rows", f do
    for table <- ~w(market_initialization_locks),
        operation <- ["UPDATE #{table} SET id=id", "DELETE FROM #{table}", "TRUNCATE #{table}"] do
      before = snapshot()
      assert_raise Postgrex.Error, fn -> Repo.query!(operation) end
      assert snapshot() == before
    end

    assert {:ok, _} = Market.initialize_player(f.player.id)

    for table <-
          ~w(market_quotes market_issuances market_initial_recipients market_initialization_locks),
        operation <- ["UPDATE #{table} SET id=id", "DELETE FROM #{table}", "TRUNCATE #{table}"] do
      before = snapshot()
      assert_raise Postgrex.Error, fn -> Repo.query!(operation) end
      assert snapshot() == before
    end
  end

  test "deferred conservation permits transfer and rejects invalid ordinary holdings", f do
    {:ok, _} = Market.initialize_player(f.player.id)
    assert {:ok, _} = transfer(f, 20)
    before = snapshot()

    for statement <- [
          "UPDATE market_holdings SET quantity=quantity+1",
          "UPDATE market_holdings SET quantity=-1",
          "UPDATE market_holdings SET quantity='1.5'",
          "DELETE FROM market_holdings",
          "TRUNCATE market_holdings",
          "UPDATE market_holdings SET user_id='#{f.owner.id}' WHERE user_id='#{f.buyer.id}'"
        ] do
      assert_raise Postgrex.Error, fn -> Repo.query!(statement) end
      assert before == snapshot()
    end

    for level <- ["REPEATABLE READ", "SERIALIZABLE"] do
      assert_raise Postgrex.Error, fn ->
        Repo.transaction(fn ->
          Repo.query!("SET TRANSACTION ISOLATION LEVEL #{level}")
          Repo.query!("UPDATE market_holdings SET quantity=quantity")
        end)
      end

      assert before == snapshot()
    end
  end

  test "canonical facts, required fields, unique originals and restrictive FK linkage", f do
    {:ok, %{issuance: e}} = Market.initialize_player(f.player.id)
    before = snapshot()

    statements = [
      "INSERT INTO market_issuances SELECT gen_random_uuid(),player_id,recipient_id,quantity,initial_unit_price,initial_quote_id,completed_at FROM market_issuances",
      "INSERT INTO market_issuances SELECT gen_random_uuid(),'#{f.other.id}',recipient_id,99,initial_unit_price,initial_quote_id,completed_at FROM market_issuances",
      "INSERT INTO market_issuances SELECT gen_random_uuid(),'#{f.other.id}',recipient_id,100,2,initial_quote_id,completed_at FROM market_issuances",
      "INSERT INTO market_issuances SELECT gen_random_uuid(),'#{f.other.id}',recipient_id,100,1,initial_quote_id,completed_at FROM market_issuances",
      "INSERT INTO market_quotes SELECT gen_random_uuid(),player_id,unit_price,effective_at,inserted_at,rule_id,rule_version FROM market_quotes",
      "INSERT INTO market_holdings VALUES(gen_random_uuid(),'#{f.player.id}','#{f.owner.id}',0)",
      "INSERT INTO market_holdings VALUES(gen_random_uuid(),'#{Ecto.UUID.generate()}','#{f.owner.id}',0)",
      "INSERT INTO market_holdings VALUES(gen_random_uuid(),'#{f.other.id}','#{Ecto.UUID.generate()}',0)",
      "INSERT INTO market_holdings VALUES(gen_random_uuid(),'#{f.other.id}','#{f.owner.id}',NULL)",
      "INSERT INTO market_quotes VALUES(gen_random_uuid(),'#{f.other.id}',1,now(),now(),'initial_issuance','2')",
      "INSERT INTO market_quotes VALUES(gen_random_uuid(),'#{f.other.id}','NaN',now(),now(),'fixture','1')",
      "DELETE FROM players WHERE id='#{f.player.id}'",
      "DELETE FROM users WHERE id='#{f.owner.id}'",
      "INSERT INTO market_issuances VALUES(gen_random_uuid(),'#{f.other.id}','#{f.owner.id}',100,1,'#{e.initial_quote_id}',NULL)"
    ]

    for statement <- statements do
      error = assert_raise Postgrex.Error, fn -> Repo.query!(statement) end

      assert error.postgres.code in [
               :unique_violation,
               :check_violation,
               :foreign_key_violation,
               :not_null_violation
             ]

      assert before == snapshot()
    end
  end

  test "direct first-commit writes require original owner, matching quote and recipient", f do
    for mutation <- [:owner, :quantity, :rule, :date, :recipient] do
      local = Map.merge(private_schema(), fixture())
      before = snapshot()

      error =
        try do
          Repo.transaction(fn ->
            now = DateTime.utc_now()

            Repo.insert!(%FootballMarket.Market.InitialRecipient{
              id: 1,
              user_id: local.owner.id,
              fixed_at: now
            })

            q =
              Repo.insert!(%FootballMarket.Market.Quote{
                player_id: local.player.id,
                unit_price: Decimal.new(1),
                effective_at: now,
                inserted_at: now,
                rule_id: if(mutation == :rule, do: "fixture", else: "initial_issuance"),
                rule_version: "1"
              })

            Repo.insert!(%FootballMarket.Market.Holding{
              player_id: local.player.id,
              user_id: if(mutation == :owner, do: local.buyer.id, else: local.owner.id),
              quantity: if(mutation == :quantity, do: 99, else: 100)
            })

            Repo.insert!(%FootballMarket.Market.Issuance{
              player_id: local.player.id,
              recipient_id: if(mutation == :recipient, do: local.buyer.id, else: local.owner.id),
              quantity: 100,
              initial_unit_price: Decimal.new(1),
              initial_quote_id: q.id,
              completed_at: if(mutation == :date, do: DateTime.add(now, 1), else: now)
            })
          end)

          nil
        rescue
          raised in [Postgrex.Error, Ecto.ConstraintError] -> raised
        end

      constraint_name =
        case error do
          %Postgrex.Error{} -> error.postgres.constraint
          %Ecto.ConstraintError{} -> error.constraint
        end

      assert constraint_name in [
               "market_quote_performance_shape",
               "market_initial_owner",
               "market_supply_conserved",
               "market_issuance_quote_consistent",
               "market_recipient_consistent"
             ]

      assert before == snapshot()
    end

    assert market_empty?()
    assert f.owner.id != f.buyer.id
  end

  test "every required original fact rejects null at the storage boundary", f do
    {:ok, _} = Market.initialize_player(f.player.id)
    before = snapshot()

    for {table, fields} <- [
          {"market_issuances",
           ~w(id player_id recipient_id quantity initial_unit_price initial_quote_id completed_at)},
          {"market_quotes",
           ~w(id player_id unit_price effective_at inserted_at rule_id rule_version)},
          {"market_initial_recipients", ~w(id user_id fixed_at)}
        ],
        missing <- fields do
      selection =
        Enum.map_join(fields, ",", fn field -> if field == missing, do: "NULL", else: field end)

      error =
        assert_raise Postgrex.Error, fn ->
          Repo.query!(
            "INSERT INTO #{table}(#{Enum.join(fields, ",")}) SELECT #{selection} FROM #{table}"
          )
        end

      assert error.postgres.code == :not_null_violation
      assert error.postgres.column == missing
      assert snapshot() == before
    end
  end

  test "quote player linkage rejects a different-player quote before commit" do
    f = Map.merge(private_schema(), fixture())
    before = snapshot()

    error =
      assert_raise Ecto.ConstraintError, fn ->
        Repo.transaction(fn ->
          now = DateTime.utc_now()

          Repo.insert!(%FootballMarket.Market.InitialRecipient{
            id: 1,
            user_id: f.owner.id,
            fixed_at: now
          })

          q =
            Repo.insert!(%FootballMarket.Market.Quote{
              player_id: f.other.id,
              unit_price: Decimal.new(1),
              effective_at: now,
              inserted_at: now,
              rule_id: "initial_issuance",
              rule_version: "1"
            })

          Repo.insert!(%FootballMarket.Market.Holding{
            player_id: f.player.id,
            user_id: f.owner.id,
            quantity: 100
          })

          Repo.insert!(%FootballMarket.Market.Issuance{
            player_id: f.player.id,
            recipient_id: f.owner.id,
            quantity: 100,
            initial_unit_price: Decimal.new(1),
            initial_quote_id: q.id,
            completed_at: now
          })
        end)
      end

    assert error.type == :foreign_key
    assert error.constraint == "market_issuance_quote_player_fkey"
    assert snapshot() == before
  end
end
