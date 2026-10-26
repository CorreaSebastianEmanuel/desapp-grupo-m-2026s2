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

    assert [%{"status" => 400}] =
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
    assert [%{"event" => "http.request.start"}, %{"status" => 500}] = records
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

  test "HEAD keeps its original HTTP method after Plug.Head routes it as GET" do
    id = Ecto.UUID.generate()

    log =
      capture_log(JSONFormatter.options(), fn ->
        conn = build_conn() |> put_req_header("x-request-id", id) |> head("/docs")
        assert conn.status == 200
      end)

    assert [%{"method" => "HEAD"}, %{"method" => "HEAD", "route" => "/docs"}] = events(log)
  end
end
