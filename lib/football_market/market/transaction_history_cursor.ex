defmodule FootballMarket.Market.TransactionHistoryCursor do
  @moduledoc false
  @aad "football-market:transaction-history:v1"

  def encode(%{owner: owner, completed_at: at, type: type, id: id}) do
    payload =
      Jason.encode!(%{
        "v" => 1,
        "owner" => owner,
        "at" => DateTime.to_iso8601(at),
        "type" => type,
        "id" => id
      })

    nonce = :crypto.strong_rand_bytes(12)
    {cipher, tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, payload, @aad, true)
    Base.url_encode64(nonce <> tag <> cipher, padding: false)
  end

  def decode(token, owner) when is_binary(token) and token != "" do
    with {:ok, <<nonce::binary-size(12), tag::binary-size(16), cipher::binary>>} <-
           Base.url_decode64(token, padding: false),
         payload when is_binary(payload) <-
           :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, cipher, @aad, tag, false),
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

  def decode(_, _), do: {:error, :invalid_cursor}

  defp key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:transaction-history:key:v1")
  end
end
