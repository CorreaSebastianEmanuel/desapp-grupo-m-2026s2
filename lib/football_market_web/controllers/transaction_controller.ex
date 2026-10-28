defmodule FootballMarketWeb.TransactionController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.TransactionJSON

  def index(conn, _params) do
    with {:ok, options} <- pagination(conn.query_string),
         {:ok, page} <- Market.transaction_history(conn.assigns[:authenticated_actor], options) do
      json(conn, %{
        data: Enum.map(page.data, &TransactionJSON.data/1),
        pagination: page.pagination
      })
    else
      {:error, :invalid_page_size} -> error(conn, 400, "invalid_page_size")
      {:error, :invalid_cursor} -> error(conn, 400, "invalid_cursor")
      {:error, %{kind: :unauthenticated}} -> error(conn, 401, "unauthenticated")
      {:error, %{kind: :temporarily_unavailable}} -> error(conn, 503, "temporarily_unavailable")
    end
  end

  defp pagination(query) do
    pairs = Enum.to_list(URI.query_decoder(query))

    with {:ok, size} <- value(pairs, "page_size", :invalid_page_size),
         {:ok, cursor} <- value(pairs, "cursor", :invalid_cursor),
         {:ok, page_size} <- page_size(size),
         :ok <- valid_cursor(cursor) do
      {:ok, %{page_size: page_size, cursor: cursor}}
    end
  rescue
    _ -> {:error, :invalid_page_size}
  end

  defp value(pairs, key, error) do
    case values(pairs, key) do
      {:ok, value} -> structured(pairs, key, value, error)
      :error -> {:error, error}
    end
  end

  defp values(pairs, key) do
    case for({candidate, v} <- pairs, candidate == key, do: v) do
      [] -> {:ok, nil}
      [v] -> {:ok, v}
      _ -> :error
    end
  end

  defp structured(pairs, key, value, error) do
    repeats =
      Enum.any?(pairs, fn {candidate, _} -> String.starts_with?(candidate, key <> "[") end)

    if repeats, do: {:error, error}, else: {:ok, value}
  end

  defp page_size(nil), do: {:ok, 25}

  defp page_size(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value) do
      case Integer.parse(value) do
        {n, ""} when n in 1..100 -> {:ok, n}
        _ -> {:error, :invalid_page_size}
      end
    else
      {:error, :invalid_page_size}
    end
  end

  defp valid_cursor(nil), do: :ok
  defp valid_cursor(""), do: {:error, :invalid_cursor}
  defp valid_cursor(_), do: :ok
  defp error(conn, status, code), do: conn |> put_status(status) |> json(%{error: %{code: code}})
end
