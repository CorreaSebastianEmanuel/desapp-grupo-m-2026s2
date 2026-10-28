defmodule FootballMarket.Market.TransactionHistoryStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Market.{Error, Purchase, Sale, TransactionHistoryCursor}

  def list(owner, %{page_size: size, cursor: cursor}) do
    with {:ok, anchor} <- anchor(cursor, owner) do
      safely(fn ->
        rows =
          (purchases(owner, anchor, size + 1) ++ sales(owner, anchor, size + 1))
          |> Enum.sort_by(fn row ->
            {-DateTime.to_unix(row.completed_at, :microsecond), row.type, row.id}
          end)

        has_more = length(rows) > size
        data = Enum.take(rows, size)

        next =
          if has_more,
            do:
              data
              |> List.last()
              |> Map.take([:completed_at, :type, :id])
              |> Map.put(:owner, owner)
              |> TransactionHistoryCursor.encode(),
            else: nil

        {:ok,
         %{
           data: data,
           pagination: %{
             page_size: size,
             returned_count: length(data),
             has_more: has_more,
             next_cursor: next
           }
         }}
      end)
    end
  end

  defp purchases(owner, anchor, limit) do
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

  defp sales(owner, anchor, limit) do
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
        from(row in query, where: row.completed_at <= ^at)

      type < cursor_type ->
        from(row in query, where: row.completed_at < ^at)

      true ->
        from(row in query,
          where: row.completed_at < ^at or (row.completed_at == ^at and row.id > ^id)
        )
    end
  end

  defp anchor(nil, _owner), do: {:ok, nil}
  defp anchor(cursor, owner), do: TransactionHistoryCursor.decode(cursor, owner)

  defp safely(fun) do
    fun.()
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] ->
      Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
