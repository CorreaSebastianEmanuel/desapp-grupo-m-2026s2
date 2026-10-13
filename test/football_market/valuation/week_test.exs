defmodule FootballMarket.Valuation.WeekTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Valuation.Week

  test "explicit UTC half-open weeks and equivalent offsets at microsecond precision" do
    assert {:ok, {a, b}} = Week.validate("2026-10-04T21:00:00-03:00", "2026-10-11T21:00:00-03:00")
    assert {:ok, {^a, ^b}} = Week.validate("2026-10-05T00:00:00Z", "2026-10-12T00:00:00Z")
    assert {:ok, _} = Week.validate("2025-12-29T00:00:00Z", "2026-01-05T00:00:00Z")

    for {s, e} <- [
          {nil, nil},
          {"bad", "bad"},
          {"2026-10-05T00:00:00", "2026-10-12T00:00:00Z"},
          {"2026-10-05T00:00:00.0000001Z", "2026-10-12T00:00:00Z"},
          {"2026-10-05T00:00:00.000001Z", "2026-10-12T00:00:00Z"},
          {"2026-10-06T00:00:00Z", "2026-10-13T00:00:00Z"},
          {"2026-10-05T00:00:00Z", "2026-10-05T00:00:00Z"},
          {"2026-10-12T00:00:00Z", "2026-10-05T00:00:00Z"},
          {"2026-10-05T00:00:00Z", "2026-10-19T00:00:00Z"}
        ] do
      assert {:error, %{kind: :validation}} = Week.validate(s, e)
    end
  end
end
