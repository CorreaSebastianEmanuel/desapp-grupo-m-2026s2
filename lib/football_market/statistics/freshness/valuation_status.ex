defmodule FootballMarket.Statistics.Freshness.ValuationStatus do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Market.Quote

  @running ~w(running retrying)
  @failed ~w(validation_failed unsupported_strategy unreproducible exhausted)

  def for_player(player) do
    latest_quote =
      Repo.one(
        from q in Quote,
          where: q.player_id == ^player.id,
          order_by: [desc: q.effective_at],
          select: %{unit_price: q.unit_price, effective_at: q.effective_at},
          limit: 1
      )

    last_quoted_at = latest_quote && latest_quote.effective_at

    current_quote =
      latest_quote &&
        latest_quote.unit_price |> Decimal.round(2) |> Decimal.to_string(:normal)

    # The newest changed import for THIS player is independent of subsequent
    # no-change checks, and may contain multiple weekly calculation requests.
    result =
      Repo.query!(
        """
        SELECT i.id, i.state, i.attempts
        FROM statistics_calculation_intents i
        WHERE EXISTS (
          SELECT 1 FROM quote_import_scope_snapshots s
          WHERE s.intent_id = i.id AND s.player_id = $1 AND s.season_id = $2
        ) OR EXISTS (
          SELECT 1 FROM player_match_performances p
          WHERE p.id = ANY(i.changed_performance_ids) AND p.player_id = $1 AND p.season_id = $2
        )
        ORDER BY i.requested_at DESC, i.id DESC LIMIT 1
        """,
        [Ecto.UUID.dump!(player.id), Ecto.UUID.dump!(player.season_id)]
      )

    case result.rows do
      [] ->
        empty("not_requested", last_quoted_at, current_quote)

      [[id, state, attempts]] ->
        summarize(Ecto.UUID.load!(id), state, attempts, player.id, last_quoted_at, current_quote)
    end
  rescue
    _ -> empty("unavailable", nil, nil)
  end

  defp summarize(id, dispatch, attempts, player_id, last_quoted_at, current_quote) do
    counts =
      Repo.all(
        from r in CalculationRequest,
          where: r.intent_id == ^id and r.player_id == ^player_id,
          group_by: r.state,
          select: {r.state, count(r.id)}
      )
      |> Map.new()

    %{
      state: state(counts, dispatch, attempts),
      calculation_intent_id: id,
      request_states: counts,
      last_quoted_at: last_quoted_at,
      current_quote: current_quote
    }
  end

  defp state(_, "failed", _), do: "failed"
  defp state(_, "pending", attempts) when attempts >= 3, do: "failed"
  defp state(_, "pending", _), do: "pending"

  defp state(counts, _, _) do
    cond do
      Enum.any?(@running, &Map.has_key?(counts, &1)) -> "running"
      Map.has_key?(counts, "pending") -> "pending"
      Enum.any?(@failed, &Map.has_key?(counts, &1)) -> "failed"
      map_size(counts) == 0 -> "pending"
      Enum.all?(Map.keys(counts), &(&1 in ~w(successful no_quote))) -> "completed"
      true -> "unavailable"
    end
  end

  defp empty(state, last_quoted_at, current_quote),
    do: %{
      state: state,
      calculation_intent_id: nil,
      request_states: %{},
      last_quoted_at: last_quoted_at,
      current_quote: current_quote
    }
end
