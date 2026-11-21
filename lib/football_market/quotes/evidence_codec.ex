defmodule FootballMarket.Quotes.EvidenceCodec do
  @moduledoc """
  Serialization/deserialization of retained valuation facts and conversion of
  valuation scores or failures into persisted quote outcomes.
  """

  alias FootballMarket.Quotes.Mappings
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Fact, Request}

  # --- Score Outcome & Failure Classification ---

  def outcome(score, scale) do
    with {:ok, exact_score} <- parse_exact_score(score) do
      case Mappings.convert(exact_score, scale) do
        {:ok, price} ->
          {:ok, %{status: "successful", reason: nil, price: price, score: exact_score}}

        {:no_quote, reason} ->
          {:ok,
           %{status: "no_quote", reason: Atom.to_string(reason), price: nil, score: exact_score}}

        error ->
          error
      end
    end
  end

  def safe_failure(%Valuation.Error{kind: :no_recorded_performances}),
    do: {:ok, "no_quote", "no_recorded_performances"}

  def safe_failure(%Valuation.Error{kind: :insufficient_data}),
    do: {:ok, "no_quote", "insufficient_data"}

  def safe_failure(%Valuation.Error{kind: :unsupported_strategy}),
    do: {:ok, "unsupported_strategy", "unsupported_strategy"}

  def safe_failure(%Valuation.Error{kind: kind})
      when kind in [:unavailable_replay, :inconsistent_replay],
      do: {:ok, "unreproducible", "original_unavailable"}

  def safe_failure(%Valuation.Error{}), do: {:ok, "validation_failed", "invalid_valuation_input"}

  # --- Fact Evidence Codec ---

  def encode_facts(facts) do
    Enum.map(facts, fn fact ->
      %{
        "performance_id" => fact.performance_id,
        "match_id" => fact.match_id,
        "player_id" => fact.player_id,
        "season_id" => fact.season_id,
        "team_id" => fact.team_id,
        "position_id" => fact.position_id,
        "home_team_id" => fact.home_team_id,
        "away_team_id" => fact.away_team_id,
        "match_identity" => fact.match_identity,
        "kickoff" => DateTime.to_iso8601(fact.kickoff),
        "minutes" => fact.minutes,
        "metrics" =>
          Map.new(Request.metrics(), fn metric ->
            {Atom.to_string(metric), Map.get(fact.metrics, metric)}
          end)
      }
    end)
  end

  def decode_facts(facts) when is_list(facts) do
    result =
      Enum.reduce_while(facts, {:ok, []}, fn value, {:ok, acc} ->
        case decode_fact(value) do
          {:ok, fact} -> {:cont, {:ok, [fact | acc]}}
          _ -> {:halt, {:error, :invalid_evidence}}
        end
      end)

    case result do
      {:ok, rows} -> {:ok, Enum.reverse(rows)}
      error -> error
    end
  end

  def decode_facts(_), do: {:error, :invalid_evidence}

  def request_facts(%{explicit_fact_material: %{"facts" => facts}} = request) do
    case decode_facts(facts) do
      {:ok, decoded} ->
        if length(decoded) == length(request.explicit_membership || []),
          do: {:ok, request, decoded},
          else: {:error, :unreproducible}

      _ ->
        {:error, :unreproducible}
    end
  end

  def request_facts(_), do: {:error, :unreproducible}

  # --- Private Helpers ---

  defp parse_exact_score(%Decimal{} = score), do: {:ok, score}

  defp parse_exact_score(score) when is_binary(score) do
    case Decimal.parse(score) do
      {%Decimal{} = decimal, ""} -> {:ok, decimal}
      _ -> {:error, :invalid_decimal}
    end
  end

  defp parse_exact_score(_), do: {:error, :invalid_decimal}

  defp decode_fact(value) when is_map(value) do
    string_fields =
      ~w(performance_id match_id player_id season_id team_id position_id home_team_id away_team_id match_identity)

    expected = string_fields ++ ~w(kickoff minutes metrics)

    with {:ok, kickoff, 0} <- DateTime.from_iso8601(value["kickoff"]),
         true <- Enum.sort(Map.keys(value)) == Enum.sort(expected),
         true <- Enum.all?(string_fields, fn key -> is_binary(value[key]) end),
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

    valid_keys? = Enum.sort(Map.keys(values)) == Enum.sort(expected)
    valid_vals? = Enum.all?(Map.values(values), fn val -> is_nil(val) or is_integer(val) end)

    if valid_keys? and valid_vals? do
      {:ok, Map.new(Request.metrics(), fn metric -> {metric, values[Atom.to_string(metric)]} end)}
    else
      {:error, :invalid_evidence}
    end
  end

  defp decode_metrics(_), do: {:error, :invalid_evidence}
end
