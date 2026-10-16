defmodule FootballMarketWeb.Plugs.BrowserAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias FootballMarket.Accounts.BrowserSessions
  def init(options), do: options
  def destination(path) when path in ["/portfolio", "/conditional-orders"], do: path
  def destination(_), do: "/portfolio"

  def call(conn, _) do
    conn = put_resp_header(conn, "cache-control", "no-store")

    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} ->
        assign(conn, :browser_actor, actor)

      {:error, :unavailable} ->
        conn
        |> put_status(503)
        |> html(
          ~s(<main><h1>Authentication temporarily unavailable</h1><p role="alert">Please retry sign in.</p><a href="/sign-in">Retry sign in</a></main>)
        )
        |> halt()

      {:error, _reason} ->
        # Expired transport may already have been removed by the browser. Use the
        # same recovery notice for missing/invalid authority without retaining it.
        conn
        |> put_status(303)
        |> redirect(
          to:
            "/sign-in?return_to=" <>
              URI.encode_www_form(destination(conn.request_path)) <> "&notice=ended"
        )
        |> halt()
    end
  end

  def live_session(conn), do: %{"actor" => conn.assigns.browser_actor}
end
