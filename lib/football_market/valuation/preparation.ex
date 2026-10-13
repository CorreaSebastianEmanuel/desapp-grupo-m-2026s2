defmodule FootballMarket.Valuation.Preparation do
  @moduledoc false
  alias FootballMarket.Valuation.{
    Error,
    Request,
    PositionGroups,
    DecimalMath,
    ScopeInputs,
    Prepared,
    Evidence
  }

  def build(request, rows) do
    rows =
      Enum.sort_by(
        rows,
        &{DateTime.to_unix(&1.kickoff, :microsecond), &1.match_identity, &1.performance_id}
      )

    with :ok <- membership(request, rows),
         {:ok, rows} <- PositionGroups.assign(rows, request.position_mapping) do
      scopes =
        [
          {:overall, rows}
          | Enum.map(tl(Request.scopes()), fn group ->
              {group, Enum.filter(rows, &(&1.group == group))}
            end)
        ]
        |> Enum.reject(fn {_, rs} -> rs == [] end)

      with :ok <- completeness(request, scopes), do: {:ok, prepared(request, rows, scopes)}
    end
  end

  defp completeness(request, scopes) do
    applicable =
      Enum.filter(scopes, fn {scope, _} -> Map.has_key?(request.requirements, scope) end)

    missing =
      for {scope, rows} <- applicable,
          metric <- request.requirements[scope],
          row <- rows,
          is_nil(Map.fetch!(row.metrics, metric)),
          do: %{scope: scope, metric: metric, performance_id: row.performance_id}

    cond do
      applicable == [] -> Error.new(:insufficient_data, :no_applicable_required_scope)
      missing != [] -> Error.new(:insufficient_data, :missing_required_metric, missing)
      true -> :ok
    end
  end

  defp prepared(request, rows, scopes) do
    %Prepared{
      request: request,
      facts: rows,
      scopes:
        Map.new(scopes, fn {scope, rs} ->
          metrics = Map.get(request.requirements, scope, [])

          totals =
            Map.new(metrics, fn m ->
              {m, Enum.reduce(rs, 0, fn r, acc -> acc + Map.fetch!(r.metrics, m) end)}
            end)

          {scope,
           %ScopeInputs{
             membership: Enum.map(rs, & &1.performance_id),
             row_count: length(rs),
             total_minutes: Enum.sum(Enum.map(rs, & &1.minutes)),
             totals: totals,
             features:
               Map.new(totals, fn {m, n} ->
                 {m, DecimalMath.normalize(n, request.references[m])}
               end)
           }}
        end)
    }
    |> Evidence.attach()
  end

  defp membership(request, rows) do
    cond do
      rows == [] ->
        Error.new(:no_recorded_performances, :empty_week)

      length(Enum.uniq_by(rows, & &1.performance_id)) != length(rows) or
          length(Enum.uniq_by(rows, &{&1.player_id, &1.match_id})) != length(rows) ->
        Error.new(:validation, :duplicate_fact)

      Enum.any?(rows, fn r ->
        r.player_id != request.player_id or r.season_id != request.season_id or
          DateTime.compare(r.kickoff, request.week_start) == :lt or
            DateTime.compare(r.kickoff, request.week_end) != :lt
      end) ->
        Error.new(:validation, :invalid_membership)

      true ->
        :ok
    end
  end
end
