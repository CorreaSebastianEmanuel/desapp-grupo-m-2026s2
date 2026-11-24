defmodule FootballMarketWeb.BusinessMetricsTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration
  import Ecto.Query

  alias FootballMarket.{BusinessMetrics, Market, Repo}
  alias FootballMarket.Market.Orders

  test "requires one valid API credential and the existing administrator policy" do
    admin = create_admin!()
    user = create_user!()

    for conn <- [
          build_conn(),
          put_req_header(build_conn(), "authorization", "Bearer invalid"),
          put_req_header(build_conn(), "x-api-key", "invalid"),
          build_conn() |> with_jwt(admin) |> with_api_key(admin)
        ] do
      assert get(conn, "/api/business-metrics").status == 401
    end

    for auth <- [&with_jwt/2, &with_api_key/2] do
      conn = auth.(build_conn(), user) |> get("/api/business-metrics")
      assert json_response(conn, 403) == %{"error" => %{"code" => "forbidden"}}
      assert auth.(build_conn(), admin) |> get("/api/business-metrics") |> json_response(200)
    end

    assert BusinessMetrics.snapshot(nil) == {:error, :unauthenticated}
    assert BusinessMetrics.snapshot(actor_for(user)) == {:error, :forbidden}
  end

  test "empty retained sources return explicit zero counts and a database timestamp" do
    admin = create_admin!()
    conn = build_conn() |> with_jwt(admin) |> get("/api/business-metrics")
    assert get_resp_header(conn, "cache-control") == ["private, no-store"]
    data = json_response(conn, 200)["data"]
    assert data["basis"] == "retained_local_records"
    assert {:ok, _, _} = DateTime.from_iso8601(data["as_of"])

    for name <- ~w(quotes conditional_orders portfolio_activity ingestion jobs) do
      assert data[name]["status"] == "empty"
      assert_zero_counts(data[name]["counts"])
    end

    assert_contract!(data)
  end

  test "counts retained quotes, request states, orders, completed trades, accepted scopes and jobs exactly" do
    market = create_tradable_market!("1000.00")
    actor = actor_for(market.investor)
    terms = %{player_id: market.player.id, quantity: 3, request_key: "metric-purchase"}
    assert {:ok, _} = Market.purchase(actor, terms)
    assert {:ok, _} = Market.purchase(actor, terms)

    assert {:ok, _} =
             Market.sale(actor, %{
               player_id: market.player.id,
               quantity: 1,
               request_key: "metric-sale"
             })

    order_terms = %{
      player_id: market.player.id,
      quantity: 1,
      maximum_unit_price: "1.00",
      expires_at: DateTime.add(DateTime.utc_now(), 3600)
    }

    assert {:ok, _} = Orders.create(actor, order_terms)
    assert {:ok, cancelled} = Orders.create(actor, order_terms)
    assert {:ok, _} = Orders.cancel(actor, cancelled.id)

    # Accepted empty checks are still accepted scopes; a never-checked scope is not.
    for checked <- [DateTime.utc_now(), nil] do
      Repo.insert!(%FootballMarket.Statistics.ScopeCheck{
        id: Ecto.UUID.generate(),
        provider: "private-provider",
        identity_namespace: "private-provider",
        league_code: "PL",
        start_year: 2026,
        end_year: 2027,
        season_id: market.season.id,
        player_id: if(checked, do: market.player.id),
        last_checked_at: checked
      })
    end

    now = DateTime.utc_now()

    for state <- ~w(pending retrying exhausted) do
      Repo.insert!(%FootballMarket.Quotes.CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: market.player.id,
        season_id: market.season.id,
        week_start: DateTime.add(now, -3600),
        week_end: now,
        selector: "active",
        state: state,
        inserted_at: now
      })
    end

    before_jobs = Repo.aggregate(Oban.Job, :count)

    for state <- ~w(suspended completed discarded cancelled retryable) do
      Repo.insert!(%Oban.Job{
        state: state,
        queue: "private-queue",
        worker: "PrivateWorker",
        args: %{"secret" => "never-return-this"},
        errors: [%{"error" => "private failure"}]
      })
    end

    data =
      build_conn()
      |> with_api_key(market.admin)
      |> get("/api/business-metrics")
      |> json_response(200)
      |> Map.fetch!("data")

    assert data["quotes"]["counts"]["performance_quotes"] == 1

    assert data["quotes"]["counts"]["requests_by_state"] == %{
             "pending" => 1,
             "running" => 0,
             "retrying" => 1,
             "successful" => 0,
             "no_quote" => 0,
             "validation_failed" => 0,
             "unsupported_strategy" => 0,
             "unreproducible" => 0,
             "exhausted" => 1
           }

    assert data["conditional_orders"]["counts"]["by_status"] == %{
             "pending" => 1,
             "cancelled" => 1,
             "executed" => 0,
             "expired" => 0,
             "rejected" => 0
           }

    assert data["portfolio_activity"]["counts"] == %{
             "purchases" => %{"count" => 1, "token_quantity" => 3},
             "sales" => %{"count" => 1, "token_quantity" => 1}
           }

    assert data["ingestion"]["counts"] == %{"accepted_scopes" => 1, "performance_records" => 1}
    assert Enum.sum(Map.values(data["jobs"]["counts"]["by_state"])) == before_jobs + 5

    for state <- ~w(suspended completed discarded cancelled retryable),
        do: assert(data["jobs"]["counts"]["by_state"][state] == 1)

    assert Enum.sort(Map.keys(data["jobs"]["counts"]["by_state"])) ==
             Enum.sort(Enum.map(Oban.Job.states(), &Atom.to_string/1))

    assert_contract!(data)
    refute Jason.encode!(data) =~ "never-return-this"

    Repo.delete_all(from(j in Oban.Job, where: j.state == "completed"))
    {:ok, later} = BusinessMetrics.snapshot(actor_for(market.admin))
    assert later.jobs.counts.by_state["completed"] == 0
  end

  test "one snapshot excludes trades and jobs committed between its aggregate reads" do
    market = create_tradable_market!()
    actor = actor_for(market.admin)
    {:ok, before_snapshot} = BusinessMetrics.snapshot(actor)
    parent = self()
    handler = "business-metrics-snapshot-#{System.unique_integer([:positive])}"

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :repo, :query],
        &__MODULE__.pause_snapshot/4,
        parent
      )

    on_exit(fn -> :telemetry.detach(handler) end)

    task = Task.async(fn -> BusinessMetrics.snapshot(actor) end)
    assert_receive {:snapshot_paused, reader}, 5000

    try do
      assert {:ok, _} =
               Market.purchase(actor_for(market.investor), %{
                 player_id: market.player.id,
                 quantity: 2,
                 request_key: "concurrent-metrics"
               })

      Repo.insert!(%Oban.Job{state: "completed", queue: "default", worker: "PrivateWorker"})
    after
      send(reader, :continue_snapshot)
    end

    assert {:ok, snapshot} = Task.await(task, 5000)
    assert snapshot.portfolio_activity == before_snapshot.portfolio_activity
    assert snapshot.jobs == before_snapshot.jobs
    :telemetry.detach(handler)
    {:ok, later} = BusinessMetrics.snapshot(actor)
    assert later.portfolio_activity.counts.purchases == %{count: 1, token_quantity: 2}
    assert later.jobs.counts.by_state["completed"] == 1
  end

  def pause_snapshot(_event, _measurements, metadata, parent) do
    if metadata[:source] == "market_quotes" and self() != parent do
      send(parent, {:snapshot_paused, self()})

      receive do
        :continue_snapshot -> :ok
      after
        5000 -> raise "snapshot barrier timed out"
      end
    end
  end

  test "a failed source invalidates all counts without exposing storage errors" do
    admin = create_admin!()
    # A real missing-table read exercises the database error path, then restores it.
    Repo.query!("ALTER TABLE oban_jobs RENAME TO metrics_test_hidden_jobs")

    try do
      conn = build_conn() |> with_jwt(admin) |> get("/api/business-metrics")
      data = json_response(conn, 503)["data"]
      assert data["as_of"] == nil

      for name <- ~w(quotes conditional_orders portfolio_activity ingestion jobs) do
        assert data[name] == %{"status" => "unavailable", "counts" => nil}
      end

      assert_contract!(data)
      refute conn.resp_body =~ "oban_jobs"
      refute conn.resp_body =~ "Postgrex"
    after
      Repo.query!("ALTER TABLE metrics_test_hidden_jobs RENAME TO oban_jobs")
    end
  end

  defp assert_zero_counts(counts) do
    for {_key, value} <- counts do
      if is_map(value), do: assert_zero_counts(value), else: assert(value == 0)
    end
  end

  defp assert_contract!(data) do
    spec = "priv/static/openapi.json" |> File.read!() |> Jason.decode!()
    schema = spec["components"]["schemas"]["BusinessMetrics"]
    assert_shape!(data, schema)
    operation = spec["paths"]["/api/business-metrics"]["get"]
    assert operation["security"] == [%{"BearerAuth" => []}, %{"ApiKeyAuth" => []}]
    assert Enum.sort(Map.keys(operation["responses"])) == ~w(200 401 403 503)
  end

  defp assert_shape!(nil, schema), do: assert(schema["nullable"])

  defp assert_shape!(value, %{"type" => "object"} = schema) do
    assert schema["additionalProperties"] == false
    assert Enum.sort(Map.keys(value)) == Enum.sort(schema["required"])
    for {key, child} <- value, do: assert_shape!(child, schema["properties"][key])
  end

  defp assert_shape!(value, %{"type" => "integer"}), do: assert(is_integer(value) and value >= 0)
  defp assert_shape!(value, %{"enum" => values}), do: assert(value in values)
  defp assert_shape!(value, %{"type" => "string"}), do: assert(is_binary(value))
end
