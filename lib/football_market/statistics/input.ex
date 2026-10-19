defmodule FootballMarket.Statistics.Input do
  @moduledoc false
  alias FootballMarket.Statistics.Error

  @metrics [
    :goals,
    :assists,
    :shots_on_target,
    :tackles,
    :interceptions,
    :saves,
    :goals_conceded,
    :yellow_cards,
    :red_cards
  ]
  @match [:match_identity, :kickoff_at, :season_id, :home_team_id, :away_team_id]
  @performance [:match_id, :player_id, :team_id, :position_id, :minutes_played]
  def metrics, do: @metrics
  def match(attrs), do: validate(attrs, @match, @match)
  def performance(attrs), do: validate(attrs, @performance ++ @metrics, @performance)

  def keys(attrs, allowed) when is_map(attrs) do
    keys = Map.keys(attrs)

    cond do
      not (Enum.all?(keys, &is_atom/1) or Enum.all?(keys, &is_binary/1)) ->
        Error.validation(:attributes, :invalid_shape)

      Enum.any?(keys, fn key -> not Enum.any?(allowed, &(key == &1 or key == to_string(&1))) end) ->
        Error.validation(:attributes, :unsupported_field)

      true ->
        {:ok,
         Map.new(attrs, fn {key, value} ->
           {Enum.find(allowed, &(key == &1 or key == to_string(&1))), value}
         end)}
    end
  end

  def keys(_, _), do: Error.validation(:attributes, :invalid_shape)

  def identifier(value, field) when is_binary(value) do
    case Ecto.UUID.cast(value) do
      {:ok, id} -> {:ok, id}
      _ -> Error.validation(field, :invalid_identifier)
    end
  end

  def identifier(_, field), do: Error.validation(field, :invalid_identifier)

  def instant(value, field) when is_binary(value) do
    if Regex.match?(~r/\.\d{7,}/, value) do
      Error.validation(field, :unsupported_precision)
    else
      case DateTime.from_iso8601(value) do
        {:ok, dt, _} -> canonical(dt, field)
        _ -> Error.validation(field, :invalid_instant)
      end
    end
  end

  def instant(%DateTime{} = value, field), do: canonical(value, field)
  def instant(_, field), do: Error.validation(field, :invalid_instant)

  defp canonical(value, field) do
    try do
      canonical_datetime(value, field)
    rescue
      _ -> Error.validation(field, :invalid_instant)
    end
  end

  defp canonical_datetime(value, field) do
    {micro, precision} = value.microsecond

    if valid_datetime?(value, micro, precision) do
      normalized = %{value | microsecond: {micro, 6}}
      roundtrip_datetime(normalized, field)
    else
      Error.validation(field, :invalid_instant)
    end
  end

  defp valid_datetime?(value, micro, precision) do
    precision in 0..6 and micro in 0..999_999 and value.calendar == Calendar.ISO and
      is_binary(value.time_zone) and is_integer(value.utc_offset) and
      is_integer(value.std_offset) and value.year in 1..9999
  end

  defp roundtrip_datetime(value, field) do
    case value |> DateTime.to_iso8601() |> DateTime.from_iso8601() do
      {:ok, dt, _} ->
        if DateTime.to_unix(dt, :microsecond) == DateTime.to_unix(value, :microsecond),
          do: {:ok, dt},
          else: Error.validation(field, :invalid_instant)

      _ ->
        Error.validation(field, :invalid_instant)
    end
  end

  def identity(value) when is_binary(value) do
    cond do
      not String.valid?(value) or :binary.match(value, <<0>>) != :nomatch ->
        Error.validation(:match_identity, :invalid_identity)

      String.trim(value) == "" ->
        Error.validation(:match_identity, :required)

      true ->
        {:ok, value}
    end
  end

  def identity(_), do: Error.validation(:match_identity, :required)

  def bounds(opts) do
    attrs =
      if is_list(opts) and Keyword.keyword?(opts) and
           length(Keyword.keys(opts)) == length(Enum.uniq(Keyword.keys(opts))),
         do: Map.new(opts),
         else: opts

    with {:ok, attrs} <- keys(attrs, [:from, :to]),
         {:ok, lower} <- bound(attrs[:from], :from),
         {:ok, upper} <- bound(attrs[:to], :to) do
      if lower && upper && DateTime.compare(lower, upper) == :gt,
        do: Error.validation(:interval, :invalid_interval),
        else: {:ok, %{from: lower, to: upper}}
    end
  end

  defp bound(nil, _), do: {:ok, nil}
  defp bound(v, f), do: instant(v, f)

  defp validate(attrs, allowed, required) do
    with {:ok, attrs} <- keys(attrs, allowed) do
      Enum.reduce_while(allowed, {:ok, %{}}, fn field, state ->
        validate_attribute(field, attrs[field], required, state)
      end)
    end
  end

  defp validate_attribute(field, value, required, {:ok, acc}) do
    case validate_value(field, value, required) do
      {:ok, normalized} -> {:cont, {:ok, Map.put(acc, field, normalized)}}
      error -> {:halt, error}
    end
  end

  defp validate_value(field, value, required) do
    case {value, field in required} do
      {nil, true} -> Error.validation(field, :required)
      _ -> validate_nonrequired_value(field, value)
    end
  end

  defp validate_nonrequired_value(field, value)
       when field in @metrics or field == :minutes_played do
    if is_nil(value) or (is_integer(value) and value >= 0),
      do: {:ok, value},
      else: Error.validation(field, :invalid_count)
  end

  defp validate_nonrequired_value(:kickoff_at, value), do: instant(value, :kickoff_at)
  defp validate_nonrequired_value(:match_identity, value), do: identity(value)
  defp validate_nonrequired_value(field, value), do: identifier(value, field)
end
