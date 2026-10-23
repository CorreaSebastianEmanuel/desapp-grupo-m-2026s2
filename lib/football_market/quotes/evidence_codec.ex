defmodule FootballMarket.Quotes.EvidenceCodec do
  @moduledoc false
  alias FootballMarket.Valuation.{Fact, Request}

  def encode_facts(facts) do
    Enum.map(facts, fn f ->
      %{
        "performance_id" => f.performance_id,
        "match_id" => f.match_id,
        "player_id" => f.player_id,
        "season_id" => f.season_id,
        "team_id" => f.team_id,
        "position_id" => f.position_id,
        "home_team_id" => f.home_team_id,
        "away_team_id" => f.away_team_id,
        "match_identity" => f.match_identity,
        "kickoff" => DateTime.to_iso8601(f.kickoff),
        "minutes" => f.minutes,
        "metrics" =>
          Map.new(Request.metrics(), fn metric ->
            {Atom.to_string(metric), Map.get(f.metrics, metric)}
          end)
      }
    end)
  end

  def decode_facts(facts) when is_list(facts) do
    Enum.reduce_while(facts, {:ok, []}, fn value, {:ok, acc} ->
      case decode_fact(value) do
        {:ok, fact} -> {:cont, {:ok, [fact | acc]}}
        _ -> {:halt, {:error, :invalid_evidence}}
      end
    end)
    |> case do
      {:ok, rows} -> {:ok, Enum.reverse(rows)}
      error -> error
    end
  end

  def decode_facts(_), do: {:error, :invalid_evidence}

  defp decode_fact(value) when is_map(value) do
    expected =
      ~w(performance_id match_id player_id season_id team_id position_id home_team_id away_team_id match_identity kickoff minutes metrics)

    with {:ok, kickoff, 0} <- DateTime.from_iso8601(value["kickoff"]),
         true <- Enum.sort(Map.keys(value)) == Enum.sort(expected),
         true <-
           Enum.all?(
             ~w(performance_id match_id player_id season_id team_id position_id home_team_id away_team_id match_identity),
             &is_binary(value[&1])
           ),
         true <- is_integer(value["minutes"]),
         {:ok, metrics} <- decode_metrics(value["metrics"]) do
      {:ok,
       %Fact{
         performance_id: value["performance_id"],
         match_id: value["match_id"],
         player_id: value["player_id"],
         season_id: value["season_id"],
         team_id: value["team_id"],
         position_id: value["position_id"],
         home_team_id: value["home_team_id"],
         away_team_id: value["away_team_id"],
         match_identity: value["match_identity"],
         kickoff: kickoff,
         minutes: value["minutes"],
         metrics: metrics
       }}
    else
      _ -> {:error, :invalid_evidence}
    end
  end

  defp decode_fact(_), do: {:error, :invalid_evidence}

  defp decode_metrics(values) when is_map(values) do
    expected = Enum.map(Request.metrics(), &Atom.to_string/1)

    if Enum.sort(Map.keys(values)) == Enum.sort(expected) and
         Enum.all?(Map.values(values), &(is_nil(&1) or is_integer(&1))) do
      {:ok, Map.new(Request.metrics(), fn metric -> {metric, values[Atom.to_string(metric)]} end)}
    else
      {:error, :invalid_evidence}
    end
  end

  defp decode_metrics(_), do: {:error, :invalid_evidence}
end
