defmodule FootballMarketWeb.Plugs.BrowserOrigin do
  @moduledoc "Reject cross-origin browser mutations in addition to CSRF protection."
  import Plug.Conn
  def init(options), do: options

  def call(conn, _) when conn.method in ["POST", "PUT", "PATCH", "DELETE"] do
    expected =
      URI.to_string(%URI{scheme: Atom.to_string(conn.scheme), host: conn.host, port: conn.port})

    case get_req_header(conn, "origin") do
      [] ->
        conn

      [^expected] ->
        conn

      _ ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(
          403,
          ~s(<main><h1>Access denied</h1><p role="alert">This request could not be accepted.</p><a href="/sign-in">Sign in</a></main>)
        )
        |> halt()
    end
  end

  def call(conn, _), do: conn
end
