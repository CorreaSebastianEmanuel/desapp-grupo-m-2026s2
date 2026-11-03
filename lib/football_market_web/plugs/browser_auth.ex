defmodule FootballMarketWeb.Plugs.BrowserAuth do
  @moduledoc false
  import Plug.Conn
  import Phoenix.Controller
  alias FootballMarket.Accounts.BrowserSessions
  def init(options), do: options

  def destination(path) when path in ["/portfolio", "/conditional-orders", "/administration"],
    do: path

  def destination(_), do: "/portfolio"

  def call(conn, :administrator), do: administrator(conn, [])

  def call(conn, _) do
    conn = put_resp_header(conn, "cache-control", "no-store")

    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} ->
        assign(conn, :browser_actor, actor)

      {:error, :unavailable} ->
        conn
        |> put_status(503)
        |> html(
          ~s(<main><h1>El inicio de sesión no está disponible</h1><p role="alert">Probá de nuevo en unos instantes.</p><a href="/sign-in">Volver a intentar</a></main>)
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

  def administrator(conn, _) do
    actor = conn.assigns.browser_actor

    domain_actor = %FootballMarket.Accounts.AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }

    if FootballMarket.Accounts.administrator?(domain_actor) do
      conn
    else
      conn |> put_status(403) |> html("<main><h1>Acceso restringido</h1></main>") |> halt()
    end
  end

  def live_session(conn), do: %{"actor" => conn.assigns.browser_actor}
end
