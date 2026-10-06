defmodule FootballMarket.Providers.Instant do
  @moduledoc "Lossless explicit instants normalized to UTC microseconds."
  def normalize(%DateTime{} = value) do
    try do
      {micro, precision} = value.microsecond

      valid =
        precision in 0..6 and micro in 0..999_999 and value.calendar == Calendar.ISO and
          is_binary(value.time_zone) and is_integer(value.utc_offset) and
          is_integer(value.std_offset) and value.year in 1..9999

      if valid do
        value = %{value | microsecond: {micro, 6}}

        case DateTime.from_iso8601(DateTime.to_iso8601(value)) do
          {:ok, parsed, _} ->
            if DateTime.to_unix(parsed, :microsecond) == DateTime.to_unix(value, :microsecond),
              do:
                {:ok, DateTime.from_unix!(DateTime.to_unix(parsed, :microsecond), :microsecond)},
              else: :error

          _ ->
            :error
        end
      else
        :error
      end
    rescue
      _ -> :error
    end
  end

  def normalize(value) when is_binary(value) do
    if String.valid?(value) and not Regex.match?(~r/\.\d{7,}/, value) do
      case DateTime.from_iso8601(value) do
        {:ok, datetime, _} -> normalize(datetime)
        _ -> :error
      end
    else
      :error
    end
  end

  def normalize(_), do: :error
end
