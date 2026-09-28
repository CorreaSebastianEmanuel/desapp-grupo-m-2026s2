defmodule FootballMarket.Catalog.PlayerCursorTest do
  use ExUnit.Case, async: true

  alias FootballMarket.Catalog.PlayerCursor

  test "round trips an opaque anchor and rejects malformed or tampered values" do
    anchor = %{name: "alice", id: Ecto.UUID.generate()}
    cursor = PlayerCursor.encode(anchor)

    assert {:ok, ^anchor} = PlayerCursor.decode(cursor)
    refute cursor =~ "alice"
    assert {:error, :invalid_cursor} = PlayerCursor.decode("")
    assert {:error, :invalid_cursor} = PlayerCursor.decode("not-a-cursor")

    <<first, rest::binary>> = cursor
    tampered = <<Bitwise.bxor(first, 1), rest::binary>>
    assert {:error, :invalid_cursor} = PlayerCursor.decode(tampered)
  end

  test "rejects wrong versions, scopes, shapes, and identifier types uniformly" do
    id = Ecto.UUID.generate()

    for payload <- [
          %{"v" => 2, "s" => "players:list", "n" => "alice", "i" => id},
          %{"v" => 1, "s" => "another:endpoint", "n" => "alice", "i" => id},
          %{"v" => 1, "s" => "players:list", "n" => "alice", "i" => "bad"},
          %{"v" => 1, "s" => "players:list", "n" => 7, "i" => id},
          %{"v" => 1, "s" => "players:list", "i" => id}
        ] do
      assert {:error, :invalid_cursor} = payload |> encrypted_token() |> PlayerCursor.decode()
    end
  end

  defp encrypted_token(payload) do
    key =
      :football_market
      |> Application.fetch_env!(FootballMarketWeb.Endpoint)
      |> Keyword.fetch!(:secret_key_base)
      |> then(&:crypto.mac(:hmac, :sha256, &1, "football-market:player-catalog-cursor:key:v1"))

    nonce = :crypto.strong_rand_bytes(12)
    json = Jason.encode!(payload)

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(
        :aes_256_gcm,
        key,
        nonce,
        json,
        "football-market:player-catalog-cursor:v1",
        true
      )

    Base.url_encode64(nonce <> tag <> ciphertext, padding: false)
  end
end
