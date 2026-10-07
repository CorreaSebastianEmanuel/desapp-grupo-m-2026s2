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
end
