defmodule FootballMarket.Observability.JSONFormatter do
  @moduledoc "JSON lines using Logger's existing report conversion and truncation."

  @fields ~w(actor_id event correlation_id request_id method route status duration_ms queue_time_ms job_id worker queue attempt max_attempts execution_state error_kind run_id delivery_id intent_id calculation_request_id)a

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
