defmodule FootballMarket.Market.ConditionalOrders.HandoffTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, Repo}
  alias FootballMarket.Market.ConditionalOrders
  setup do: ConditionalOrdersCase.fixture()

  test "transaction participant rolls back and pending cursor includes due no-quote rows", f do
    {:ok, terms} =
      ConditionalOrders.validate_terms(
        ConditionalOrdersCase.actor(f.buyer),
        ConditionalOrdersCase.terms(f)
      )

    before = ConditionalOrdersCase.snapshot()

    assert {:error, :outer_abort} =
             Repo.transaction(fn ->
               result = ConditionalOrders.create_in_transaction!(terms)
               assert result.status == "pending"
               Repo.rollback(:outer_abort)
             end)

    assert before == ConditionalOrdersCase.snapshot()
    orders = for _ <- 1..5, do: ConditionalOrdersCase.order!(f)
    ConditionalOrdersCase.due!(hd(orders))
    Repo.query!("ALTER TABLE market_quotes RENAME TO retained_quotes")
    Repo.query!("CREATE TABLE market_quotes AS TABLE retained_quotes WITH NO DATA")
    before = ConditionalOrdersCase.snapshot()
    {:ok, first} = ConditionalOrders.pending_candidates(f.player.id, nil, 2)
    {:ok, second} = ConditionalOrders.pending_candidates(f.player.id, List.last(first).id, 2)
    {:ok, third} = ConditionalOrders.pending_candidates(f.player.id, List.last(second).id, 2)

    assert Enum.sort(Enum.map(first ++ second ++ third, & &1.id)) ==
             Enum.sort(Enum.map(orders, & &1.id))

    assert before == ConditionalOrdersCase.snapshot()
    Repo.query!("DROP TABLE market_quotes")
    Repo.query!("ALTER TABLE retained_quotes RENAME TO market_quotes")

    assert {:error, %{kind: :invalid_request}} =
             ConditionalOrders.pending_candidates(nil, nil, 101)
  end
end
