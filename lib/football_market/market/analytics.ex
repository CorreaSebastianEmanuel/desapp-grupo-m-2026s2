defmodule FootballMarket.Market.Analytics do
  @moduledoc """
  Owner-scoped portfolio allocation weights and daily historical valuation series.

  Reads a single `REPEATABLE READ, READ ONLY` PostgreSQL snapshot and runs a
  pure deterministic projection (`build_projection/2`) over all committed trades
  and historical quotes.
  """

  import Ecto.Query

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Market.{Error, Portfolio, Quote}
  alias FootballMarket.Repo

  # --- Public API ---

  def allocation(actor), do: read(actor, :allocation, %{})
  def history(actor, options), do: read(actor, :history, options)

  # --- Query & Date Range Validation ---

  def decode_query(query) do
    pairs = Enum.to_list(URI.query_decoder(query))

    with {:ok, from_date} <- extract_date_param(pairs, "from"),
         {:ok, to_date} <- extract_date_param(pairs, "to") do
      {:ok, %{from: from_date, to: to_date}}
    end
  rescue
    _ in [ArgumentError] -> {:error, :invalid_date}
  end

  def validate_range(options, today) when is_map(options) do
    to_date = Map.get(options, :to) || today

    if valid_date?(to_date) do
      from_date = Map.get(options, :from) || Date.add(to_date, -29)
      check_date_bounds(from_date, to_date, today)
    else
      {:error, :invalid_date}
    end
  end

  def validate_range(_, _), do: {:error, :invalid_date}

  # --- Pure Projection Engine ---

  def build_projection(snapshot, mode) do
    initial_state = %{
      positions: %{},
      quotes: %{},
      purchases: Decimal.new(0),
      sales: Decimal.new(0),
      trades:
        Enum.sort_by(snapshot.transactions, fn tx ->
          {unix_us(tx.completed_at), tx.type, tx.id}
        end),
      pending_quotes: Enum.sort_by(snapshot.quotes, fn quote -> unix_us(quote.effective_at) end)
    }

    case mode do
      :allocation ->
        state = advance_to_cutoff(initial_state, snapshot.as_of)
        {positions, totals} = value_positions(state, snapshot.players)
        %{as_of: snapshot.as_of, positions: attach_weights(positions, totals), totals: totals}

      :history ->
        {points, _final_state} =
          Enum.map_reduce(
            Date.range(snapshot.range.from, snapshot.range.to),
            initial_state,
            fn date, acc ->
              cutoff = min_time(day_end(date), snapshot.as_of)
              next_state = advance_to_cutoff(acc, cutoff)
              {_positions, totals} = value_positions(next_state, snapshot.players)

              point =
                Map.merge(totals, %{
                  date: date,
                  cutoff_at: cutoff,
                  partial: date == DateTime.to_date(snapshot.as_of)
                })

              {point, next_state}
            end
          )

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

  # --- Database Snapshot ---

  defp read(%AuthenticatedActor{account_id: owner_id}, mode, options) when is_binary(owner_id) do
    with {:ok, _uuid} <- Ecto.UUID.cast(owner_id),
         {:ok, snapshot} <- read_snapshot(owner_id, mode, options) do
      {:ok, Portfolio.exact(fn -> build_projection(snapshot, mode) end)}
    else
      :error -> Error.new(:unauthenticated, :unauthenticated)
      {:error, reason} -> Error.new(reason, reason)
    end
  end

  defp read(_, _, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp read_snapshot(owner_id, mode, options) do
    if Repo.in_transaction?() do
      {:error, :temporarily_unavailable}
    else
      Repo.transaction(fn -> load_snapshot(owner_id, mode, options) end)
    end
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] -> {:error, :temporarily_unavailable}
  end

  defp load_snapshot(owner_id, mode, options) do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
    %{rows: [[as_of]]} = Repo.query!("SELECT transaction_timestamp()")
    range = resolve_range!(mode, options, DateTime.to_date(as_of))
    cutoff = if mode == :allocation, do: as_of, else: min_time(day_end(range.to), as_of)

    opening =
      if mode == :allocation,
        do: as_of,
        else: DateTime.new!(range.from, ~T[00:00:00], "Etc/UTC")

    transactions =
      from(tx in subquery(Portfolio.transaction_query(owner_id)),
        where: tx.completed_at <= ^cutoff
      )
      |> Repo.all()

    player_ids = transactions |> Enum.map(fn tx -> tx.player_id end) |> Enum.uniq()

    players =
      Repo.all(from p in Player, where: p.id in ^player_ids, select: {p.id, p.display_name})
      |> Map.new()

    %{
      as_of: as_of,
      range: range,
      transactions: transactions,
      players: players,
      quotes: opening_quotes(player_ids, opening) ++ quote_changes(player_ids, opening, cutoff)
    }
  end

  defp resolve_range!(:allocation, _, _), do: nil

  defp resolve_range!(:history, options, today) do
    case validate_range(options, today) do
      {:ok, range} -> range
      {:error, reason} -> Repo.rollback(reason)
    end
  end

  # Effective time admits a quote; performance sequence remains authoritative among candidates.
  defp opening_quotes(player_ids, opening) do
    Repo.all(
      from q in Quote,
        where: q.player_id in ^player_ids and q.effective_at < ^opening,
        distinct: q.player_id,
        order_by: [
          asc: q.player_id,
          desc: fragment("COALESCE(?, 0)", q.performance_sequence),
          desc: q.effective_at,
          desc: q.inserted_at,
          desc: q.id
        ]
    )
  end

  defp quote_changes(player_ids, opening, cutoff) do
    Repo.all(
      from q in Quote,
        where:
          q.player_id in ^player_ids and q.effective_at >= ^opening and q.effective_at <= ^cutoff
    )
  end

  # --- Projection Helpers ---

  defp advance_to_cutoff(state, cutoff) do
    {applied_trades, remaining_trades} =
      Enum.split_while(state.trades, fn tx ->
        DateTime.compare(tx.completed_at, cutoff) != :gt
      end)

    state = Enum.reduce(applied_trades, %{state | trades: remaining_trades}, &apply_trade/2)

    {applied_quotes, remaining_quotes} =
      Enum.split_while(state.pending_quotes, fn quote ->
        DateTime.compare(quote.effective_at, cutoff) != :gt
      end)

    selected_quotes = Enum.reduce(applied_quotes, state.quotes, &select_authoritative_quote/2)
    %{state | quotes: selected_quotes, pending_quotes: remaining_quotes}
  end

  defp apply_trade(transaction, state) do
    total_field = if transaction.type == "purchase", do: :purchases, else: :sales

    state
    |> Map.put(:positions, Portfolio.apply_transaction(transaction, state.positions))
    |> Map.update!(total_field, fn current -> Decimal.add(current, transaction.total) end)
  end

  defp select_authoritative_quote(candidate, selected) do
    Map.update(selected, candidate.player_id, candidate, fn prior ->
      if quote_authority(candidate) > quote_authority(prior), do: candidate, else: prior
    end)
  end

  defp quote_authority(quote) do
    {quote.performance_sequence || 0, unix_us(quote.effective_at), unix_us(quote.inserted_at),
     quote.id}
  end

  defp value_positions(state, players) do
    positions =
      state.positions
      |> Enum.filter(fn {_player_id, position} -> position.quantity > 0 end)
      |> Enum.sort_by(fn {player_id, _position} -> player_id end)
      |> Enum.map(fn {player_id, position} ->
        build_position_row(player_id, position, Map.get(state.quotes, player_id), players)
      end)

    missing_ids =
      positions
      |> Enum.filter(fn position -> is_nil(position.market_value) end)
      |> Enum.map(fn position -> position.player_id end)

    complete = missing_ids == []
    market_value = if complete, do: sum_field(positions, :market_value)
    cost_basis = sum_field(positions, :cost_basis)
    realized = state.positions |> Map.values() |> sum_field(:realized_profit_loss)
    unrealized = if complete, do: sum_field(positions, :unrealized_profit_loss)

    totals = %{
      market_value: market_value,
      cost_basis: cost_basis,
      purchase_expenditure: state.purchases,
      sale_proceeds: state.sales,
      net_invested: Decimal.sub(state.purchases, state.sales),
      realized_profit_loss: realized,
      unrealized_profit_loss: unrealized,
      total_profit_loss: if(complete, do: Decimal.add(realized, unrealized)),
      valuation_complete: complete,
      missing_quote_player_ids: missing_ids
    }

    {positions, totals}
  end

  defp build_position_row(player_id, position, quote, players) do
    basis = Decimal.mult(position.average_unit_cost, position.quantity)
    market_value = if quote, do: Decimal.mult(quote.unit_price, position.quantity)

    quote_summary =
      if quote, do: Map.take(quote, [:id, :unit_price, :effective_at, :performance_sequence])

    Map.merge(position, %{
      player_id: player_id,
      player_name: Map.fetch!(players, player_id),
      cost_basis: basis,
      quote: quote_summary,
      market_value: market_value,
      unrealized_profit_loss: if(market_value, do: Decimal.sub(market_value, basis))
    })
  end

  defp attach_weights(positions, totals) do
    Enum.map(positions, fn position ->
      weight =
        if totals.valuation_complete and Decimal.positive?(totals.market_value) do
          position.market_value |> Decimal.div(totals.market_value) |> Decimal.round(18, :half_up)
        end

      Map.put(position, :weight, weight)
    end)
  end

  defp sum_field(rows, field) do
    Enum.reduce(rows, Decimal.new(0), fn row, acc ->
      Decimal.add(Map.fetch!(row, field), acc)
    end)
  end

  # --- Date Helpers ---

  defp extract_date_param(pairs, key) do
    selected =
      Enum.filter(pairs, fn {name, _value} ->
        name == key or String.starts_with?(name, key <> "[")
      end)

    case selected do
      [] -> {:ok, nil}
      [{^key, value}] -> parse_iso_date(value)
      _ -> {:error, :invalid_date}
    end
  end

  defp parse_iso_date(value) do
    with true <- Regex.match?(~r/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/, value),
         {:ok, date} <- Date.from_iso8601(value),
         true <- valid_date?(date) do
      {:ok, date}
    else
      _ -> {:error, :invalid_date}
    end
  end

  defp valid_date?(%Date{calendar: Calendar.ISO, year: year}), do: year in 1..9999
  defp valid_date?(_), do: false

  defp check_date_bounds(from_date, to_date, today) do
    cond do
      not valid_date?(from_date) -> {:error, :invalid_date}
      Date.compare(to_date, today) == :gt -> {:error, :invalid_date_range}
      Date.diff(to_date, from_date) not in 0..365 -> {:error, :invalid_date_range}
      true -> {:ok, %{from: from_date, to: to_date}}
    end
  end

  defp unix_us(datetime), do: DateTime.to_unix(datetime, :microsecond)
  defp day_end(date), do: DateTime.new!(date, ~T[23:59:59.999999], "Etc/UTC")
  defp min_time(left, right), do: if(DateTime.compare(left, right) == :gt, do: right, else: left)
end
