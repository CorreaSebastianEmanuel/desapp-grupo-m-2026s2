defmodule FootballMarket.Market.Sales.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.{Sale, SaleCreditEntry, SaleInput}
  alias FootballMarket.PurchasesCase

  test "strict actor UUID quantity key and authority boundaries" do
    actor = PurchasesCase.actor(%{id: Ecto.UUID.generate()})
    input = %{player_id: Ecto.UUID.generate(), quantity: 1, request_key: "key"}

    assert {:ok, %{request_key: " key "}} =
             SaleInput.validate(actor, %{input | request_key: " key "})

    assert {:ok, _} =
             SaleInput.validate(actor, %{input | request_key: String.duplicate("é", 128)})

    for quantity <- [0, -1, 1.5, 1.0, "1", nil, %{}, 2_147_483_648] do
      assert {:error, %{kind: :invalid_request}} =
               SaleInput.validate(actor, %{input | quantity: quantity})
    end

    for key <- [nil, "", "  ", 1, String.duplicate("é", 129), "sale\0key"] do
      assert {:error, %{kind: :invalid_request}} =
               SaleInput.validate(actor, %{input | request_key: key})
    end

    assert {:error, %{kind: :unauthenticated}} = SaleInput.validate(nil, input)

    for field <- [:seller_id, :recipient_id, :unit_price, :total, :quote_id] do
      assert {:error, %{kind: :invalid_request}} =
               SaleInput.validate(actor, Map.put(input, field, actor.account_id))
    end

    for player_id <- ["bad", "abcdefghijklmnop"] do
      assert {:error, %{kind: :invalid_request}} =
               SaleInput.validate(actor, %{input | player_id: player_id})
    end
  end

  test "sale money changesets reject floats nonfinite negative and fractional cents" do
    for value <- ["NaN", "Infinity", "-1", "0.001", 1.25] do
      refute Sale.changeset(%Sale{}, %{unit_price: value}).valid?
      refute SaleCreditEntry.changeset(%SaleCreditEntry{}, %{amount: value}).valid?
    end

    assert Sale.changeset(%Sale{}, %{unit_price: "1.25", total: "2.50"}).valid?
    assert SaleCreditEntry.changeset(%SaleCreditEntry{}, %{amount: "2.50"}).valid?
  end
end
