defmodule FootballMarketWeb.SessionController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.BrowserSessions
  alias FootballMarketWeb.Plugs.BrowserAuth
  plug :put_view, html: FootballMarketWeb.SessionHTML
  plug :no_store

  def new(conn, params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, _} ->
        redirect303(conn, BrowserAuth.destination(params["return_to"]))

      {:error, :unavailable} ->
        form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")

      _ ->
        case BrowserSessions.create_anonymous() do
          {:ok, handle} ->
            conn
            |> put_session(:browser_handle, handle)
            |> form(
              params,
              200,
              if(params["notice"] == "ended", do: "Your session ended. Please sign in again.")
            )

          _ ->
            form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")
        end
    end
  end

  def create(conn, params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, _} ->
        redirect303(conn, BrowserAuth.destination(params["return_to"]))

      {:error, :unavailable} ->
        form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")

      _ ->
        sign_in(conn, params)
    end
  end

  defp sign_in(conn, params) do
    with {:ok, user} <- Accounts.verify_browser_credentials(params),
         {:ok, handle} <-
           BrowserSessions.authenticate(get_session(conn, :browser_handle), user.id) do
      Plug.CSRFProtection.delete_csrf_token()

      conn
      |> clear_session()
      |> configure_session(renew: true)
      |> put_session(:browser_handle, handle)
      |> redirect303(BrowserAuth.destination(params["return_to"]))
    else
      {:error, :unavailable} ->
        form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")

      _ ->
        form(conn, params, 422, "Unable to sign in with those credentials.")
    end
  end

  def delete(conn, _params) do
    case BrowserSessions.revoke(get_session(conn, :browser_handle)) do
      :ok ->
        Plug.CSRFProtection.delete_csrf_token()

        conn
        |> clear_session()
        |> configure_session(drop: true)
        |> redirect303("/sign-in?notice=ended")

      _ ->
        conn
        |> put_status(503)
        |> html(
          ~s(<main><h1>Sign out temporarily unavailable</h1><p role="alert">Your session could not be ended. Please retry sign out.</p><form method="post" action="/sign-out"><input type="hidden" name="_csrf_token" value="#{get_csrf_token()}"><button>Retry sign out</button></form></main>)
        )
    end
  end

  defp form(conn, params, status, message) do
    conn
    |> put_status(status)
    |> render(:new,
      email: if(is_binary(params["email"]), do: params["email"], else: ""),
      return_to: BrowserAuth.destination(params["return_to"]),
      message: message,
      invalid: status == 422
    )
  end

  defp redirect303(conn, path), do: conn |> put_status(303) |> redirect(to: path)
  defp no_store(conn, _), do: put_resp_header(conn, "cache-control", "no-store")
end
