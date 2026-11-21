defmodule FootballMarket.Market.TransactionHistory do
  @moduledoc "Read-only, authenticated user's immutable purchase and sale history."
  import Ecto.Query

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, Purchase, Sale}
  alias FootballMarket.Repo

  @cursor_aad "football-market:transaction-history:v1"

  def list(%AuthenticatedActor{account_id: owner}, %{page_size: size, cursor: cursor})
      when is_binary(owner) do
    with {:ok, anchor} <- decode_anchor(cursor, owner) do
      safely(fn -> page(owner, size, anchor) end)
    end
  end

  def list(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp page(owner, size, anchor) do
    rows =
      (purchases(owner, anchor, size + 1) ++ sales(owner, anchor, size + 1))
      |> Enum.sort_by(&order_key/1)

    has_more = length(rows) > size
    data = Enum.take(rows, size)

    {:ok,
     %{
       data: data,
       pagination: %{
         page_size: size,
         returned_count: length(data),
         has_more: has_more,
         next_cursor: continuation(data, owner, has_more)
       }
     }}
  end

  defp order_key(row), do: {-DateTime.to_unix(row.completed_at, :microsecond), row.type, row.id}

  defp continuation(_data, _owner, false), do: nil

  defp continuation(data, owner, true) do
    data
    |> List.last()
    |> Map.take([:completed_at, :type, :id])
    |> Map.put(:owner, owner)
    |> encode_cursor()
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

  defp decode_anchor(nil, _owner), do: {:ok, nil}
  defp decode_anchor(cursor, owner), do: decode_cursor(cursor, owner)

  defp encode_cursor(%{owner: owner, completed_at: at, type: type, id: id}) do
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

  defp decode_cursor(token, owner) when is_binary(token) and token != "" do
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
         {:ok, id} <- Ecto.UUID.cast(id) do
      {:ok, %{completed_at: completed_at, type: type, id: id}}
    else
      _ -> {:error, :invalid_cursor}
    end
  rescue
    _ -> {:error, :invalid_cursor}
  end

  defp decode_cursor(_, _), do: {:error, :invalid_cursor}

  defp cursor_key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:transaction-history:key:v1")
  end

  defp safely(fun) do
    fun.()
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] ->
      Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
