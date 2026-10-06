defmodule FootballMarket.Providers.FootballData.RetryExpiryTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers
  alias Providers.{FixtureRuntime, FootballData, Error}
  alias FootballData.{Configuration, ContractCase}
  @origin 7_000_000
  @utc ~U[2026-10-06 12:00:00.000000Z]

  defdelegate now_us(s), to: FixtureRuntime
  defdelegate launch(f, d, s), to: FixtureRuntime
  defdelegate await(h, d, s), to: FixtureRuntime
  defdelegate cancel(h, s), to: FixtureRuntime
  defdelegate close(h, s), to: FixtureRuntime

  def utc_now(s) do
    FixtureRuntime.advance(s.post_us)
    Map.get(s, :later_utc, ~U[2040-01-01 00:00:00Z])
  end

  def provider_label, do: "legacy"

  def read(_, context, state) do
    for expiry <- state.expiries, do: context.record_retry_not_before.(expiry)

    case state.outcome do
      :raise -> raise "synthetic"
      :throw -> throw(:synthetic)
      other -> other
    end
  end

  defp request, do: %{league_code: "PL", start_year: 2026, end_year: 2027}

  defp run_case(
         headers,
         parse_us,
         post_us,
         receipt \\ %{received_us: @origin, received_utc: @utc},
         options \\ []
       ) do
    Process.put(:fixture_elapsed, Keyword.get(options, :origin, @origin))

    config =
      Configuration.new(%{
        enabled: true,
        token: "FD_SYNTHETIC_SENTINEL",
        transport:
          {FootballData.RecordingTransport,
           %{status: 429, headers: headers, parse_us: parse_us, receipt_override: receipt}}
      })

    assert {:error, error} =
             Providers.catalog(request(),
               provider: {FootballData, config},
               positions: ContractCase.positions(),
               runtime:
                 {__MODULE__,
                  %{
                    post_us: post_us,
                    later_utc: Keyword.get(options, :later_utc, ~U[2040-01-01 00:00:00Z])
                  }}
             )

    assert error.category == :rate_limited

    assert Map.keys(Map.from_struct(error)) |> Enum.sort() ==
             Enum.sort([
               :category,
               :explanation,
               :operation,
               :scope,
               :retryable,
               :retry_after_ms,
               :field,
               :reference
             ])

    refute inspect(error) =~ "received"
    error
  end

  test "FD-E05-B1 complete readiness delta/date/reset matrix repeats independently" do
    for headers <- [
          [{"Retry-After", "2"}],
          [{"Retry-After", "Tue, 06 Oct 2026 12:00:02 GMT"}],
          [{"X-RequestCounter-Reset", "2"}]
        ],
        {elapsed, expected} <- [
          {0, 2000},
          {1_000_000, 1000},
          {2_000_000, nil},
          {3_000_000, nil},
          {1_999_001, nil},
          {999_001, 1000}
        ],
        parse_us <- Enum.uniq([0, elapsed, div(elapsed, 2)]) do
      a = run_case(headers, parse_us, elapsed - parse_us)
      b = run_case(headers, parse_us, elapsed - parse_us)
      assert a == b
      assert a.retry_after_ms == expected
    end
  end

  test "FD-E05-B2 fractional HTTP-date receipts floor only at complete readiness" do
    # Literal oracles retain the sub-millisecond source interval. UTC fractions
    # and monotonic origins vary independently; no production helper computes waits.
    cases = [
      {~U[2026-10-06 12:00:00.000999Z],
       [{999_001, 1000}, {1_998_001, 1}, {1_998_002, nil}, {1_999_001, nil}, {2_000_001, nil}]},
      {~U[2026-10-06 12:00:00.000001Z],
       [{999_999, 1000}, {1_998_999, 1}, {1_999_000, nil}, {1_999_999, nil}]},
      {~U[2026-10-06 12:00:00.500001Z],
       [{499_999, 1000}, {1_498_999, 1}, {1_499_000, nil}, {1_499_999, nil}]},
      {~U[2026-10-06 12:00:00.999999Z],
       [{1, 1000}, {999_001, 1}, {999_002, nil}, {1_000_001, nil}]}
    ]

    for {utc, offsets} <- cases,
        origin <- [7_000_000, 7_000_999, -7_000_888],
        later_utc <- [~U[1900-01-01 00:00:00Z], ~U[2040-01-01 00:00:00Z]],
        {elapsed, expected} <- offsets,
        parse_us <- Enum.uniq([0, elapsed, div(elapsed, 2)]) do
      receipt = %{received_us: origin, received_utc: utc}
      options = [origin: origin, later_utc: later_utc]
      headers = [{"Retry-After", "Tue, 06 Oct 2026 12:00:02 GMT"}]
      a = run_case(headers, parse_us, elapsed - parse_us, receipt, options)
      b = run_case(headers, parse_us, elapsed - parse_us, receipt, options)
      assert a == b
      assert a.retry_after_ms == expected
    end
  end

  test "missing/incoherent receipt never reanchors at parser entry" do
    for receipt <- [
          %{},
          %{received_us: @origin},
          %{received_us: "bad", received_utc: @utc},
          %{received_us: @origin + 1, received_utc: @utc},
          %{received_us: @origin, received_utc: nil}
        ] do
      assert run_case([{"Retry-After", "2"}], 0, 0, receipt).retry_after_ms == nil
    end
  end

  test "legacy errors are exact and worker-local registrations clean up on every outcome" do
    Process.put(:fixture_elapsed, @origin)
    before = Process.get()

    for {outcome, category} <- [
          {{:error, %{category: :rate_limited, retry_after_ms: 2000}}, :rate_limited},
          {{:error, %{category: :not_found}}, :not_found},
          {{:ok, %{}}, :invalid_response},
          {{:error, %{category: :rate_limited, extra: :hostile}}, :invalid_response},
          {:malformed, :invalid_response},
          {:raise, :unavailable},
          {:throw, :unavailable}
        ] do
      Process.put(:fixture_elapsed, @origin)

      assert {:error, e} =
               Providers.catalog(request(),
                 provider:
                   {__MODULE__,
                    %{
                      expiries: [
                        @origin + 2_000_000,
                        "ignored",
                        @origin + 3_000_000,
                        @origin + 1_000_000
                      ],
                      outcome: outcome
                    }},
                 positions: ContractCase.positions(),
                 runtime: {__MODULE__, %{post_us: 500_000}}
               )

      assert e.category == category
      if category == :rate_limited, do: assert(e.retry_after_ms == 500)

      assert Map.new(Process.get()) ==
               Map.new(Keyword.put(before, :fixture_elapsed, FixtureRuntime.now_us(nil)))

      Process.put(:fixture_elapsed, @origin)

      assert {:error, legacy} =
               Providers.catalog(request(),
                 provider:
                   {__MODULE__,
                    %{
                      expiries: [],
                      outcome: {:error, %{category: :rate_limited, retry_after_ms: 2000}}
                    }},
                 positions: ContractCase.positions(),
                 runtime: {__MODULE__, %{post_us: 3_000_000}}
               )

      assert legacy == Error.new(:rate_limited, :catalog, request(), nil, 2000)
    end
  end

  test "registered expiry cannot contaminate a valid success or override exact deadline" do
    candidate = %{
      operation: :catalog,
      scope: request(),
      facts: %{
        league: %{ref: "league", code: "PL", name: "Premier League"},
        season: %{ref: "season", league_ref: "league", start_year: 2026, end_year: 2027},
        teams: [],
        players: [],
        positions: []
      },
      bindings: [
        %{kind: :league, ref: "league", source_id: "1"},
        %{kind: :season, ref: "season", source_id: "2"}
      ]
    }

    for outcome <- [{:ok, candidate}, {:error, %{category: :not_found}}] do
      results =
        for expiries <- [[@origin + 1_000_000], []] do
          Process.put(:fixture_elapsed, @origin)

          Providers.catalog(request(),
            provider: {__MODULE__, %{expiries: expiries, outcome: outcome}},
            positions: ContractCase.positions(),
            runtime: {__MODULE__, %{post_us: 500_000}}
          )
        end

      assert [a, a] = results
      if match?({:ok, _}, outcome), do: assert(match?({:ok, _}, a))
    end

    for post_us <- [4_999_999, 5_000_000, 5_000_001] do
      Process.put(:fixture_elapsed, @origin)

      assert {:error, error} =
               Providers.catalog(request(),
                 provider:
                   {__MODULE__,
                    %{
                      expiries: [@origin + 10_000_000],
                      outcome: {:error, %{category: :rate_limited, retry_after_ms: 10000}}
                    }},
                 positions: ContractCase.positions(),
                 runtime: {__MODULE__, %{post_us: post_us}}
               )

      assert error.category == if(post_us < 5_000_000, do: :rate_limited, else: :timeout)
    end
  end
end
