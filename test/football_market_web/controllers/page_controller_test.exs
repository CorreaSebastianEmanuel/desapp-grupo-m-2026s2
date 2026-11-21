defmodule FootballMarketWeb.PageControllerTest do
  use FootballMarketWeb.ConnCase

  @moduletag :integration

  test "GET / returns the application foundation", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)
    assert html =~ "Football Market"

    for path <- ["/sign-in", "/register", "/portfolio", "/conditional-orders", "/docs"] do
      assert html =~ ~s(href="#{path}")
    end

    assert html =~ "100"
    refute html =~ "Phoenix application foundation"
  end

  test "health endpoints are public and report liveness and readiness", %{conn: conn} do
    assert conn |> get("/health/live") |> json_response(200) == %{"status" => "live"}

    response = conn |> recycle() |> get("/health/ready") |> json_response(200)
    assert response["status"] == "ready"
    assert response["dependencies"]["postgresql"] == "ready"
    assert response["dependencies"]["oban"] == "ready"
    assert response["dependencies"]["redis"] in ["ready", "degraded"]
    refute inspect(response) =~ "password"
    refute inspect(response) =~ "postgresql://"
  end

  test "refused Redis connection preserves liveness and degraded readiness", %{conn: conn} do
    redis = Application.fetch_env!(:football_market, :redis)
    on_exit(fn -> Application.put_env(:football_market, :redis, redis) end)

    {:ok, listener} = :gen_tcp.listen(0, ip: {127, 0, 0, 1}, active: false)
    {:ok, port} = :inet.port(listener)
    :ok = :gen_tcp.close(listener)

    Application.put_env(:football_market, :redis, host: "127.0.0.1", port: port, password: nil)

    test_pid = self()

    {request, monitor} =
      spawn_monitor(fn ->
        live = conn |> get("/health/live") |> json_response(200)
        ready = conn |> recycle() |> get("/health/ready") |> json_response(200)
        send(test_pid, {self(), live, ready})
      end)

    assert_receive {^request, %{"status" => "live"}, readiness}, 2_500
    assert_receive {:DOWN, ^monitor, :process, ^request, :normal}

    assert readiness == %{
             "status" => "ready",
             "dependencies" => %{
               "postgresql" => "ready",
               "redis" => "degraded",
               "oban" => "ready"
             }
           }
  end

  test "not-ready responses use HTTP 503 and expose only dependency statuses", %{conn: conn} do
    conn =
      FootballMarketWeb.HealthController.respond_ready(conn, %{
        status: :unavailable,
        dependencies: %{postgresql: :unavailable, redis: :degraded, oban: :ready}
      })

    assert %{
             "status" => "unavailable",
             "dependencies" => %{
               "postgresql" => "unavailable",
               "redis" => "degraded",
               "oban" => "ready"
             }
           } = json_response(conn, 503)
  end
end
