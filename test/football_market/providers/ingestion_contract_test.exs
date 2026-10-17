defmodule FootballMarket.Providers.IngestionContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Providers.{Performances, Request, Validator}
  alias FootballMarket.Statistics.Input

  defp request do
    {:ok, request} =
      Request.normalize(:performances, %{league_code: "PL", start_year: 2025, end_year: 2026})

    request
  end

  defp facts(participation, position_ref, counts \\ %{}) do
    scope = Map.take(request().scope, [:league_code, :start_year, :end_year])

    %{
      league: %{ref: "league", code: "PL", name: "Premier League"},
      season: %{ref: "season", league_ref: "league", start_year: 2025, end_year: 2026},
      teams: [
        %{ref: "home", season_ref: "season", name: "Home", code: "H"},
        %{ref: "away", season_ref: "season", name: "Away", code: "A"}
      ],
      positions: [%{ref: "MID", code: "MID", name: "Midfielder"}],
      players: [
        %{
          ref: "player",
          season_ref: "season",
          display_name: "Player",
          team_ref: "home",
          position_ref: "MID"
        }
      ],
      matches: [
        %{
          ref: "match",
          scope: scope,
          season_ref: "season",
          status: :completed,
          kickoff_at: ~U[2026-02-01 12:00:00Z],
          home_team_ref: "home",
          away_team_ref: "away"
        }
      ],
      performances: [
        %{
          ref: "row",
          match_ref: "match",
          player_ref: "player",
          team_ref: "home",
          position_ref: position_ref,
          minutes_played: 20,
          counts: counts,
          participation: participation
        }
      ]
    }
  end

  defp bindings do
    for {kind, ref, source_id} <- [
          {:league, "league", "league"},
          {:season, "season", "season"},
          {:team, "home", "home"},
          {:team, "away", "away"},
          {:player, "player", "player"},
          {:match, "match", "match"}
        ],
        do: %{kind: kind, ref: ref, source_id: source_id}
  end

  defp completeness(match_ids, request) do
    %{
      version: 1,
      scope: request.scope,
      full_scope: true,
      terminal_witness: "terminal-v1",
      eligible_match_identities: match_ids,
      detail_coverage: match_ids,
      assessment_revision: "assessment-v1",
      assessment_reference: "assessment-ref-v1",
      complete_empty: match_ids == []
    }
  end

  defp validate(candidate, request) do
    Validator.validate(
      candidate,
      request,
      %{
        positions: %{"MID" => "Midfielder"},
        runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
      },
      "synthetic-a"
    )
  end

  test "only an evidenced substitute may retain an unknown effective position" do
    {normalized, _} =
      Performances.validate(facts(:substitute_entered, nil), bindings(), request(), %{
        "MID" => "Midfielder"
      })

    assert hd(normalized.performances).position_ref == nil
    assert hd(normalized.performances).participation == :substitute_entered

    assert catch_throw(
             Performances.validate(facts(:starter, nil), bindings(), request(), %{
               "MID" => "Midfielder"
             })
           ) == {:invalid, :position}
  end

  test "a direct match position remains present for an entrant" do
    {normalized, _} =
      Performances.validate(facts(:substitute_entered, "MID"), bindings(), request(), %{
        "MID" => "Midfielder"
      })

    assert hd(normalized.performances).position_ref == "MID"
  end

  test "legacy direct positions remain valid while unsupported or missing role evidence is rejected" do
    {legacy, _} =
      Performances.validate(facts(nil, "MID"), bindings(), request(), %{"MID" => "Midfielder"})

    assert hd(legacy.performances).position_ref == "MID"

    for {participation, position_ref} <- [
          {nil, nil},
          {:unknown_role, "MID"},
          {:starter, "UNMAPPED"}
        ] do
      assert {:invalid, _field} =
               catch_throw(
                 Performances.validate(
                   facts(participation, position_ref),
                   bindings(),
                   request(),
                   %{"MID" => "Midfielder"}
                 )
               )
    end
  end

  test "all optional metrics preserve unknown separately from an explicit zero" do
    counts = Map.new(Performances.count_keys(), &{&1, nil}) |> Map.put(:goals, 0)
    source = facts(:starter, "MID")
    source = put_in(source, [:performances, Access.at(0), :counts], counts)

    {normalized, _} =
      Performances.validate(source, bindings(), request(), %{"MID" => "Midfielder"})

    actual = hd(normalized.performances).counts
    assert actual.goals == 0
    assert actual.assists == nil
    assert Map.keys(actual) |> Enum.sort() == Enum.sort(Performances.count_keys())
    assert Enum.count(Map.values(actual), &is_nil/1) == length(Performances.count_keys()) - 1
  end

  test "completeness requires a full unbounded scope, terminal witness and detail for every eligible match" do
    request = request()
    source_facts = facts(:starter, "MID")

    candidate = %{
      operation: :performances,
      scope: request.scope,
      facts: source_facts,
      bindings: bindings(),
      completeness: completeness(["match"], request)
    }

    assert {:ok, %{completeness: %{full_scope: true}}} = validate(candidate, request)

    incomplete = put_in(candidate, [:completeness, :detail_coverage], [])
    assert {:error, %{field: :completeness}} = validate(incomplete, request)

    no_terminal = put_in(candidate, [:completeness, :terminal_witness], " ")
    assert {:error, %{field: :completeness}} = validate(no_terminal, request)

    malformed = %{candidate | completeness: Map.delete(candidate.completeness, :full_scope)}
    assert {:error, %{field: :completeness}} = validate(malformed, request)

    wrong_scope = put_in(candidate, [:completeness, :scope, :start_year], 2024)
    assert {:error, %{field: :completeness}} = validate(wrong_scope, request)

    missing_eligible_match =
      put_in(candidate, [:completeness, :eligible_match_identities], [])

    assert {:error, %{field: :completeness}} = validate(missing_eligible_match, request)

    wrong_detail_identity =
      put_in(candidate, [:completeness, :detail_coverage], ["another-match"])

    assert {:error, %{field: :completeness}} = validate(wrong_detail_identity, request)
  end

  test "an explicit empty complete scope needs a matching empty attestation" do
    request = request()

    source_facts = facts(:starter, "MID")
    source_facts = %{source_facts | matches: [], performances: []}
    source_bindings = Enum.reject(bindings(), &(&1.kind == :match))

    candidate = %{
      operation: :performances,
      scope: request.scope,
      facts: source_facts,
      bindings: source_bindings,
      completeness: completeness([], request)
    }

    assert {:ok, %{facts: %{matches: [], performances: []}}} = validate(candidate, request)

    no_attestation = put_in(candidate, [:completeness, :complete_empty], false)
    assert {:error, %{field: :completeness}} = validate(no_attestation, request)
  end

  test "bounded performance requests cannot claim full-season completeness" do
    {:ok, request} =
      Request.normalize(:performances, %{
        league_code: "PL",
        start_year: 2025,
        end_year: 2026,
        from: ~U[2026-01-01 00:00:00Z]
      })

    candidate = %{
      operation: :performances,
      scope: request.scope,
      facts: facts(:starter, "MID"),
      bindings: bindings(),
      completeness: completeness(["match"], request)
    }

    assert {:error, %{field: :completeness}} = validate(candidate, request)
  end

  test "provider errors redact rejected source diagnostics" do
    request = request()

    candidate = %{
      operation: :performances,
      scope: request.scope,
      facts: facts(:starter, "MID"),
      bindings: bindings(),
      fixture_id: "api_key=private-fixture-secret"
    }

    assert {:error, %{field: :provenance, reference: nil} = error} = validate(candidate, request)
    refute inspect(error) =~ "private-fixture-secret"
  end

  test "provider validation preserves each optional metric as unknown or explicit zero" do
    for metric <- Input.metrics() do
      counts = Map.new(Input.metrics(), &{&1, nil}) |> Map.put(metric, 0)

      {normalized, _} =
        Performances.validate(facts(:starter, "MID", counts), bindings(), request(), %{
          "MID" => "Midfielder"
        })

      assert hd(normalized.performances).counts == counts
    end
  end
end
