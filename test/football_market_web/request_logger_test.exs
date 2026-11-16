defmodule FootballMarketWeb.RequestLoggerTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  import ExUnit.CaptureLog
  alias FootballMarket.Observability.JSONFormatter
  @endpoint FootballMarketWeb.Endpoint

  setup do
    level = Logger.level()
    metadata = Logger.metadata()
    Logger.configure(level: :info)

    on_exit(fn ->
      Logger.configure(level: level)
      Logger.reset_metadata(metadata)
    end)

    :ok
  end

  defp events(log), do: log |> String.split("\n", trim: true) |> Enum.map(&Jason.decode!/1)

  test "default runtime handler uses JSON and preserves the environment level" do
    assert {:ok, %{formatter: {Logger.Formatter, config}}} = :logger.get_handler_config(:default)
    assert config.template == {JSONFormatter, :format}
    assert config.utc_log?
    assert config.colors.enabled == false
  end

  test "normal static unauthorized and unmatched responses have one terminal event" do
    for {path, status} <- [
          {"/docs?secret=DO-NOT-LOG", 200},
          {"/openapi.json", 200},
          {"/api/players", 401},
          {"/absent-DO-NOT-LOG", 404}
        ] do
      id = Ecto.UUID.generate()

      log =
        capture_log(JSONFormatter.options(), fn ->
          conn = build_conn() |> put_req_header("x-request-id", id) |> get(path)
          assert conn.status == status
          assert get_resp_header(conn, "x-request-id") == [id]
        end)

      records =
        Enum.filter(events(log), &String.starts_with?(Map.get(&1, "event", ""), "http.request."))

      assert [start, terminal] = records
      assert start["event"] == "http.request.start"
      assert terminal["status"] == status
      assert terminal["correlation_id"] == id
      assert terminal["actor_id"] == "anonymous"
      assert terminal["parameters"] == %{}
      assert is_integer(terminal["duration_ms"])
      refute log =~ "DO-NOT-LOG"
      if path == "/api/players", do: assert(terminal["route"] == "/api/players")
    end
  end

  test "missing and invalid IDs are generated and parser failures finish once" do
    for request_id <- [nil, "short", String.duplicate("x", 201)] do
      conn = build_conn()
      conn = if request_id, do: put_req_header(conn, "x-request-id", request_id), else: conn
      conn = get(conn, "/docs")
      assert [id] = get_resp_header(conn, "x-request-id")
      assert byte_size(id) in 20..200
      refute id == request_id
    end

    id = Ecto.UUID.generate()

    log =
      capture_log(JSONFormatter.options(), fn ->
        assert_error_sent 400, fn ->
          build_conn()
          |> put_req_header("x-request-id", id)
          |> put_req_header("content-type", "application/json")
          |> post("/sign-in", "{invalid")
        end
      end)

    records = Enum.filter(events(log), &(&1["correlation_id"] == id))
    assert length(Enum.filter(records, &(&1["event"] == "http.request.start"))) == 1

    assert [%{"status" => 400, "actor_id" => "anonymous", "parameters" => %{}}] =
             Enum.filter(
               records,
               &(&1["event"] in ["http.request.stop", "http.request.exception"])
             )
  end

  test "raised endpoint errors have one safe terminal record" do
    id = Ecto.UUID.generate()

    log =
      capture_log(JSONFormatter.options(), fn ->
        assert_error_sent 500, fn ->
          build_conn()
          |> put_req_header("x-request-id", id)
          |> FootballMarketWeb.LoggingFailureEndpoint.call([])
        end
      end)

    records = Enum.filter(events(log), &(&1["correlation_id"] == id))

    assert [
             %{"event" => "http.request.start"},
             %{"status" => 500, "actor_id" => "anonymous", "parameters" => %{}}
           ] = records

    refute log =~ "DO-NOT-LOG"
  end

  test "encoded routes and overlapping requests use their own template and identifiers" do
    log =
      capture_log(JSONFormatter.options(), fn ->
        1..8
        |> Enum.map(fn _ ->
          Task.async(fn ->
            id = Ecto.UUID.generate()
            conn = build_conn() |> put_req_header("x-request-id", id) |> get("/api/%70layers")
            assert conn.status == 401
            assert get_resp_header(conn, "x-request-id") == [id]
            assert Logger.metadata()[:correlation_id] == id
          end)
        end)
        |> Enum.each(&Task.await/1)
      end)

    groups = events(log) |> Enum.group_by(& &1["correlation_id"])
    assert map_size(groups) == 8

    for {_id, records} <- groups do
      assert [%{"event" => "http.request.start"}, %{"route" => "/api/players", "status" => 401}] =
               records
    end
  end

  test "every published router service emits one anonymous audit on rejection or response" do
    for route <- Phoenix.Router.routes(FootballMarketWeb.Router) do
      path = Regex.replace(~r/:[a-z_]+/, route.path, Ecto.UUID.generate())

      log =
        capture_log(JSONFormatter.options(), fn ->
          build_conn() |> dispatch(@endpoint, route.verb, path, %{})
        end)

      assert [record] = terminal_events(log)
      assert record["method"] == route.verb |> Atom.to_string() |> String.upcase()
      assert record["route"] == route.path
      assert record["actor_id"] == "anonymous"
      assert {:ok, _, 0} = DateTime.from_iso8601(record["timestamp"])
      assert is_integer(record["duration_ms"]) and record["duration_ms"] >= 0
      assert is_map(record["parameters"])
    end
  end

  test "JWT and API key identities are verified and request identity overrides are excluded" do
    alias FootballMarket.Accounts
    {:ok, user} = Accounts.register_user(FootballMarket.AccountsCase.registration_attrs())
    {:ok, token} = Accounts.Authentication.issue(user.id)
    {:ok, key} = Accounts.issue_api_key(user.id)
    player_id = Ecto.UUID.generate()

    for {header, credential} <- [{"authorization", "Bearer " <> token}, {"x-api-key", key.secret}] do
      log =
        capture_log(JSONFormatter.options(), fn ->
          conn =
            build_conn()
            |> put_req_header(header, credential)
            |> post("/api/purchases", %{
              "player_id" => player_id,
              "quantity" => 2,
              "request_key" => "DO-NOT-LOG",
              "actor_id" => "DO-NOT-LOG",
              "password" => "DO-NOT-LOG"
            })

          assert conn.status == 400
        end)

      assert [record] = terminal_events(log)
      assert record["actor_id"] == user.id
      assert record["parameters"] == %{"player_id" => player_id, "quantity" => 2}
      refute log =~ "DO-NOT-LOG"
      refute log =~ credential
    end

    log =
      capture_log(JSONFormatter.options(), fn ->
        build_conn()
        |> put_req_header("authorization", "Bearer DO-NOT-LOG")
        |> get("/api/players")
      end)

    assert [%{"actor_id" => "anonymous", "status" => 401}] = terminal_events(log)
    refute log =~ "DO-NOT-LOG"
  end

  test "query and path parameters retain only typed safe values" do
    alias FootballMarket.Accounts
    {:ok, user} = Accounts.register_user(FootballMarket.AccountsCase.registration_attrs())
    {:ok, token} = Accounts.Authentication.issue(user.id)
    player_id = Ecto.UUID.generate()

    log =
      capture_log(JSONFormatter.options(), fn ->
        build_conn()
        |> put_req_header("authorization", "Bearer " <> token)
        |> get("/api/players/#{player_id}/quotes/at?date=2026-01-01&password=DO-NOT-LOG")
      end)

    assert [record] = terminal_events(log)
    assert record["parameters"] == %{"player_id" => player_id, "date" => "2026-01-01"}
    assert record["route"] == "/api/players/:player_id/quotes/at"
    refute log =~ "DO-NOT-LOG"

    terms = %{
      "player_id" => player_id,
      "quantity" => 2,
      "maximum_unit_price" => "12.34",
      "expires_at" => "2099-01-01T00:00:00Z"
    }

    log =
      capture_log(JSONFormatter.options(), fn ->
        build_conn()
        |> put_req_header("authorization", "Bearer " <> token)
        |> post("/api/conditional-orders", terms)
      end)

    assert [record] = terminal_events(log)
    assert record["parameters"] == terms

    for value <- [
          %{"password" => "DO-NOT-LOG"},
          ["DO-NOT-LOG"],
          "DO-NOT-LOG",
          1.5,
          -1,
          100_000_000_000_000_000_000
        ] do
      log =
        capture_log(JSONFormatter.options(), fn ->
          build_conn()
          |> put_req_header("authorization", "Bearer " <> token)
          |> post("/api/conditional-orders", %{
            "quantity" => value,
            "player_id" => String.duplicate("x", 16),
            "maximum_unit_price" => "DO-NOT-LOG",
            "expires_at" => "DO-NOT-LOG"
          })
        end)

      assert [%{"parameters" => %{}} = record] = terminal_events(log)
      assert map_size(record["parameters"]) == 0
      refute log =~ String.duplicate("x", 16)
      refute log =~ "DO-NOT-LOG"
    end
  end

  test "browser login workspace and logout retain account identity without session secrets" do
    alias FootballMarket.Accounts
    attrs = FootballMarket.AccountsCase.registration_attrs()
    {:ok, user} = Accounts.register_user(attrs)
    opened = get(build_conn(), "/sign-in")

    log =
      capture_log(JSONFormatter.options(), fn ->
        rejected = opened |> recycle() |> post("/sign-in", %{attrs | password: "DO-NOT-LOG"})
        assert rejected.status == 422
        signed = rejected |> recycle() |> post("/sign-in", attrs)
        assert signed.status == 303

        for {method, path} <- [
              get: "/sign-in",
              get: "/register",
              post: "/sign-in",
              post: "/register"
            ] do
          assert signed
                 |> recycle()
                 |> dispatch(@endpoint, method, path, %{})
                 |> Map.fetch!(:status) == 303
        end

        workspace = signed |> recycle() |> get("/portfolio")
        assert workspace.status == 200
        ended = workspace |> recycle() |> post("/sign-out", %{})
        assert ended.status == 303
        get(build_conn(), "/docs")
      end)

    assert records = terminal_events(log)
    assert length(records) == 9

    assert Enum.map(records, & &1["actor_id"]) ==
             ["anonymous"] ++ List.duplicate(user.id, 7) ++ ["anonymous"]

    assert Enum.all?(records, &(&1["parameters"] == %{}))
    refute log =~ "DO-NOT-LOG"
    refute log =~ attrs.email
    refute log =~ attrs.password
    refute log =~ get_session(opened, :browser_handle)
  end

  defp terminal_events(log) do
    Enum.filter(events(log), &(&1["event"] in ["http.request.stop", "http.request.exception"]))
  end

  test "HEAD keeps its original HTTP method after Plug.Head routes it as GET" do
    id = Ecto.UUID.generate()

    log =
      capture_log(JSONFormatter.options(), fn ->
        conn = build_conn() |> put_req_header("x-request-id", id) |> head("/docs")
        assert conn.status == 200

        FootballMarketWeb.RequestLogger.handle_event(
          [:phoenix, :error_rendered],
          %{},
          %{conn: conn, status: 500},
          nil
        )
      end)

    assert [%{"method" => "HEAD"}, %{"method" => "HEAD", "route" => "/docs"}] = events(log)
  end
end
