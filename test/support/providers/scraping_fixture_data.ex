defmodule FootballMarket.Providers.ScrapingFixtureData do
  @moduledoc "Synthetic source inputs and independently authored football oracle."
  import ExUnit.Assertions
  alias FootballMarket.Providers
  alias FootballMarket.Providers.{FixtureRuntime, FactOracle, Scraping}
  @external_resource "test/fixtures/scraping/cases.exs"
  @external_resource "test/fixtures/scraping/documents.exs"
  @external_resource "test/fixtures/scraping/expected.exs"
  @external_resource "test/fixtures/scraping/inventory.exs"
  @cases Code.eval_file("test/fixtures/scraping/cases.exs") |> elem(0)
  @documents Code.eval_file("test/fixtures/scraping/documents.exs") |> elem(0)
  @expected Code.eval_file("test/fixtures/scraping/expected.exs") |> elem(0)
  @inventory Code.eval_file("test/fixtures/scraping/inventory.exs") |> elem(0)
  @positions %{"FW" => "Forward", "GK" => "Goalkeeper"}
  @counts [
    :goals,
    :assists,
    :shots_on_target,
    :tackles,
    :interceptions,
    :saves,
    :goals_conceded,
    :yellow_cards,
    :red_cards
  ]
  def cases, do: @cases
  def inventory, do: @inventory
  def documents(id), do: Map.fetch!(@documents, id)
  def positions, do: @positions
  def case!(id), do: Enum.find(@cases, &(&1["id"] == id)) || raise("Unknown synthetic case")

  def assessment(c) do
    metrics =
      Map.new(Enum.with_index(@counts), fn {key, i} ->
        status =
          if c["unverified"] == i or (c["event_unverified"] && key in [:tackles, :goals_conceded]),
            do: :unverified,
            else: if(c["unavailable"] == i, do: :unavailable, else: :verified)

        {key,
         %{
           status: status,
           evidence: "synthetic-direct-#{key}",
           meaning:
             %{
               goals: "ordinary player goals excluding own goals",
               assists: "player-match assists",
               shots_on_target: "ordinary player attempts on target",
               tackles: "successful tackles",
               interceptions: "opposition passes intercepted",
               saves: "goalkeeper saves",
               goals_conceded: "opposition goals while player on field",
               yellow_cards: "player-match yellow cards",
               red_cards: "player-match red cards"
             }[key]
         }}
      end)

    row = %{
      required: :verified,
      witness: "synthetic-terminal-v1",
      competition: c["league"],
      season: "#{c["year"]}/#{c["year"] + 1}",
      positions: %{"attack" => "FW", "keeper" => "GK"},
      metrics: metrics
    }

    assessment = %{
      mode: :fixture,
      revision: 1,
      reviewed_at: ~U[2026-10-07 00:00:00Z],
      expires_at: ~U[2030-01-01 00:00:00Z],
      permission: :granted,
      withdrawn: false,
      conditions: :satisfied,
      destinations: ["fixture"],
      limits: %{concurrency: 1, volume: 1000, cadence_ms: 0},
      evidence: "synthetic-permission-v1",
      scopes: %{{operation(c), c["league"], c["year"], c["year"] + 1} => row}
    }

    case c["gate"] do
      "missing" -> nil
      "expired" -> %{assessment | expires_at: ~U[2020-01-01 00:00:00Z]}
      "withdrawn" -> %{assessment | withdrawn: true}
      "conditions" -> %{assessment | conditions: :unknown}
      "coverage" -> %{assessment | scopes: %{}}
      "operation" -> %{assessment | scopes: %{}}
      "scope" -> %{assessment | scopes: %{}}
      _ -> assessment
    end
  end

  def operation(c), do: if(c["operation"] == "catalog", do: :catalog, else: :performances)

  def request(c) do
    r = %{
      league_code: if(c["invalid"], do: "ZZ", else: c["league"]),
      start_year: c["year"],
      end_year: c["year"] + 1
    }

    r = if c["timeout"], do: Map.put(r, :timeout_ms, c["timeout"]), else: r

    case c["bounds"] do
      [from, to] -> Map.merge(r, %{from: from, to: to})
      _ -> r
    end
  end

  def state(c, overrides \\ %{}) do
    portions =
      Map.new(documents(c["id"]), fn {key, body} ->
        observation = %{
          terminal: c["terminal"] != false,
          witness: if(c["witness"] == false, do: nil, else: "synthetic-terminal-v1"),
          destination: "fixture"
        }

        {key, %{body: body, observation: observation}}
      end)

    portions =
      if c["failure"],
        do:
          Map.put(portions, "catalog", %{
            failure: %{category: fixed_category(c["failure"]), retry_after_ms: c["delay"]}
          }),
        else: portions

    portions =
      if c["later_failure"],
        do: Map.put(portions, "roster:b", %{failure: %{category: :authentication_failed}}),
        else: portions

    overrides =
      if c["revoke_at"] do
        reader = fn ->
          n = Process.get(:scraping_assessment_reads, 0) + 1
          Process.put(:scraping_assessment_reads, n)
          a = assessment(c)
          if n >= c["revoke_at"], do: %{a | withdrawn: true}, else: a
        end

        Map.put(overrides, :assessment_reader, reader)
      else
        overrides
      end

    portions =
      if c["detail_failure"],
        do:
          Map.put(portions, "match:m1", %{failure: %{category: :rate_limited, retry_after_ms: 19}}),
        else: portions

    Map.merge(
      %{
        mode: if(c["live"], do: :live, else: :fixture),
        enabled: c["enabled"] || false,
        assessment: assessment(c),
        fixture_id: c["id"],
        transport: Scraping.FixtureTransport,
        portions: portions,
        elapsed_us: c["elapsed"] || 0,
        owner: self(),
        repeat: c["repeat"] || false
      },
      overrides
    )
  end

  defp fixed_category(name),
    do: Enum.find(Providers.Error.categories(), &(Atom.to_string(&1) == name))

  def run(c, overrides \\ %{}, runtime \\ {FixtureRuntime, %{}}) do
    Process.put(:fixture_elapsed, 0)
    Process.put(:scraping_assessment_reads, 0)

    apply(Providers, operation(c), [
      request(c),
      [provider: {Scraping, state(c, overrides)}, positions: @positions, runtime: runtime]
    ])
  end

  def assert_case!(c, overrides \\ %{}, runtime \\ {FixtureRuntime, %{}}) do
    outcome = run(c, overrides, runtime)
    expected = Map.fetch!(@expected, c["id"])

    if expected["category"] do
      assert {:error, error} = outcome, c["id"] <> ": " <> inspect(outcome)
      assert Atom.to_string(error.category) == expected["category"], c["id"]
      assert error.retry_after_ms == expected["delay"]
      assert error.retryable == error.category in [:rate_limited, :unavailable, :timeout]
      refute inspect(error) =~ "FAKE_SENTINEL"
    else
      assert {:ok, result} = outcome, c["id"] <> ": " <> inspect(outcome)
      facts = expected_facts(c, expected)
      FactOracle.assert_facts!(result.facts, facts, correspondence(facts))
      assert result.provenance.provider == "fotmob-shaped-offline"
      assert result.provenance.fixture_id == c["id"]
      assert result.provenance.retrieved_at == ~U[2026-10-06 12:00:00.000000Z]

      targets =
        [{:league, "league"}, {:season, "season"}] ++
          for(
            {kind, field} <- [{:team, :teams}, {:player, :players}, {:match, :matches}],
            row <- Map.get(facts, field, []),
            do: {kind, row.ref}
          )

      assert Enum.sort(Enum.map(result.provenance.bindings, &{&1.kind, &1.ref, &1.source_id})) ==
               Enum.sort(
                 Enum.map(targets, fn {kind, ref} ->
                   {kind, ref,
                    if(ref == "league",
                      do: c["league"],
                      else:
                        if(ref == "season",
                          do: "#{c["year"]}/#{c["year"] + 1}",
                          else: String.replace_prefix(ref, Atom.to_string(kind) <> ":", "")
                        )
                    )}
                 end)
               )

      for b <- result.provenance.bindings do
        assert b.provider == "fotmob-shaped-offline"

        assert {b.league_code, b.start_year, b.end_year} ==
                 {c["league"], c["year"], c["year"] + 1}
      end
    end

    outcome
  end

  # Literal football model independent from parsing and production Validator.
  def expected_facts(_c, %{"facts" => facts}), do: facts

  def expected_facts(c, e) do
    names = %{
      "PL" => "Premier League",
      "BL1" => "Bundesliga",
      "PD" => "La Liga",
      "SA" => "Serie A",
      "FL1" => "Ligue 1"
    }

    base = %{
      league: %{ref: "league", code: c["league"], name: names[c["league"]]},
      season: %{
        ref: "season",
        league_ref: "league",
        start_year: c["year"],
        end_year: c["year"] + 1
      },
      teams: [
        %{ref: "team:a", season_ref: "season", name: "Alpha", code: "ALP"},
        %{ref: "team:b", season_ref: "season", name: "Beta", code: "BET"}
      ],
      positions: [
        %{ref: "FW", code: "FW", name: "Forward"},
        %{ref: "GK", code: "GK", name: "Goalkeeper"}
      ],
      players: [
        %{
          ref: "player:p1",
          season_ref: "season",
          display_name: "Alex Example",
          team_ref: "team:a",
          position_ref: "FW"
        },
        %{
          ref: "player:p2",
          season_ref: "season",
          display_name: "Alex Example",
          team_ref: "team:b",
          position_ref: "GK"
        }
      ]
    }

    cond do
      e["empty"] && operation(c) == :catalog ->
        %{base | teams: [], players: []}

      operation(c) == :catalog ->
        base

      e["empty"] ->
        Map.merge(%{base | teams: [], positions: [], players: []}, %{
          matches: [],
          performances: []
        })

      true ->
        match = %{
          ref: "match:m1",
          season_ref: "season",
          status: :completed,
          kickoff_at: "2024-10-01T12:00:00.000000Z",
          home_team_ref: "team:a",
          away_team_ref: "team:b"
        }

        performances =
          if e["empty_appearances"],
            do: [],
            else: [
              %{
                ref: "performance:m1:p1",
                match_ref: "match:m1",
                player_ref: "player:p1",
                team_ref: "team:a",
                position_ref: "FW",
                minutes_played: e["minutes"],
                counts: Map.new(Enum.zip(@counts, e["counts"]))
              }
            ]

        players =
          if e["empty_appearances"],
            do: [],
            else: [
              %{
                ref: "player:p1",
                season_ref: "season",
                display_name: "Alex Example",
                team_ref: "team:b",
                position_ref: "GK"
              }
            ]

        positions = if e["empty_appearances"], do: [], else: base.positions

        Map.merge(%{base | players: players, positions: positions}, %{
          matches: [match],
          performances: performances
        })
    end
  end

  def correspondence(facts),
    do:
      Map.new(facts, fn {key, value} ->
        kind =
          %{
            teams: :team,
            positions: :position,
            players: :player,
            matches: :match,
            performances: :performance
          }[key] || key

        {kind, Map.new(if(is_list(value), do: value, else: [value]), &{&1.ref, &1.ref})}
      end)
end
