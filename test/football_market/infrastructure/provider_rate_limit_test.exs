defmodule FootballMarket.Infrastructure.ProviderRateLimitTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Infrastructure.ProviderRateLimit
  alias FootballMarket.Providers.RateLimit

  setup do
    previous = Application.get_env(:football_market, :provider_rate_limit_backend)
    Application.put_env(:football_market, :provider_rate_limit_backend, ProviderRateLimit)

    on_exit(fn ->
      if is_nil(previous),
        do: Application.delete_env(:football_market, :provider_rate_limit_backend),
        else: Application.put_env(:football_market, :provider_rate_limit_backend, previous)
    end)

    :ok
  end

  test "credential pacing reservations remain shared across callers and adjacent runs" do
    token = "durable-secret-#{Ecto.UUID.generate()}"

    results =
      1..10
      |> Task.async_stream(fn _ -> RateLimit.reserve(token, 6_100, 60_000) end,
        max_concurrency: 4,
        timeout: 5_000
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.all?(results, &match?({:ok, _}, &1))
    waits = Enum.map(results, fn {:ok, wait} -> wait end) |> Enum.sort()
    assert hd(waits) == 0
    assert Enum.at(waits, 1) >= 6_000
    assert Enum.at(waits, 8) >= 48_000
    assert List.last(waits) >= 54_000
    assert List.last(waits) < 60_000

    assert {:defer, next_run_wait} = RateLimit.reserve(token, 6_100, 0)
    assert next_run_wait >= 60_000

    %{rows: [[credential_key]]} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT credential_key FROM provider_rate_limits LIMIT 1",
        []
      )

    refute credential_key =~ token
  end

  test "provider reset remains durable beyond the current attempt and does not slide on retry" do
    token = "reset-secret-#{Ecto.UUID.generate()}"
    :ok = RateLimit.block(token, 125_000)

    assert {:defer, first_wait} = RateLimit.reserve(token, 6_100, 60_000)
    assert first_wait > 120_000

    assert {:defer, retry_wait} = RateLimit.reserve(token, 6_100, 60_000)
    assert retry_wait <= first_wait
    assert retry_wait > 120_000

    credential_key = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)

    Ecto.Adapters.SQL.query!(
      Repo,
      "UPDATE provider_rate_limits SET blocked_until = clock_timestamp() - interval '1 second', " <>
        "next_allowed_at = clock_timestamp() - interval '1 second' WHERE credential_key = $1",
      [credential_key]
    )

    assert {:ok, 0} = RateLimit.reserve(token, 6_100, 0)
  end

  test "rolling import volume is shared, expires and survives caller replacement" do
    provider = "volume-#{Ecto.UUID.generate()}"

    results =
      1..110
      |> Task.async_stream(fn _ -> RateLimit.reserve_volume(provider, 100, 3_600_000) end,
        max_concurrency: 8,
        timeout: 10_000
      )
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.count(results, &(&1 == :ok)) == 100
    waits = for {:defer, wait} <- results, do: wait
    assert length(waits) == 10
    assert Enum.all?(waits, &(&1 > 3_500_000 and &1 <= 3_600_000))

    assert {:defer, _} =
             Task.async(fn -> RateLimit.reserve_volume(provider, 100, 3_600_000) end)
             |> Task.await()

    key = :crypto.hash(:sha256, provider) |> Base.encode16(case: :lower)

    assert %{rows: [[100]]} =
             Repo.query!(
               "SELECT cardinality(reservations) FROM provider_rate_limits WHERE credential_key=$1",
               [key]
             )

    Repo.query!(
      "UPDATE provider_rate_limits SET reservations = ARRAY[clock_timestamp() - interval '61 minutes'] WHERE credential_key=$1",
      [key]
    )

    assert :ok = RateLimit.reserve_volume(provider, 100, 3_600_000)

    assert %{rows: [[1]]} =
             Repo.query!(
               "SELECT cardinality(reservations) FROM provider_rate_limits WHERE credential_key=$1",
               [key]
             )

    assert :ok = RateLimit.block(provider, 120_000)
    assert {:defer, wait} = RateLimit.reserve_volume(provider, 100, 3_600_000)
    assert wait > 110_000
    assert wait <= 120_000
  end

  test "live scraping volume survives lease-table replacement and propagates provider blocks" do
    alias FootballMarket.Providers.Scraping.{HttpTransport, Assessment}
    alias FootballMarket.Providers.{Request, Runtime, ScrapingFixtureData}
    assessment = ScrapingFixtureData.assessment(ScrapingFixtureData.case!("performance-PL-2024"))

    assessment = %{
      assessment
      | mode: :live,
        destinations: ["https://example.test"],
        limits: %{concurrency: 1, volume: 2, window_ms: 3_600_000, cadence_ms: 0}
    }

    assessment =
      update_in(
        assessment.scopes[{:performances, "PL", 2024, 2025}],
        &Map.put(&1, :documents, %{"quota-check" => "https://example.test/quota"})
      )

    {:ok, request} =
      Request.normalize(:performances, %{league_code: "PL", start_year: 2024, end_year: 2025})

    context = %{runtime: {Runtime, nil}, deadline_us: Runtime.now_us(nil) + 20_000_000}
    state = %{mode: :live, assessment: assessment, admission: :ets.new(:quota, [:public, :set])}
    assert {:ok, first} = HttpTransport.acquire(request, context, state)
    assert {:error, %{category: :rate_limited}} = HttpTransport.acquire(request, context, state)
    :ok = HttpTransport.release(first, state)
    state = %{state | admission: :ets.new(:quota_replacement, [:public, :set])}
    assert {:ok, second} = HttpTransport.acquire(request, context, state)
    :ok = HttpTransport.release(second, state)

    assert {:error, %{category: :rate_limited, retry_after_ms: wait}} =
             HttpTransport.acquire(request, context, state)

    assert wait > 3_500_000

    # A provider-directed pause also covers imports with otherwise unused volume.
    state = %{state | assessment: put_in(assessment.limits.volume, 100)}
    {:ok, revision, _} = Assessment.admit(request, state)

    state =
      Map.merge(state, %{
        request: request,
        assessment_revision: revision,
        http_start: fn _, _, receiver ->
          id = make_ref()

          send(
            receiver,
            {:http, {id, {~c"HTTP/1.1", 429, ~c"Wait"}, [{~c"retry-after", ~c"120"}], ""}}
          )

          {:ok, id}
        end
      })

    assert {:error, %{category: :rate_limited, retry_after_ms: 120_000}} =
             HttpTransport.fetch("quota-check", context, state)

    assert {:error, %{category: :rate_limited, retry_after_ms: pause}} =
             HttpTransport.acquire(request, context, state)

    assert pause > 110_000
  end

  test "expired reservations do not bank request intervals during an idle period" do
    token = "idle-secret-#{Ecto.UUID.generate()}"
    :ok = RateLimit.block(token, 1_000)
    credential_key = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)

    Ecto.Adapters.SQL.query!(
      Repo,
      "UPDATE provider_rate_limits SET blocked_until = clock_timestamp() - interval '10 minutes', " <>
        "next_allowed_at = clock_timestamp() - interval '10 minutes' WHERE credential_key = $1",
      [credential_key]
    )

    waits =
      Enum.map(1..12, fn _ ->
        assert {:ok, wait} = RateLimit.reserve(token, 6_100, 120_000)
        wait
      end)

    assert hd(waits) == 0
    assert Enum.at(waits, 10) >= 58_000
    assert List.last(waits) >= 64_000
  end
end
