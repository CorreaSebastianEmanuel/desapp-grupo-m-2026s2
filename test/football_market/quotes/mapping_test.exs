defmodule FootballMarket.Quotes.MappingTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Quotes.Mappings

  test "saved mappings require an explicit positive scale and remain versioned" do
    assert {:ok, mapping} = Mappings.save("fixture", "1", Decimal.new("1.25"))
    assert mapping.scale == Decimal.new("1.25")
    assert mapping.schema_version == 1
    assert mapping.rounding_rule == "two-half-away-v1"
    assert {:ok, ^mapping} = Mappings.get(mapping.id)
    assert {:error, :invalid_mapping} = Mappings.save("fixture", "zero", Decimal.new("0"))
    assert {:error, _} = Mappings.save("fixture", "1", Decimal.new("2"))
  end
end
