defmodule FootballMarket.Providers.FixtureMatrixTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.ProviderContractCase, as: Contract
  alias FootballMarket.Providers.{FixtureSourceA, FixtureSourceB}

  test "F-O01/F-O03 exhaustive traceability, all scenarios and deterministic two-source repetition" do
    cases = Contract.cases()
    ids = Enum.map(cases, & &1.id)
    assert length(ids) >= 200
    assert length(Enum.uniq(ids)) == length(ids)
    assert Enum.sort(Map.keys(Contract.expected())) == Enum.sort(ids)

    for adapter <- [FixtureSourceA, FixtureSourceB] do
      assert Enum.sort(adapter.example_ids()) == Enum.sort(ids)

      for c <- cases do
        assert c.sources[adapter.source_key()] == c.id
        assert c.scenarios != [] and c.requirements != [] and c.success_criteria != []
        assert Enum.all?(c.requirements, &Regex.match?(~r/^FR-0(?:0[1-9]|1[0-4])$/, &1))
        assert Enum.all?(c.success_criteria, &Regex.match?(~r/^SC-00[1-6]$/, &1))
        first = Contract.assert_contract!(adapter, c.id)
        second = Contract.assert_contract!(adapter, c.id)
        assert first == second

        if String.starts_with?(c.id, "F-I01") do
          assert c.state_check == "catalog-isolation"
          assert c.state_oracle == "exact five-table/read equality"
        end
      end
    end

    scenarios = Enum.flat_map(cases, & &1.scenarios) |> Enum.uniq() |> Enum.sort()

    required =
      for {story, count} <- [{1, 4}, {2, 5}, {3, 5}, {4, 3}],
          scenario <- 1..count,
          do: "US#{story}.#{scenario}"

    assert scenarios == Enum.sort(required)

    for prefix <- ["F-C01", "F-P01"] do
      full = Enum.filter(cases, &String.starts_with?(&1.id, prefix))
      assert length(full) == 20

      assert full |> Enum.map(& &1.request.league_code) |> Enum.uniq() |> Enum.sort() ==
               Enum.sort(["PL", "BL1", "PD", "SA", "FL1"])

      assert full |> Enum.map(& &1.request.start_year) |> Enum.uniq() |> Enum.sort() == [
               2024,
               2025
             ]
    end

    for family <-
          ~w(F-R01 F-R02 F-R03 F-R04 F-C01 F-C02 F-C03 F-C04 F-C05 F-P01 F-P02 F-P03 F-P04 F-P05 F-P06 F-P07 F-P08 F-P09 F-P10 F-E01 F-E02 F-E03 F-D01 F-D02 F-D03 F-D04 F-D05 F-I01 F-O01 F-O02 F-O03),
        do: assert(Contract.ids(family) != [])

    assert_raise ExUnit.AssertionError, fn -> Contract.ids("unknown-empty-inventory") end
  end

  test "offline bootstrap rejects unknown/empty selection and propagates a failed assertion" do
    for selector <- ["unknown", ""] do
      {_, status} =
        System.cmd("elixir", ["test/provider_contract_offline.exs", selector],
          stderr_to_stdout: true
        )

      assert status == 2
    end

    source = File.read!("test/provider_contract_offline.exs")

    injected =
      "Code.eval_string(\"defmodule OfflineFailureProbe do use ExUnit.Case; test \\\"intentional assertion\\\" do assert false end end\")\nresult = ExUnit.run()"

    source = String.replace(source, "result = ExUnit.run()", injected)
    source = String.replace(source, "Path.expand(\"..\", __DIR__)", inspect(File.cwd!()))

    path =
      Path.join(System.tmp_dir!(), "provider-offline-#{System.unique_integer([:positive])}.exs")

    try do
      File.write!(path, source)
      {output, status} = System.cmd("elixir", [path, "request"], stderr_to_stdout: true)
      assert status == 1
      assert output =~ "intentional assertion"
    after
      File.rm(path)
    end
  end
end
