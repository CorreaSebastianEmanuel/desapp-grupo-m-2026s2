defmodule FootballMarket.Market.Analytics.Projection do
  @moduledoc false
  alias FootballMarket.Market.PortfolioLedger

  def build(snapshot, mode) do
    state = %{
      positions: %{},
      quotes: %{},
      purchases: Decimal.new(0),
      sales: Decimal.new(0),
      trades: Enum.sort_by(snapshot.transactions, &{time(&1.completed_at), &1.type, &1.id}),
      pending_quotes: Enum.sort_by(snapshot.quotes, &time(&1.effective_at))
    }

    case mode do
      :allocation ->
        state = advance(state, snapshot.as_of)
        {positions, totals} = value(state, snapshot.players)
        %{as_of: snapshot.as_of, positions: weights(positions, totals), totals: totals}

      :history ->
        {points, _state} =
          Enum.map_reduce(Date.range(snapshot.range.from, snapshot.range.to), state, fn date,
                                                                                        acc ->
            cutoff = min_time(DateTime.new!(date, ~T[23:59:59.999999], "Etc/UTC"), snapshot.as_of)
            next = advance(acc, cutoff)
            {_, totals} = value(next, snapshot.players)

            {Map.merge(totals, %{
               date: date,
               cutoff_at: cutoff,
               partial: date == DateTime.to_date(snapshot.as_of)
             }), next}
          end)

        %{
          as_of: snapshot.as_of,
          from: snapshot.range.from,
          to: snapshot.range.to,
          timezone: "UTC",
          interval: "day",
          points: points
        }
    end
  end

  defp advance(state, cutoff) do
    {trades, remaining} =
      Enum.split_while(state.trades, &(DateTime.compare(&1.completed_at, cutoff) != :gt))

    state = Enum.reduce(trades, %{state | trades: remaining}, &trade/2)

    {quotes, remaining_quotes} =
      Enum.split_while(state.pending_quotes, &(DateTime.compare(&1.effective_at, cutoff) != :gt))

    selected = Enum.reduce(quotes, state.quotes, &select_quote/2)
    %{state | quotes: selected, pending_quotes: remaining_quotes}
  end

  defp trade(transaction, state) do
    field = if transaction.type == "purchase", do: :purchases, else: :sales

    state
    |> Map.put(:positions, PortfolioLedger.apply_transaction(transaction, state.positions))
    |> Map.update!(field, &Decimal.add(&1, transaction.total))
  end

  defp select_quote(candidate, selected) do
    Map.update(selected, candidate.player_id, candidate, fn prior ->
      if authority(candidate) > authority(prior), do: candidate, else: prior
    end)
  end

  defp authority(q),
    do: {q.performance_sequence || 0, time(q.effective_at), time(q.inserted_at), q.id}

  defp time(at), do: DateTime.to_unix(at, :microsecond)
  defp min_time(a, b), do: if(DateTime.compare(a, b) == :gt, do: b, else: a)

  defp value(state, players) do
    positions =
      state.positions
      |> Enum.filter(fn {_, p} -> p.quantity > 0 end)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {id, p} -> position(id, p, Map.get(state.quotes, id), players) end)

    missing = positions |> Enum.filter(&is_nil(&1.market_value)) |> Enum.map(& &1.player_id)
    complete = missing == []
    market_value = if complete, do: sum(positions, :market_value)
    cost_basis = sum(positions, :cost_basis)
    realized = state.positions |> Map.values() |> sum(:realized_profit_loss)
    unrealized = if complete, do: sum(positions, :unrealized_profit_loss)

    {positions,
     %{
       market_value: market_value,
       cost_basis: cost_basis,
       purchase_expenditure: state.purchases,
       sale_proceeds: state.sales,
       net_invested: Decimal.sub(state.purchases, state.sales),
       realized_profit_loss: realized,
       unrealized_profit_loss: unrealized,
       total_profit_loss: if(complete, do: Decimal.add(realized, unrealized)),
       valuation_complete: complete,
       missing_quote_player_ids: missing
     }}
  end

  defp position(id, p, quote, players) do
    basis = Decimal.mult(p.average_unit_cost, p.quantity)
    value = if quote, do: Decimal.mult(quote.unit_price, p.quantity)

    Map.merge(p, %{
      player_id: id,
      player_name: Map.fetch!(players, id),
      cost_basis: basis,
      quote:
        if(quote, do: Map.take(quote, [:id, :unit_price, :effective_at, :performance_sequence])),
      market_value: value,
      unrealized_profit_loss: if(value, do: Decimal.sub(value, basis))
    })
  end

  defp weights(positions, totals) do
    Enum.map(positions, fn p ->
      weight =
        if totals.valuation_complete and Decimal.positive?(totals.market_value) do
          p.market_value |> Decimal.div(totals.market_value) |> Decimal.round(18, :half_up)
        end

      Map.put(p, :weight, weight)
    end)
  end

  defp sum(rows, field),
    do: Enum.reduce(rows, Decimal.new(0), &Decimal.add(Map.fetch!(&1, field), &2))
end
