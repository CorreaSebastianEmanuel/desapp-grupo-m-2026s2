defmodule FootballMarketWeb.UserAuth do
  @moduledoc """
  Browser session authentication for LiveView pages.

  The session holds the short-lived access token issued by
  `FootballMarket.Accounts.login/1`. Every dead render, LiveView mount,
  parameter change, and LiveView event revalidates it through Accounts, so a
  browser session ends exactly when its token expires.
  """
  use FootballMarketWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias FootballMarket.Accounts

  @login_required "You must log in to access this page."
  @session_expired "Your session expired. Log in again."

  def signed_in_path, do: ~p"/players"

  @doc "Starts a fresh browser session for a token just issued by Accounts."
  def log_in_user(conn, token) do
    case Accounts.validate_access_token(token) do
      {:ok, %{token_id: token_id}} ->
        return_to = get_session(conn, :user_return_to)

        conn
        |> renew_session()
        |> put_session(:access_token, token)
        |> put_session(:live_socket_id, live_socket_id(token_id))
        |> redirect(to: return_to || signed_in_path())

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  @doc "Ends the browser session and disconnects its LiveView sockets."
  def log_out_user(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      FootballMarketWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> redirect(to: ~p"/")
  end

  def fetch_current_user(conn, _opts) do
    token = get_session(conn, :access_token)

    case user_from_token(token) do
      {:ok, user} ->
        assign(conn, :current_user, user)

      :error when is_binary(token) ->
        conn
        |> delete_session(:access_token)
        |> delete_session(:live_socket_id)
        |> assign(:current_user, nil)

      :error ->
        assign(conn, :current_user, nil)
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, @login_required)
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log-in")
      |> halt()
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: signed_in_path())
      |> halt()
    else
      conn
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, attach_session_checks(socket, session["access_token"])}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, @login_required)
       |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")}
    end
  end

  def on_mount(:redirect_if_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path())}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      case user_from_token(session["access_token"]) do
        {:ok, user} -> user
        :error -> nil
      end
    end)
  end

  # The token is captured by the hooks rather than assigned, so it can never be
  # rendered or pushed to the client by accident.
  defp attach_session_checks(socket, token) do
    socket
    |> Phoenix.LiveView.attach_hook(:session_expiry_params, :handle_params, fn _params,
                                                                               _uri,
                                                                               socket ->
      ensure_active_session(socket, token)
    end)
    |> Phoenix.LiveView.attach_hook(:session_expiry_events, :handle_event, fn _event,
                                                                              _params,
                                                                              socket ->
      ensure_active_session(socket, token)
    end)
  end

  defp ensure_active_session(socket, token) do
    case Accounts.validate_access_token(token) do
      {:ok, _identity} ->
        {:cont, socket}

      {:error, _reason} ->
        {:halt,
         socket
         |> Phoenix.LiveView.put_flash(:error, @session_expired)
         |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")}
    end
  end

  defp user_from_token(token) when is_binary(token) do
    with {:ok, %{account_id: account_id}} <- Accounts.validate_access_token(token),
         {:ok, user} <- Accounts.get_user(account_id) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp user_from_token(_token), do: :error

  defp live_socket_id(token_id), do: "user_sessions:#{token_id}"

  # Renewing the session ID and clearing its contents prevents session fixation.
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp maybe_store_return_to(%{method: "GET"} = conn),
    do: put_session(conn, :user_return_to, current_path(conn))

  defp maybe_store_return_to(conn), do: conn
end
