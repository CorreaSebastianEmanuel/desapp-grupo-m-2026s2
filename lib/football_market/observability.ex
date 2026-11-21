defmodule FootballMarket.Observability do
  @moduledoc """
  Structured logging, telemetry lifecycle subscriptions, and correlation context.

  Owns:
    * Telemetry attach/detach (`attach/0`, `detach/0`) for HTTP & Oban job events
    * Scoped Logger metadata helpers (`keys/0`, `capture/0`, `current/0`, `id/2`,
      `valid?/1`, `put/1`, `with_context/2`)
    * Oban job telemetry handler (`handle_event/4`)
    * `Observability.JobContext` — database correlation lookup for Oban jobs
    * `Observability.JSONFormatter` — structured JSON line Logger formatter
  """

  require Logger

  @context_keys ~w(
    correlation_id request_id job_id worker queue attempt max_attempts
    run_id delivery_id intent_id calculation_request_id
  )a

  @job_identifiers [
    {"run_id", :run_id},
    {"delivery_id", :delivery_id},
    {"intent_id", :intent_id},
    {"request_id", :calculation_request_id}
  ]

  @subscriptions [
    {FootballMarketWeb.RequestLogger,
     [[:phoenix, :endpoint, :start], [:phoenix, :endpoint, :stop], [:phoenix, :error_rendered]]},
    {__MODULE__, [[:oban, :job, :start], [:oban, :job, :stop], [:oban, :job, :exception]]}
  ]

  # --- Telemetry Lifecycle ---

  def attach do
    Enum.each(@subscriptions, fn {module, events} ->
      case :telemetry.attach_many({__MODULE__, module}, events, &module.handle_event/4, nil) do
        :ok -> :ok
        {:error, :already_exists} -> :ok
      end
    end)
  end

  def detach do
    Enum.each(@subscriptions, fn {module, _events} -> :telemetry.detach({__MODULE__, module}) end)
  end

  # --- Logging Correlation Context ---

  def keys, do: @context_keys
  def capture, do: Keyword.take(Logger.metadata(), @context_keys)

  def current do
    metadata = Logger.metadata()
    id(metadata[:correlation_id], metadata[:request_id])
  end

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

  def put(metadata) do
    Logger.reset_metadata(Keyword.merge(Keyword.drop(Logger.metadata(), @context_keys), metadata))
  end

  def with_context(metadata, fun) do
    previous = Logger.metadata()

    try do
      put(metadata)
      fun.()
    after
      Logger.reset_metadata(previous)
    end
  end

  # --- Oban Job Telemetry Handler ---

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
        Logger.log(if(event == :exception, do: :error, else: :info), "Job delivery finished",
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
    args = if is_map(job.args), do: job.args, else: %{}
    meta = if is_map(job.meta), do: job.meta, else: %{}

    identifiers =
      for {argument, key} <- @job_identifiers,
          {:ok, uuid} <- [Ecto.UUID.cast(Map.get(args, argument))],
          do: {key, uuid}

    fallback = Keyword.get(identifiers, :run_id) || List.first(Keyword.values(identifiers))
    correlation = id(meta["correlation_id"], fallback || "oban:#{job.id}")

    [
      correlation_id: correlation,
      job_id: job.id,
      worker: job.worker,
      queue: job.queue,
      attempt: job.attempt,
      max_attempts: job.max_attempts
    ] ++ identifiers
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

defmodule FootballMarket.Observability.Context do
  @moduledoc false
  defdelegate current(), to: FootballMarket.Observability
end

defmodule FootballMarket.Observability.JobContext do
  @moduledoc "Durable logging lineage adapter, kept out of telemetry callbacks."
  import Ecto.Query
  alias FootballMarket.Observability
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.{CalculationIntent, Check}
  alias FootballMarket.Synchronization.Run

  def for_run(run), do: Observability.id(run.correlation_id, run.id)

  def annotate(changeset, correlation_id) do
    meta = Ecto.Changeset.get_field(changeset, :meta) || %{}
    Ecto.Changeset.put_change(changeset, :meta, Map.put(meta, "correlation_id", correlation_id))
  end

  def for_intents([]), do: %{}

  def for_intents(ids) do
    from(i in CalculationIntent,
      left_join: c in Check,
      on: c.id == i.accepted_check_id,
      left_join: r in Run,
      on: r.id == c.run_id,
      where: i.id in ^ids,
      select: {i.id, r.correlation_id, r.id}
    )
    |> load_contexts()
  end

  def for_calculations([]), do: %{}

  def for_calculations(ids) do
    from(q in CalculationRequest,
      left_join: i in CalculationIntent,
      on: i.id == q.intent_id,
      left_join: c in Check,
      on: c.id == i.accepted_check_id,
      left_join: r in Run,
      on: r.id == c.run_id,
      where: q.id in ^ids,
      select: {q.id, r.correlation_id, r.id}
    )
    |> load_contexts()
  end

  defp load_contexts(query) do
    query
    |> Repo.all()
    |> Map.new(fn {id, correlation, run_id} ->
      {id, Observability.id(correlation, run_id || id)}
    end)
  rescue
    _ -> %{}
  end
end

defmodule FootballMarket.Observability.JSONFormatter do
  @moduledoc "Structured JSON line Logger formatter configured in `config/runtime.exs`."

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
