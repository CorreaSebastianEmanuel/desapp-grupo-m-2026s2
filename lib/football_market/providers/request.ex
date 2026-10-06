defmodule FootballMarket.Providers.Request do
  @moduledoc "Fixed-vocabulary request normalization before source work."
  alias FootballMarket.Providers.Instant
  defstruct [:operation, :scope, :timeout_ms]
  @type t :: %__MODULE__{operation: atom(), scope: map(), timeout_ms: pos_integer()}
  @leagues %{
    "PL" => "Premier League",
    "BL1" => "Bundesliga",
    "PD" => "La Liga",
    "SA" => "Serie A",
    "FL1" => "Ligue 1"
  }
  def leagues, do: @leagues

  def normalize(operation, input) do
    with {:ok, values} <- keys(operation, input),
         {:ok, scope} <- scope(values),
         {:ok, bounds} <- bounds(operation, values) do
      scope = Map.merge(scope, bounds)
      timeout = Map.get(values, :timeout_ms, 5000)

      if is_integer(timeout) and timeout > 0 do
        {:ok, %__MODULE__{operation: operation, scope: scope, timeout_ms: timeout}}
      else
        {:error, :timeout_ms, scope}
      end
    end
  end

  def scope(values) when is_map(values) do
    league = Map.get(values, :league_code)
    start = Map.get(values, :start_year)
    ending = Map.get(values, :end_year)

    code =
      if is_binary(league) and String.valid?(league),
        do: league |> String.trim() |> String.upcase(),
        else: nil

    cond do
      not Map.has_key?(@leagues, code) -> {:error, :league_code}
      not is_integer(start) -> {:error, :start_year}
      not is_integer(ending) or ending not in [start, start + 1] -> {:error, :end_year}
      true -> {:ok, %{league_code: code, start_year: start, end_year: ending}}
    end
  end

  def scope(_), do: {:error, :scope}

  def vocabulary?(positions) when is_map(positions) and map_size(positions) > 0 do
    Enum.all?(positions, fn {code, name} ->
      plain?(code) and plain?(name) and String.trim(code) == code and String.trim(name) == name
    end) and
      unique?(Map.keys(positions)) and unique?(Map.values(positions))
  end

  def vocabulary?(_), do: false
  defp plain?(v), do: FootballMarket.Providers.Provenance.safe_text?(v)
  defp unique?(xs), do: length(xs) == length(Enum.uniq_by(xs, &String.downcase/1))

  defp keys(operation, input) when is_map(input) do
    allowed =
      [:league_code, :start_year, :end_year, :timeout_ms] ++
        if(operation == :performances, do: [:from, :to], else: [])

    ks = Map.keys(input)

    cond do
      Enum.all?(ks, &(&1 in allowed)) ->
        {:ok, input}

      Enum.all?(ks, &(&1 in Enum.map(allowed, fn k -> Atom.to_string(k) end))) ->
        {:ok,
         Map.new(input, fn {k, v} -> {Enum.find(allowed, &(Atom.to_string(&1) == k)), v} end)}

      true ->
        {:error, :request}
    end
  end

  defp keys(_, _), do: {:error, :request}
  defp bounds(:catalog, _), do: {:ok, %{}}

  defp bounds(:performances, input) do
    with {:ok, from} <- bound(input, :from), {:ok, to} <- bound(input, :to) do
      if from && to && DateTime.compare(from, to) == :gt,
        do: {:error, :interval},
        else: {:ok, %{from: from, to: to}}
    end
  end

  defp bound(input, key) do
    case Map.get(input, key) do
      nil ->
        {:ok, nil}

      value ->
        case Instant.normalize(value) do
          {:ok, instant} -> {:ok, instant}
          _ -> {:error, key}
        end
    end
  end
end
