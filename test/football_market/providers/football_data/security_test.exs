defmodule FootballMarket.Providers.FootballData.SecurityTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  import ExUnit.CaptureLog
  alias FootballMarket.Providers
  alias Providers.{FootballData, FixtureRuntime}
  alias FootballData.{Configuration, ContractCase, FixtureData, RecordingTransport}

  test "hostile source fields and diagnostics never expose the credential" do
    log =
      capture_log(fn ->
        for c <- FixtureData.cases(),
            String.starts_with?(c.id, ["FD-S03", "FD-S04"]),
            do: ContractCase.run(c)
      end)

    refute log =~ "FD_SYNTHETIC_SENTINEL"

    refute inspect(
             Configuration.new(%{
               enabled: true,
               token: "FD_SYNTHETIC_SENTINEL",
               transport: {RecordingTransport, %{token: "FD_SYNTHETIC_SENTINEL"}}
             })
           ) =~ "FD_SYNTHETIC_SENTINEL"
  end

  test "consumer errors win under every configuration and both operations do no work" do
    inputs = [
      nil,
      [],
      %{},
      %{league_code: "XX", start_year: 2026, end_year: 2027},
      %{"start_year" => 2026, league_code: "PL"},
      %{league_code: "PL", start_year: 2026, end_year: 2027, vendor: "x"},
      %{league_code: "PL", start_year: 2026, end_year: 2027, timeout_ms: 0}
    ]

    for config <- [
          %{enabled: false},
          %{enabled: "invalid"},
          %{enabled: true, token: nil},
          %{enabled: true, token: "FD_SYNTHETIC_SENTINEL", base_url: "evil"}
        ],
        op <- [:catalog, :performances],
        input <- inputs do
      Process.put(:fd_calls, 0)

      assert {:error, error} =
               apply(Providers, op, [
                 input,
                 [
                   provider: {FootballData, Configuration.new(config)},
                   positions: ContractCase.positions(),
                   runtime: {FixtureRuntime, %{}}
                 ]
               ])

      assert error.category == :invalid_request
      assert Process.get(:fd_calls) == 0
    end

    for token <- [nil, "", "   "], op <- [:catalog, :performances] do
      c = %{
        id: "FD-S02-both",
        operation: op,
        config: %{token: token},
        expected: :authentication_failed,
        calls: 0
      }

      ContractCase.run(c)
    end
  end

  test "unsafe destination options and invalid-timeout scope never start transport" do
    for settings <- [
          %{scheme: "http"},
          %{port: 80},
          %{proxy: "https://evil.example"},
          %{headers: [{"Authorization", "FD_SYNTHETIC_SENTINEL"}]},
          %{
            transport:
              {FootballData.MintTransport,
               %{address: {8, 8, 8, 8}, port: 443, hostname: "localhost", cacertfile: "fixture"}}
          }
        ] do
      c = %{id: "FD-S04-options", config: settings, expected: :invalid_request, calls: 0}
      ContractCase.run(c)
    end

    Process.put(:fd_calls, 0)
    request = %{league_code: "PL", start_year: 2026, end_year: 2027, timeout_ms: -1}

    assert {:error, error} =
             Providers.catalog(request,
               provider: {FootballData, Configuration.new(%{enabled: true, token: nil})},
               positions: ContractCase.positions()
             )

    assert error.category == :invalid_request
    assert error.scope == %{league_code: "PL", start_year: 2026, end_year: 2027}
    assert Process.get(:fd_calls) == 0
  end

  test "production-compiled capability refuses both loopback overrides and recording injection" do
    script = """
    Mix.start()
    Mix.env(:prod)
    Code.require_file("lib/football_market/providers/types.ex")
    Code.require_file("lib/football_market/providers/provenance.ex")
    Code.require_file("lib/football_market/providers/football_data/configuration.ex")
    alias FootballMarket.Providers.FootballData.Configuration
    for transport <- [{FootballMarket.Providers.FootballData.MintTransport, %{address: {127,0,0,1},port: 12345,hostname: "localhost",cacertfile: "fixture.pem"}}, {FootballMarket.Providers.FootballData.RecordingTransport,%{}}] do
      state = Configuration.new(%{enabled: true,token: "FD_SYNTHETIC_SENTINEL",transport: transport})
      {:error,%{category: :invalid_request}} = Configuration.validate(state,%{positions: Configuration.positions()})
    end
    IO.puts("production-refusal-ok")
    """

    {output, status} = System.cmd("elixir", ["-e", script], stderr_to_stdout: true)
    assert status == 0
    assert String.trim(output) == "production-refusal-ok"
    refute output =~ "FD_SYNTHETIC_SENTINEL"
  end
end
