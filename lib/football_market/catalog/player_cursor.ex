defmodule FootballMarket.Catalog.PlayerCursor do
  @moduledoc false

  @scope "players:list"
  @aad "football-market:player-catalog-cursor:v1"
  @filter_keys %{
    league_id: "league_id",
    team_id: "team_id",
    position_id: "position_id"
  }

  def encode(anchor, filters \\ %{})

  def encode(%{name: name, id: id}, filters) when is_binary(name) and is_binary(id) do
    payload_map = %{"v" => 1, "s" => @scope, "n" => name, "i" => id}

    payload_map = cursor_filters(payload_map, filters)

    payload = Jason.encode!(payload_map)
    nonce = :crypto.mac(:hmac, :sha256, key(), payload) |> binary_part(0, 12)

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, payload, @aad, true)

    Base.url_encode64(nonce <> tag <> ciphertext, padding: false)
  end

  def decode(token, filters \\ %{})

  def decode(token, filters) when is_binary(token) and token != "" and is_map(filters) do
    with {:ok, bytes} <- Base.url_decode64(token, padding: false),
         <<nonce::binary-size(12), tag::binary-size(16), ciphertext::binary>> <- bytes,
         payload when is_binary(payload) <-
           :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, ciphertext, @aad, tag, false),
         {:ok, decoded} <- Jason.decode(payload),
         {:ok, name, id} <- validate_payload(decoded, filters),
         true <- is_binary(name) and name != "",
         {:ok, uuid} <- Ecto.UUID.cast(id) do
      {:ok, %{name: name, id: uuid}}
    else
      _ -> {:error, :invalid_cursor}
    end
  rescue
    _ -> {:error, :invalid_cursor}
  end

  def decode(_, _), do: {:error, :invalid_cursor}

  defp validate_payload(%{"v" => 1, "s" => @scope, "n" => name, "i" => id} = payload, filters)
       when map_size(payload) == 4 and map_size(filters) == 0,
       do: {:ok, name, id}

  defp validate_payload(
         %{"v" => 2, "s" => @scope, "n" => name, "i" => id, "f" => stored} = payload,
         filters
       )
       when map_size(payload) == 5 and is_map(stored) and map_size(filters) > 0 and
              not is_map_key(filters, :search_name) do
    expected = canonical_filters(filters)

    if stored == expected and
         Enum.all?(stored, fn {key, value} ->
           key in Map.values(@filter_keys) and canonical_uuid?(value)
         end) do
      {:ok, name, id}
    else
      {:error, :invalid_cursor}
    end
  end

  defp validate_payload(
         %{"v" => 3, "s" => @scope, "n" => name, "i" => id, "f" => stored, "q" => query} = payload,
         filters
       )
       when map_size(payload) == 6 and is_map(stored) and is_binary(query) and
              map_size(filters) > 0 do
    expected = canonical_filters(filters)

    if stored == expected and Map.get(filters, :search_name) == query and
         Enum.all?(stored, fn {key, value} ->
           key in Map.values(@filter_keys) and canonical_uuid?(value)
         end) do
      {:ok, name, id}
    else
      {:error, :invalid_cursor}
    end
  end

  defp validate_payload(_, _), do: {:error, :invalid_cursor}

  defp canonical_filters(filters) do
    filters
    |> Enum.reject(fn {key, _value} -> key == :search_name end)
    |> Map.new(fn {key, value} -> {Map.fetch!(@filter_keys, key), value} end)
  end

  defp cursor_filters(payload_map, filters) do
    if map_size(filters) == 0 do
      payload_map
    else
      filters = Map.new(filters)
      version = if Map.has_key?(filters, :search_name), do: 3, else: 2

      payload_map =
        payload_map |> Map.put("v", version) |> Map.put("f", canonical_filters(filters))

      if version == 3, do: Map.put(payload_map, "q", filters.search_name), else: payload_map
    end
  end

  defp canonical_uuid?(value) when is_binary(value) do
    match?({:ok, ^value}, Ecto.UUID.cast(value))
  end

  defp canonical_uuid?(_), do: false

  defp key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:player-catalog-cursor:key:v1")
  end
end
