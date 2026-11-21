defmodule FootballMarket.Market.Sales.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.Trading
  alias FootballMarket.PurchasesCase

  test "strict actor, UUID, quantity, key and authority boundaries" do
    actor = PurchasesCase.actor(%{id: Ecto.UUID.generate()})
    input = %{player_id: Ecto.UUID.generate(), quantity: 1, request_key: "key"}

    assert {:ok, canonical} =
             Trading.validate(:sale, actor, %{input | request_key: String.duplicate("é", 128)})

    assert canonical.seller_id == actor.account_id

    assert {:ok, %{request_key: " key "}} =
             Trading.validate(:sale, actor, %{input | request_key: " key "})

    for quantity <- [0, -1, 1.5, 1.0, "1", nil, %{}, 2_147_483_648],
        do:
          assert(
            {:error, %{kind: :invalid_request}} =
              Trading.validate(:sale, actor, %{input | quantity: quantity})
          )

    for key <- [nil, "", "  ", 1, String.duplicate("é", 129), "sale\0key"],
        do:
          assert(
            {:error, %{kind: :invalid_request}} =
              Trading.validate(:sale, actor, %{input | request_key: key})
          )

    assert {:error, %{kind: :unauthenticated}} = Trading.validate(:sale, nil, input)

    assert {:error, %{kind: :invalid_request}} =
             Trading.validate(:sale, actor, Map.put(input, :seller_id, actor.account_id))

    assert {:error, %{kind: :invalid_request}} =
             Trading.validate(:sale, actor, Map.put(input, :buyer_id, actor.account_id))

    assert {:error, %{kind: :invalid_request}} =
             Trading.validate(:sale, actor, Map.put(input, :unit_price, "3"))

    for player_id <- ["bad", "abcdefghijklmnop"] do
      assert {:error, %{kind: :invalid_request}} =
               Trading.validate(:sale, actor, %{input | player_id: player_id})
    end

    assert {:error, %{kind: :invalid_request}} = Trading.validate(:sale, actor, [])
  end
end
