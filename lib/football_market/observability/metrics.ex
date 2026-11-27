defmodule FootballMarket.Observability.Metrics do
  @moduledoc false
  use GenServer

  @table :football_market_prometheus_metrics
  @duration_buckets [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]
  @bucket_labels Enum.map(@duration_buckets, &Float.to_string/1) ++ ["+Inf"]
  @count_index length(@bucket_labels)
  @sum_index @count_index + 1
  @empty_histogram List.duplicate(0, @sum_index)
  @queues ~w(catalog_sync catalog_scout statistics_import quote_calculation conditional_orders)
  @outcomes ~w(success failure cancelled discard snoozed)
  @providers ~w(football_data_org fotmob_public_html)
  @provider_operations ~w(catalog player_search player_profile match_details)
  @provider_outcomes ~w(success rate_limited access_refused unavailable timeout invalid_response missing_configuration invalid_request transport_error unexpected_failure other_failure)
  @ranking_cache_outcomes ~w(hit miss error)

  @families [
    {"football_market_http_requests_total", "Completed HTTP requests", :counter,
     ["route", "status_class"]},
    {"football_market_http_errors_total", "HTTP requests with error status classes", :counter,
     ["route", "status_class"]},
    {"football_market_http_request_duration_seconds", "HTTP request duration in seconds",
     :histogram, ["route", "status_class"]},
    {"football_market_repo_query_duration_seconds", "Repo query duration in seconds", :histogram,
     []},
    {"football_market_vm_memory_bytes", "Total BEAM memory in bytes", :gauge, []},
    {"football_market_vm_run_queue_length", "BEAM run queue length", :gauge, ["kind"]},
    {"football_market_oban_jobs_total", "Completed Oban jobs", :counter, ["queue", "outcome"]},
    {"football_market_oban_job_duration_seconds", "Oban job execution duration in seconds",
     :histogram, ["queue", "outcome"]},
    {"football_market_provider_requests_total", "External provider requests", :counter,
     ["provider", "operation", "outcome"]},
    {"football_market_provider_request_duration_seconds",
     "External provider request duration in seconds", :histogram,
     ["provider", "operation", "outcome"]},
    {"football_market_ranking_cache_total", "Active-strategy ranking cache lookups", :counter,
     ["outcome"]}
  ]

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, :ok, Keyword.put(opts, :name, __MODULE__))

  @impl true
  def init(:ok) do
    :ets.new(@table, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    :ok =
      :telemetry.attach_many(
        "football-market-prometheus-metrics",
        [
          [:football_market, :http, :request],
          [:football_market, :repo, :query],
          [:vm, :memory],
          [:vm, :total_run_queue_lengths],
          [:oban, :job, :stop],
          [:oban, :job, :exception],
          [:football_market, :provider, :request],
          [:football_market, :ranking, :cache, :hit],
          [:football_market, :ranking, :cache, :miss],
          [:football_market, :ranking, :cache, :error]
        ],
        &__MODULE__.handle_event/4,
        nil
      )

    {:ok, :ok}
  end

  @impl true
  def terminate(_reason, _state) do
    :telemetry.detach("football-market-prometheus-metrics")
    :ok
  end

  def handle_event([:football_market, :http, :request], %{duration: duration}, metadata, _config) do
    labels = [metadata.route, metadata.status_class]
    increment("football_market_http_requests_total", labels)

    if metadata.status_class in ["4xx", "5xx"],
      do: increment("football_market_http_errors_total", labels)

    observe("football_market_http_request_duration_seconds", duration, labels)
  end

  def handle_event([:football_market, :repo, :query], %{query_time: duration}, _metadata, _config)
      when is_integer(duration) and duration >= 0 do
    observe("football_market_repo_query_duration_seconds", duration, [])
  end

  def handle_event([:vm, :memory], %{total: total}, _metadata, _config) when is_number(total) do
    gauge("football_market_vm_memory_bytes", [], total)
  end

  def handle_event([:vm, :total_run_queue_lengths], measurements, _metadata, _config) do
    for kind <- [:total, :cpu, :io], is_number(measurements[kind]) do
      gauge("football_market_vm_run_queue_length", [Atom.to_string(kind)], measurements[kind])
    end
  end

  def handle_event([:oban, :job, event], %{duration: duration}, %{job: job} = metadata, _config)
      when event in [:stop, :exception] and is_integer(duration) and duration >= 0 do
    queue = bounded(@queues, job.queue)

    state =
      if event == :exception,
        do: "failure",
        else: bounded(@outcomes, metadata[:state])

    labels = [queue, state]
    increment("football_market_oban_jobs_total", labels)
    observe("football_market_oban_job_duration_seconds", duration, labels)
  end

  def handle_event(
        [:football_market, :provider, :request],
        %{duration: duration},
        metadata,
        _config
      )
      when is_integer(duration) and duration >= 0 do
    labels = [
      bounded(@providers, metadata[:provider]),
      bounded(@provider_operations, metadata[:operation]),
      bounded(@provider_outcomes, metadata[:outcome])
    ]

    increment("football_market_provider_requests_total", labels)
    observe("football_market_provider_request_duration_seconds", duration, labels)
  end

  def handle_event([:football_market, :ranking, :cache, outcome], %{count: count}, _metadata, _)
      when is_integer(count) and count > 0 do
    increment("football_market_ranking_cache_total", [bounded(@ranking_cache_outcomes, outcome)])
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok

  def families, do: @families

  def scrape do
    rows = :ets.tab2list(@table)

    Enum.map_join(families(), "", fn {name, help, type, label_names} ->
      header = "# HELP #{name} #{help}\n# TYPE #{name} #{type}\n"
      header <> render_family(name, type, label_names, rows)
    end)
  end

  defp render_family(name, :histogram, labels, rows) do
    rows
    |> Enum.flat_map(fn row ->
      case elem(row, 0) do
        {^name, values, :histogram} -> [{values, row}]
        _ -> []
      end
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("", fn {values, row} ->
      bucket_lines =
        @bucket_labels
        |> Enum.with_index(1)
        |> Enum.map_join("", fn {bound, index} ->
          labels_text = labels_text(labels ++ ["le"], values ++ [bound])
          "#{name}_bucket#{labels_text} #{elem(row, index)}\n"
        end)

      count = elem(row, @count_index)
      sum = row |> elem(@sum_index) |> native_seconds()

      bucket_lines <>
        "#{name}_count#{labels_text(labels, values)} #{count}\n" <>
        "#{name}_sum#{labels_text(labels, values)} #{sum}\n"
    end)
  end

  defp render_family(name, _type, labels, rows) do
    rows
    |> Enum.filter(fn
      {{family, _values, :value}, _value} -> family == name
      _ -> false
    end)
    |> Enum.sort_by(fn {{_family, values, _part}, _value} -> values end)
    |> Enum.map_join("", fn {{_family, values, :value}, value} ->
      "#{name}#{labels_text(labels, values)} #{value}\n"
    end)
  end

  defp labels_text([], []), do: ""

  defp labels_text(names, values) do
    rendered =
      Enum.zip(names, values)
      |> Enum.map_join(",", fn {name, value} -> ~s(#{name}="#{escape(value)}") end)

    "{" <> rendered <> "}"
  end

  defp escape(value),
    do:
      value
      |> to_string()
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> String.replace("\n", "\\n")

  defp increment(name, labels),
    do: :ets.update_counter(@table, {name, labels, :value}, {2, 1}, {{name, labels, :value}, 0})

  defp gauge(name, labels, value), do: :ets.insert(@table, {{name, labels, :value}, value})

  defp observe(name, duration, labels) do
    seconds = native_seconds(duration)
    key = {name, labels, :histogram}

    # ETS updates all positions together. The final bucket is also the observation count.
    finite_buckets =
      for {bound, position} <- Enum.with_index(@duration_buckets, 2), seconds <= bound do
        {position, 1}
      end

    updates = [{@count_index + 1, 1}, {@sum_index + 1, duration} | finite_buckets]
    :ets.update_counter(@table, key, updates, List.to_tuple([key | @empty_histogram]))
  end

  defp native_seconds(duration), do: duration / System.convert_time_unit(1, :second, :native)

  defp bounded(allowed, value) do
    label = to_string(value)
    if label in allowed, do: label, else: "other"
  end
end
