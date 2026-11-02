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
        form(
          conn,
          params,
          503,
          "El inicio de sesión no está disponible temporalmente. Probá de nuevo."
        )

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
        form(
          conn,
          params,
          503,
          "El inicio de sesión no está disponible temporalmente. Probá de nuevo."
        )
    end
  end

  def create(conn, params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, _} ->
        redirect303(conn, BrowserAuth.destination(params["return_to"]))

      {:error, :unavailable} ->
        form(
          conn,
          params,
          503,
          "El inicio de sesión no está disponible temporalmente. Probá de nuevo."
        )

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
          "La creación de cuentas no está disponible temporalmente. Probá de nuevo."
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
          "La creación de cuentas no está disponible temporalmente. Probá de nuevo."
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
            "No pudimos crear la cuenta. Revisá los datos e intentá de nuevo."
          )
      end
    else
      registration_form(conn, params, 422, "Las contraseñas no coinciden. Intentá de nuevo.")
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
        form(
          conn,
          params,
          503,
          "El inicio de sesión no está disponible temporalmente. Probá de nuevo."
        )

      {:error, :expired_form} ->
        new_anonymous(conn, params, 422, "El formulario venció. Volvé a iniciar sesión.")

      _ ->
        form(conn, params, 422, "No se pudo iniciar sesión con esos datos.")
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
        |> render(:sign_out_unavailable)
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

  defp notice_message("ended"), do: "Tu sesión finalizó. Iniciá sesión otra vez."
  defp notice_message("created"), do: "Cuenta creada. Iniciá sesión para continuar."
  defp notice_message(_), do: nil

  defp redirect303(conn, path), do: conn |> put_status(303) |> redirect(to: path)
  defp no_store(conn, _), do: put_resp_header(conn, "cache-control", "no-store")
end
