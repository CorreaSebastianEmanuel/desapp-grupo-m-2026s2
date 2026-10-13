defmodule FootballMarket.Valuation.StatisticsReader do
  @moduledoc "Read-only bridge through Catalog and Statistics public contracts."
  alias FootballMarket.{Catalog, Statistics}
  alias FootballMarket.Valuation.{Error, Fact}

  def subject(request) do
    case Catalog.get_player(request.player_id) do
      {:error, :not_found} -> Error.new(:not_found, :player_not_found)
      {:ok, %{season_id: season}} when season == request.season_id -> :ok
      _ -> Error.new(:validation, :season_mismatch, [:season_id])
    end
  end

  def select(request) do
    with :ok <- subject(request),
         {:ok, rows} <-
           read(fn ->
             Statistics.list_player_history(request.player_id,
               from: request.week_start,
               to: request.week_end
             )
           end) do
      {:ok,
       rows
       |> Enum.filter(&(DateTime.compare(&1.match.kickoff_at, request.week_end) == :lt))
       |> Enum.map(&snapshot(&1, &1.match))}
    end
  end

  def originals(facts) do
    Enum.reduce_while(facts, {:ok, []}, fn fact, {:ok, acc} ->
      with {:ok, row} <- read(fn -> Statistics.get_performance(fact.player_id, fact.match_id) end),
           {:ok, match} <- Statistics.get_match(fact.match_id) do
        authoritative = snapshot(row, match)

        if authoritative == %{fact | group: nil},
          do: {:cont, {:ok, [authoritative | acc]}},
          else: {:halt, Error.new(:inconsistent_replay, :altered_fact, [fact.performance_id])}
      else
        _ ->
          {:halt,
           Error.new(:unavailable_replay, :original_fact_unavailable, [fact.performance_id])}
      end
    end)
    |> case do
      {:ok, rows} -> {:ok, Enum.reverse(rows)}
      error -> error
    end
  end

  # PostgreSQL NUMERIC admits at most 131072 integral digits. Isolate its
  # existing Ecto Count loader from caller precision; this adds no count limit.
  defp read(fun),
    do:
      Decimal.Context.with(
        %Decimal.Context{precision: 131_072, emax: :infinity, emin: :infinity},
        fun
      )

  defp snapshot(row, match) do
    %Fact{
      performance_id: row.id,
      match_id: match.id,
      player_id: row.player_id,
      season_id: match.season_id,
      team_id: row.team_id,
      position_id: row.position_id,
      home_team_id: match.home_team_id,
      away_team_id: match.away_team_id,
      match_identity: match.match_identity,
      kickoff: match.kickoff_at,
      minutes: row.minutes_played,
      metrics: Map.take(row, FootballMarket.Valuation.Request.metrics())
    }
  end
end
