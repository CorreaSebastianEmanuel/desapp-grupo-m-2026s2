defmodule FootballMarket.Providers.FootballData.Errors do
  @moduledoc "Numeric failure categories and known future waits; source messages are ignored."
  def response(response, context) do
    category = category(response.status)

    if category == :rate_limited do
      %{
        category: category,
        retry_after_ms: delay(Map.get(response, :headers, []), context, response)
      }
    else
      %{category: category}
    end
  end

  def category(status) when status in [401, 403], do: :authentication_failed
  def category(status) when status in [404, 410], do: :not_found
  def category(429), do: :rate_limited
  def category(status) when status in 300..399 or status in 500..599, do: :unavailable
  def category(_), do: :invalid_response

  def delay(headers, context, receipt \\ %{}) do
    try do
      {runtime, state} = context.runtime
      received = Map.get(receipt, :received_us)
      utc = Map.get(receipt, :received_utc)
      now = runtime.now_us(state)
      true = is_integer(received) and received <= now
      true = match?(%DateTime{utc_offset: 0, std_offset: 0}, utc)
      preferred = values(headers, "retry-after")
      reset = values(headers, "x-requestcounter-reset")

      if length(preferred) > 1 or length(reset) > 1 do
        nil
      else
        wait_us = parse(List.first(preferred), utc) || seconds(List.first(reset))

        if wait_us do
          expiry = received + wait_us

          if is_function(context[:record_retry_not_before], 1),
            do: context.record_retry_not_before.(expiry)

          remaining = div(max(expiry - runtime.now_us(state), 0), 1000)
          if remaining > 0, do: remaining, else: nil
        end
      end
    rescue
      _ -> nil
    catch
      _, _ -> nil
    end
  end

  defp values(headers, name),
    do: for({key, value} <- headers, is_binary(key) and String.downcase(key) == name, do: value)

  defp seconds(value) when is_binary(value) do
    if Regex.match?(~r/^[0-9]+$/, value) do
      result = String.to_integer(value) * 1_000_000
      if result > 0, do: result, else: nil
    end
  end

  defp seconds(_), do: nil
  defp parse(nil, _), do: nil

  defp parse(value, utc) do
    seconds(value) || date(value, utc)
  end

  defp date(value, utc) do
    case :httpd_util.convert_request_date(String.to_charlist(value)) do
      {{year, month, day}, {hour, minute, second}} ->
        {:ok, date} = Date.new(year, month, day)
        {:ok, time} = Time.new(hour, minute, second)
        {:ok, instant} = DateTime.new(date, time, "Etc/UTC")
        difference = DateTime.diff(instant, utc, :microsecond)
        if difference > 0, do: difference, else: nil

      _ ->
        nil
    end
  rescue
    _ -> nil
  end
end
