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
