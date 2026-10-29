defmodule FootballMarket.Market.Analytics.Input do
  @moduledoc false

  def decode(query) do
    pairs = Enum.to_list(URI.query_decoder(query))

    with {:ok, from} <- date(pairs, "from"),
         {:ok, to} <- date(pairs, "to") do
      {:ok, %{from: from, to: to}}
    end
  rescue
    _ in [ArgumentError] -> {:error, :invalid_date}
  end

  def range(options, today) when is_map(options) do
    to = Map.get(options, :to) || today

    if valid_date?(to) do
      from = Map.get(options, :from) || Date.add(to, -29)
      validate_range(from, to, today)
    else
      {:error, :invalid_date}
    end
  end

  def range(_, _), do: {:error, :invalid_date}

  defp date(pairs, key) do
    selected =
      Enum.filter(pairs, fn {name, _} -> name == key or String.starts_with?(name, key <> "[") end)

    case selected do
      [] -> {:ok, nil}
      [{^key, value}] -> parse(value)
      _ -> {:error, :invalid_date}
    end
  end

  defp parse(value) do
    with true <- Regex.match?(~r/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/, value),
         {:ok, date} <- Date.from_iso8601(value),
         true <- valid_date?(date) do
      {:ok, date}
    else
      _ -> {:error, :invalid_date}
    end
  end

  defp valid_date?(%Date{calendar: Calendar.ISO, year: year}), do: year in 1..9999
  defp valid_date?(_), do: false

  defp validate_range(from, to, today) do
    cond do
      not valid_date?(from) -> {:error, :invalid_date}
      Date.compare(to, today) == :gt -> {:error, :invalid_date_range}
      Date.diff(to, from) not in 0..365 -> {:error, :invalid_date_range}
      true -> {:ok, %{from: from, to: to}}
    end
  end
end
