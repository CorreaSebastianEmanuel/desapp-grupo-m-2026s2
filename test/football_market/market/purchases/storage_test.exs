defmodule FootballMarket.Market.Purchases.StorageTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.Repo
  alias FootballMarket.PurchasesCase

  setup do
    PurchasesCase.fixture()
  end

  test "balances reject negative, nonfinite and off-cent money without changing state", f do
    for amount <- ["-1", "NaN", "Infinity", "0.001"] do
      assert_raise Postgrex.Error, fn -> PurchasesCase.fund(f.buyer, amount) end
    end

    assert Repo.query!("SELECT count(*) FROM market_credit_balances").rows == [[0]]
    PurchasesCase.fund(f.buyer, "10.25")

    assert Repo.query!("SELECT amount FROM market_credit_balances").rows == [
             [Decimal.new("10.25")]
           ]
  end

  test "successful financial evidence is immutable for ordinary update delete and truncate", f do
    PurchasesCase.fund(f.buyer, "100")
    assert {:ok, _} = PurchasesCase.purchase(f)
    assert Repo.query!("SELECT conditional_order_id FROM market_purchases").rows == [[nil]]
    before = PurchasesCase.snapshot()

    for table <- ~w(market_purchases market_credit_entries market_token_transfers),
        sql <- ["UPDATE #{table} SET id=id", "DELETE FROM #{table}", "TRUNCATE #{table} CASCADE"] do
      assert_raise Postgrex.Error, fn -> Repo.query!(sql) end
      assert before == PurchasesCase.snapshot()
    end
  end

  test "deferred guards reject incomplete records and corrupt participants and quote facts", f do
    PurchasesCase.fund(f.buyer, "100")
    assert {:ok, original} = PurchasesCase.purchase(f)
    before = PurchasesCase.snapshot()

    for field <- [
          :quantity,
          :unit_price,
          :recipient_id,
          :rule_version,
          :total,
          :quote_effective_at,
          :mapping_id
        ] do
      exception =
        if field in [:quantity, :unit_price, :total, :recipient_id],
          do: Ecto.ConstraintError,
          else: Postgrex.Error

      assert_raise exception, fn ->
        Repo.transaction(fn ->
          p = Repo.get!(FootballMarket.Market.Purchase, original.id)

          change =
            case field do
              :quantity -> 4
              :unit_price -> Decimal.new("2")
              :total -> Decimal.new("5")
              :recipient_id -> f.buyer.id
              :rule_version -> "wrong"
              :quote_effective_at -> DateTime.add(p.quote_effective_at, 1, :second)
              :mapping_id -> Ecto.UUID.generate()
            end

          # Insert a new candidate with no linked children: both incomplete and
          # contradictory snapshots must be rejected at the owning commit.
          attrs =
            p
            |> Map.from_struct()
            |> Map.drop([:__meta__, :id])
            |> Map.put(field, change)
            |> Map.put(:request_key, Ecto.UUID.generate())

          Repo.insert!(struct!(FootballMarket.Market.Purchase, attrs))
        end)
      end

      assert before == PurchasesCase.snapshot()
    end

    assert_raise Ecto.ConstraintError, fn ->
      p = Repo.get!(FootballMarket.Market.Purchase, original.id)

      Repo.insert!(%{
        p
        | id: Ecto.UUID.generate(),
          __meta__: %Ecto.Schema.Metadata{state: :built, source: "market_purchases"}
      })
    end
  end

  test "upgrade from the preceding schema preserves accounts and creates no opening credits" do
    schema = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{schema}")
    PurchasesCase.cleanup(schema)

    FootballMarket.MarketCase.in_client(schema, fn ->
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up,
        to: 20_261_018_001_100,
        prefix: schema,
        log: false
      )

      {:ok, user} =
        FootballMarket.Accounts.register_user(%{
          email: "upgrade@example.test",
          password: "purchase-password"
        })

      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)
      assert Repo.get!(FootballMarket.Accounts.User, user.id).email == "upgrade@example.test"
      assert Repo.query!("SELECT count(*) FROM market_credit_balances").rows == [[0]]
      assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[0]]
    end)
  end
end
