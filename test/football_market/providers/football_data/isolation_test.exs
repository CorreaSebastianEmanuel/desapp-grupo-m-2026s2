defmodule FootballMarket.Providers.FootballData.IsolationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, Catalog, Statistics, StatisticsCase, Providers}

  alias Providers.FootballData.{
    ContractCase,
    FixtureData,
    Configuration,
    MintTransport,
    TLSServer,
    RecordingTransport
  }

  alias Providers.FootballData

  defp snapshot do
    for module <- [
          Catalog.League,
          Catalog.Season,
          Catalog.Team,
          Catalog.Position,
          Catalog.Player,
          Statistics.Match,
          Statistics.Performance
        ],
        do: Repo.all(module) |> Enum.sort_by(& &1.id)
  end

  defp reads(f, match) do
    [
      Catalog.get_season(f.season.id),
      Catalog.get_team(f.home.id),
      Catalog.get_position(f.position.id),
      Catalog.list_players(),
      Enum.map(f.players, &Catalog.get_player_detail(&1.id)),
      Statistics.get_match(match.id),
      Statistics.get_performance(hd(f.players).id, match.id),
      Statistics.list_player_history(hd(f.players).id)
    ]
  end

  test "FD-I01 real adapter success all eight errors and cancellation preserve every local table/read" do
    f = StatisticsCase.fixture()
    {:ok, match} = Statistics.record_match(StatisticsCase.match_attrs(f))

    {:ok, _} =
      Statistics.record_performance(StatisticsCase.performance_attrs(f, match, %{goals: 0}))

    initial = snapshot()
    initial_reads = reads(f, match)
    original = Application.get_env(:football_market, Providers)
    on_exit(fn -> Application.put_env(:football_market, Providers, original) end)

    Application.put_env(:football_market, Providers,
      provider:
        {FootballData,
         Configuration.new(%{
           enabled: true,
           token: "FD_SYNTHETIC_SENTINEL",
           transport: {RecordingTransport, %{owner: self()}}
         })},
      positions: ContractCase.positions()
    )

    categories = [:ok | Providers.Error.categories()]

    for category <- categories do
      c = Enum.find(FixtureData.cases(), &(&1.expected == category))
      assert c != nil
      ContractCase.run(c)
      assert snapshot() == initial
      assert reads(f, match) == initial_reads
      refute_receive :fd_external_attempt, 10
    end

    s = TLSServer.start(block_body: true)
    on_exit(fn -> TLSServer.stop(s) end)

    options = [
      provider:
        {FootballData,
         Configuration.new(%{
           enabled: true,
           token: "FD_SYNTHETIC_SENTINEL",
           transport: {MintTransport, s.transport}
         })},
      positions: ContractCase.positions()
    ]

    {caller, monitor} =
      spawn_monitor(fn ->
        Providers.catalog(%{league_code: "PL", start_year: 2026, end_year: 2027}, options)
      end)

    assert_receive {:tls_request, _, _, _}, 1000
    Process.exit(caller, :kill)
    assert_receive {:DOWN, ^monitor, :process, ^caller, :killed}, 1000
    assert_receive {:tls_closed, _}, 1000
    assert snapshot() == initial
    assert reads(f, match) == initial_reads
    refute_receive :fd_external_attempt, 10
  end

  test "default running application and enabled missing-token configuration need no source for local reads" do
    assert Application.get_env(:football_market, Providers)[:provider] == nil
    assert :football_market in Enum.map(Application.started_applications(), &elem(&1, 0))
    f = StatisticsCase.fixture()
    {:ok, match} = Statistics.record_match(StatisticsCase.match_attrs(f))
    original = Application.get_env(:football_market, Providers)
    on_exit(fn -> Application.put_env(:football_market, Providers, original) end)
    baseline = reads(f, match)

    for state <- [
          Configuration.new(%{enabled: false}),
          Configuration.new(%{enabled: true, token: nil})
        ] do
      Application.put_env(:football_market, Providers,
        provider: {FootballData, state},
        positions: ContractCase.positions()
      )

      assert {:ok, _} = Application.ensure_all_started(:football_market)
      assert reads(f, match) == baseline
      refute_receive :fd_external_attempt, 10
    end
  end

  test "fresh application boots with disabled selection and enabled missing token without retrieval" do
    script = """
    alias FootballMarket.Providers.FootballData
    Code.ensure_loaded!(FootballData)
    :erlang.trace_pattern({FootballData,:read,3},true,[:local])
    :erlang.trace(:all,true,[:call])
    {:ok,_} = Application.ensure_all_started(:football_market)
    FootballMarket.Catalog.list_players()
    FootballMarket.Statistics.list_player_history(-1)
    receive do
      {:trace,_,:call,{FootballData,:read,_}} -> raise "unexpected source work"
    after
      50 -> IO.puts("boot-local-only")
    end
    """

    for enabled <- ["false", "true"] do
      {output, status} =
        System.cmd("mix", ["run", "--no-start", "--no-compile", "-e", script],
          env: [
            {"MIX_ENV", "test"},
            {"FOOTBALL_DATA_ENABLED", enabled},
            {"FOOTBALL_DATA_TOKEN", ""}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, "fresh boot failed"
      assert String.contains?(output, "boot-local-only")
      refute output =~ "FD_SYNTHETIC_SENTINEL"
    end
  end
end
