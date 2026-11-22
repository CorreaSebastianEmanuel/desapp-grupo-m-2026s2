defmodule FootballMarket.Observability do
  @moduledoc """
  Structured JSON logging, correlation IDs, and telemetry subscriptions.

  Every HTTP request and Oban background job gets a `correlation_id` attached
  to Elixir's Logger metadata so all log lines for one operation can be traced
  together.
  """

  require Logger

  @context_keys ~w(
    correlation_id request_id job_id worker queue attempt max_attempts
    run_id delivery_id intent_id calculation_request_id
  )a

  @subscriptions [
    {FootballMarketWeb.RequestLogger,
     [[:phoenix, :endpoint, :start], [:phoenix, :endpoint, :stop], [:phoenix, :error_rendered]]},
    {__MODULE__, [[:oban, :job, :start], [:oban, :job, :stop], [:oban, :job, :exception]]}
  ]

  @doc "Attaches HTTP request and Oban job telemetry handlers on application boot."
  def attach do
    Enum.each(@subscriptions, fn {module, events} ->
      case :telemetry.attach_many({__MODULE__, module}, events, &module.handle_event/4, nil) do
        :ok -> :ok
        {:error, :already_exists} -> :ok
      end
    end)
  end

  @doc "Detaches telemetry handlers on application stop."
  def detach do
    Enum.each(@subscriptions, fn {module, _events} -> :telemetry.detach({__MODULE__, module}) end)
  end

  @doc "Returns the current correlation ID from Logger metadata (or generates a new UUID)."
  def current do
    metadata = Logger.metadata()
    id(metadata[:correlation_id], metadata[:request_id])
  end

  @doc "Picks the first valid correlation ID or generates a fresh UUID."
  def id(value, fallback \\ nil) do
    cond do
      valid?(value) -> value
      valid?(fallback) -> fallback
      true -> Ecto.UUID.generate()
    end
  end

  def valid?(value) when is_binary(value) and byte_size(value) in 1..200,
    do: String.valid?(value) and :binary.match(value, <<0>>) == :nomatch

  def valid?(_), do: false

  @doc "Replaces observability keys in the current process's Logger metadata."
  def put(metadata) do
    Logger.reset_metadata(Keyword.merge(Keyword.drop(Logger.metadata(), @context_keys), metadata))
  end

  @doc "Runs `fun` with temporary Logger metadata and restores the previous metadata afterwards."
  def with_context(metadata, fun) do
    previous = Logger.metadata()

    try do
      put(metadata)
      fun.()
    after
      Logger.reset_metadata(previous)
    end
  end

  # --- Oban Telemetry Callbacks ---

  def handle_event([:oban, :job, :start], _, %{job: %Oban.Job{} = job}, _) do
    Process.put({__MODULE__, job.id}, Logger.metadata())
    put(job_metadata(job))
    Logger.info("Job delivery started", event: "job.start", execution_state: :executing)
  end

  def handle_event([:oban, :job, event], measures, %{job: %Oban.Job{} = job} = meta, _)
      when event in [:stop, :exception] and is_map(measures) do
    previous = Process.delete({__MODULE__, job.id})

    try do
      with_context(job_metadata(job), fn ->
        level = if event == :exception, do: :error, else: :info

        Logger.log(level, "Job delivery finished",
          event: "job.#{event}",
          execution_state: job_state(meta[:state]),
          duration_ms: to_milliseconds(measures[:duration]),
          queue_time_ms: to_milliseconds(measures[:queue_time]),
          error_kind: error_kind(meta[:kind])
        )
      end)
    after
      if previous, do: Logger.reset_metadata(previous)
    end
  end

  def handle_event(_, _, _, _), do: :ok

  defp job_metadata(job) do
    meta = if is_map(job.meta), do: job.meta, else: %{}

    [
      correlation_id: id(meta["correlation_id"], "oban:#{job.id}"),
      job_id: job.id,
      worker: job.worker,
      queue: job.queue,
      attempt: job.attempt,
      max_attempts: job.max_attempts
    ]
  end

  defp to_milliseconds(value) when is_integer(value),
    do: System.convert_time_unit(max(value, 0), :native, :millisecond)

  defp to_milliseconds(_), do: nil

  defp error_kind(value) when value in [:error, :exit, :throw], do: value
  defp error_kind(_), do: nil

  defp job_state(value) when value in [:success, :failure, :cancelled, :discard, :snoozed],
    do: value

  defp job_state(_), do: :unknown
end

defmodule FootballMarket.Observability.JSONFormatter do
  @moduledoc "Structured JSON-line Logger formatter configured in `config/runtime.exs`."

  @fields ~w(
    actor_id event correlation_id request_id method route status duration_ms
    queue_time_ms job_id worker queue attempt max_attempts execution_state
    error_kind run_id delivery_id intent_id calculation_request_id
  )a

  def options do
    [
      format: {__MODULE__, :format},
      metadata: [:parameters | @fields],
      utc_log: true,
      colors: [enabled: false]
    ]
  end

  def format(level, message, {date, time}, metadata) do
    timestamp =
      IO.iodata_to_binary([
        Logger.Formatter.format_date(date),
        "T",
        Logger.Formatter.format_time(time),
        "Z"
      ])

    fields =
      for {key, value} <- metadata, key in @fields, scalar?(value), into: %{} do
        {key, normalize(value)}
      end

    fields =
      case Keyword.fetch(metadata, :parameters) do
        {:ok, parameters} when is_map(parameters) -> Map.put(fields, :parameters, parameters)
        _ -> fields
      end

    record =
      Map.merge(fields, %{
        timestamp: timestamp,
        level: Atom.to_string(level),
        message: message |> Logger.Formatter.prune() |> IO.chardata_to_string()
      })

    [Jason.encode_to_iodata!(record), "\n"]
  end

  defp scalar?(value),
    do: is_binary(value) or is_atom(value) or is_integer(value) or is_float(value)

  defp normalize(value) when is_binary(value), do: Logger.Formatter.prune(value)
  defp normalize(value), do: value
end
