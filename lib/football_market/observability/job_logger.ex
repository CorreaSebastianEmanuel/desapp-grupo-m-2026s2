defmodule FootballMarket.Observability.JobLogger do
  @moduledoc "Allowlisted Oban transport events, independent of domain outcomes."
  require Logger
  alias FootballMarket.Observability.Context

  @identifiers [
    {"run_id", :run_id},
    {"delivery_id", :delivery_id},
    {"intent_id", :intent_id},
    {"request_id", :calculation_request_id}
  ]

  def handle_event([:oban, :job, :start], _, %{job: %Oban.Job{} = job}, _) do
    Process.put({__MODULE__, job.id}, Logger.metadata())
    Context.put(metadata(job))
    Logger.info("Job delivery started", event: "job.start", execution_state: :executing)
  end

  def handle_event([:oban, :job, event], measures, %{job: %Oban.Job{} = job} = meta, _)
      when event in [:stop, :exception] and is_map(measures) do
    previous = Process.delete({__MODULE__, job.id})

    try do
      Context.with_context(metadata(job), fn ->
        Logger.log(if(event == :exception, do: :error, else: :info), "Job delivery finished",
          event: "job.#{event}",
          execution_state: state(meta[:state]),
          duration_ms: milliseconds(measures[:duration]),
          queue_time_ms: milliseconds(measures[:queue_time]),
          error_kind: kind(meta[:kind])
        )
      end)
    after
      if previous, do: Logger.reset_metadata(previous)
    end
  end

  def handle_event(_, _, _, _), do: :ok

  defp metadata(job) do
    args = if is_map(job.args), do: job.args, else: %{}
    meta = if is_map(job.meta), do: job.meta, else: %{}

    identifiers =
      for {argument, key} <- @identifiers,
          {:ok, id} <- [Ecto.UUID.cast(Map.get(args, argument))],
          do: {key, id}

    fallback = Keyword.get(identifiers, :run_id) || List.first(Keyword.values(identifiers))
    correlation = Context.id(meta["correlation_id"], fallback || "oban:#{job.id}")

    [
      correlation_id: correlation,
      job_id: job.id,
      worker: job.worker,
      queue: job.queue,
      attempt: job.attempt,
      max_attempts: job.max_attempts
    ] ++ identifiers
  end

  defp milliseconds(value) when is_integer(value),
    do: System.convert_time_unit(max(value, 0), :native, :millisecond)

  defp milliseconds(_), do: nil
  defp kind(value) when value in [:error, :exit, :throw], do: value
  defp kind(_), do: nil

  defp state(value) when value in [:success, :failure, :cancelled, :discard, :snoozed],
    do: value

  defp state(_), do: :unknown
end
