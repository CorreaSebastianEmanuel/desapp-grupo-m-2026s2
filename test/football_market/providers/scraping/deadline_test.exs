defmodule FootballMarket.Providers.ScrapingDeadlineTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.{ScrapingFixtureData, FixtureRuntime, Runtime}
  alias ScrapingFixtureData, as: Data

  test "strict shared budget: before, equal, after, default/custom/huge override" do
    for c <- Data.cases(), String.starts_with?(c["id"], "deadline-") do
      Data.assert_case!(c)
    end

    for op <- ["catalog", "performance"] do
      c = Data.case!(op <> "-PL-2024")
      assert {:error, e} = Data.run(c, %{}, {FixtureRuntime, %{validation_us: 5_000_000}})
      assert e.category == :timeout
      c = Map.put(c, "timeout", 1)
      assert {:error, e} = Data.run(c, %{on_fetch: fn _ -> FixtureRuntime.advance(600) end})
      assert e.category == :timeout
    end
  end

  test "production Runtime kills synchronous source work and prevents late publication" do
    for id <- ["catalog-PL-2024", "performance-PL-2024"] do
      c = Data.case!(id) |> Map.put("timeout", 40)
      assert {:error, e} = Data.run(c, %{sleep_ms: 200}, {Runtime, nil})
      assert e.category == :timeout
      assert_receive {:scraping_fetch, _, worker}
      monitor = Process.monitor(worker)
      assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 300
      refute Process.alive?(worker)
      refute_receive {:provider_ready, _, _, _}, 220
      flush()
    end
  end

  test "production Runtime accepts VM-sized overrides for both operations" do
    for id <- ["catalog-PL-2024", "performance-PL-2024"],
        timeout <- [4_294_968_000, 10_000_000_000_000] do
      c = Data.case!(id) |> Map.put("timeout", timeout)
      assert {:ok, result} = Data.run(c, %{}, {Runtime, nil})
      assert result.provenance.fixture_id == id
    end
  end

  test "worker cancellation releases shared concurrency on the next synchronous admission" do
    table = :ets.new(:cancelled_admission, [:public, :set])
    c = Data.case!("catalog-PL-2024") |> Map.put("timeout", 40)

    assert {:error, %{category: :timeout}} =
             Data.run(c, %{admission: table, sleep_ms: 200}, {Runtime, nil})

    assert_receive {:scraping_fetch, _, worker}
    monitor = Process.monitor(worker)
    assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 300
    assert {:ok, _} = Data.run(Map.delete(c, "timeout"), %{admission: table}, {Runtime, nil})
  end

  defp flush do
    receive do
      {:scraping_fetch, _, _} -> flush()
    after
      0 -> :ok
    end
  end
end
