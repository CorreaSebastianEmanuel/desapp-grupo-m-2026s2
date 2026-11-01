defmodule FootballMarket.Providers.ScrapingAssessmentTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.{Scraping, ScrapingFixtureData, Request}
  alias ScrapingFixtureData, as: Data

  test "explicit scoped fixture admission and rejection before fetch" do
    for c <- Data.cases(), String.starts_with?(c["id"], ["access-", "assessment-"]) do
      Data.assert_case!(c)
      if c["gate"] || c["live"] || c["invalid"], do: refute_receive({:scraping_fetch, _, _})
      flush()
    end
  end

  test "actual assessment remains blocked with inspectable twenty rows" do
    before = Scraping.Assessment.actual()
    assert before.permission == :missing
    assert map_size(before.scopes) == 20

    for {_, row} <- before.scopes do
      assert row.required == :unverified
      assert map_size(row.metrics) == 9
      assert Enum.all?(row.metrics, fn {_, m} -> m.status == :unverified && m.meaning != "" end)
    end

    Data.assert_case!(Data.case!("access-scoped"))
    assert Scraping.Assessment.actual() == before
  end

  test "live catalog and performances use assessed HTTPS documents through the existing pipeline" do
    for id <- ["catalog-PL-2024", "performance-PL-2024"] do
      c = Data.case!(id)
      state = live_state(c)
      assert {:ok, result} = Data.run(c, state)
      assert result.provenance.fixture_id == id
      assert_received {:live_http_start, url, timeout}
      assert String.starts_with?(url, "https://example.test/")
      assert timeout > 0
    end
  end

  test "actual live assessment denies before the HTTP callback is reached" do
    for id <- ["catalog-PL-2024", "performance-PL-2024"] do
      c = Data.case!(id)
      owner = self()

      start = fn _, _, _ ->
        send(owner, :unexpected_http_request)
        {:error, :closed}
      end

      assert {:error, error} =
               Data.run(c, %{assessment: Scraping.Assessment.actual(), http_start: start})

      assert error.category == :unsupported_capability
      refute_received :unexpected_http_request
    end
  end

  test "live evidence withdrawal after a document fetch prevents publication" do
    c = Data.case!("catalog-PL-2024")
    state = live_state(c)
    owner = self()

    for change <- [
          fn a -> %{a | withdrawn: true} end,
          fn a -> %{a | revision: "changed"} end,
          fn a -> %{a | scopes: %{}} end
        ] do
      {:ok, evidence} = Agent.start_link(fn -> 0 end)

      reader = fn ->
        Agent.get_and_update(evidence, fn n ->
          assessment = if n >= 6, do: change.(state.assessment), else: state.assessment
          {assessment, n + 1}
        end)
      end

      test_state =
        Map.put(state, :assessment_reader, reader)
        |> Map.put(:http_start, fn url, timeout, receiver ->
          send(owner, {:live_http_start, url, timeout})
          request_id = make_ref()

          send(
            receiver,
            {:http, {request_id, {~c"HTTP/1.1", 200, ~c"OK"}, [], Map.fetch!(responses(c), url)}}
          )

          {:ok, request_id}
        end)

      assert {:error, %{category: :unsupported_capability}} = Data.run(c, test_state)
      refute_received {:live_http_start, _, _}
      Agent.stop(evidence)
    end
  end

  test "live HTTP failures and shared volume limits return no partial result" do
    c = Data.case!("catalog-PL-2024")
    state = live_state(c, http_start: fn _, _, _ -> {:error, :closed} end)
    assert {:error, %{category: :unavailable}} = Data.run(c, state)

    oversized =
      live_state(c,
        http_start: fn _url, _timeout, receiver ->
          request_id = make_ref()

          send(
            receiver,
            {:http, {request_id, {~c"HTTP/1.1", 200, ~c"OK"}, [], :binary.copy("x", 2_000_001)}}
          )

          {:ok, request_id}
        end
      )

    assert {:error, %{category: :invalid_response}} = Data.run(c, oversized)

    table = :ets.new(:live_budget, [:public, :set])
    budget_state = live_state(c)

    assessment = %{
      budget_state.assessment
      | limits: %{concurrency: 1, volume: 1, cadence_ms: 0}
    }

    state = Map.merge(budget_state, %{assessment: assessment, admission: table})
    assert {:ok, _} = Data.run(c, state)
    assert {:error, %{category: :rate_limited}} = Data.run(c, state)
  end

  test "live admission fails closed without shared state and enforces concurrent leases" do
    c = Data.case!("catalog-PL-2024")
    owner = self()

    state =
      live_state(c,
        admission: nil,
        http_start: fn _, _, _ -> send(owner, :unexpected_live_contact) end
      )

    assert {:error, %{category: :rate_limited}} = Data.run(c, state)
    refute_received :unexpected_live_contact

    state = live_state(c)
    assessment = %{state.assessment | limits: %{concurrency: 1, volume: 10, cadence_ms: 0}}
    state = %{state | assessment: assessment}
    {:ok, request} = Request.normalize(:catalog, Data.request(c))
    context = %{runtime: {FootballMarket.Providers.FixtureRuntime, %{}}, deadline_us: 5_000_000}

    assert {:ok, lease} = Scraping.HttpTransport.acquire(request, context, state)
    task = Task.async(fn -> Scraping.HttpTransport.acquire(request, context, state) end)
    assert {:error, %{category: :rate_limited}} = Task.await(task)
    Scraping.HttpTransport.release(lease, state)
  end

  test "live request deadline cancels the HTTP callback before it can publish" do
    c = Data.case!("catalog-PL-2024") |> Map.put("timeout", 40)
    owner = self()

    state =
      live_state(c,
        http_start: fn _url, _timeout, _receiver ->
          send(owner, {:live_http_started, self()})
          {:ok, make_ref()}
        end,
        http_cancel: fn request_id ->
          send(owner, {:live_http_cancelled, request_id})
          :ok
        end
      )

    assert {:error, %{category: :timeout}} =
             Data.run(c, state, {FootballMarket.Providers.Runtime, nil})

    assert_receive {:live_http_started, worker}
    assert_receive {:live_http_cancelled, _}, 300
    monitor = Process.monitor(worker)
    assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 300
  end

  test "expired and future-reviewed live evidence deny before HTTP contact" do
    c = Data.case!("catalog-PL-2024")
    base = live_state(c, assessment_clock: fn -> ~U[2026-10-09 00:00:00Z] end)
    owner = self()

    callback = fn _, _, _ ->
      send(owner, :unexpected_live_contact)
      {:error, :closed}
    end

    for assessment <- [
          %{base.assessment | expires_at: ~U[2026-10-08 00:00:00Z]},
          %{base.assessment | reviewed_at: ~U[2026-11-01 00:00:00Z]}
        ] do
      state = %{base | assessment: assessment, http_start: callback}
      assert {:error, %{category: :unsupported_capability}} = Data.run(c, state)
      refute_received :unexpected_live_contact
    end
  end

  test "oversized streamed response is cancelled before another chunk is requested" do
    c = Data.case!("catalog-PL-2024")
    owner = self()

    state =
      live_state(c,
        http_start: fn _url, _timeout, receiver ->
          request_id = make_ref()
          Process.put(:stream_request_id, request_id)
          send(receiver, {:http, {request_id, :stream_start, [], self()}})
          send(owner, {:stream_started, request_id})
          {:ok, request_id}
        end,
        http_stream_next: fn handler ->
          send(owner, :stream_next_requested)

          send(
            handler,
            {:http, {Process.get(:stream_request_id), :stream, :binary.copy("x", 2_000_001)}}
          )
        end,
        http_cancel: fn request_id ->
          send(owner, {:stream_cancelled, request_id})
          :ok
        end
      )

    assert {:error, %{category: :invalid_response}} = Data.run(c, state)
    assert_received {:stream_started, _}
    assert_received :stream_next_requested
    refute_received :stream_next_requested
    assert_received {:stream_cancelled, _}
  end

  test "revision, expiry and withdrawal invalidate current evidence" do
    c = Data.case!("access-scoped")

    for change <- [
          fn a -> %{a | revision: 2} end,
          fn a -> %{a | withdrawn: true} end,
          fn a -> %{a | expires_at: ~U[2020-01-01 00:00:00Z]} end
        ] do
      {:ok, reader} = Agent.start_link(fn -> {Data.assessment(c), 0} end)

      read = fn ->
        Agent.get_and_update(reader, fn {a, n} ->
          {if(n < 2, do: a, else: change.(a)), {a, n + 1}}
        end)
      end

      assert {:error, e} = Data.run(c, %{assessment_reader: read})
      assert e.category == :unsupported_capability
      Agent.stop(reader)
    end
  end

  test "atomic fixture admission is shared across simultaneous callers" do
    c = Data.case!("access-scoped")
    table = :ets.new(:admission, [:public, :set])
    :ets.insert(table, {:active, 0})
    {:ok, request} = Request.normalize(:catalog, Data.request(c))
    ctx = %{runtime: {FootballMarket.Providers.FixtureRuntime, %{}}, deadline_us: 5_000_000}
    state = Data.state(c, %{admission: table})
    assert {:ok, lease} = Scraping.FixtureTransport.acquire(request, ctx, state)
    task = Task.async(fn -> Scraping.FixtureTransport.acquire(request, ctx, state) end)
    assert {:error, %{category: :rate_limited}} = Task.await(task)
    Scraping.FixtureTransport.release(lease, state)
    assert {:ok, lease} = Scraping.FixtureTransport.acquire(request, ctx, state)
    Scraping.FixtureTransport.release(lease, state)
  end

  test "unapproved destination, incomplete conditions and limits cannot admit" do
    c = Data.case!("access-scoped")
    a = Data.assessment(c)

    for assessment <- [
          %{a | destinations: []},
          %{a | evidence: nil},
          %{a | limits: %{}},
          %{a | reviewed_at: nil}
        ] do
      assert {:error, e} = Data.run(c, %{assessment: assessment})
      assert e.category == :unsupported_capability
    end

    portions =
      put_in(Data.state(c).portions, ["roster:b", :observation, :destination], "unapproved")

    assert {:error, e} = Data.run(c, %{portions: portions})
    assert e.category == :unsupported_capability

    live = live_state(Data.case!("catalog-PL-2024"))
    [{scope_key, scope_row}] = Map.to_list(live.assessment.scopes)
    document_urls = Map.put(scope_row.documents, "catalog", "http://example.test/catalog")

    assessment = %{
      live.assessment
      | scopes: %{scope_key => %{scope_row | documents: document_urls}}
    }

    live = Map.put(live, :assessment, assessment)

    assert {:error, %{category: :unsupported_capability}} =
             Data.run(Data.case!("catalog-PL-2024"), live)

    refute_received {:live_http_start, _, _}
  end

  test "aggregate fixture volume and cadence cannot be exceeded across callers" do
    c = Data.case!("access-scoped")
    a = Data.assessment(c)

    for limits <- [
          %{concurrency: 1, volume: 1, cadence_ms: 0},
          %{concurrency: 1, volume: 100, cadence_ms: 1000}
        ] do
      table = :ets.new(:budget, [:public, :set])
      state = %{assessment: %{a | limits: limits}, admission: table}
      assert {:ok, _} = Data.run(c, state)
      assert {:error, e} = Data.run(c, state)
      assert e.category == :rate_limited
    end
  end

  test "shared admission works with the production runtime's negative monotonic origin" do
    c = Data.case!("access-scoped")
    table = :ets.new(:negative_origin, [:public, :set])
    state = Data.state(c, %{admission: table})
    {:ok, request} = Request.normalize(:catalog, Data.request(c))

    context = %{
      runtime: {FootballMarket.Providers.Runtime, nil},
      deadline_us: FootballMarket.Providers.Runtime.now_us(nil) + 5_000_000
    }

    assert {:ok, lease} = Scraping.FixtureTransport.acquire(request, context, state)
    Scraping.FixtureTransport.release(lease, state)
  end

  test "malformed evidence denies before source work with unsupported capability" do
    c = Data.case!("access-scoped")
    a = Data.assessment(c)
    key = {:catalog, "PL", 2024, 2025}

    for invalid <- [
          %{a | scopes: "malformed"},
          %{a | destinations: :unknown},
          %{a | scopes: %{key => %{a.scopes[key] | metrics: :unknown}}}
        ] do
      assert {:error, e} = Data.run(c, %{assessment: invalid})
      assert e.category == :unsupported_capability
      refute_receive {:scraping_fetch, _, _}, 0
    end
  end

  test "publication rejects expiry, withdrawal and revision changes during final validation" do
    base = ~U[2026-10-07 00:00:00.000000Z]

    for id <- ["catalog-PL-2024", "performance-PL-2024"],
        change <- [:expiry, :withdrawal, :revision] do
      c = Data.case!(id)
      a = Data.assessment(c)

      overrides =
        case change do
          :expiry ->
            %{
              assessment: %{a | expires_at: DateTime.add(base, 1, :microsecond)},
              assessment_clock: fn ->
                DateTime.add(
                  base,
                  FootballMarket.Providers.FixtureRuntime.now_us(nil),
                  :microsecond
                )
              end
            }

          kind ->
            %{
              assessment_reader: fn ->
                if FootballMarket.Providers.FixtureRuntime.now_us(nil) >= 1 do
                  if kind == :withdrawal, do: %{a | withdrawn: true}, else: %{a | revision: 2}
                else
                  a
                end
              end
            }
        end

      assert {:error, %{category: :unsupported_capability}} =
               Data.run(
                 c,
                 overrides,
                 {FootballMarket.Providers.FixtureRuntime, %{validation_us: 2}}
               )

      # Runner's shared deadline still takes precedence over failed admission.
      assert {:error, %{category: :timeout}} =
               Data.run(
                 c,
                 overrides,
                 {FootballMarket.Providers.FixtureRuntime, %{validation_us: 5_000_000}}
               )
    end
  end

  defp flush do
    receive do
      {:scraping_fetch, _, _} -> flush()
    after
      0 -> :ok
    end
  end

  defp live_state(c, overrides \\ []) do
    assessment = Data.assessment(c)
    {key, row} = Enum.at(assessment.scopes, 0)

    documents =
      Map.new(Data.documents(c["id"]), fn {portion, _body} ->
        {portion, "https://example.test/" <> URI.encode(portion)}
      end)

    assessment = %{
      assessment
      | mode: :live,
        destinations: ["https://example.test"],
        scopes: %{key => Map.put(row, :documents, documents)}
    }

    responses = responses(c)

    owner = self()

    start = fn url, timeout, receiver ->
      send(owner, {:live_http_start, url, timeout})
      request_id = make_ref()

      send(
        receiver,
        {:http, {request_id, {~c"HTTP/1.1", 200, ~c"OK"}, [], Map.fetch!(responses, url)}}
      )

      {:ok, request_id}
    end

    Map.merge(
      %{
        mode: :live,
        assessment: assessment,
        admission: :ets.new(:test_live_admission, [:public, :set]),
        http_start: start
      },
      Map.new(overrides)
    )
  end

  defp responses(c) do
    Map.new(Data.documents(c["id"]), fn {portion, body} ->
      {"https://example.test/" <> URI.encode(portion), body}
    end)
  end
end
