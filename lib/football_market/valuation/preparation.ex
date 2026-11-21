defmodule FootballMarket.Valuation.Preparation do
  @moduledoc """
  Deterministic weekly feature preparation from accepted player match performances.

  Orders performances canonically, assigns each row to its configured position
  group, checks required metric completeness, and normalizes feature totals into
  a `Prepared` struct with an attached `Descriptor`.
  """

  alias FootballMarket.Valuation.{
    DecimalMath,
    Error,
    Evidence,
    Prepared,
    Request,
    ScopeInputs
  }

  def build(request, rows) do
    ordered_rows = canonical_order(rows)

    with :ok <- verify_membership(request, ordered_rows),
         {:ok, grouped_rows} <- assign_position_groups(ordered_rows, request.position_mapping) do
      scopes =
        [
          {:overall, grouped_rows}
          | Enum.map(tl(Request.scopes()), fn group ->
              {group, Enum.filter(grouped_rows, fn row -> row.group == group end)}
            end)
        ]
        |> Enum.reject(fn {_scope, scope_rows} -> scope_rows == [] end)

      with :ok <- verify_completeness(request, scopes) do
        {:ok, build_prepared(request, grouped_rows, scopes)}
      end
    end
  end

  def canonical_order(rows) do
    Enum.sort_by(rows, fn row ->
      {DateTime.to_unix(row.kickoff, :microsecond), row.match_identity, row.performance_id}
    end)
  end

  def assign_position_groups(rows, mapping_pairs) do
    mapping = Map.new(mapping_pairs)

    result =
      Enum.reduce_while(rows, {:ok, []}, fn row, {:ok, acc} ->
        case Map.fetch(mapping, row.position_id) do
          {:ok, group} -> {:cont, {:ok, [%{row | group: group} | acc]}}
          :error -> {:halt, Error.new(:validation, :missing_position_mapping, [row.position_id])}
        end
      end)

    case result do
      {:ok, grouped} -> {:ok, Enum.reverse(grouped)}
      error -> error
    end
  end

  # --- Private Helpers ---

  defp verify_completeness(request, scopes) do
    applicable =
      Enum.filter(scopes, fn {scope, _rows} -> Map.has_key?(request.requirements, scope) end)

    missing =
      for {scope, scope_rows} <- applicable,
          metric <- request.requirements[scope],
          row <- scope_rows,
          is_nil(Map.fetch!(row.metrics, metric)),
          do: %{scope: scope, metric: metric, performance_id: row.performance_id}

    cond do
      applicable == [] -> Error.new(:insufficient_data, :no_applicable_required_scope)
      missing != [] -> Error.new(:insufficient_data, :missing_required_metric, missing)
      true -> :ok
    end
  end

  defp build_prepared(request, rows, scopes) do
    scope_inputs = Map.new(scopes, &build_scope_inputs(&1, request))

    %Prepared{request: request, facts: rows, scopes: scope_inputs}
    |> Evidence.attach()
  end

  defp build_scope_inputs({scope, scope_rows}, request) do
    metrics = Map.get(request.requirements, scope, [])
    totals = Map.new(metrics, fn metric -> {metric, sum_metric(scope_rows, metric)} end)

    features =
      Map.new(totals, fn {metric, total} ->
        {metric, DecimalMath.normalize(total, request.references[metric])}
      end)

    {scope,
     %ScopeInputs{
       membership: Enum.map(scope_rows, fn row -> row.performance_id end),
       row_count: length(scope_rows),
       total_minutes: Enum.sum(Enum.map(scope_rows, fn row -> row.minutes end)),
       totals: totals,
       features: features
     }}
  end

  defp sum_metric(rows, metric),
    do: Enum.reduce(rows, 0, fn row, acc -> acc + Map.fetch!(row.metrics, metric) end)

  defp verify_membership(request, rows) do
    has_duplicates? =
      length(Enum.uniq_by(rows, fn row -> row.performance_id end)) != length(rows) or
        length(Enum.uniq_by(rows, fn row -> {row.player_id, row.match_id} end)) != length(rows)

    out_of_scope? =
      Enum.any?(rows, fn row ->
        row.player_id != request.player_id or
          row.season_id != request.season_id or
          DateTime.compare(row.kickoff, request.week_start) == :lt or
          DateTime.compare(row.kickoff, request.week_end) != :lt
      end)

    cond do
      rows == [] -> Error.new(:no_recorded_performances, :empty_week)
      has_duplicates? -> Error.new(:validation, :duplicate_fact)
      out_of_scope? -> Error.new(:validation, :invalid_membership)
      true -> :ok
    end
  end
end
