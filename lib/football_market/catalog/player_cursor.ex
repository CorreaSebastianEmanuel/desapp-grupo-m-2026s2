defmodule FootballMarket.Catalog.PlayerCursor do
  @moduledoc false

  @version 1
  @scope "players:list"
  @aad "football-market:player-catalog-cursor:v1"

  def encode(%{name: name, id: id}) when is_binary(name) and is_binary(id) do
    payload = Jason.encode!(%{"v" => @version, "s" => @scope, "n" => name, "i" => id})
    nonce = :crypto.mac(:hmac, :sha256, key(), payload) |> binary_part(0, 12)

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, payload, @aad, true)

    Base.url_encode64(nonce <> tag <> ciphertext, padding: false)
  end

  def decode(token) when is_binary(token) and token != "" do
    with {:ok, bytes} <- Base.url_decode64(token, padding: false),
         <<nonce::binary-size(12), tag::binary-size(16), ciphertext::binary>> <- bytes,
         payload when is_binary(payload) <-
           :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, ciphertext, @aad, tag, false),
         {:ok, %{"v" => @version, "s" => @scope, "n" => name, "i" => id}} <- Jason.decode(payload),
         true <- is_binary(name) and name != "",
         {:ok, uuid} <- Ecto.UUID.cast(id) do
      {:ok, %{name: name, id: uuid}}
    else
      _ -> {:error, :invalid_cursor}
    end
  rescue
    _ -> {:error, :invalid_cursor}
  end

  def decode(_), do: {:error, :invalid_cursor}

  defp key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:player-catalog-cursor:key:v1")
  end
end
