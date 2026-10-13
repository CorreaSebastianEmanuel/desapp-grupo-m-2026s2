defmodule FootballMarket.Valuation.Configurations.CodecTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations.{Rules, Codec}
  @position "00000000-0000-0000-0000-000000000001"

  test "typed canonical JSON round-trip preserves arbitrary exact values across contexts" do
    values = [
      1,
      Integer.pow(10, 100) + 1,
      -12,
      Decimal.new("1.00"),
      Decimal.new("-0.00"),
      Decimal.new("-0.125"),
      %Decimal{sign: -1, coef: Integer.pow(10, 100) + 3, exp: -1000},
      %Decimal{sign: 1, coef: 7, exp: 1000}
    ]

    for strategy <- ["balanced", "position_aware"], value <- values, precision <- [2, 28, 80] do
      Decimal.Context.with(%Decimal.Context{precision: precision}, fn ->
        assert {:ok, r} = Rules.validate(rules(@position, strategy, %{goals: value}))
        encoded = r |> Codec.encode() |> Jason.encode!() |> Jason.decode!()
        assert {:ok, decoded} = Codec.decode(encoded)

        assert canonical(Map.take(r, [:config, :references, :requirements, :position_mapping])) ==
                 canonical(decoded)
      end)
    end

    refute canonical(1) == canonical(Decimal.new(1))
    assert canonical(Decimal.new("1.0")) == canonical(Decimal.new("1.00"))
  end

  test "corrupt stored enums, numeric shapes and schema fail without atom creation" do
    {:ok, r} = Rules.validate(rules(@position))
    encoded = Codec.encode(r)

    for value <- [
          nil,
          [],
          %{},
          Map.put(encoded, "schema_version", 99),
          Map.put(encoded, "surprise", "Elixir.Evil"),
          Map.put(encoded, "config", %{"weights" => "evil"}),
          Map.put(encoded, "references", [
            ["not_a_metric_92813", %{"type" => "integer", "value" => "1"}]
          ]),
          Map.put(encoded, "references", [["goals", %{"type" => "integer", "value" => "1.0"}]])
        ] do
      assert {:error, :invalid_stored_rules} = Codec.decode(value)
    end
  end
end
