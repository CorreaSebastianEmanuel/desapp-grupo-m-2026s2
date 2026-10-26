defmodule FootballMarket.Market.Purchases.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.PurchaseInput
  alias FootballMarket.PurchasesCase

  test "money changesets reject nonfinite fractional and floating point input" do
    for value <- ["NaN", "Infinity", "-1", "0.001", 1.25] do
      refute FootballMarket.Market.CreditBalance.changeset(
               %FootballMarket.Market.CreditBalance{},
               %{amount: value}
             ).valid?
    end

    assert FootballMarket.Market.CreditBalance.changeset(
             %FootballMarket.Market.CreditBalance{},
             %{amount: "1.25"}
           ).valid?
  end

  test "strict actor, UUID, quantity, key and authority boundaries" do
    actor = PurchasesCase.actor(%{id: Ecto.UUID.generate()})
    input = %{player_id: Ecto.UUID.generate(), quantity: 1, request_key: "key"}

    assert {:ok, _} =
             PurchaseInput.validate(actor, %{input | request_key: String.duplicate("é", 128)})

    assert {:ok, %{request_key: " key "}} =
             PurchaseInput.validate(actor, %{input | request_key: " key "})

    for quantity <- [0, -1, 1.5, 1.0, "1", nil, %{}, 2_147_483_648],
        do:
          assert(
            {:error, %{kind: :invalid_request}} =
              PurchaseInput.validate(actor, %{input | quantity: quantity})
          )

    for key <- [nil, "", "  ", 1, String.duplicate("é", 129), "purchase\0key"],
        do:
          assert(
            {:error, %{kind: :invalid_request}} =
              PurchaseInput.validate(actor, %{input | request_key: key})
          )

    assert {:error, %{kind: :unauthenticated}} = PurchaseInput.validate(nil, input)

    assert {:error, %{kind: :invalid_request}} =
             PurchaseInput.validate(actor, Map.put(input, :buyer_id, actor.account_id))

    for player_id <- ["bad", "abcdefghijklmnop"] do
      assert {:error, %{kind: :invalid_request}} =
               PurchaseInput.validate(actor, %{input | player_id: player_id})
    end

    assert {:error, %{kind: :invalid_request}} = PurchaseInput.validate(actor, [])
  end
end
