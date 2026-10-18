defmodule FootballMarket.Statistics.Ingestion.PositionsTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.Ingestion.Positions

  @kickoff ~U[2026-03-01 12:00:00Z]
  defp subject,
    do: %{
      id: "subject",
      player_id: "p",
      season_id: "s",
      match_id: "current",
      kickoff_at: @kickoff
    }

  defp prior(id, match, position, kickoff),
    do: %{
      id: id,
      player_id: "p",
      season_id: "s",
      match_id: match,
      position_id: position,
      kickoff_at: kickoff
    }

  test "chooses unique match-count mode and retains its full basis" do
    history = [
      prior("a", "m1", "mid", ~U[2026-01-01 00:00:00Z]),
      prior("b", "m2", "mid", ~U[2026-02-01 00:00:00Z]),
      prior("c", "m3", "forward", ~U[2026-02-10 00:00:00Z]),
      prior("late", "m4", "forward", @kickoff)
    ]

    assert {:ok, result} = Positions.derive(subject(), history)
    assert result.position_id == "mid"
    assert result.frequencies == %{"mid" => 2, "forward" => 1}
    assert length(result.basis) == 3
  end

  test "equal mode counts and empty usable history remain unknown" do
    tied = [
      prior("a", "m1", "mid", ~U[2026-01-01 00:00:00Z]),
      prior("b", "m2", "forward", ~U[2026-02-01 00:00:00Z])
    ]

    assert {:ok, %{position_id: nil, reason: :tie}} = Positions.derive(subject(), tied)

    later = prior("c", "m3", "forward", ~U[2026-03-02 00:00:00Z])
    equal = prior("same", "current", "forward", @kickoff)
    other_season = %{prior("d", "m4", "mid", ~U[2026-01-01 00:00:00Z]) | season_id: "other"}

    assert {:ok, %{position_id: nil, reason: :insufficient_history, basis: []}} =
             Positions.derive(subject(), [later, equal, other_season])
  end

  test "counts one vote per earlier match and excludes other players and proposed rows" do
    same_match = prior("a2", "m1", "forward", ~U[2026-01-02 00:00:00Z])
    other_player = %{prior("b", "m2", "forward", ~U[2026-02-01 00:00:00Z]) | player_id: "other"}

    assert {:ok,
            %{
              position_id: "mid",
              frequencies: %{"mid" => 1},
              basis: [%{performance_id: "a", position_id: "mid"}]
            }} =
             Positions.derive(subject(), [
               prior("a", "m1", "mid", ~U[2026-01-01 00:00:00Z]),
               same_match,
               other_player
             ])
  end
end

defmodule FootballMarket.Statistics.Ingestion.PositionAcceptanceTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Catalog.{Player, Position, Season, Team}
  alias FootballMarket.Statistics.{Match, Performance}
  alias FootballMarket.Statistics.Ingestion.PositionBasis
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  defp setup_scope(_year) do
    year =
      DateTime.utc_now().year +
        rem(System.unique_integer([:positive]) + System.os_time(:millisecond), 7_000)

    scope = Fixtures.scope(year)
    Case.seed_catalog!(scope)
    season = Repo.one!(from s in Season, where: s.start_year == ^year)
    home = Repo.one!(from t in Team, where: t.season_id == ^season.id and t.code == "ALP")
    away = Repo.one!(from t in Team, where: t.season_id == ^season.id and t.code == "BET")

    player =
      Repo.one!(from p in Player, where: p.season_id == ^season.id and p.display_name == "Alex")

    gk = Repo.get_by!(Position, code: "GK")

    fw =
      Repo.get_by(Position, code: "FW") ||
        Repo.insert!(Position.changeset(%Position{}, %{code: "FW", name: "Forward"}))

    %{scope: scope, season: season, home: home, away: away, player: player, gk: gk, fw: fw}
  end

  defp record_prior!(f, suffix, day, position, minutes \\ 90) do
    date = Date.new!(f.season.start_year, 1, day)

    {:ok, match} =
      Statistics.record_match(%{
        match_identity: "position-prior-#{suffix}",
        kickoff_at: DateTime.new!(date, ~T[12:00:00Z]),
        season_id: f.season.id,
        home_team_id: f.home.id,
        away_team_id: f.away.id
      })

    {:ok, performance} =
      Statistics.record_performance(%{
        match_id: match.id,
        player_id: f.player.id,
        team_id: f.home.id,
        position_id: position.id,
        minutes_played: minutes
      })

    performance
  end

  defp import_substitute!(f) do
    request = Fixtures.request(f.scope)
    candidate = Case.candidate(request)
    kickoff = DateTime.new!(Date.new!(f.season.start_year, 2, 1), ~T[12:00:00Z])
    match = %{hd(candidate.facts.matches) | kickoff_at: kickoff}

    performance =
      hd(candidate.facts.performances)
      |> Map.put(:position_ref, nil)
      |> Map.put(:participation, :substitute_entered)

    completeness = %{
      candidate.completeness
      | eligible_match_identities: ["match-1"],
        detail_coverage: ["match-1"]
    }

    candidate = %{
      candidate
      | facts: %{candidate.facts | matches: [match], performances: [performance]},
        completeness: completeness
    }

    context = Case.delivery_context!(f.scope)

    assert {:ok, outcome} =
             Statistics.Ingestion.import_scope(
               f.scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    match =
      Repo.one!(
        from m in Match,
          where:
            m.match_identity == "provider:v1:synthetic-a:match-1" and
              m.season_id == ^f.season.id
      )

    {Repo.one!(from p in Performance, where: p.match_id == ^match.id), outcome}
  end

  test "substitute receives the unique earlier match-count mode" do
    f = setup_scope(2110)
    first_prior = record_prior!(f, "a", 1, f.gk, 1)
    second_prior = record_prior!(f, "b", 10, f.gk, 2)
    third_prior = record_prior!(f, "c", 20, f.fw, 90)
    {performance, _} = import_substitute!(f)
    Repo.query!("SET CONSTRAINTS statistics_position_basis_validate IMMEDIATE", [])
    assert performance.position_id == f.gk.id
    assert performance.position_basis == "derived_history"
    assert performance.position_evidence["policy_version"] == 1
    assert performance.position_evidence["frequencies"][f.gk.id] == 2

    basis_rows = Repo.all(from b in PositionBasis, where: b.performance_id == ^performance.id)
    assert length(basis_rows) == 3

    assert MapSet.new(Enum.map(basis_rows, & &1.prior_performance_id)) ==
             MapSet.new([first_prior.id, second_prior.id, third_prior.id])
  end

  test "trusted direct position on an entrant takes precedence over prior history" do
    f = setup_scope(2114)
    record_prior!(f, "direct-prior", 1, f.gk)
    candidate = Case.candidate(Fixtures.request(f.scope))
    kickoff = DateTime.new!(Date.new!(f.season.start_year, 2, 1), ~T[12:00:00Z])
    match = %{hd(candidate.facts.matches) | kickoff_at: kickoff}

    performance_fact =
      hd(candidate.facts.performances)
      |> Map.put(:position_ref, "FW")
      |> Map.put(:participation, :substitute_entered)

    candidate = %{
      candidate
      | facts: %{
          candidate.facts
          | matches: [match],
            positions: candidate.facts.positions ++ [%{ref: "FW", code: "FW", name: "Forward"}],
            performances: [performance_fact]
        }
    }

    context = Case.delivery_context!(f.scope)

    assert {:ok, _} =
             FootballMarket.Statistics.Ingestion.import_scope(
               f.scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    stored_match =
      Repo.one!(
        from m in Match,
          where:
            m.match_identity == "provider:v1:synthetic-a:match-1" and m.season_id == ^f.season.id
      )

    stored = Repo.one!(from p in Performance, where: p.match_id == ^stored_match.id)
    assert stored.position_id == f.fw.id
    assert stored.position_basis == "direct_source"
    assert stored.participation == "substitute_entered"
  end

  test "tied and insufficient history persist explicit unknown evidence" do
    tied = setup_scope(2111)
    record_prior!(tied, "a", 1, tied.gk)
    record_prior!(tied, "b", 10, tied.fw)
    {unknown, _} = import_substitute!(tied)
    Repo.query!("SET CONSTRAINTS statistics_position_basis_validate IMMEDIATE", [])
    assert is_nil(unknown.position_id)
    assert unknown.position_basis == "unknown_history"
    assert unknown.position_reason == "tie"
    assert unknown.position_evidence["frequencies"] == %{tied.gk.id => 1, tied.fw.id => 1}

    empty = setup_scope(2112)
    {unknown, _} = import_substitute!(empty)
    Repo.query!("SET CONSTRAINTS statistics_position_basis_validate IMMEDIATE", [])
    assert is_nil(unknown.position_id)
    assert unknown.position_reason == "insufficient_history"
    assert unknown.position_evidence["frequencies"] == %{}

    accepted_evidence = unknown.position_evidence
    late_prior = record_prior!(empty, "late-a", 1, empty.gk)
    record_prior!(empty, "late-b", 10, empty.gk)

    assert_raise Postgrex.Error, fn ->
      Repo.query!(
        """
        INSERT INTO statistics_position_basis
          (performance_id, prior_performance_id, position_id, frequency)
        VALUES ($1, $2, $3, 1)
        """,
        [
          Ecto.UUID.dump!(unknown.id),
          Ecto.UUID.dump!(late_prior.id),
          Ecto.UUID.dump!(empty.gk.id)
        ]
      )
    end

    assert Repo.query!(
             "SELECT count(*) FROM statistics_position_basis WHERE performance_id = $1",
             [Ecto.UUID.dump!(unknown.id)]
           ).rows == [[0]]

    candidate = Case.candidate(Fixtures.request(empty.scope))
    match_kickoff = DateTime.new!(Date.new!(empty.season.start_year, 2, 1), ~T[12:00:00Z])
    match = %{hd(candidate.facts.matches) | kickoff_at: match_kickoff}

    performance_fact =
      hd(candidate.facts.performances)
      |> Map.put(:position_ref, nil)
      |> Map.put(:participation, :substitute_entered)

    candidate = %{
      candidate
      | facts: %{
          candidate.facts
          | matches: [match],
            performances: [performance_fact]
        }
    }

    context = Case.delivery_context!(empty.scope)

    later_runtime =
      {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-17 12:00:00.000000Z]}}

    assert {:ok, %{status: :accepted_unchanged}} =
             FootballMarket.Statistics.Ingestion.import_scope(
               empty.scope,
               Keyword.put(Case.provider_options(candidate), :runtime, later_runtime) ++
                 [delivery_context: context]
             )

    retained = Repo.get!(Performance, unknown.id)
    assert is_nil(retained.position_id)
    assert retained.position_evidence == accepted_evidence

    week_start = Date.new!(empty.season.start_year, 2, 1)
    week_start = Date.add(week_start, 1 - Date.day_of_week(week_start))
    week_end = Date.add(week_start, 7)

    valuation_request =
      FootballMarket.ValuationCase.request(
        %{players: [empty.player], season: empty.season, position: empty.gk},
        %{
          week_start: DateTime.new!(week_start, ~T[00:00:00Z]),
          week_end: DateTime.new!(week_end, ~T[00:00:00Z]),
          position_mapping: []
        }
      )

    assert {:error, %{kind: :validation, reason: :missing_position_mapping}} =
             FootballMarket.Valuation.prepare(valuation_request)
  end

  test "a shuffled proposed match cannot become history for another row in the same batch" do
    f = setup_scope(2113)
    candidate = Case.candidate(Fixtures.request(f.scope))
    first = hd(candidate.facts.matches)

    earlier = %{
      first
      | ref: "match-1",
        kickoff_at: DateTime.new!(Date.new!(f.season.start_year, 2, 1), ~T[12:00:00Z])
    }

    later = %{
      first
      | ref: "match-2",
        kickoff_at: DateTime.new!(Date.new!(f.season.start_year, 2, 2), ~T[12:00:00Z])
    }

    direct = hd(candidate.facts.performances)

    substitute =
      direct
      |> Map.put(:ref, "performance-2")
      |> Map.put(:match_ref, "match-2")
      |> Map.put(:position_ref, nil)
      |> Map.put(:participation, :substitute_entered)

    candidate = %{
      candidate
      | facts: %{candidate.facts | matches: [later, earlier], performances: [substitute, direct]},
        completeness: %{
          candidate.completeness
          | eligible_match_identities: ["match-1", "match-2"],
            detail_coverage: ["match-1", "match-2"]
        },
        bindings: candidate.bindings ++ [%{kind: :match, ref: "match-2", source_id: "match-2"}]
    }

    context = Case.delivery_context!(f.scope)

    assert {:ok, _} =
             FootballMarket.Statistics.Ingestion.import_scope(
               f.scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    second_match =
      Repo.one!(
        from m in Match,
          where:
            m.match_identity == "provider:v1:synthetic-a:match-2" and m.season_id == ^f.season.id
      )

    proposed_substitute = Repo.one!(from p in Performance, where: p.match_id == ^second_match.id)
    assert is_nil(proposed_substitute.position_id)
    assert proposed_substitute.position_reason == "insufficient_history"

    refute Repo.exists?(
             from b in PositionBasis, where: b.performance_id == ^proposed_substitute.id
           )
  end
end
