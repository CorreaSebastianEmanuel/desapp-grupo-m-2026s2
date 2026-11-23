defmodule RankingBenchmarkHelpers do
  def timed(fun) do
    started = System.monotonic_time(:microsecond)
    result = fun.()
    {System.monotonic_time(:microsecond) - started, result}
  end

  def percentile(sorted, percentile) do
    index = max(ceil(length(sorted) * percentile / 100) - 1, 0)
    Enum.at(sorted, index)
  end

  def git_revision do
    case System.cmd("git", ["rev-parse", "--short", "HEAD"], stderr_to_stdout: true) do
      {revision, 0} -> String.trim(revision)
      _ -> "unknown"
    end
  end

  def measure_reads(read_fun, counter, opts \\ []) do
    clients = Keyword.get(opts, :clients, 10)
    reads_per_client = Keyword.get(opts, :reads_per_client, 100)
    expected_entries = Keyword.get(opts, :expected_entries, 100)

    :atomics.put(counter, 1, 0)
    :atomics.put(counter, 2, 0)

    started = System.monotonic_time(:microsecond)

    latencies =
      1..clients
      |> Task.async_stream(
        fn _client ->
          Enum.map(1..reads_per_client, fn _read ->
            {elapsed_us, {:ok, result}} = timed(read_fun)

            unless length(result.entries) == expected_entries,
              do: Mix.raise("ranking result changed")

            elapsed_us
          end)
        end,
        max_concurrency: clients,
        timeout: 120_000,
        ordered: false
      )
      |> Enum.flat_map(fn
        {:ok, reads} -> reads
        {:exit, reason} -> Mix.raise("benchmark client failed: #{inspect(reason)}")
      end)

    workload_elapsed_us = System.monotonic_time(:microsecond) - started
    sorted = Enum.sort(latencies)

    %{
      count: length(latencies),
      workload_elapsed_us: workload_elapsed_us,
      cumulative_request_latency_us: Enum.sum(latencies),
      p50_us: percentile(sorted, 50),
      p95_us: percentile(sorted, 95),
      ranking_sql_statements: :atomics.get(counter, 1),
      ranking_aggregation_statements: :atomics.get(counter, 2)
    }
  end

  def print_measurement(label, values) do
    IO.puts(
      "#{label}: reads=#{values.count} workload_elapsed_us=#{values.workload_elapsed_us} cumulative_request_latency_us=#{values.cumulative_request_latency_us} p50_us=#{values.p50_us} p95_us=#{values.p95_us} ranking_sql_statements=#{values.ranking_sql_statements} ranking_aggregation_statements=#{values.ranking_aggregation_statements}"
    )
  end
end
