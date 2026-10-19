defmodule FootballMarket.Valuation.Request do
  @moduledoc false
  alias FootballMarket.Valuation.{Error, Week, DecimalMath, Evidence}

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
  @scopes [:overall, :goalkeeper, :defender, :midfielder, :forward]
  @keys [
    :player_id,
    :season_id,
    :week_start,
    :week_end,
    :requirements,
    :references,
    :position_mapping
  ]
  defstruct @keys
  def metrics, do: @metrics
  def scopes, do: @scopes
  def validate(%__MODULE__{} = request), do: validate(Map.from_struct(request))

  def validate(request) when is_map(request) and not is_struct(request) do
    if Enum.sort(Map.keys(request)) != Enum.sort(@keys) do
      Error.new(:validation, :invalid_request_keys, [:request])
    else
      with {:ok, player} <- identifier(request.player_id, :player_id),
           {:ok, season} <- identifier(request.season_id, :season_id),
           {:ok, {a, b}} <- Week.validate(request.week_start, request.week_end),
           {:ok, requirements} <- requirements(request.requirements),
           :ok <- references(request.references, requirements),
           {:ok, mapping} <- mapping(request.position_mapping) do
        {:ok,
         struct!(__MODULE__, %{
           request
           | player_id: player,
             season_id: season,
             week_start: a,
             week_end: b,
             requirements: requirements,
             references: FootballMarket.Valuation.Evidence.normalize_config(request.references),
             position_mapping: mapping
         })}
      end
    end
  end

  def validate(_), do: Error.new(:validation, :invalid_request, [:request])

  @doc "Validate a managed calculation's subject and explicit UTC week without football reads."
  def subject_week(s) when is_map(s) and not is_struct(s) do
    if Enum.sort(Map.keys(s)) == Enum.sort([:player_id, :season_id, :week_start, :week_end]) do
      with {:ok, player} <- identifier(s.player_id, :player_id),
           {:ok, season} <- identifier(s.season_id, :season_id),
           {:ok, {a, b}} <- Week.validate(s.week_start, s.week_end) do
        {:ok, %{s | player_id: player, season_id: season, week_start: a, week_end: b}}
      end
    else
      Error.new(:validation, :invalid_request_keys, [:request])
    end
  end

  def subject_week(_), do: Error.new(:validation, :invalid_request, [:request])

  @doc "Validate reusable rule fields; preserves the explicit helper's empty-mapping behavior."
  def rule_fields(required, refs, pairs) do
    with {:ok, requirements} <- requirements(required),
         :ok <- references(refs, requirements),
         {:ok, position_mapping} <- mapping(pairs) do
      {:ok,
       %{
         requirements: requirements,
         references: Evidence.normalize_config(refs),
         position_mapping: position_mapping
       }}
    end
  end

  defp identifier(id, field) do
    case FootballMarket.Statistics.Input.identifier(id, field) do
      {:ok, canonical} -> {:ok, canonical}
      _ -> Error.new(:validation, :invalid_identifier, [field])
    end
  end

  def requirements(r) when is_map(r) and not is_struct(r) and map_size(r) > 0 do
    valid =
      Enum.all?(r, fn {scope, metrics} ->
        scope in @scopes and Evidence.proper_list?(metrics) and metrics != [] and
          Enum.all?(metrics, &(&1 in @metrics)) and length(Enum.uniq(metrics)) == length(metrics)
      end)

    if valid,
      do: {:ok, Map.new(r, fn {s, m} -> {s, Enum.filter(@metrics, &(&1 in m))} end)},
      else: Error.new(:validation, :invalid_requirements, [:requirements])
  end

  def requirements(_), do: Error.new(:validation, :invalid_requirements, [:requirements])

  defp references(r, requirements) when is_map(r) and not is_struct(r) do
    needed = requirements |> Map.values() |> List.flatten() |> Enum.uniq() |> Enum.sort()

    if Enum.sort(Map.keys(r)) == needed and Enum.all?(Map.values(r), &DecimalMath.positive?/1),
      do: :ok,
      else: Error.new(:validation, :invalid_references, [:references])
  end

  defp references(_, _), do: Error.new(:validation, :invalid_references, [:references])

  defp mapping(pairs) when is_list(pairs) do
    if Evidence.proper_list?(pairs),
      do: mapping_pairs(pairs),
      else: Error.new(:validation, :invalid_mapping, [:position_mapping])
  end

  defp mapping(_), do: Error.new(:validation, :invalid_mapping, [:position_mapping])

  defp mapping_pairs(pairs) do
    Enum.reduce_while(pairs, {:ok, []}, &mapping_pair/2)
    |> case do
      {:ok, pairs} -> {:ok, Enum.sort(pairs)}
      error -> error
    end
  end

  defp mapping_pair({id, group}, {:ok, acc}) do
    case identifier(id, :position_mapping) do
      {:ok, id} ->
        if group in tl(@scopes) and not mapping_id_present?(acc, id),
          do: {:cont, {:ok, [{id, group} | acc]}},
          else: {:halt, Error.new(:validation, :invalid_mapping, [:position_mapping])}

      error ->
        {:halt, error}
    end
  end

  defp mapping_pair(_, _),
    do: {:halt, Error.new(:validation, :invalid_mapping, [:position_mapping])}

  defp mapping_id_present?(pairs, id), do: Enum.any?(pairs, fn {key, _} -> key == id end)
end
