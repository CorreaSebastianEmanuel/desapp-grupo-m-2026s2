defmodule FootballMarket.Valuation.Request do
  @moduledoc """
  Validation for weekly valuation requests, UTC Monday-to-Monday week windows,
  required metrics, reference caps, and position-group mappings.
  """

  alias FootballMarket.Statistics.Input
  alias FootballMarket.Valuation.{DecimalMath, Error, Evidence}

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

  @week_microseconds 604_800_000_000

  defstruct @keys

  def metrics, do: @metrics
  def scopes, do: @scopes

  # --- Request & Week Validation ---

  def validate(%__MODULE__{} = request), do: validate(Map.from_struct(request))

  def validate(request) when is_map(request) and not is_struct(request) do
    if Enum.sort(Map.keys(request)) != Enum.sort(@keys) do
      Error.new(:validation, :invalid_request_keys, [:request])
    else
      with {:ok, player_id} <- validate_identifier(request.player_id, :player_id),
           {:ok, season_id} <- validate_identifier(request.season_id, :season_id),
           {:ok, {week_start, week_end}} <- validate_week(request.week_start, request.week_end),
           {:ok, requirements} <- requirements(request.requirements),
           :ok <- validate_references(request.references, requirements),
           {:ok, mapping} <- validate_mapping(request.position_mapping) do
        {:ok,
         struct!(__MODULE__, %{
           request
           | player_id: player_id,
             season_id: season_id,
             week_start: week_start,
             week_end: week_end,
             requirements: requirements,
             references: Evidence.normalize_config(request.references),
             position_mapping: mapping
         })}
      end
    end
  end

  def validate(_), do: Error.new(:validation, :invalid_request, [:request])

  @doc "Validates an exact 7-day UTC Monday 00:00:00Z to next Monday 00:00:00Z window."
  def validate_week(start_at, end_at) do
    with {:ok, start_dt} <- Input.instant(start_at, :week_start),
         {:ok, end_dt} <- Input.instant(end_at, :week_end) do
      starts_on_monday_midnight? =
        Date.day_of_week(DateTime.to_date(start_dt)) == 1 and
          start_dt.hour == 0 and start_dt.minute == 0 and start_dt.second == 0 and
          elem(start_dt.microsecond, 0) == 0

      exact_seven_days? = DateTime.diff(end_dt, start_dt, :microsecond) == @week_microseconds

      if starts_on_monday_midnight? and exact_seven_days? do
        {:ok, {start_dt, end_dt}}
      else
        Error.new(:validation, :invalid_week, [:week_start, :week_end])
      end
    else
      {:error, detail} ->
        Error.new(:validation, :invalid_week, [Map.take(detail, [:field, :reason])])
    end
  end

  @doc "Validates a managed calculation's subject and explicit UTC week without database reads."
  def subject_week(subject) when is_map(subject) and not is_struct(subject) do
    expected = [:player_id, :season_id, :week_start, :week_end]

    if Enum.sort(Map.keys(subject)) == Enum.sort(expected) do
      with {:ok, player_id} <- validate_identifier(subject.player_id, :player_id),
           {:ok, season_id} <- validate_identifier(subject.season_id, :season_id),
           {:ok, {week_start, week_end}} <- validate_week(subject.week_start, subject.week_end) do
        {:ok,
         %{
           subject
           | player_id: player_id,
             season_id: season_id,
             week_start: week_start,
             week_end: week_end
         }}
      end
    else
      Error.new(:validation, :invalid_request_keys, [:request])
    end
  end

  def subject_week(_), do: Error.new(:validation, :invalid_request, [:request])

  @doc "Validates reusable rule fields (`requirements`, `references`, `position_mapping`)."
  def rule_fields(required, refs, pairs) do
    with {:ok, requirements} <- requirements(required),
         :ok <- validate_references(refs, requirements),
         {:ok, position_mapping} <- validate_mapping(pairs) do
      {:ok,
       %{
         requirements: requirements,
         references: Evidence.normalize_config(refs),
         position_mapping: position_mapping
       }}
    end
  end

  def requirements(required)
      when is_map(required) and not is_struct(required) and map_size(required) > 0 do
    valid? =
      Enum.all?(required, fn {scope, metrics} ->
        scope in @scopes and Evidence.proper_list?(metrics) and metrics != [] and
          Enum.all?(metrics, fn metric -> metric in @metrics end) and
          length(Enum.uniq(metrics)) == length(metrics)
      end)

    if valid? do
      canonical =
        Map.new(required, fn {scope, metrics} ->
          {scope, Enum.filter(@metrics, fn metric -> metric in metrics end)}
        end)

      {:ok, canonical}
    else
      Error.new(:validation, :invalid_requirements, [:requirements])
    end
  end

  def requirements(_), do: Error.new(:validation, :invalid_requirements, [:requirements])

  # --- Private Helpers ---

  defp validate_identifier(id, field) do
    case Input.identifier(id, field) do
      {:ok, canonical} -> {:ok, canonical}
      _ -> Error.new(:validation, :invalid_identifier, [field])
    end
  end

  defp validate_references(refs, requirements) when is_map(refs) and not is_struct(refs) do
    needed = requirements |> Map.values() |> List.flatten() |> Enum.uniq() |> Enum.sort()

    if Enum.sort(Map.keys(refs)) == needed and
         Enum.all?(Map.values(refs), &DecimalMath.positive?/1),
       do: :ok,
       else: Error.new(:validation, :invalid_references, [:references])
  end

  defp validate_references(_, _), do: Error.new(:validation, :invalid_references, [:references])

  defp validate_mapping(pairs) when is_list(pairs) do
    if Evidence.proper_list?(pairs),
      do: validate_mapping_pairs(pairs),
      else: Error.new(:validation, :invalid_mapping, [:position_mapping])
  end

  defp validate_mapping(_), do: Error.new(:validation, :invalid_mapping, [:position_mapping])

  defp validate_mapping_pairs(pairs) do
    case Enum.reduce_while(pairs, {:ok, []}, &validate_mapping_pair/2) do
      {:ok, validated} -> {:ok, Enum.sort(validated)}
      error -> error
    end
  end

  defp validate_mapping_pair({id, group}, {:ok, acc}) do
    case validate_identifier(id, :position_mapping) do
      {:ok, uuid} ->
        position_groups = tl(@scopes)

        if group in position_groups and not mapping_id_present?(acc, uuid),
          do: {:cont, {:ok, [{uuid, group} | acc]}},
          else: {:halt, Error.new(:validation, :invalid_mapping, [:position_mapping])}

      error ->
        {:halt, error}
    end
  end

  defp validate_mapping_pair(_, _),
    do: {:halt, Error.new(:validation, :invalid_mapping, [:position_mapping])}

  defp mapping_id_present?(pairs, id),
    do: Enum.any?(pairs, fn {key, _group} -> key == id end)
end
