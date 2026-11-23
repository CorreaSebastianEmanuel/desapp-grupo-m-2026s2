defmodule FootballMarket.RankingBenchmarkHelpersTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  Code.require_file("../../scripts/ranking_benchmark_helpers.exs", __DIR__)

  test "concurrent workload elapsed time is distinct from cumulative request latency" do
    counter = :atomics.new(2, [])

    measurement =
      RankingBenchmarkHelpers.measure_reads(
        fn ->
          Process.sleep(20)
          {:ok, %{entries: [:entry]}}
        end,
        counter,
        clients: 8,
        reads_per_client: 2,
        expected_entries: 1
      )

    assert measurement.count == 16
    assert measurement.workload_elapsed_us > 0
    assert measurement.cumulative_request_latency_us > measurement.workload_elapsed_us
    assert measurement.p50_us >= 15_000
    assert measurement.p95_us >= measurement.p50_us
  end
end
