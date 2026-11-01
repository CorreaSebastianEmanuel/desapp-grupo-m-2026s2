defmodule FootballMarket.Catalog.ScoutingPolicyTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  alias FootballMarket.Catalog.Scouting

  test "normalizes equivalent Unicode player names for durable deduplication" do
    assert {:ok, "LIONEL MESSI", "lionel messi"} = Scouting.normalize_name("  LIONEL   MESSI ")
    assert {:ok, "Luka Modrić", "luka modric"} = Scouting.normalize_name("Luka Modrić")
  end

  test "rejects arbitrary or malformed search input before external admission" do
    for value <- ["", "1", "12345", "---", "Messi%", "<script>", String.duplicate("a", 81)] do
      assert :error = Scouting.normalize_name(value)
    end

    assert :error = Scouting.normalize_name(:not_a_name)
  end
end
