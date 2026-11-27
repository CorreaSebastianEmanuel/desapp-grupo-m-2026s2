# Authentication and browser session security for HTTP API, browser routes, and LiveView:
#   * `FootballMarketWeb.Plugs.AuthenticateAPI` — JWT Bearer or X-API-Key auth for `/api/*`
#   * `FootballMarketWeb.Plugs.BrowserAuth` — cookie session & admin guard for HTML/LiveView routes
#   * `FootballMarketWeb.Plugs.BrowserCookie` — caps cookie max-age to the server session deadline
#   * `FootballMarketWeb.Plugs.BrowserOrigin` — rejects cross-origin browser mutations
#   * `FootballMarketWeb.Live.BrowserAuth` — LiveView `on_mount` session & expiry guard

defmodule FootballMarketWeb.Plugs.AuthenticateAPI do
  @moduledoc "Authenticates exactly one supported API credential (JWT or X-API-Key)."
  import Plug.Conn

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarketWeb.Plugs.RequestQuota, as: QuotaPlug

  @event [:football_market, :api, :authentication]
  @challenge ~s(Bearer realm="api")
  @body Jason.encode!(%{error: %{code: "unauthenticated"}})

  def init(opts), do: opts

  def call(conn, opts) do
    started = System.monotonic_time()
    validator = Keyword.get(opts, :validator, Accounts)
    {conn, outcome, method} = authenticate(conn, validator)

    :telemetry.execute(
      @event,
      %{duration: System.monotonic_time() - started},
      %{route_policy: :protected, outcome: outcome, authentication_method: method}
    )

    if outcome == :ok, do: QuotaPlug.authenticated_api(conn), else: conn
  end

  defp authenticate(conn, validator) do
    case {get_req_header(conn, "authorization"), get_req_header(conn, "x-api-key")} do
      {[value], []} when is_binary(value) -> authenticate_bearer(conn, value, validator)
      {[], [value]} when is_binary(value) -> authenticate_api_key(conn, value, validator)
      _ -> {reject(conn), :error, nil}
    end
  end

  defp authenticate_bearer(conn, value, validator) do
    with {:ok, token} <- bearer_token(value),
         {:ok, %{account_id: account_id, token_id: token_id}} <-
           safely_validate(fn -> validator.validate_access_token(token) end) do
      actor = %AuthenticatedActor{
        account_id: account_id,
        authentication_method: :jwt,
        credential_id: token_id
      }

      {assign(conn, :authenticated_actor, actor), :ok, :jwt}
    else
      _ -> {reject(conn), :error, :jwt}
    end
  end

  defp authenticate_api_key(conn, secret, validator) do
    case safely_validate(fn -> validator.identify_api_key(secret) end) do
      {:ok, %{account_id: account_id, key_id: key_id}} ->
        actor = %AuthenticatedActor{
          account_id: account_id,
          authentication_method: :api_key,
          credential_id: key_id
        }

        {assign(conn, :authenticated_actor, actor), :ok, :api_key}

      _ ->
        {reject(conn), :error, :api_key}
    end
  end

  defp bearer_token(value) do
    case Regex.run(~r/\A(?i:bearer)[\t ]+([^\t ]+)\z/, value, capture: :all_but_first) do
      [token] -> {:ok, token}
      _ -> :error
    end
  end

  defp safely_validate(fun) do
    fun.()
  rescue
    _ -> {:error, :authentication_failed}
  catch
    _, _ -> {:error, :authentication_failed}
  end

  defp reject(conn) do
    %{conn | assigns: Map.delete(conn.assigns, :authenticated_actor)}
    |> put_resp_header("www-authenticate", @challenge)
    |> put_resp_content_type("application/json")
    |> send_resp(401, @body)
    |> halt()
  end
end

defmodule FootballMarketWeb.RequestQuota do
  @moduledoc "Supervised fixed-window request quotas for a single application instance."
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def take(scope, subject) do
    config = Application.fetch_env!(:football_market, __MODULE__)
    {limit, window_ms} = Keyword.fetch!(config, scope)

    case Process.whereis(__MODULE__) do
      nil -> {:error, :unavailable}
      server -> call(server, {:take, {scope, subject}, limit, window_ms})
    end
  end

  def release({server, key, generation}), do: call(server, {:release, key, generation})

  defp call(server, request) do
    GenServer.call(server, request)
  catch
    :exit, _ -> {:error, :unavailable}
  end

  @impl true
  def init(windows), do: {:ok, windows}

  @impl true
  def handle_call({:take, key, limit, window_ms}, _, windows) do
    now = System.monotonic_time(:millisecond)

    {count, expires_at, generation} =
      case windows do
        %{^key => {_count, expires_at, _generation} = window} when expires_at > now ->
          window

        _ ->
          generation = :erlang.start_timer(window_ms, self(), {:expire, key})
          {0, now + window_ms, generation}
      end

    if count < limit do
      {:reply, {:ok, {self(), key, generation}},
       Map.put(windows, key, {count + 1, expires_at, generation})}
    else
      {:reply, {:error, {:limited, div(expires_at - now + 999, 1000)}}, windows}
    end
  end

  def handle_call({:release, key, generation}, _, windows) do
    case windows do
      %{^key => {1, _, ^generation}} ->
        Process.cancel_timer(generation)
        {:reply, :ok, Map.delete(windows, key)}

      %{^key => {count, expires_at, ^generation}} ->
        {:reply, :ok, Map.put(windows, key, {count - 1, expires_at, generation})}

      _ ->
        {:reply, :ok, windows}
    end
  end

  @impl true
  def handle_info({:timeout, generation, {:expire, key}}, windows) do
    case windows do
      %{^key => {_, _, ^generation}} -> {:noreply, Map.delete(windows, key)}
      _ -> {:noreply, windows}
    end
  end
end

defmodule FootballMarketWeb.Plugs.RequestQuota do
  @moduledoc "Applies request quotas at the browser and authenticated API boundaries."
  import Plug.Conn
  require Logger

  alias FootballMarketWeb.RequestQuota

  def init(scope), do: scope

  def authenticated_api(conn) do
    case RequestQuota.take(:api, conn.assigns.authenticated_actor.account_id) do
      {:ok, _} ->
        conn

      {:error, :unavailable} ->
        Logger.warning("Authenticated API rate limiter unavailable",
          event: "api.rate_limit.unavailable"
        )

        conn

      {:error, {:limited, seconds}} ->
        conn
        |> retry_after(seconds)
        |> put_resp_content_type("application/json")
        |> send_resp(429, ~s({"error":{"code":"rate_limited"}}))
        |> halt()
    end
  end

  def call(conn, scope) do
    case RequestQuota.take(scope, source_ip(conn)) do
      {:ok, _} -> conn
      {:error, reason} -> browser_error(conn, reason)
    end
  end

  def browser_error(conn, {:limited, seconds}) do
    conn
    |> retry_after(seconds)
    |> put_resp_content_type("text/html")
    |> send_resp(
      429,
      ~s(<main><p role="alert">Demasiadas solicitudes. Probá de nuevo más tarde.</p></main>)
    )
    |> halt()
  end

  def browser_error(conn, :unavailable) do
    conn
    |> put_resp_header("cache-control", "no-store")
    |> put_resp_content_type("text/html")
    |> send_resp(
      503,
      ~s(<main><p role="alert">El servicio no está disponible temporalmente. Probá de nuevo.</p></main>)
    )
    |> halt()
  end

  defp retry_after(conn, seconds) do
    conn
    |> put_resp_header("cache-control", "no-store")
    |> put_resp_header("retry-after", Integer.to_string(seconds))
  end

  defp source_ip(conn) do
    peer = conn |> get_peer_data() |> Map.fetch!(:address) |> canonical_ip()

    trusted =
      Enum.map(Application.get_env(:football_market, :trusted_proxies, []), &canonical_ip/1)

    with true <- peer in trusted,
         [_ | _] = headers <- get_req_header(conn, "x-forwarded-for"),
         {:ok, hops} <- proxy_hops(headers) do
      Enum.find(Enum.reverse(hops), peer, &(&1 not in trusted))
    else
      _ -> peer
    end
  end

  defp proxy_hops(headers) do
    hops =
      headers
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(fn value ->
        if String.valid?(value) do
          value |> String.trim() |> String.to_charlist() |> :inet.parse_strict_address()
        else
          :error
        end
      end)

    if Enum.all?(hops, &match?({:ok, _}, &1)),
      do: {:ok, Enum.map(hops, fn {:ok, ip} -> canonical_ip(ip) end)},
      else: :error
  end

  defp canonical_ip({0, 0, 0, 0, 0, 65_535, high, low}),
    do: {div(high, 256), rem(high, 256), div(low, 256), rem(low, 256)}

  defp canonical_ip(ip), do: ip
end

defmodule FootballMarketWeb.Plugs.BrowserAuth do
  @moduledoc "Browser session authentication and administrator authorization plug."
  import Plug.Conn
  import Phoenix.Controller

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.{AuthenticatedActor, BrowserSessions}

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

    domain_actor = %AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }

    if Accounts.administrator?(domain_actor) do
      conn
    else
      conn |> put_status(403) |> html("<main><h1>Acceso restringido</h1></main>") |> halt()
    end
  end

  def live_session(conn), do: %{"actor" => conn.assigns.browser_actor}
end

defmodule FootballMarketWeb.Plugs.BrowserCookie do
  @moduledoc "Caps cookie max-age to the server session deadline."
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
  @moduledoc "Rejects cross-origin browser mutations in addition to CSRF protection."
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

defmodule FootballMarketWeb.Live.BrowserAuth do
  @moduledoc "LiveView `on_mount` hook enforcing active sessions and admin privileges."
  import Phoenix.LiveView
  import Phoenix.Component

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.{AuthenticatedActor, BrowserSessions}

  def on_mount(:administrator, _params, _session, socket),
    do: socket |> assign(:administrator_required, true) |> guard()

  def on_mount(:workspace, _params, session, socket) do
    case initial_result(socket, session) do
      {:ok, actor} -> mount_actor(actor, socket)
      _ -> {:halt, ended(socket)}
    end
  end

  def guard(socket) do
    case BrowserSessions.revalidate(socket.assigns.actor.session_id) do
      {:ok, actor} ->
        socket = assign(socket, :actor, actor)

        if socket.assigns[:administrator_required],
          do: administrator_guard(socket),
          else: {:cont, socket}

      _ ->
        {:halt, ended(socket)}
    end
  end

  defp administrator_guard(socket) do
    actor = %AuthenticatedActor{
      account_id: socket.assigns.actor.account_id,
      authentication_method: :browser,
      credential_id: socket.assigns.actor.session_id
    }

    if Accounts.administrator?(actor),
      do: {:cont, socket},
      else: {:halt, redirect(socket, to: "/portfolio")}
  end

  defp initial_result(_socket, session) do
    case session["browser_handle"] do
      handle when is_binary(handle) ->
        BrowserSessions.validate(handle)

      _ ->
        case session["actor"] do
          %{session_id: id} -> BrowserSessions.revalidate(id)
          _ -> {:error, :invalid}
        end
    end
  end

  defp mount_actor(actor, socket) do
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(FootballMarket.PubSub, BrowserSessions.topic(actor.session_id))

    case BrowserSessions.revalidate(actor.session_id) do
      {:ok, fresh} -> mount_fresh(fresh, socket)
      _ -> {:halt, ended(socket)}
    end
  end

  defp mount_fresh(fresh, socket) do
    if connected?(socket) do
      Process.send_after(self(), :browser_validate, 250)
      schedule_deadline(fresh)
    end

    socket =
      socket
      |> assign(:actor, fresh)
      |> attach_hook(:browser_params, :handle_params, fn _, _, s -> guard(s) end)
      |> attach_hook(:browser_events, :handle_event, fn _, _, s -> guard(s) end)
      |> attach_hook(:browser_info, :handle_info, &info/2)
      |> attach_hook(:browser_async, :handle_async, fn _, _, s -> guard(s) end)

    {:cont, socket}
  end

  defp schedule_deadline(actor) do
    remaining =
      max(
        div(DateTime.diff(actor.expires_at, BrowserSessions.now(), :microsecond) + 999, 1000),
        1
      )

    Process.send_after(self(), :browser_deadline, remaining)
  end

  defp info(:browser_deadline, socket) do
    case guard(socket) do
      {:cont, socket} ->
        schedule_deadline(socket.assigns.actor)
        {:halt, socket}

      other ->
        other
    end
  end

  defp info(:browser_session_ended, socket), do: {:halt, ended(socket)}

  defp info(:browser_validate, socket) do
    case guard(socket) do
      {:cont, socket} ->
        Process.send_after(self(), :browser_validate, 250)
        {:halt, socket}

      other ->
        other
    end
  end

  defp info(_, socket), do: guard(socket)
  defp ended(socket), do: socket |> assign(:actor, nil) |> redirect(to: "/sign-in?notice=ended")
end

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
