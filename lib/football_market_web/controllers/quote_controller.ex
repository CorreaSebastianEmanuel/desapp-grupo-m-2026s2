defmodule FootballMarketWeb.QuoteController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Quotes

  def current(conn, %{"player_id" => id}), do: respond(conn, Quotes.latest(id), :show)
  def history(conn, %{"player_id" => id}), do: respond(conn, Quotes.list_history(id), :index)

  def at(conn, %{"player_id" => id}) do
    case requested_date(conn.query_string) do
      {:ok, date} -> respond(conn, Quotes.at_date(id, date), :show)
      {:error, :invalid_date} -> respond(conn, {:error, :invalid_date}, :show)
    end
  end

  defp requested_date(query_string) do
    values =
      query_string
      |> URI.query_decoder()
      |> Enum.filter(fn {key, _} -> key == "date" or String.starts_with?(key, "date[") end)

    with [{"date", value}] <- values,
         true <- Regex.match?(~r/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/, value),
         {:ok, date} <- Date.from_iso8601(value) do
      {:ok, date}
    else
      _ -> {:error, :invalid_date}
    end
  rescue
    _ -> {:error, :invalid_date}
  end

  defp respond(conn, {:ok, records}, :index), do: render(conn, :index, quotes: records)
  defp respond(conn, {:ok, record}, :show), do: render(conn, :show, quote: record)

  defp respond(conn, {:error, reason}, _) do
    status =
      case reason do
        :invalid_date -> 400
        :player_not_found -> 404
        :quote_not_found -> 404
        :temporarily_unavailable -> 503
      end

    conn |> put_status(status) |> json(%{error: %{code: Atom.to_string(reason)}})
  end
end
