defmodule FootballMarket.Market.RetryTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  setup do
    ns = private_schema()
    Map.merge(ns, fixture())
  end

  test "US2 retry preserves evidence and entire current snapshot", f do
    {:ok, %{issuance: e}} = Market.initialize_player(f.player.id)
    before = snapshot()

    for _ <- 1..3 do
      assert {:ok, %{outcome: :already_completed, issuance: ^e}} =
               Market.initialize_player(f.player.id)

      assert snapshot() == before
    end

    for quantity <- [20, 100] do
      local = Map.merge(private_schema(), fixture())
      {:ok, %{issuance: retained}} = Market.initialize_player(local.player.id)
      assert {:ok, _} = transfer(local, quantity)
      later = later_quote(local.player, "7.15")
      before = snapshot()

      assert {:ok, %{outcome: :already_completed, issuance: ^retained}} =
               Market.initialize_player(local.player.id)

      assert snapshot() == before
      assert Repo.get!(FootballMarket.Market.Quote, later.id).unit_price == Decimal.new("7.15")
    end
  end

  test "retry rejects stale isolation and invalid conserved inventory", f do
    {:ok, _} = Market.initialize_player(f.player.id)
    legacy = legacy_namespace(f.schema)

    in_client(legacy, fn ->
      Repo.query!("UPDATE market_holdings SET quantity=99")
      before = snapshot()
      assert_error(Market.initialize_player(f.player.id), :inconsistent_state)
      assert before == snapshot()
    end)
  end
end
