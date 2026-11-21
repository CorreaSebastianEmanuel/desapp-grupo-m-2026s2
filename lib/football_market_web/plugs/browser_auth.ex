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

defmodule FootballMarketWeb.Plugs.BrowserCookie do
  @moduledoc "Caps cookie retention at the immutable server deadline after session encoding."
  import Plug.Conn
  alias FootballMarket.Accounts.BrowserSessions

  def init(options), do: options

  def call(conn, _) do
    register_before_send(conn, fn conn ->
      with %{value: _} = cookie <- conn.resp_cookies["_football_market_key"],
           {:ok, actor} <- BrowserSessions.validate(get_session(conn, :browser_handle)) do
        remaining = DateTime.diff(actor.expires_at, BrowserSessions.now(), :microsecond)
        seconds = max(div(remaining + 999_999, 1_000_000), 0)

        %{
          conn
          | resp_cookies:
              Map.put(
                conn.resp_cookies,
                "_football_market_key",
                Map.put(cookie, :max_age, seconds)
              )
        }
      else
        _ -> conn
      end
    end)
  end
end

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
          ~s(<main><h1>Acceso denegado</h1><p role="alert">No se pudo aceptar esta solicitud.</p><a href="/sign-in">Iniciar sesión</a></main>)
        )
        |> halt()
    end
  end

  def call(conn, _), do: conn
end
