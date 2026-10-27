defmodule FootballMarket.Market.Sales.StorageTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, SalesCase}

  setup do
    SalesCase.fixture()
  end

  test "sale history is immutable", fixture do
    assert {:ok, _sale} = SalesCase.sell(fixture)
    before = SalesCase.snapshot()

    for table <- ~w(market_sales market_sale_credit_entries market_sale_token_transfers),
        sql <- ["UPDATE #{table} SET id=id", "DELETE FROM #{table}", "TRUNCATE #{table} CASCADE"] do
      assert_raise Postgrex.Error, fn -> Repo.query!(sql) end
      assert before == SalesCase.snapshot()
    end
  end

  test "deferred guards reject incomplete or contradictory evidence", fixture do
    assert {:ok, original} = SalesCase.sell(fixture)
    before = SalesCase.snapshot()

    for field <- [
          :quantity,
          :unit_price,
          :recipient_id,
          :rule_version,
          :total,
          :quote_effective_at
        ] do
      exception =
        if field in [:quantity, :unit_price, :recipient_id, :total],
          do: Ecto.ConstraintError,
          else: Postgrex.Error

      assert_raise exception, fn ->
        Repo.transaction(fn ->
          sale = Repo.get!(FootballMarket.Market.Sale, original.id)

          changed =
            case field do
              :quantity -> 2
              :unit_price -> Decimal.new("2")
              :recipient_id -> fixture.buyer.id
              :rule_version -> "wrong"
              :total -> Decimal.new("5")
              :quote_effective_at -> DateTime.add(sale.quote_effective_at, 1, :second)
            end

          attrs =
            sale
            |> Map.from_struct()
            |> Map.drop([:__meta__, :id])
            |> Map.put(field, changed)
            |> Map.put(:request_key, Ecto.UUID.generate())

          Repo.insert!(struct!(FootballMarket.Market.Sale, attrs))
        end)
      end

      assert before == SalesCase.snapshot()
    end
  end

  test "upgrade creates no sale or credit records" do
    schema = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{schema}")
    FootballMarket.PurchasesCase.cleanup(schema)

    FootballMarket.MarketCase.in_client(schema, fn ->
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up,
        to: 20_261_026_000_100,
        prefix: schema,
        log: false
      )

      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)
      assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[0]]
      assert Repo.query!("SELECT count(*) FROM market_sale_credit_entries").rows == [[0]]
    end)
  end
end
