defmodule FootballMarket.Market.PortfolioStore do
  @moduledoc false
  import Ecto.Query

  alias FootballMarket.{Catalog.Player, Market.Purchase, Market.Quote, Market.Sale, Repo}
  alias FootballMarket.Market.Error

  def transactions(owner) do
    {:ok, Repo.all(transaction_query(owner))}
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def transaction_query(owner) do
    purchases =
      from(p in Purchase,
        where: p.buyer_id == ^owner,
        select: %{
          id: p.id,
          player_id: p.player_id,
          type: type(^"purchase", :string),
          quantity: p.quantity,
          total: p.total,
          completed_at: p.completed_at
        }
      )

    sales =
      from(s in Sale,
        where: s.seller_id == ^owner,
        select: %{
          id: s.id,
          player_id: s.player_id,
          type: type(^"sale", :string),
          quantity: s.quantity,
          total: s.total,
          completed_at: s.completed_at
        }
      )

    # Both trade kinds are fetched in one statement, so the reducer reads a
    # single committed consistent snapshot and no committed trade can interleave.
    union_all(purchases, ^sales)
  end

  def details(player_ids) do
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
       Map.new(player_ids, fn player_id ->
         {player_id,
          %{
            player_name: Map.fetch!(players, player_id),
            current_quote: Map.fetch!(quotes, player_id)
          }}
       end)}
    else
      Error.new(:temporarily_unavailable, :quote_unavailable)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
