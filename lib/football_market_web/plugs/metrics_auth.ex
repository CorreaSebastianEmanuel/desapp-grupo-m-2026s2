defmodule FootballMarketWeb.Plugs.MetricsAuth do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    expected = Application.get_env(:football_market, :metrics_scrape_token)

    if valid_token?(get_req_header(conn, "authorization"), expected) do
      conn
    else
      conn
      |> put_resp_header("cache-control", "no-store")
      |> send_resp(:unauthorized, "Unauthorized")
      |> halt()
    end
  end

  defp valid_token?(["Bearer " <> supplied], expected)
       when is_binary(expected) and byte_size(expected) > 0 and
              byte_size(supplied) == byte_size(expected) do
    Plug.Crypto.secure_compare(supplied, expected)
  end

  defp valid_token?(_headers, _expected), do: false
end
