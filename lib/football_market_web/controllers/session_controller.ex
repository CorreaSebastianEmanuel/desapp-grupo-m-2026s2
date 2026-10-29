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
        new_anonymous(conn, params)
    end
  end

  defp new_anonymous(conn, params, status \\ 200, message \\ nil) do
    case BrowserSessions.create_anonymous() do
      {:ok, handle} ->
        conn
        |> put_session(:browser_handle, handle)
        |> form(
          params,
          status,
          message || notice_message(params["notice"])
        )

      _ ->
        form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")
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

  def new_registration(conn, _params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, _} ->
        redirect303(conn, "/portfolio")

      {:error, :unavailable} ->
        registration_form(
          conn,
          %{},
          503,
          "Account creation is temporarily unavailable. Please retry."
        )

      _ ->
        registration_form(conn, %{}, 200, nil)
    end
  end

  def create_registration(conn, params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, _} ->
        redirect303(conn, "/portfolio")

      {:error, :unavailable} ->
        registration_form(
          conn,
          params,
          503,
          "Account creation is temporarily unavailable. Please retry."
        )

      _ ->
        register(conn, params)
    end
  end

  defp register(conn, params) do
    if params["password"] == params["password_confirmation"] do
      case Accounts.register_user(%{
             "email" => params["email"],
             "password" => params["password"]
           }) do
        {:ok, _user} ->
          redirect303(conn, "/sign-in?notice=created")

        {:error, _changeset} ->
          registration_form(
            conn,
            params,
            422,
            "We couldn't create the account. Check the details and try again."
          )
      end
    else
      registration_form(conn, params, 422, "Passwords do not match. Please try again.")
    end
  end

  defp sign_in(conn, params) do
    with {:ok, user} <- Accounts.verify_browser_credentials(params),
         {:ok, handle} <-
           authenticate_anonymous(conn, user.id) do
      Plug.CSRFProtection.delete_csrf_token()

      conn
      |> clear_session()
      |> configure_session(renew: true)
      |> put_session(:browser_handle, handle)
      |> redirect303(BrowserAuth.destination(params["return_to"]))
    else
      {:error, :unavailable} ->
        form(conn, params, 503, "Authentication temporarily unavailable. Please retry.")

      {:error, :expired_form} ->
        new_anonymous(conn, params, 422, "Your sign-in form expired. Please try again.")

      _ ->
        form(conn, params, 422, "Unable to sign in with those credentials.")
    end
  end

  defp authenticate_anonymous(conn, user_id) do
    case BrowserSessions.authenticate(get_session(conn, :browser_handle), user_id) do
      {:error, :invalid} -> {:error, :expired_form}
      result -> result
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

  defp registration_form(conn, params, status, message) do
    conn
    |> put_status(status)
    |> render(:register,
      email: if(is_binary(params["email"]), do: params["email"], else: ""),
      message: message,
      invalid: status == 422
    )
  end

  defp notice_message("ended"), do: "Your session ended. Please sign in again."
  defp notice_message("created"), do: "Account created. Sign in to continue."
  defp notice_message(_), do: nil

  defp redirect303(conn, path), do: conn |> put_status(303) |> redirect(to: path)
  defp no_store(conn, _), do: put_resp_header(conn, "cache-control", "no-store")
end
