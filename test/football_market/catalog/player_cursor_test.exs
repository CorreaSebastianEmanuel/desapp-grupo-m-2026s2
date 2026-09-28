defmodule FootballMarket.Catalog.PlayerCursorTest do
  use ExUnit.Case, async: false

  alias FootballMarket.Catalog.PlayerCursor

  # Generated before TASK-012 changes with:
  # MIX_ENV=test mix run -e 'anchor = %{name: "alice", id: "00000000-0000-4000-8000-000000000011"}; IO.puts(FootballMarket.Catalog.PlayerCursor.encode(anchor))'

  test "accepts the literal pre-change v1 cursor only without filters" do
    cursor = File.read!("test/fixtures/player_catalog_v1_cursor.txt") |> String.trim()
    anchor = %{name: "alice", id: "00000000-0000-4000-8000-000000000011"}
    assert PlayerCursor.encode(anchor) == cursor
    assert {:ok, ^anchor} = PlayerCursor.decode(cursor, %{})

    assert {:error, :invalid_cursor} =
             PlayerCursor.decode(cursor, %{team_id: Ecto.UUID.generate()})
  end

  test "filtered v2 round trips and binds normalized filters" do
    anchor = %{name: "alice", id: Ecto.UUID.generate()}
    filters = %{league_id: Ecto.UUID.generate(), team_id: Ecto.UUID.generate()}
    cursor = PlayerCursor.encode(anchor, filters)
    assert {:ok, ^anchor} = PlayerCursor.decode(cursor, filters)
    refute cursor =~ anchor.name
    refute cursor =~ filters.league_id
    assert {:error, :invalid_cursor} = PlayerCursor.decode(cursor, %{})

    assert {:error, :invalid_cursor} =
             PlayerCursor.decode(cursor, %{league_id: filters.league_id})
  end

  test "rejects malformed v2 payloads and all filter-set mismatches" do
    id = Ecto.UUID.generate()
    team_id = Ecto.UUID.generate()
    filters = %{team_id: team_id}

    valid = %{
      "v" => 2,
      "s" => "players:list",
      "n" => "alice",
      "i" => id,
      "f" => %{"team_id" => team_id}
    }

    for payload <- [
          %{valid | "v" => 3},
          %{valid | "s" => "other"},
          %{valid | "f" => %{"team_id" => "bad"}},
          %{valid | "f" => %{"team_id" => String.upcase(team_id)}},
          %{valid | "f" => %{"unknown" => team_id}},
          Map.put(valid, "extra", 1),
          Map.delete(valid, "f"),
          Map.put(%{"v" => 1, "s" => "players:list", "n" => "alice", "i" => id}, "f", %{})
        ] do
      assert {:error, :invalid_cursor} =
               payload |> encrypted_token() |> PlayerCursor.decode(filters)
    end

    cursor = PlayerCursor.encode(%{name: "alice", id: id}, filters)

    assert {:error, :invalid_cursor} =
             PlayerCursor.decode(cursor, %{team_id: Ecto.UUID.generate()})

    assert {:error, :invalid_cursor} =
             PlayerCursor.decode(cursor, %{team_id: team_id, league_id: Ecto.UUID.generate()})
  end

  test "existing key changes invalidate both cursor versions until restored" do
    legacy = File.read!("test/fixtures/player_catalog_v1_cursor.txt") |> String.trim()
    filters = %{team_id: Ecto.UUID.generate()}
    filtered = PlayerCursor.encode(%{name: "alice", id: Ecto.UUID.generate()}, filters)
    original = Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)

    try do
      Application.put_env(
        :football_market,
        FootballMarketWeb.Endpoint,
        Keyword.put(original, :secret_key_base, String.duplicate("changed-test-key", 5))
      )

      assert {:error, :invalid_cursor} = PlayerCursor.decode(legacy)
      assert {:error, :invalid_cursor} = PlayerCursor.decode(filtered, filters)
    after
      Application.put_env(:football_market, FootballMarketWeb.Endpoint, original)
    end

    assert {:ok, _} = PlayerCursor.decode(legacy)
    assert {:ok, _} = PlayerCursor.decode(filtered, filters)
  end

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
