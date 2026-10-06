defmodule FootballMarket.Providers.CatalogContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.ProviderContractCase, as: Contract
  alias FootballMarket.Providers.{FixtureSourceA, FixtureSourceB}

  test "F-C01 both shapes across five leagues/two seasons and same-name players" do
    for case_id <- Contract.ids("F-C01"), adapter <- [FixtureSourceA, FixtureSourceB] do
      {:ok, result} = Contract.assert_contract!(adapter, case_id)
      assert length(result.facts.players) == 2
      assert length(Enum.uniq_by(result.facts.players, & &1.ref)) == 2
      assert length(Enum.uniq_by(result.facts.players, & &1.display_name)) == 1
    end
  end

  test "F-C02/F-C03 empty, missing scope and unsupported coverage remain distinct" do
    for case_id <- Contract.ids(["F-C02", "F-C03"]),
        adapter <- [FixtureSourceA, FixtureSourceB],
        do: Contract.assert_contract!(adapter, case_id)
  end

  test "F-C04 complete invalidity matrix rejects duplicates, fields and edges" do
    assert length(Contract.ids("F-C04")) >= 16

    for case_id <- Contract.ids("F-C04"), adapter <- [FixtureSourceA, FixtureSourceB] do
      assert {:error, error} = Contract.assert_contract!(adapter, case_id)
      assert error.category == :invalid_response
    end
  end

  test "F-C05 qualified source identifiers remain opaque and scope-specific" do
    for case_id <- Contract.ids("F-C05"),
        adapter <- [FixtureSourceA, FixtureSourceB],
        do: Contract.assert_contract!(adapter, case_id)
  end

  def provider_label, do: "candidate-envelope"

  def read(request, context, mutate) do
    {:ok, candidate} = FixtureSourceA.read(request, context, "F-C01-PL-2025-2026-A")
    {:ok, mutate.(candidate)}
  end

  test "envelope mismatch and unrecognized normalized keys fail as complete invalid responses" do
    request = %{league_code: "PL", start_year: 2025, end_year: 2026}

    for mutate <- [
          fn c -> %{c | operation: :performances} end,
          fn c -> put_in(c, [:scope, :end_year], 2027) end,
          fn c -> Map.delete(c, :facts) end,
          fn c -> Map.put(c, :payload, "FAKE_SENTINEL") end,
          fn c ->
            update_in(c, [:bindings], fn [b | rest] -> [Map.delete(b, :source_id) | rest] end)
          end
        ] do
      Process.put(:fixture_elapsed, 0)

      assert {:error, error} =
               FootballMarket.Providers.catalog(request,
                 provider: {__MODULE__, mutate},
                 positions: %{"FW" => "Forward", "GK" => "Goalkeeper"},
                 runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
               )

      assert error.category == :invalid_response
      refute inspect(error) =~ "FAKE_SENTINEL"
    end
  end
end
