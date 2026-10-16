defmodule FootballMarket.BrowserSessionCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias FootballMarket.Accounts.BrowserSessions
      alias FootballMarket.Repo
      import FootballMarket.BrowserSessionCase
    end
  end

  setup do
    owner = Ecto.Adapters.SQL.Sandbox.start_owner!(FootballMarket.Repo, shared: true)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(owner) end)
    :ok
  end

  def shell_paths(feature) do
    if feature == "specs/063-liveview-shell-authentication" do
      [
        "config/config.exs",
        "config/prod.exs",
        "config/test.exs",
        "lib/football_market/accounts.ex",
        "lib/football_market/accounts/browser_session.ex",
        "lib/football_market/accounts/browser_sessions.ex",
        "lib/football_market_web/components/workspace_components.ex",
        "lib/football_market_web/controllers/error_html.ex",
        "lib/football_market_web/controllers/session_controller.ex",
        "lib/football_market_web/controllers/session_html.ex",
        "lib/football_market_web/controllers/session_html/new.html.heex",
        "lib/football_market_web/endpoint.ex",
        "lib/football_market_web/live/browser_auth.ex",
        "lib/football_market_web/live/workspace_live.ex",
        "lib/football_market_web/plugs/browser_auth.ex",
        "lib/football_market_web/plugs/browser_cookie.ex",
        "lib/football_market_web/plugs/browser_origin.ex",
        "lib/football_market_web/router.ex",
        "priv/repo/migrations/20261015235000_create_browser_sessions.exs",
        "priv/repo/migrations/20261015235100_align_browser_session_contract.exs",
        "test/football_market/accounts/browser_credentials_test.exs",
        "test/football_market/accounts/browser_sessions_test.exs",
        "test/football_market/market/scope_test.exs",
        "test/football_market/providers/scope_test.exs",
        "test/football_market/statistics/scope_test.exs",
        "test/ci/sonarcloud_contract_test.exs",
        ".github/workflows/sonarcloud.yml",
        "test/football_market_web/browser_feedback_test.exs",
        "test/football_market_web/browser_return_test.exs",
        "test/football_market_web/controllers/error_html_test.exs",
        "test/football_market_web/controllers/session_controller_test.exs",
        "test/football_market_web/live/browser_session_lifecycle_test.exs",
        "test/football_market_web/live/workspace_navigation_test.exs",
        "test/football_market_web/workspace_browser_test.exs",
        "test/football_market_web/workspace_http_runtime_test.exs",
        "test/support/browser_session_case.ex"
      ]
    else
      []
    end
  end

  def owned_resource(socket, owner) do
    with {:cont, socket} <- FootballMarketWeb.Live.BrowserAuth.guard(socket),
         true <- socket.assigns.actor.account_id == owner do
      {:ok, :owned}
    else
      _ -> {:error, :denied}
    end
  end

  def start_runtime! do
    control = Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)
    {:ok, listener} = :gen_tcp.listen(0, [:binary, ip: {127, 0, 0, 1}, active: false])
    {:ok, port} = :inet.port(listener)
    :gen_tcp.close(listener)

    {:ok, pid} =
      Bandit.start_link(
        plug: {FootballMarket.BrowserRuntimePlug, control: control},
        scheme: :http,
        ip: {127, 0, 0, 1},
        port: port,
        startup_log: false
      )

    {"http://127.0.0.1:#{port}", pid, control}
  end

  def controlled_clock! do
    Application.put_env(
      :football_market,
      :browser_clock,
      {FootballMarket.BrowserTestClock, :now, []}
    )

    :persistent_term.put({FootballMarket.BrowserTestClock, :now}, DateTime.utc_now())

    ExUnit.Callbacks.on_exit(fn ->
      Application.delete_env(:football_market, :browser_clock)
      Application.delete_env(:football_market, :browser_failure)
      :persistent_term.erase({FootballMarket.BrowserTestClock, :now})
    end)
  end

  def account(email \\ "browser@example.com") do
    {:ok, user} =
      FootballMarket.Accounts.register_user(%{email: email, password: "correct-password-123"})

    user
  end
end

defmodule FootballMarket.BrowserTestClock do
  def now do
    :persistent_term.get({__MODULE__, :now}, DateTime.utc_now())
  end
end

defmodule FootballMarket.BrowserRuntimePlug do
  require Phoenix.LiveViewTest
  import Plug.Conn
  def init(opts), do: opts

  def call(%{request_path: "/__test/control"} = conn, opts) do
    if get_req_header(conn, "x-test-control") == [opts[:control]] do
      conn = fetch_query_params(conn)

      case conn.params do
        %{"advance" => value} ->
          now = FootballMarket.BrowserTestClock.now()

          :persistent_term.put(
            {FootballMarket.BrowserTestClock, :now},
            DateTime.add(now, String.to_integer(value), :microsecond)
          )

        %{"rename" => email, "to" => replacement} ->
          user = FootballMarket.Repo.get_by!(FootballMarket.Accounts.User, email: email)

          user
          |> FootballMarket.Accounts.User.changeset(%{email: replacement})
          |> FootballMarket.Repo.update!()

        %{"failure" => "clear"} ->
          Application.delete_env(:football_market, :browser_failure)

        %{"failure" => "revoke"} ->
          Application.put_env(:football_market, :browser_failure, :revoke)

        %{"failure" => "all"} ->
          Application.put_env(:football_market, :browser_failure, :all)

        _ ->
          :ok
      end

      send_resp(conn, 200, "ok")
    else
      send_resp(conn, 403, "Denied")
    end
  end

  def call(%{request_path: "/__test/owned-resource"} = conn, opts) do
    if get_req_header(conn, "x-test-control") == [opts[:control]] do
      conn =
        Plug.Session.call(
          %{conn | secret_key_base: FootballMarketWeb.Endpoint.config(:secret_key_base)},
          Plug.Session.init(
            store: :cookie,
            key: "_football_market_key",
            signing_salt: "StBRTN8C",
            encryption_salt: "browser-session-v1"
          )
        )
        |> fetch_session()

      case FootballMarket.Accounts.BrowserSessions.validate(get_session(conn, :browser_handle)) do
        {:ok, actor} ->
          other =
            FootballMarket.Repo.get_by!(FootballMarket.Accounts.User, email: "second@example.com")

          socket = %Phoenix.LiveView.Socket{assigns: %{actor: actor, __changed__: %{}}}
          {:error, :denied} = FootballMarket.BrowserSessionCase.owned_resource(socket, other.id)

          html =
            Phoenix.LiveViewTest.render_component(
              &FootballMarketWeb.WorkspaceComponents.recovery/1,
              kind: "Access denied"
            )

          conn |> put_resp_content_type("text/html") |> send_resp(403, html)

        _ ->
          conn |> put_resp_header("location", "/sign-in") |> send_resp(303, "")
      end
    else
      send_resp(conn, 403, "Denied")
    end
  end

  def call(conn, _),
    do: FootballMarketWeb.Endpoint.call(conn, FootballMarketWeb.Endpoint.init([]))
end
