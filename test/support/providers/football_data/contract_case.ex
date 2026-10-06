defmodule FootballMarket.Providers.FootballData.ContractCase do
  @moduledoc false
  import ExUnit.Assertions
  alias FootballMarket.Providers

  alias Providers.{
    FixtureRuntime,
    FactOracle,
    FootballData,
    FootballData.FixtureData,
    FootballData.RecordingTransport,
    FootballData.Configuration
  }

  def positions,
    do: %{"GK" => "Goalkeeper", "DEF" => "Defender", "MID" => "Midfielder", "FWD" => "Forward"}

  def run(c) do
    Process.put(:fixture_elapsed, 0)
    Process.put(:fd_calls, 0)
    Process.put(:fd_routes, [])

    config =
      %{
        enabled: true,
        token: "FD_SYNTHETIC_SENTINEL",
        transport: {RecordingTransport, c},
        fixture_id: c.id
      }
      |> Map.merge(Map.get(c, :config, %{}))

    outcome =
      apply(Providers, Map.get(c, :operation, :catalog), [
        FixtureData.request(c),
        [
          provider: {FootballData, Configuration.new(config)},
          positions: positions(),
          runtime: {FixtureRuntime, %{validation_us: Map.get(c, :validation_us, 0)}}
        ]
      ])

    if c.calls == :bounded,
      do: assert(Process.get(:fd_calls) in 1..9),
      else: assert(Process.get(:fd_calls) == c.calls, c.id)

    case c.expected do
      :ok ->
        assert {:ok, result} = outcome
        assert result.operation == Map.get(c, :operation, :catalog)

        assert result.scope ==
                 Map.take(FixtureData.request(c), [:league_code, :start_year, :end_year])

        assert result.provenance.provider == "football-data-org"
        assert result.provenance.fixture_id == c.id
        assert result.provenance.retrieved_at == ~U[2026-10-06 12:00:00.000000Z]
        assert_facts(result, c)

      category ->
        assert {:error, error} = outcome
        assert error.operation == Map.get(c, :operation, :catalog)
        request = FixtureData.request(c)

        expected_scope =
          if c.expected == :invalid_request and request.league_code == "XX",
            do: nil,
            else: Map.take(request, [:league_code, :start_year, :end_year])

        expected_scope =
          if error.operation == :performances and expected_scope,
            do: Map.merge(expected_scope, %{from: nil, to: nil}),
            else: expected_scope

        assert error.scope == expected_scope
        assert error.category == category, "#{c.id}: #{inspect(error)}"
        assert error.retryable == category in [:rate_limited, :unavailable, :timeout]
        assert error.retry_after_ms == Map.get(c, :delay)
    end

    refute inspect(outcome) =~ "FD_SYNTHETIC_SENTINEL"
    outcome
  end

  def assert_facts(result, c) do
    oracle = FixtureData.expected()
    request = FixtureData.request(c)

    {teams, players, positions, bindings} =
      case c[:variant] do
        :empty_teams ->
          {[], [], [], Enum.take(oracle.bindings, 2)}

        :empty_squad ->
          {oracle.teams, [], [], Enum.take(oracle.bindings, 3)}

        :multi ->
          teams =
            for i <- 1..2,
                do: %{ref: "team-#{i}", season_ref: "season", name: "Club #{i}", code: "T#{i}"}

          players =
            for t <- 1..2,
                {p, code} <- [{1, "GK"}, {2, "DEF"}],
                do: %{
                  ref: "player-#{t * 1000 + p}",
                  season_ref: "season",
                  team_ref: "team-#{t}",
                  display_name: "Alex Example",
                  position_ref: code
                }

          bindings =
            Enum.take(oracle.bindings, 2) ++
              for(t <- 1..2, do: {:team, "team-#{t}", "#{t}"}) ++
              for t <- 1..2, p <- 1..2, do: {:player, "player-#{t * 1000 + p}", "#{t * 1000 + p}"}

          {teams, players, Enum.filter(oracle.positions, &(&1.code in ["GK", "DEF"])), bindings}

        :large ->
          teams =
            for i <- 1..20,
                do: %{ref: "team-#{i}", season_ref: "season", name: "Club #{i}", code: "T#{i}"}

          players =
            for t <- 1..20,
                p <- 1..25,
                do: %{
                  ref: "player-#{t * 1000 + p}",
                  season_ref: "season",
                  team_ref: "team-#{t}",
                  display_name: "Player #{t}-#{p}",
                  position_ref: "MID"
                }

          bindings =
            Enum.take(oracle.bindings, 2) ++
              for(t <- 1..20, do: {:team, "team-#{t}", "#{t}"}) ++
              for t <- 1..20,
                  p <- 1..25,
                  do: {:player, "player-#{t * 1000 + p}", "#{t * 1000 + p}"}

          {teams, players, Enum.filter(oracle.positions, &(&1.code == "MID")), bindings}

        _ ->
          {oracle.teams, oracle.players, oracle.positions, oracle.bindings}
      end

    expected = %{
      league: %{
        ref: "league",
        code: request.league_code,
        name: oracle.league_names[request.league_code]
      },
      season: %{
        ref: "season",
        league_ref: "league",
        start_year: request.start_year,
        end_year: request.end_year
      },
      teams: teams,
      players: players,
      positions: positions
    }

    declared = Map.new(bindings, fn {kind, ref, source} -> {{kind, source}, ref} end)

    correspondence =
      Enum.reduce(result.provenance.bindings, %{}, fn b, acc ->
        assert b.provider == "football-data-org"
        assert b.league_code == request.league_code
        assert b.start_year == request.start_year and b.end_year == request.end_year

        Map.update(
          acc,
          b.kind,
          %{b.ref => Map.fetch!(declared, {b.kind, b.source_id})},
          &Map.put(&1, b.ref, Map.fetch!(declared, {b.kind, b.source_id}))
        )
      end)
      |> Map.put(:position, Map.new(positions, &{&1.ref, &1.ref}))
      |> Map.put_new(:team, %{})
      |> Map.put_new(:player, %{})

    FactOracle.assert_facts!(result.facts, expected, correspondence)

    actual =
      for b <- result.provenance.bindings,
          do: {b.kind, correspondence[b.kind][b.ref], b.source_id}

    assert Enum.sort(actual) == Enum.sort(bindings)
  end
end
