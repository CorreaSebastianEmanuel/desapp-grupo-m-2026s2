defmodule FootballMarketWeb.PlayerController do
  use FootballMarketWeb, :controller

  alias FootballMarket.Catalog

  def index(conn, _params) do
    with {:ok, page_size, cursor, filters} <- pagination_params(conn.query_string),
         {:ok, page} <-
           Catalog.list_player_page(%{page_size: page_size, cursor: cursor, filters: filters}) do
      render(conn, :index, page: page)
    else
      {:error, :invalid_page_size} -> error(conn, 400, "invalid_page_size")
      {:error, :invalid_league_id} -> error(conn, 400, "invalid_league_id")
      {:error, :invalid_team_id} -> error(conn, 400, "invalid_team_id")
      {:error, :invalid_position_id} -> error(conn, 400, "invalid_position_id")
      {:error, :invalid_cursor} -> error(conn, 400, "invalid_cursor")
    end
  end

  def show(conn, %{"player_id" => player_id}) do
    case Catalog.get_player_detail(player_id) do
      {:ok, player} -> render(conn, :show, player: player)
      {:error, :not_found} -> error(conn, 404, "player_not_found")
    end
  end

  defp pagination_params(query_string) do
    pairs = Enum.to_list(URI.query_decoder(query_string))

    with :ok <- reject_structured_key(pairs, "page_size", :invalid_page_size),
         {:ok, page_size_value} <- unique_value(pairs, "page_size", :invalid_page_size),
         {:ok, page_size} <- parse_page_size(page_size_value),
         {:ok, league_id} <- filter_value(pairs, "league_id", :invalid_league_id),
         {:ok, team_id} <- filter_value(pairs, "team_id", :invalid_team_id),
         {:ok, position_id} <- filter_value(pairs, "position_id", :invalid_position_id),
         :ok <- reject_structured_key(pairs, "cursor", :invalid_cursor),
         {:ok, cursor} <- unique_value(pairs, "cursor", :invalid_cursor),
         :ok <- validate_cursor_presence(cursor) do
      filters =
        [league_id: league_id, team_id: team_id, position_id: position_id]
        |> Enum.reject(fn {_key, value} -> is_nil(value) end)
        |> Map.new()

      {:ok, page_size, cursor, filters}
    end
  rescue
    _ -> {:error, :invalid_page_size}
  end

  defp reject_structured_key(pairs, key, error) do
    if Enum.any?(pairs, fn {candidate, _value} -> String.starts_with?(candidate, key <> "[") end),
      do: {:error, error},
      else: :ok
  end

  defp unique_value(pairs, key, error) do
    case for({^key, value} <- pairs, do: value) do
      [] -> {:ok, nil}
      [value] -> {:ok, value}
      _ -> {:error, error}
    end
  end

  defp filter_value(pairs, key, error) do
    with :ok <- reject_structured_key(pairs, key, error),
         {:ok, value} <- unique_value(pairs, key, error) do
      case value do
        nil ->
          {:ok, nil}

        value ->
          if Regex.match?(~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/, value) do
            case Ecto.UUID.cast(value) do
              {:ok, uuid} -> {:ok, uuid}
              :error -> {:error, error}
            end
          else
            {:error, error}
          end
      end
    end
  end

  defp parse_page_size(nil), do: {:ok, 25}

  defp parse_page_size(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value) do
      case Integer.parse(value) do
        {size, ""} when size in 1..100 -> {:ok, size}
        _ -> {:error, :invalid_page_size}
      end
    else
      {:error, :invalid_page_size}
    end
  end

  defp validate_cursor_presence(nil), do: :ok
  defp validate_cursor_presence(""), do: {:error, :invalid_cursor}
  defp validate_cursor_presence(_cursor), do: :ok

  defp error(conn, status, code), do: conn |> put_status(status) |> json(%{error: %{code: code}})
end
