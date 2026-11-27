defmodule FootballMarketWeb.MetricsControllerTest do
  use FootballMarketWeb.ConnCase
  alias FootballMarket.Observability.Metrics
  alias Oban.Job

  @moduletag :integration

  setup do
    previous = Application.fetch_env(:football_market, :metrics_scrape_token)
    Application.put_env(:football_market, :metrics_scrape_token, nil)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :metrics_scrape_token, value)
        :error -> Application.delete_env(:football_market, :metrics_scrape_token)
      end
    end)

    :ok
  end

  test "scrape denies missing configuration and missing or invalid credentials", %{conn: conn} do
    assert conn |> get("/metrics") |> response(401) == "Unauthorized"

    Application.put_env(:football_market, :metrics_scrape_token, "scrape-test-secret")

    assert conn
           |> recycle()
           |> put_req_header("authorization", "Bearer wrong")
           |> get("/metrics")
           |> response(401) == "Unauthorized"

    assert conn |> recycle() |> get("/metrics") |> response(401) == "Unauthorized"
  end

  test "authorized scrape exports bounded HTTP, Repo, VM, and Oban metrics", %{conn: conn} do
    Application.put_env(:football_market, :metrics_scrape_token, "scrape-test-secret")

    :telemetry.execute(
      [:football_market, :http, :request],
      %{duration: System.convert_time_unit(20, :millisecond, :native)},
      %{route: "/api/players", status_class: "5xx"}
    )

    :telemetry.execute(
      [:football_market, :repo, :query],
      %{query_time: System.convert_time_unit(3, :millisecond, :native)},
      %{query: "sensitive query"}
    )

    :telemetry.execute([:vm, :memory], %{total: 42_000}, %{})

    :telemetry.execute(
      [:vm, :total_run_queue_lengths],
      %{total: 3},
      %{}
    )

    Metrics.handle_event(
      [:oban, :job, :stop],
      %{duration: System.convert_time_unit(12, :millisecond, :native)},
      %{
        job: %Job{queue: "catalog_sync", args: %{"credential" => "job-secret"}},
        state: :success
      },
      nil
    )

    Metrics.handle_event(
      [:oban, :job, :exception],
      %{duration: System.convert_time_unit(6, :second, :native)},
      %{job: %Job{queue: "unknown-private-queue", args: %{"credential" => "job-secret"}}},
      nil
    )

    Metrics.handle_event(
      [:football_market, :provider, :request],
      %{duration: System.convert_time_unit(8, :millisecond, :native)},
      %{provider: :fotmob_public_html, operation: :player_search, outcome: :access_refused},
      nil
    )

    Metrics.handle_event(
      [:football_market, :provider, :request],
      %{duration: 1},
      %{provider: "private-provider", operation: "private-operation", outcome: "private-error"},
      nil
    )

    :telemetry.execute([:football_market, :ranking, :cache, :hit], %{count: 1}, %{})
    :telemetry.execute([:football_market, :ranking, :cache, :miss], %{count: 1}, %{})
    :telemetry.execute([:football_market, :ranking, :cache, :error], %{count: 1}, %{})

    Metrics.handle_event(
      [:football_market, :ranking, :cache, :private_outcome],
      %{count: 1},
      %{},
      nil
    )

    scrape_conn =
      conn
      |> put_req_header("authorization", "Bearer scrape-test-secret")
      |> get("/metrics")

    response = text_response(scrape_conn, 200)

    assert get_resp_header(scrape_conn, "content-type") == [
             "text/plain; version=0.0.4; charset=utf-8"
           ]

    assert Regex.scan(~r/^# TYPE football_market_(\S+) (\S+)$/m, response,
             capture: :all_but_first
           ) ==
             [
               ["http_requests_total", "counter"],
               ["http_errors_total", "counter"],
               ["http_request_duration_seconds", "histogram"],
               ["repo_query_duration_seconds", "histogram"],
               ["vm_memory_bytes", "gauge"],
               ["vm_run_queue_length", "gauge"],
               ["oban_jobs_total", "counter"],
               ["oban_job_duration_seconds", "histogram"],
               ["provider_requests_total", "counter"],
               ["provider_request_duration_seconds", "histogram"],
               ["ranking_cache_total", "counter"]
             ]

    for [label] <-
          Regex.scan(~r/(?:\{|,)(\w+)="/, response, capture: :all_but_first) do
      assert label in ~w(route status_class kind queue outcome provider operation le)
    end

    assert response =~
             ~s(football_market_http_errors_total{route="/api/players",status_class="5xx"} 1)

    assert response =~ "football_market_http_request_duration_seconds_bucket"
    assert response =~ "football_market_repo_query_duration_seconds_count"
    assert response =~ "football_market_vm_memory_bytes 42000"
    assert response =~ ~s(football_market_vm_run_queue_length{kind="total"} 3)

    assert response =~
             ~s(football_market_oban_jobs_total{queue="catalog_sync",outcome="success"} 1)

    assert response =~ ~s(football_market_oban_jobs_total{queue="other",outcome="failure"} 1)
    assert response =~ "football_market_oban_job_duration_seconds_count"

    assert response =~
             ~s(football_market_provider_requests_total{provider="fotmob_public_html",operation="player_search",outcome="access_refused"} 1)

    assert response =~
             ~s(football_market_provider_requests_total{provider="other",operation="other",outcome="other"} 1)

    assert response =~ "football_market_provider_request_duration_seconds_count"

    assert response =~
             ~s(football_market_oban_job_duration_seconds_bucket{queue="other",outcome="failure",le="5.0"} 0)

    assert response =~ ~s(football_market_ranking_cache_total{outcome="hit"} )
    assert response =~ ~s(football_market_ranking_cache_total{outcome="miss"} )
    assert response =~ ~s(football_market_ranking_cache_total{outcome="error"} )
    assert response =~ ~s(football_market_ranking_cache_total{outcome="other"} 1)

    refute response =~ "private_outcome"
    refute response =~ "scrape-test-secret"
    refute response =~ "sensitive query"
    refute response =~ "job-secret"
    refute response =~ "unknown-private-queue"
    refute response =~ "private-provider"
    refute response =~ "private-operation"
    refute response =~ "private-error"

    _ =
      conn
      |> recycle()
      |> put_req_header("authorization", "Bearer scrape-test-secret")
      |> get("/metrics?private-query-marker")

    next_scrape =
      conn
      |> recycle()
      |> put_req_header("authorization", "Bearer scrape-test-secret")
      |> get("/metrics")
      |> text_response(200)

    assert next_scrape =~ ~s(route="/metrics")
    refute next_scrape =~ "private-query-marker"
  end

  test "scrape labels use the route template and omit account and request identifiers" do
    Application.put_env(:football_market, :metrics_scrape_token, "scrape-test-secret")
    user = create_user!()
    {:ok, %{secret: secret}} = FootballMarket.Accounts.issue_api_key(user.id)
    path = "/api/players/#{user.id}"

    assert build_conn()
           |> put_req_header("x-api-key", secret)
           |> get(path)
           |> response(404)

    response = scrape()
    assert response =~ ~s(route="/api/players/:player_id",status_class="4xx")
    refute response =~ path
    refute response =~ user.id
    refute response =~ secret
  end

  test "rendered errors contribute exactly one request, error, and latency observation" do
    Application.put_env(:football_market, :metrics_scrape_token, "scrape-test-secret")
    before = scrape()

    assert_error_sent 400, fn ->
      build_conn()
      |> put_req_header("content-type", "application/json")
      |> post("/sign-in", "{invalid-private-body")
    end

    assert_error_sent 500, fn ->
      FootballMarketWeb.LoggingFailureEndpoint.call(build_conn(), [])
    end

    after_errors = scrape()

    for status_class <- ~w(4xx 5xx) do
      for metric <- ~w(http_requests_total http_errors_total http_request_duration_seconds_count) do
        assert sample(after_errors, metric, status_class) ==
                 sample(before, metric, status_class) + 1
      end

      metric = "http_request_duration_seconds_sum"
      assert sample(after_errors, metric, status_class) > sample(before, metric, status_class)
    end

    refute after_errors =~ "invalid-private-body"
  end

  test "concurrent observations expose coherent duration histograms" do
    observe = fn ->
      Metrics.handle_event([:football_market, :repo, :query], %{query_time: 1}, %{}, nil)
    end

    observe.()

    writers =
      for _ <- 1..4 do
        Task.async(fn -> Enum.each(1..30_000, fn _ -> observe.() end) end)
      end

    for _ <- 1..500 do
      histogram = Metrics.scrape()

      assert metric_value(
               histogram,
               ~s(football_market_repo_query_duration_seconds_bucket{le="+Inf"} )
             ) ==
               metric_value(histogram, "football_market_repo_query_duration_seconds_count ")
    end

    Enum.each(writers, &Task.await(&1, 10_000))
  end

  defp scrape do
    build_conn()
    |> put_req_header("authorization", "Bearer scrape-test-secret")
    |> get("/metrics")
    |> text_response(200)
  end

  defp sample(scrape, metric, status_class) do
    prefix = ~s(football_market_#{metric}{route="unmatched",status_class="#{status_class}"} )
    metric_value(scrape, prefix)
  end

  defp metric_value(scrape, prefix) do
    scrape
    |> String.split("\n")
    |> Enum.find_value(0, fn line ->
      if String.starts_with?(line, prefix) do
        {value, ""} = line |> String.replace_prefix(prefix, "") |> Float.parse()
        value
      end
    end)
  end
end
