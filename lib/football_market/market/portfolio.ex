defmodule FootballMarket.Market.Portfolio do
  @moduledoc """
  Authenticated investor read models:
    * Current token holdings with weighted-average cost basis & unrealized P&L (`list/1`)
    * Spendable credit balance (`credit_balance/1`)
    * Initial recipient inventory (`initial_inventory/1`, `initial_recipient?/1`)
    * Cursor-paginated purchase & sale history (`transaction_history/2`)
    * Portfolio allocation weights (`allocation/1`) & daily valuation history (`history/2`)
  """

  import Ecto.Query

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    CreditBalance,
    Error,
    Holding,
    InitialRecipient,
    Issuance,
    Purchase,
    Quote,
    Sale
  }

  alias FootballMarket.Repo

  @average_decimals 18
  @cursor_aad "football-market:transaction-history:v1"

  # --- Holdings, Credit Balance & Initial Inventory ---

  def list(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    transactions = Repo.all(transaction_query(owner_id))
    build_portfolio_view(transactions)
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  def credit_balance(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    case Ecto.UUID.cast(owner_id) do
      {:ok, uuid} ->
        amount =
          Repo.one(from b in CreditBalance, where: b.user_id == ^uuid, select: b.amount)

        {:ok, amount || Decimal.new("0.00")}

      :error ->
        Error.new(:unauthenticated, :unauthenticated)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def credit_balance(_), do: Error.new(:unauthenticated, :unauthenticated)

  def initial_inventory(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    rows =
      Repo.all(
        from issuance in Issuance,
          join: holding in Holding,
          on:
            holding.player_id == issuance.player_id and
              holding.user_id == issuance.recipient_id,
          join: player in Player,
          on: player.id == issuance.player_id,
          where: issuance.recipient_id == ^owner_id and holding.quantity > 0,
          order_by: [asc: player.display_name, asc: player.id],
          select: %{
            player_id: player.id,
            player_name: player.display_name,
            quantity: holding.quantity
          }
      )

    {:ok, rows}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def initial_inventory(_), do: Error.new(:unauthenticated, :unauthenticated)

  def initial_recipient?(%AuthenticatedActor{account_id: owner_id}) when is_binary(owner_id) do
    case Ecto.UUID.cast(owner_id) do
      {:ok, uuid} ->
        {:ok, Repo.exists?(from r in InitialRecipient, where: r.user_id == ^uuid)}

      :error ->
        Error.new(:unauthenticated, :unauthenticated)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def initial_recipient?(_), do: Error.new(:unauthenticated, :unauthenticated)

  # --- Paginated Transaction History ---

  def transaction_history(%AuthenticatedActor{account_id: owner}, %{
        page_size: size,
        cursor: cursor
      })
      when is_binary(owner) do
    with {:ok, anchor} <- decode_history_anchor(cursor, owner) do
      try do
        rows =
          (fetch_purchases(owner, anchor, size + 1) ++ fetch_sales(owner, anchor, size + 1))
          |> Enum.sort_by(fn row ->
            {-DateTime.to_unix(row.completed_at, :microsecond), row.type, row.id}
          end)

        has_more = length(rows) > size
        data = Enum.take(rows, size)

        next_cursor =
          if has_more do
            data
            |> List.last()
            |> Map.take([:completed_at, :type, :id])
            |> Map.put(:owner, owner)
            |> encode_history_cursor()
          end

        {:ok,
         %{
           data: data,
           pagination: %{
             page_size: size,
             returned_count: length(data),
             has_more: has_more,
             next_cursor: next_cursor
           }
         }}
      rescue
        _ in [Postgrex.Error, DBConnection.ConnectionError] ->
          Error.new(:temporarily_unavailable, :storage_rejected)
      end
    end
  end

  def transaction_history(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  # --- Portfolio Allocation & Daily Valuation History ---

  def allocation(actor), do: read_analytics(actor, :allocation, %{})
  def history(actor, options), do: read_analytics(actor, :history, options)

  def decode_history_query(query) do
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

      cond do
        not valid_date?(from_date) -> {:error, :invalid_date}
        Date.compare(to_date, today) == :gt -> {:error, :invalid_date_range}
        Date.diff(to_date, from_date) not in 0..365 -> {:error, :invalid_date_range}
        true -> {:ok, %{from: from_date, to: to_date}}
      end
    else
      {:error, :invalid_date}
    end
  end

  def validate_range(_, _), do: {:error, :invalid_date}

  # --- Weighted-Average Ledger Math ---

  def exact(fun), do: Decimal.Context.with(%Decimal.Context{precision: 200}, fun)

  def apply_transaction(%{type: "purchase"} = tx, positions) do
    prior = Map.get(positions, tx.player_id, empty_position())
    quantity = prior.quantity + tx.quantity
    basis = Decimal.add(Decimal.mult(prior.average_unit_cost, prior.quantity), tx.total)
    average = basis |> Decimal.div(quantity) |> Decimal.round(@average_decimals, :half_up)

    Map.put(positions, tx.player_id, %{
      quantity: quantity,
      average_unit_cost: average,
      realized_profit_loss: prior.realized_profit_loss
    })
  end

  def apply_transaction(%{type: "sale"} = tx, positions) do
    prior = Map.get(positions, tx.player_id, empty_position())
    cost = Decimal.mult(prior.average_unit_cost, tx.quantity)

    Map.put(positions, tx.player_id, %{
      quantity: prior.quantity - tx.quantity,
      average_unit_cost: prior.average_unit_cost,
      realized_profit_loss: Decimal.add(prior.realized_profit_loss, Decimal.sub(tx.total, cost))
    })
  end

  # --- Private Portfolio Helpers ---

  defp empty_position,
    do: %{quantity: 0, average_unit_cost: Decimal.new(0), realized_profit_loss: Decimal.new(0)}

  defp calculate_open_positions(transactions) do
    exact(fn ->
      transactions
      |> Enum.sort_by(fn tx -> {unix_us(tx.completed_at), tx.type, tx.id} end)
      |> Enum.reduce(%{}, &apply_transaction/2)
      |> Enum.filter(fn {_id, pos} -> pos.quantity > 0 end)
      |> Enum.map(fn {id, pos} -> Map.put(pos, :player_id, id) end)
      |> Enum.sort_by(& &1.player_id)
    end)
  end

  defp build_portfolio_view(transactions) do
    positions = calculate_open_positions(transactions)

    if positions == [] do
      {:ok, []}
    else
      player_ids = Enum.map(positions, & &1.player_id)

      with {:ok, details} <- load_player_details(player_ids) do
        {:ok, exact(fn -> present_positions(positions, details) end)}
      end
    end
  end

  defp load_player_details(player_ids) do
    players =
      Repo.all(from p in Player, where: p.id in ^player_ids, select: {p.id, p.display_name})
      |> Map.new()

    quotes =
      from(q in Quote,
        where: q.player_id in ^player_ids,
        distinct: q.player_id,
        order_by: [
          asc: q.player_id,
          desc: fragment("COALESCE(?, 0)", q.performance_sequence),
          desc: q.effective_at,
          desc: q.inserted_at,
          desc: q.id
        ],
        select: {q.player_id, q.unit_price}
      )
      |> Repo.all()
      |> Map.new()

    if Enum.all?(player_ids, &(Map.has_key?(players, &1) and Map.has_key?(quotes, &1))) do
      {:ok,
       Map.new(player_ids, fn id ->
         {id, %{player_name: Map.fetch!(players, id), current_quote: Map.fetch!(quotes, id)}}
       end)}
    else
      Error.new(:temporarily_unavailable, :quote_unavailable)
    end
  end

  defp present_positions(positions, details) do
    Enum.map(positions, fn pos ->
      detail = Map.fetch!(details, pos.player_id)
      current_value = Decimal.mult(detail.current_quote, pos.quantity)

      unrealized =
        Decimal.mult(Decimal.sub(detail.current_quote, pos.average_unit_cost), pos.quantity)

      Map.merge(pos, %{
        player_name: detail.player_name,
        current_quote: detail.current_quote,
        current_value: current_value,
        unrealized_profit_loss: unrealized
      })
    end)
  end

  defp transaction_query(owner_id) do
    purchases =
      from p in Purchase,
        where: p.buyer_id == ^owner_id,
        select: %{
          id: p.id,
          player_id: p.player_id,
          type: type(^"purchase", :string),
          quantity: p.quantity,
          total: p.total,
          completed_at: p.completed_at
        }

    sales =
      from s in Sale,
        where: s.seller_id == ^owner_id,
        select: %{
          id: s.id,
          player_id: s.player_id,
          type: type(^"sale", :string),
          quantity: s.quantity,
          total: s.total,
          completed_at: s.completed_at
        }

    union_all(purchases, ^sales)
  end

  # --- Private Analytics Helpers ---

  defp read_analytics(%AuthenticatedActor{account_id: owner_id}, mode, options)
       when is_binary(owner_id) do
    with {:ok, _uuid} <- Ecto.UUID.cast(owner_id),
         {:ok, snapshot} <- load_analytics_snapshot(owner_id, mode, options) do
      {:ok, exact(fn -> build_projection(snapshot, mode) end)}
    else
      :error -> Error.new(:unauthenticated, :unauthenticated)
      {:error, reason} -> Error.new(reason, reason)
    end
  end

  defp read_analytics(_, _, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp load_analytics_snapshot(owner_id, mode, options) do
    if Repo.in_transaction?() do
      {:error, :temporarily_unavailable}
    else
      Repo.transaction(fn -> query_analytics_snapshot!(owner_id, mode, options) end)
    end
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] -> {:error, :temporarily_unavailable}
  end

  defp query_analytics_snapshot!(owner_id, mode, options) do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
    %{rows: [[as_of]]} = Repo.query!("SELECT transaction_timestamp()")
    range = resolve_range!(mode, options, DateTime.to_date(as_of))
    cutoff = if mode == :allocation, do: as_of, else: min_time(day_end(range.to), as_of)

    opening =
      if mode == :allocation,
        do: as_of,
        else: DateTime.new!(range.from, ~T[00:00:00], "Etc/UTC")

    transactions =
      from(tx in subquery(transaction_query(owner_id)), where: tx.completed_at <= ^cutoff)
      |> Repo.all()

    player_ids = transactions |> Enum.map(& &1.player_id) |> Enum.uniq()

    players =
      Repo.all(from p in Player, where: p.id in ^player_ids, select: {p.id, p.display_name})
      |> Map.new()

    opening_quotes =
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

    quote_changes =
      Repo.all(
        from q in Quote,
          where:
            q.player_id in ^player_ids and q.effective_at >= ^opening and
              q.effective_at <= ^cutoff
      )

    %{
      as_of: as_of,
      range: range,
      transactions: transactions,
      players: players,
      quotes: opening_quotes ++ quote_changes
    }
  end

  defp resolve_range!(:allocation, _, _), do: nil

  defp resolve_range!(:history, options, today) do
    case validate_range(options, today) do
      {:ok, range} -> range
      {:error, reason} -> Repo.rollback(reason)
    end
  end

  defp build_projection(snapshot, mode) do
    state = %{
      positions: %{},
      quotes: %{},
      purchases: Decimal.new(0),
      sales: Decimal.new(0),
      trades: Enum.sort_by(snapshot.transactions, &{unix_us(&1.completed_at), &1.type, &1.id}),
      pending_quotes: Enum.sort_by(snapshot.quotes, &unix_us(&1.effective_at))
    }

    case mode do
      :allocation ->
        final = advance_to_cutoff(state, snapshot.as_of)
        {positions, totals} = value_positions(final, snapshot.players)
        %{as_of: snapshot.as_of, positions: attach_weights(positions, totals), totals: totals}

      :history ->
        {points, _} =
          Enum.map_reduce(Date.range(snapshot.range.from, snapshot.range.to), state, fn date,
                                                                                        acc ->
            cutoff = min_time(day_end(date), snapshot.as_of)
            next = advance_to_cutoff(acc, cutoff)
            {_positions, totals} = value_positions(next, snapshot.players)

            point =
              Map.merge(totals, %{
                date: date,
                cutoff_at: cutoff,
                partial: date == DateTime.to_date(snapshot.as_of)
              })

            {point, next}
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

  defp advance_to_cutoff(state, cutoff) do
    {applied_trades, remaining_trades} =
      Enum.split_while(state.trades, &(DateTime.compare(&1.completed_at, cutoff) != :gt))

    state =
      Enum.reduce(applied_trades, %{state | trades: remaining_trades}, fn tx, acc ->
        field = if tx.type == "purchase", do: :purchases, else: :sales

        acc
        |> Map.put(:positions, apply_transaction(tx, acc.positions))
        |> Map.update!(field, &Decimal.add(&1, tx.total))
      end)

    {applied_quotes, remaining_quotes} =
      Enum.split_while(state.pending_quotes, &(DateTime.compare(&1.effective_at, cutoff) != :gt))

    selected_quotes = Enum.reduce(applied_quotes, state.quotes, &pick_authoritative_quote/2)

    %{state | quotes: selected_quotes, pending_quotes: remaining_quotes}
  end

  defp pick_authoritative_quote(candidate, selected) do
    Map.update(selected, candidate.player_id, candidate, fn prior ->
      if quote_authority(candidate) > quote_authority(prior), do: candidate, else: prior
    end)
  end

  defp quote_authority(q),
    do: {q.performance_sequence || 0, unix_us(q.effective_at), unix_us(q.inserted_at), q.id}

  defp value_positions(state, players) do
    positions =
      state.positions
      |> Enum.filter(fn {_id, pos} -> pos.quantity > 0 end)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {id, pos} ->
        quote = Map.get(state.quotes, id)
        basis = Decimal.mult(pos.average_unit_cost, pos.quantity)
        market_value = if quote, do: Decimal.mult(quote.unit_price, pos.quantity)

        Map.merge(pos, %{
          player_id: id,
          player_name: Map.fetch!(players, id),
          cost_basis: basis,
          quote:
            quote && Map.take(quote, [:id, :unit_price, :effective_at, :performance_sequence]),
          market_value: market_value,
          unrealized_profit_loss: if(market_value, do: Decimal.sub(market_value, basis))
        })
      end)

    missing_ids = positions |> Enum.filter(&is_nil(&1.market_value)) |> Enum.map(& &1.player_id)
    complete = missing_ids == []
    realized = state.positions |> Map.values() |> sum_field(:realized_profit_loss)
    unrealized = if complete, do: sum_field(positions, :unrealized_profit_loss)

    totals = %{
      market_value: if(complete, do: sum_field(positions, :market_value)),
      cost_basis: sum_field(positions, :cost_basis),
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

  defp attach_weights(positions, totals) do
    Enum.map(positions, fn pos ->
      weight =
        if totals.valuation_complete and Decimal.positive?(totals.market_value) do
          pos.market_value |> Decimal.div(totals.market_value) |> Decimal.round(18, :half_up)
        end

      Map.put(pos, :weight, weight)
    end)
  end

  defp sum_field(rows, field),
    do: Enum.reduce(rows, Decimal.new(0), &Decimal.add(Map.fetch!(&1, field), &2))

  # --- Transaction History Query & Cursor Helpers ---

  defp fetch_purchases(owner, anchor, limit) do
    from(p in Purchase,
      where: p.buyer_id == ^owner,
      select: %{
        id: p.id,
        type: "purchase",
        player_id: p.player_id,
        quantity: p.quantity,
        unit_price: p.unit_price,
        total: p.total,
        quote_id: p.quote_id,
        completed_at: p.completed_at
      }
    )
    |> after_anchor(anchor, "purchase")
    |> order_by([p], desc: p.completed_at, asc: p.id)
    |> limit(^limit)
    |> Repo.all()
  end

  defp fetch_sales(owner, anchor, limit) do
    from(s in Sale,
      where: s.seller_id == ^owner,
      select: %{
        id: s.id,
        type: "sale",
        player_id: s.player_id,
        quantity: s.quantity,
        unit_price: s.unit_price,
        total: s.total,
        quote_id: s.quote_id,
        completed_at: s.completed_at
      }
    )
    |> after_anchor(anchor, "sale")
    |> order_by([s], desc: s.completed_at, asc: s.id)
    |> limit(^limit)
    |> Repo.all()
  end

  defp after_anchor(query, nil, _type), do: query

  defp after_anchor(query, %{completed_at: at, type: cursor_type, id: id}, type) do
    cond do
      type > cursor_type ->
        from(r in query, where: r.completed_at <= ^at)

      type < cursor_type ->
        from(r in query, where: r.completed_at < ^at)

      true ->
        from(r in query, where: r.completed_at < ^at or (r.completed_at == ^at and r.id > ^id))
    end
  end

  defp decode_history_anchor(nil, _owner), do: {:ok, nil}

  defp decode_history_anchor(token, owner) when is_binary(token) and token != "" do
    with {:ok, <<nonce::binary-size(12), tag::binary-size(16), cipher::binary>>} <-
           Base.url_decode64(token, padding: false),
         payload when is_binary(payload) <-
           :crypto.crypto_one_time_aead(
             :aes_256_gcm,
             cursor_key(),
             nonce,
             cipher,
             @cursor_aad,
             tag,
             false
           ),
         {:ok, %{"v" => 1, "owner" => ^owner, "at" => at, "type" => type, "id" => id}}
         when type in ["purchase", "sale"] <- Jason.decode(payload),
         {:ok, completed_at, 0} <- DateTime.from_iso8601(at),
         {:ok, uuid} <- Ecto.UUID.cast(id) do
      {:ok, %{completed_at: completed_at, type: type, id: uuid}}
    else
      _ -> {:error, :invalid_cursor}
    end
  rescue
    _ -> {:error, :invalid_cursor}
  end

  defp decode_history_anchor(_, _), do: {:error, :invalid_cursor}

  defp encode_history_cursor(%{owner: owner, completed_at: at, type: type, id: id}) do
    payload =
      Jason.encode!(%{
        "v" => 1,
        "owner" => owner,
        "at" => DateTime.to_iso8601(at),
        "type" => type,
        "id" => id
      })

    nonce = :crypto.strong_rand_bytes(12)

    {cipher, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, cursor_key(), nonce, payload, @cursor_aad, true)

    Base.url_encode64(nonce <> tag <> cipher, padding: false)
  end

  defp cursor_key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:transaction-history:key:v1")
  end

  defp extract_date_param(pairs, key) do
    selected =
      Enum.filter(pairs, fn {name, _} -> name == key or String.starts_with?(name, key <> "[") end)

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

  defp unix_us(dt), do: DateTime.to_unix(dt, :microsecond)
  defp day_end(date), do: DateTime.new!(date, ~T[23:59:59.999999], "Etc/UTC")
  defp min_time(a, b), do: if(DateTime.compare(a, b) == :gt, do: b, else: a)
end
