defmodule FootballMarketWeb.SessionController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.{BrowserSessions, User}
  alias FootballMarketWeb.Plugs.BrowserAuth
  alias FootballMarketWeb.Plugs.RequestQuota, as: QuotaPlug
  alias FootballMarketWeb.RequestQuota
  plug :put_view, html: FootballMarketWeb.SessionHTML
  plug :no_store
  plug QuotaPlug, :sign_in_ip when action == :create
  plug QuotaPlug, :registration when action == :create_registration
  plug :audit_actor when action == :delete

  def new(conn, params) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} ->
        conn
        |> assign(:browser_actor, actor)
        |> redirect303(BrowserAuth.destination(params["return_to"]))

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
    params =
      conn.body_params
      |> Map.take(~w(email password))
      |> Map.put("return_to", params["return_to"])

    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} ->
        conn
        |> assign(:browser_actor, actor)
        |> redirect303(BrowserAuth.destination(params["return_to"]))

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
      {:ok, actor} ->
        conn |> assign(:browser_actor, actor) |> redirect303("/portfolio")

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

  def create_registration(conn, _params) do
    params = Map.take(conn.body_params, ~w(email password password_confirmation))

    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} ->
        conn |> assign(:browser_actor, actor) |> redirect303("/portfolio")

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
    with {:ok, user} <- verify_credentials(params),
         {:ok, handle} <-
           authenticate_anonymous(conn, user.id) do
      Plug.CSRFProtection.delete_csrf_token()

      conn
      |> assign(:audit_account_id, user.id)
      |> clear_session()
      |> configure_session(renew: true)
      |> put_session(:browser_handle, handle)
      |> redirect303(BrowserAuth.destination(params["return_to"]))
    else
      {:error, {:limited, _} = reason} ->
        QuotaPlug.browser_error(conn, reason)

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

  defp verify_credentials(params) do
    with {:ok, reservation} <- reserve_identifier(User.normalize_email(params["email"])) do
      result = Accounts.verify_browser_credentials(params)

      case result do
        {:error, :invalid} -> result
        _ -> release_identifier(reservation, result)
      end
    end
  end

  defp reserve_identifier(identifier) when identifier in [nil, ""], do: {:ok, nil}

  defp reserve_identifier(identifier),
    do: RequestQuota.take(:sign_in_identifier, :crypto.hash(:sha256, identifier))

  defp release_identifier(nil, result), do: result

  defp release_identifier(reservation, result) do
    with :ok <- RequestQuota.release(reservation), do: result
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

  defp audit_actor(conn, _) do
    case BrowserSessions.validate(get_session(conn, :browser_handle)) do
      {:ok, actor} -> assign(conn, :browser_actor, actor)
      _ -> conn
    end
  end

  defp no_store(conn, _), do: put_resp_header(conn, "cache-control", "no-store")
end
