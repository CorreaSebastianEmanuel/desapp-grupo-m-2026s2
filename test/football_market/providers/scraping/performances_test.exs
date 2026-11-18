defmodule FootballMarket.Providers.ScrapingPerformancesTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data

  test "literal dated facts, tri-state metrics, affiliation and required-field failures" do
    for c <- Data.cases(),
        c["operation"] == "performances",
        not String.starts_with?(c["id"], ["deadline-", "source-equivalence-"]) do
      Data.assert_case!(c)
    end
  end

  test "unrelated duplicate rating and aggregate labels do not become football counts" do
    c = Data.case!("performance-PL-2024")
    state = Data.state(c)
    match = Jason.decode!(state.portions["match:m1"].body)
    stats = get_in(match, ["content", "playerStats", "p1", "stats"])
    rating = %{"key" => "rating", "stat" => %{"value" => "FAKE_SENTINEL"}}

    match =
      put_in(
        match,
        ["content", "playerStats", "p1", "stats"],
        stats ++ [%{"stats" => [rating, rating]}]
      )

    portions = put_in(state.portions, ["match:m1", :body], Jason.encode!(match))
    assert {:ok, result} = Data.assert_case!(c, %{portions: portions})
    refute inspect(result) =~ "FAKE_SENTINEL"
  end

  test "player mode fetches only one profile and its match details" do
    c = Data.case!("performance-PL-2024")

    state =
      Data.state(c, %{
        owner: self(),
        player_name: "Alex Example",
        player_team_name: "Alpha",
        player_position_code: "FW"
      })

    scope_key = {:performances, c["league"], c["year"], c["year"] + 1}

    assessment = %{
      state.assessment
      | scopes:
          Map.update!(state.assessment.scopes, scope_key, fn row ->
            %{row | positions: %{"keeper" => "GK", "attack" => "FW"}}
          end)
    }

    state = %{state | assessment: assessment}

    match = Jason.decode!(state.portions["match:m1"].body)
    player = get_in(match, ["content", "playerStats", "p1"])

    player =
      player
      |> Map.put("positionId", "attack")
      |> Map.put("usualPosition", "attack")
      |> Map.update!("stats", fn groups ->
        Enum.map(groups, fn group ->
          Map.update!(group, "stats", fn stats ->
            stats
            |> Map.new(&{&1["key"], &1})
            |> Map.drop(["yellow_cards", "red_cards"])
          end)
        end)
      end)

    player = Map.put(player, "currentTeamId", "a")

    player =
      update_in(player, ["stats"], fn groups ->
        Enum.map(groups, fn group ->
          update_in(group, ["stats"], fn stats ->
            stats |> put_in(["goals", "stat", "value"], 1)
          end)
        end)
      end)

    match = put_in(match, ["content", "playerStats", "p1"], player)
    match_body = Jason.encode!(match)

    portions =
      state.portions
      |> Map.put("player_search:Alex Example", %{
        body:
          Jason.encode!([
            %{
              "title" => %{"key" => "all", "value" => "All"},
              "suggestions" => [
                %{
                  "type" => "player",
                  "id" => "p1",
                  "name" => "Alex Example",
                  "teamName" => "Alpha"
                }
              ]
            },
            %{
              "title" => %{"key" => "players", "value" => "Players"},
              "suggestions" => [
                %{
                  "type" => "player",
                  "id" => "p1",
                  "name" => "Alex Example",
                  "teamName" => "Alpha"
                }
              ]
            }
          ]),
        observation: state.portions["match:m1"].observation
      })
      |> Map.put("player_data:p1", %{
        body:
          Jason.encode!(%{
            "id" => "p1",
            "name" => "Alex Example",
            "statSeasons" => [
              %{
                "seasonName" => "2024/2025",
                "tournaments" => [%{"tournamentId" => "PL"}]
              }
            ],
            "initialMatchesPage" => %{
              "matches" => [
                %{
                  "id" => "m1",
                  "leagueId" => "PL",
                  "teamId" => "a",
                  "teamName" => "Alpha",
                  "opponentTeamId" => "b",
                  "opponentTeamName" => "Beta",
                  "isHomeTeam" => true,
                  "matchDate" => %{"utcTime" => "2024-10-01T12:00:00Z"},
                  "playedInMatch" => true,
                  "lineupPositionId" => nil,
                  "minutesPlayed" => 90,
                  "goals" => 1,
                  "assists" => 0,
                  "yellowCards" => 1,
                  "redCards" => 0,
                  "matchPageUrl" => "/matches/alpha-beta/m1"
                }
              ],
              "previous" => nil
            }
          }),
        observation: state.portions["match:m1"].observation
      })
      |> Map.put("match_details:m1", %{state.portions["match:m1"] | body: match_body})

    result =
      FootballMarket.Providers.performances(Data.request(c),
        provider: {FootballMarket.Providers.Scraping, %{state | portions: portions}},
        positions: Data.positions(),
        runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
      )

    assert {:ok, result} = result
    assert result.completeness.full_scope == "player"
    assert Enum.all?(result.facts.performances, &(&1.player_ref == "player:p1"))
    assert hd(result.facts.performances).position_ref == "FW"
    assert hd(result.facts.performances).minutes_played == 90
    assert hd(result.facts.performances).counts.goals == 1
    assert hd(result.facts.performances).counts.assists == 0
    assert hd(result.facts.performances).counts.yellow_cards == 1
    assert hd(result.facts.performances).counts.red_cards == 0
    assert Enum.map(result.facts.matches, & &1.ref) == ["match:m1"]

    assert_receive {:scraping_fetch, "player_search:Alex Example", _pid}
    assert_receive {:scraping_fetch, "player_data:p1", _pid}
    assert_receive {:scraping_fetch, "match_details:m1", _pid}
    refute_receive {:scraping_fetch, "schedule", _pid}
    assert hd(result.facts.performances).counts.shots_on_target == 0
    assert hd(result.facts.performances).counts.tackles == 0
    assert hd(result.facts.performances).counts.interceptions == 0

    for mutate <- [
          &put_in(&1, ["general", "matchId"], "wrong"),
          &put_in(&1, ["general", "parentLeagueId"], "wrong"),
          &put_in(&1, ["general", "season"], "2023/2024"),
          &put_in(&1, ["general", "matchTimeUTCDate"], "2024-10-02T12:00:00Z"),
          &put_in(&1, ["general", "finished"], false),
          &put_in(&1, ["general", "homeTeam", "id"], "wrong"),
          &put_in(&1, ["content", "playerStats", "p1", "id"], "wrong"),
          &put_in(&1, ["content", "playerStats", "p1", "teamId"], "wrong"),
          fn data ->
            data
            |> put_in(["content", "playerStats", "p1", "positionId"], "unknown")
            |> put_in(["content", "playerStats", "p1", "usualPosition"], "unknown")
          end
        ] do
      changed = put_in(portions, ["match_details:m1", :body], Jason.encode!(mutate.(match)))

      assert {:error, %{category: :invalid_response}} =
               FootballMarket.Providers.performances(Data.request(c),
                 provider: {FootballMarket.Providers.Scraping, %{state | portions: changed}},
                 positions: Data.positions(),
                 runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
               )
    end

    absent_profile =
      Jason.decode!(portions["player_data:p1"].body)
      |> update_in(["initialMatchesPage", "matches"], fn [entry] ->
        [Map.put(entry, "playedInMatch", false)]
      end)

    absent_portions = put_in(portions, ["player_data:p1", :body], Jason.encode!(absent_profile))
    assert {:ok, no_participation} = player_result(c, %{state | portions: absent_portions})
    assert no_participation.facts.performances == []
    assert no_participation.completeness.complete_empty

    # Observed Haaland shape: profile 105, match 115, assessed usual role 3.
    tactical =
      match
      |> put_in(["content", "playerStats", "p1", "positionId"], 115)
      |> put_in(["content", "playerStats", "p1", "usualPosition"], 3)
      |> put_in(["content", "lineup"], %{
        "homeTeam" => %{
          "id" => "a",
          "starters" => [%{"id" => "p1", "positionId" => 115, "usualPlayingPositionId" => 3}]
        },
        "awayTeam" => %{"id" => "b", "starters" => []}
      })

    profile = Jason.decode!(portions["player_data:p1"].body)

    profile =
      update_in(profile, ["initialMatchesPage", "matches"], fn [entry] ->
        [Map.put(entry, "lineupPositionId", 105)]
      end)

    tactical_portions =
      portions
      |> put_in(["player_data:p1", :body], Jason.encode!(profile))
      |> put_in(["match_details:m1", :body], Jason.encode!(tactical))

    tactical_assessment =
      update_in(assessment.scopes[scope_key].positions, &Map.put(&1, "3", "FW"))

    tactical_state = %{state | assessment: tactical_assessment, portions: tactical_portions}
    assert {:ok, corroborated} = player_result(c, tactical_state)
    assert hd(corroborated.facts.performances).position_ref == "FW"

    numeric_portions =
      Map.new(tactical_portions, fn {key, portion} ->
        {String.replace(key, "p1", "737066"),
         %{portion | body: String.replace(portion.body, "p1", "737066")}}
      end)

    numeric_match =
      Jason.decode!(numeric_portions["match_details:m1"].body)
      |> put_in(["content", "playerStats", "737066", "id"], 737_066)

    numeric_portions =
      put_in(numeric_portions, ["match_details:m1", :body], Jason.encode!(numeric_match))

    assert {:ok, _} =
             player_result(
               c,
               Map.merge(tactical_state, %{portions: numeric_portions, player_source_id: "737066"})
             )

    for mutate <- [
          &put_in(&1, ["content", "lineup", "homeTeam", "id"], "wrong"),
          &put_in(&1, ["content", "lineup", "homeTeam", "starters"], []),
          &put_in(&1, ["content", "lineup", "homeTeam", "starters"], [
            %{"id" => "p1", "positionId" => 105, "usualPlayingPositionId" => 3}
          ]),
          &put_in(&1, ["content", "lineup", "homeTeam", "starters"], [
            %{"id" => "p1", "positionId" => 115, "usualPlayingPositionId" => "keeper"}
          ]),
          &put_in(&1, ["content", "playerStats", "p1", "positionId"], nil),
          &put_in(&1, ["content", "playerStats", "p1", "usualPosition"], "unknown"),
          &put_in(&1, ["content", "playerStats", "p1", "positionId"], "keeper")
        ] do
      changed =
        put_in(tactical_portions, ["match_details:m1", :body], Jason.encode!(mutate.(tactical)))

      assert {:error, %{category: :invalid_response}} =
               player_result(c, %{tactical_state | portions: changed})
    end

    contradictory =
      update_in(profile, ["initialMatchesPage", "matches"], fn [entry] ->
        [Map.put(entry, "lineupPositionId", "keeper")]
      end)

    changed = put_in(tactical_portions, ["player_data:p1", :body], Jason.encode!(contradictory))

    assert {:error, %{category: :invalid_response}} =
             player_result(c, %{tactical_state | portions: changed})

    # Observed Anselmino shape: November 2026 match, stale 2025/2026 summary.
    current_case = Map.put(c, "year", 2026)

    current_assessment = %{
      tactical_assessment
      | scopes: %{
          {:performances, "PL", 2026, 2027} => %{
            tactical_assessment.scopes[scope_key]
            | season: "2026/2027"
          }
        }
    }

    current_portions =
      Map.new(tactical_portions, fn {key, portion} ->
        {key,
         %{
           portion
           | body:
               portion.body
               |> String.replace("2024-10-01", "2026-11-08")
               |> String.replace("2024/2025", "2025/2026")
         }}
      end)

    current_match = Jason.decode!(current_portions["match_details:m1"].body)
    current_match = put_in(current_match, ["general", "season"], "2026/2027")

    current_portions =
      put_in(current_portions, ["match_details:m1", :body], Jason.encode!(current_match))

    current_state = %{tactical_state | assessment: current_assessment, portions: current_portions}

    assert {:ok, recovered} =
             player_result(current_case, current_state)

    assert hd(recovered.facts.matches).kickoff_at == ~U[2026-11-08 12:00:00.000000Z]
    incomplete_profile = Jason.decode!(current_portions["player_data:p1"].body)

    for mutate <- [
          &put_in(&1, ["initialMatchesPage", "previous"], "more"),
          &update_in(&1, ["initialMatchesPage", "matches"], fn [entry] ->
            [Map.put(entry, "playedInMatch", false)]
          end)
        ] do
      changed =
        put_in(
          current_portions,
          ["player_data:p1", :body],
          Jason.encode!(mutate.(incomplete_profile))
        )

      assert {:error, _} =
               player_result(current_case, %{current_state | portions: changed})
    end

    missing =
      update_in(match, ["content", "playerStats", "p1", "stats"], fn groups ->
        Enum.map(groups, fn group ->
          Map.update!(group, "stats", &Map.delete(&1, "ShotsOnTarget"))
        end)
      end)

    changed = put_in(portions, ["match_details:m1", :body], Jason.encode!(missing))

    assert {:ok, partial} =
             FootballMarket.Providers.performances(Data.request(c),
               provider: {FootballMarket.Providers.Scraping, %{state | portions: changed}},
               positions: Data.positions(),
               runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
             )

    assert hd(partial.facts.performances).counts.shots_on_target == nil

    assert {:ok, bounded} =
             FootballMarket.Providers.performances(
               Map.put(Data.request(c), :from, "2024-10-02T00:00:00Z"),
               provider: {FootballMarket.Providers.Scraping, %{state | portions: portions}},
               positions: Data.positions(),
               runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
             )

    assert bounded.facts.matches == []
  end

  test "player mode rejects a history page that cannot prove season coverage" do
    c = Data.case!("performance-PL-2024")
    state = Data.state(c, %{owner: self(), player_source_id: "p1"})

    portions =
      Map.put(state.portions, "player_data:p1", %{
        body:
          Jason.encode!(%{
            "id" => "p1",
            "initialMatchesPage" => %{
              "matches" => [
                %{
                  "id" => "m1",
                  "leagueId" => "PL",
                  "matchDate" => %{"utcTime" => "2024-10-01T12:00:00Z"},
                  "playedInMatch" => true
                }
              ],
              "previous" => "older-page"
            }
          }),
        observation: state.portions["match:m1"].observation
      })

    assert {:error, %{category: :invalid_response}} =
             FootballMarket.Providers.performances(Data.request(c),
               provider: {FootballMarket.Providers.Scraping, %{state | portions: portions}},
               positions: Data.positions(),
               runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
             )

    assert_receive {:scraping_fetch, "player_data:p1", _pid}
    refute_receive {:scraping_fetch, "schedule", _pid}
  end

  test "player mode classifies a profile without the requested league season as unsupported" do
    c = Data.case!("performance-PL-2024")
    state = Data.state(c, %{owner: self(), player_source_id: "p1"})

    portions =
      Map.put(state.portions, "player_data:p1", %{
        body:
          Jason.encode!(%{
            "id" => "p1",
            "statSeasons" => [
              %{
                "seasonName" => "2023/2024",
                "tournaments" => [%{"tournamentId" => "PL"}]
              }
            ]
          }),
        observation: state.portions["match:m1"].observation
      })

    assert {:error, %{category: :unsupported_capability}} =
             FootballMarket.Providers.performances(Data.request(c),
               provider: {FootballMarket.Providers.Scraping, %{state | portions: portions}},
               positions: Data.positions(),
               runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
             )

    assert_receive {:scraping_fetch, "player_data:p1", _pid}
    refute_receive {:scraping_fetch, "schedule", _pid}
  end

  test "nullable substitute slots require corroborated same-match roles" do
    {c, state, profile, match} = audit_player_sample()

    substitute =
      match
      |> put_in(["content", "playerStats", "p1", "positionId"], nil)
      |> put_in(["content", "lineup", "homeTeam", "starters"], [])
      |> put_in(["content", "lineup", "homeTeam", "subs"], [
        %{"id" => "p1", "positionId" => nil, "usualPlayingPositionId" => 3}
      ])

    assert {:ok, result} = audit_player_result(c, state, profile, substitute)
    assert [performance] = result.facts.performances
    assert performance.position_ref == "FW"
    assert performance.minutes_played == 90

    for mutate <- [
          &put_in(&1, ["content", "lineup"], nil),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs"], []),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs"], [
            %{"id" => "p1", "positionId" => 115, "usualPlayingPositionId" => 3}
          ]),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs"], [
            %{"id" => "p1", "positionId" => nil, "usualPlayingPositionId" => "keeper"}
          ]),
          &put_in(&1, ["content", "playerStats", "p1", "usualPosition"], "unknown"),
          fn data ->
            data
            |> put_in(["content", "lineup", "homeTeam", "subs"], [])
            |> put_in(["content", "lineup", "homeTeam", "starters"], [
              %{"id" => "p1", "positionId" => nil, "usualPlayingPositionId" => 3}
            ])
          end
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, profile, mutate.(substitute))
    end
  end

  test "complete history and independent unused bench evidence verify an empty season" do
    {c, state, profile, match} = audit_player_sample()

    profile =
      profile
      |> Map.put("statSeasons", [])
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "playedInMatch"], false)
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "minutesPlayed"], nil)

    match =
      match
      |> put_in(["content", "playerStats", "p1", "stats"], [])
      |> put_in(["content", "lineup", "homeTeam", "starters"], [])
      |> put_in(["content", "lineup", "homeTeam", "subs"], [
        %{"id" => "p1", "performance" => %{}}
      ])

    assert {:ok, result} = audit_player_result(c, state, profile, match)
    assert result.facts.matches == []
    assert result.facts.performances == []

    for mutate <- [
          &put_in(&1, ["general", "finished"], false),
          &put_in(&1, ["general", "matchId"], "other"),
          &put_in(&1, ["general", "homeTeam", "id"], "other"),
          &put_in(&1, ["content", "playerStats", "p1", "teamId"], "other"),
          &put_in(&1, ["content", "playerStats", "p1", "stats"], [%{"stats" => []}]),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs"], []),
          &put_in(&1, ["content", "lineup", "homeTeam", "starters"], [%{"id" => "p1"}]),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs", Access.at(0), "positionId"], 115),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs", Access.at(0), "performance"], %{
            "rating" => 6
          })
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, profile, mutate.(match))
    end

    incomplete = put_in(profile, ["initialMatchesPage", "previous"], "more-history")

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, incomplete, match)

    contradictory =
      put_in(profile, ["initialMatchesPage", "matches", Access.at(0), "minutesPlayed"], 1)

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, contradictory, match)

    other_league =
      put_in(profile, ["initialMatchesPage", "matches", Access.at(0), "leagueId"], "other")

    assert {:error, %{category: :unsupported_capability}} =
             audit_player_result(c, state, other_league, match)
  end

  test "club suffix equivalence retains exact and unambiguous player identity" do
    for {catalog_team, source_team, league} <- [
          {"Real Madrid CF", "Real Madrid", "PL"},
          {"Genoa CFC", "Genoa", "PL"},
          {"Le Havre AC", "Le Havre", "FL1"},
          {"Lille OSC", "Lille", "FL1"},
          {"Stade Rennais FC 1901", "Rennes", "FL1"},
          {"Club Atlético de Madrid", "Atlético Madrid", "PD"},
          {"Real Sociedad de Fútbol", "Real Sociedad", "PD"},
          {"ACF Fiorentina", "Fiorentina", "SA"},
          {"Cagliari Calcio", "Cagliari", "SA"},
          {"Parma Calcio 1913", "Parma", "SA"},
          {"Racing Club de Lens", "Lens", "FL1"},
          {"RC Celta de Vigo", "Celta Vigo", "PD"},
          {"CA Osasuna", "Osasuna", "PD"},
          {"AJ Auxerre", "Auxerre", "FL1"},
          {"OGC Nice", "Nice", "FL1"},
          {"Angers SCO", "Angers", "FL1"},
          {"Bologna FC 1909", "Bologna", "SA"},
          {"Levante UD", "Levante", "PD"},
          {"RC Deportivo La Coruña", "Deportivo A Coruña", "PD"},
          {"AC Milan", "Milan", "SA"},
          {"AC Monza", "Monza", "SA"},
          {"AS Roma", "Roma", "SA"},
          {"Como 1907", "Como", "SA"},
          {"FC Internazionale Milano", "Inter", "SA"},
          {"US Sassuolo Calcio", "Sassuolo", "SA"},
          {"Udinese Calcio", "Udinese", "SA"},
          {"Olympique de Marseille", "Marseille", "FL1"},
          {"ES Troyes AC", "Troyes", "FL1"}
        ] do
      {c, state, profile, match} = audit_player_sample(league)

      candidate = %{
        "type" => "player",
        "id" => "p1",
        "name" => "Alex Example",
        "teamName" => source_team
      }

      discovery =
        state
        |> Map.delete(:player_source_id)
        |> Map.put(:player_name, "Alex Example")
        |> Map.put(:player_team_name, catalog_team)

      for {candidates, expected} <- [
            {[candidate], :accepted},
            {[Map.put(candidate, "teamName", source_team <> " Women")], :rejected},
            {[Map.put(candidate, "name", "Other Example")], :rejected},
            {[candidate, Map.put(candidate, "id", "p2")], :rejected}
          ] do
        search = %{
          state.portions["match:m1"]
          | body: Jason.encode!([%{"suggestions" => candidates}])
        }

        discovery = put_in(discovery.portions["player_search:Alex Example"], search)
        result = audit_player_result(c, discovery, profile, match)

        if expected == :accepted,
          do: assert({:ok, _} = result),
          else: assert({:error, _} = result)
      end
    end
  end

  test "observed player aliases require exact league, club and unique source identity" do
    for {catalog_name, source_name, team, league} <- [
          {"Chikwubuike Adamu", "Chukwubuike Adamu", "FC Schalke 04", "BL1"},
          {"Daniel Fernandes", "Daniel Heuer Fernandes", "Hamburger SV", "BL1"},
          {"David Wolfe", "David Møller Wolfe", "Hamburger SV", "BL1"},
          {"Dina Ebimbe", "Junior Dina Ebimbe", "FC Schalke 04", "BL1"},
          {"Lennart Maloney", "Lennard Maloney", "1. FSV Mainz 05", "BL1"},
          {"Philipp Mwene", "Phillipp Mwene", "1. FSV Mainz 05", "BL1"},
          {"Sehrou Guirassy", "Serhou Guirassy", "Borussia Dortmund", "BL1"},
          {"Soufiane El-Faouzi", "Soufian El-Faouzi", "FC Schalke 04", "BL1"},
          {"Victor Boniface", "Victor Okoh Boniface", "Bayer 04 Leverkusen", "BL1"},
          {"Ørjan Nyland", "Ørjan Håskjold Nyland", "RB Leipzig", "BL1"},
          {"Isak Jensen", "Isak Steiner Jensen", "FC Lorient", "FL1"},
          {"Lionel Mpasi", "Lionel Mpasi-Nzau", "Le Havre AC", "FL1"},
          {"Luc Zogbe", "Luck Zogbé", "Stade Brestois 29", "FL1"},
          {"Matvei Safonov", "Matvey Safonov", "Paris Saint-Germain FC", "FL1"},
          {"Merwan Ifnaoui", "Merwan Ifnaou", "ES Troyes AC", "FL1"},
          {"Mezian Soares", "Mezian Mesloub Soares", "Racing Club de Lens", "FL1"},
          {"Mickaël Cuisance", "Michaël Cuisance", "Racing Club de Lens", "FL1"},
          {"Mohammed Amoura", "Mohamed Amoura", "OGC Nice", "FL1"},
          {"Ousman Camara", "Ousmane Camara", "Angers SCO", "FL1"},
          {"Pape Diop", "Pape Demba Diop", "RC Strasbourg Alsace", "FL1"},
          {"Srđan Kuzmić", "Srdjan Kuzmić", "FC Lorient", "FL1"},
          {"Timothée Nkada", "Timothé Nkada", "ES Troyes AC", "FL1"},
          {"Tochukwu Nadi", "Tochukwu Nnadi", "Olympique de Marseille", "FL1"},
          {"William Pacho", "Willian Pacho", "Paris Saint-Germain FC", "FL1"},
          {"Aleñà", "Carles Aleñá", "Deportivo Alavés", "PD"},
          {"Arana", "Juan Carlos Arana", "Real Racing Club de Santander", "PD"},
          {"Bartra", "Marc Bartra", "Real Betis Balompié", "PD"},
          {"Buba", "Buba Sangaré", "Elche CF", "PD"},
          {"Canales", "Sergio Canales", "Real Racing Club de Santander", "PD"},
          {"Catena", "Alejandro Catena", "CA Osasuna", "PD"},
          {"Christian Romero", "Cristian Romero", "Club Atlético de Madrid", "PD"},
          {"Copete", "José Copete", "Valencia CF", "PD"},
          {"Cristian", "Cristian Rivero", "Valencia CF", "PD"},
          {"Cucho Hernández", "Juan Hernández", "Real Betis Balompié", "PD"},
          {"Cucurella", "Marc Cucurella", "Real Madrid CF", "PD"},
          {"Gaya", "José Gayà", "Valencia CF", "PD"},
          {"Isaac", "Isaac Romero", "Sevilla FC", "PD"},
          {"Johnny", "Johnny Cardoso", "Club Atlético de Madrid", "PD"},
          {"Moscardo", "Gabriel Moscardo", "RCD Espanyol de Barcelona", "PD"},
          {"Ochieng", "Job Ochieng", "Real Sociedad de Fútbol", "PD"},
          {"Odisseas Vlachodimos", "Odysseas Vlachodimos", "Sevilla FC", "PD"},
          {"Pedrosa", "Adrià Pedrosa", "Rayo Vallecano de Madrid", "PD"},
          {"Peque", "Peque Fernández", "Sevilla FC", "PD"},
          {"Puga", "Carlos Puga", "Málaga CF", "PD"},
          {"Randy Ntekja", "Randy Nteka", "Rayo Vallecano de Madrid", "PD"},
          {"Raúl", "Raúl Asencio", "Real Madrid CF", "PD"},
          {"Roberto Navarro", "Robert Navarro", "Athletic Club", "PD"},
          {"Ruiz de Galarreta", "Iñigo Ruiz de Galarreta", "Athletic Club", "PD"},
          {"Salinas", "Jorge Salinas", "Real Racing Club de Santander", "PD"},
          {"Sannadi", "Maroan Sannadi", "Athletic Club", "PD"},
          {"Sivera", "Antonio Sivera", "Deportivo Alavés", "PD"},
          {"Unai Egiluz", "Unai Eguiluz", "Athletic Club", "PD"},
          {"Valou", "Jean Ives Valou", "Getafe CF", "PD"},
          {"Zaid Romero", "Zaid Abner Romero", "Getafe CF", "PD"},
          {"Alysson", "Alysson Edward", "Aston Villa FC", "PL"},
          {"Arnaud Kalimuendo", "Arnaud Kalimuendo-Muinga", "Nottingham Forest FC", "PL"},
          {"Cheick Doucouré", "Cheick Oumar Doucouré", "Crystal Palace FC", "PL"},
          {"Jocelin Bi", "Jocelin Ta Bi", "Sunderland AFC", "PL"},
          {"Joe Gomez", "Joseph Gomez", "Liverpool FC", "PL"},
          {"John", "John Victor", "Nottingham Forest FC", "PL"},
          {"Juanlu", "Juanlu Sánchez", "AFC Bournemouth", "PL"},
          {"Kaine Kesler", "Kaine Kesler-Hayden", "Coventry City FC", "PL"},
          {"Malick Yalcouyé", "Malick Junior Yalcouyé", "Brighton & Hove Albion FC", "PL"},
          {"Mickey van de Ven", "Micky van de Ven", "Tottenham Hotspur FC", "PL"},
          {"Mykhailo Mudryk", "Mykhaylo Mudryk", "Tottenham Hotspur FC", "PL"},
          {"Sindre Egeli", "Sindre Walle Egeli", "Ipswich Town FC", "PL"},
          {"Thiago", "Igor Thiago", "Brentford FC", "PL"},
          {"Vitalii Mykolenko", "Vitaliy Mykolenko", "Everton FC", "PL"},
          {"Yankubah Minteh", "Yankuba Minteh", "Brighton & Hove Albion FC", "PL"},
          {"Ardon Jasari", "Ardon Jashari", "AC Milan", "SA"},
          {"Bremer", "Gleison Bremer", "Juventus FC", "SA"},
          {"Carlos", "Carlos Augusto", "FC Internazionale Milano", "SA"},
          {"Filipe", "Filipe Bordon", "SS Lazio", "SA"},
          {"Francesco Esposito", "Francesco Pio Esposito", "FC Internazionale Milano", "SA"},
          {"Gila", "Mario Gila", "AC Milan", "SA"},
          {"Khéphren Thuram-Ulie", "Khéphren Thuram-Ulien", "Juventus FC", "SA"},
          {"Lorenzo Ginelli", "Lorenzo Luigi Ginelli", "Como 1907", "SA"},
          {"Michel Adopo", "Michel Ndary Adopo", "Cagliari Calcio", "SA"},
          {"Yvan Maye", "Yvan Kouadio Maye", "AC Monza", "SA"},
          {"Alexander Røssing-Lelesiit", "Alexander Røssing", "Hamburger SV", "BL1"},
          {"David Mokwa Ntusu", "David Mokwa", "SV 07 Elversberg", "BL1"},
          {"Felix Kalu Nmecha", "Felix Nmecha", "Borussia Dortmund", "BL1"},
          {"Jan Jakob Olschowsky", "Jan Olschowsky", "Borussia Mönchengladbach", "BL1"},
          {"Julian Chabot", "Jeff Chabot", "VfB Stuttgart", "BL1"},
          {"Kouakou Gadou", "Joane Gadou", "Borussia Dortmund", "BL1"},
          {"Look Sa Nicholas Mickelson", "Nicholas Mickelson", "SV 07 Elversberg", "BL1"},
          {"Nicolas Kühn", "Nicolas-Gerrit Kühn", "Borussia Mönchengladbach", "BL1"},
          {"Noel Aseko Nkili", "Noël Aséko", "Eintracht Frankfurt", "BL1"},
          {"Ohis Uduokhai", "Felix Uduokhai", "1. FC Union Berlin", "BL1"},
          {"Romulo Cruz", "Rômulo", "RB Leipzig", "BL1"},
          {"Silas Wamangituka", "Silas Katompa Mvumpa", "1. FSV Mainz 05", "BL1"},
          {"Timmy Chandler", "Timothy Chandler", "Eintracht Frankfurt", "BL1"},
          {"Young-woo Seol", "Seol Young-Woo", "FC Augsburg", "BL1"},
          {"Ísak Bergmann Jóhannesson", "Ísak Jóhannesson", "1. FC Köln", "BL1"},
          {"Alexsandro Ribeiro", "Alexsandro", "Lille OSC", "FL1"},
          {"Ali El Abdi", "Ali Abdi", "OGC Nice", "FL1"},
          {"Arthur Ebong", "Arthur Avom", "FC Lorient", "FL1"},
          {"Cristian Cásseres Jr.", "Cristian Cásseres", "Toulouse FC", "FL1"},
          {"Daniel Namaso", "Danny Namaso", "AJ Auxerre", "FL1"},
          {"Elias Jelert Kristensen", "Elias Jelert", "Le Havre AC", "FL1"},
          {"Elias Legendre Quiñonez", "Elías Legendre", "Stade Rennais FC 1901", "FL1"},
          {"Gio Reyna", "Giovanni Reyna", "RC Strasbourg Alsace", "FL1"},
          {"Illia Zabarnyi", "Ilya Zabarnyi", "Paris Saint-Germain FC", "FL1"},
          {"Ismaëlben Boura", "Ismaël Boura", "ES Troyes AC", "FL1"},
          {"Joseph Nonge", "Joseph Boende", "Stade Brestois 29", "FL1"},
          {"Justin Jose Bengui Joao", "Justin Bengui", "Olympique Lyonnais", "FL1"},
          {"Kan Guy Arsène Kouassi", "Arsène Kouassi", "FC Lorient", "FL1"},
          {"Karim Dermane", "Dermane Karim", "ES Troyes AC", "FL1"},
          {"Lucas Beraldo", "Beraldo", "Paris Saint-Germain FC", "FL1"},
          {"Nianzou Kouassi", "Tanguy Nianzou", "Lille OSC", "FL1"},
          {"Otavio Ataide", "Otávio", "Paris FC", "FL1"},
          {"Paolo Gozzi Iweru", "Paolo Gozzi", "ES Troyes AC", "FL1"},
          {"Sepe Elye Wahi", "Elye Wahi", "OGC Nice", "FL1"},
          {"Stanis Idumbo-Muzambo", "Stanis Idumbo", "AS Monaco FC", "FL1"},
          {"Tim Weah", "Timothy Weah", "Olympique de Marseille", "FL1"},
          {"Aitor Paredes Casamichana", "Aitor Paredes", "Athletic Club", "PD"},
          {"Alejandro Baena", "Álex Baena", "Club Atlético de Madrid", "PD"},
          {"Alex Pastor Carayol", "Álex Pastor", "Málaga CF", "PD"},
          {"Alfonso González", "Alfon González", "Sevilla FC", "PD"},
          {"Carlos Benavidez", "Carlos Protesoni", "Deportivo Alavés", "PD"},
          {"Dakonam Djené", "Djené", "Getafe CF", "PD"},
          {"Ede Bright", "Bright Ede", "RC Deportivo La Coruña", "PD"},
          {"Eneko Jauregi Escobar", "Eneko Jauregi", "Málaga CF", "PD"},
          {"Georgiy Tsitaishvili", "Giorgi Tsitaishvili", "Rayo Vallecano de Madrid", "PD"},
          {"Javier Galán", "Javi Galán", "RC Celta de Vigo", "PD"},
          {"Jens Cajuste", "Jens-Lys Cajuste", "Málaga CF", "PD"},
          {"Jesus Vazquez Alcalde", "Jesús Vázquez", "Valencia CF", "PD"},
          {"Jofre Carreras Pagès", "Jofre Carreras", "RCD Espanyol de Barcelona", "PD"},
          {"Jonathan Asp-Jensen", "Jonathan Asp", "RC Deportivo La Coruña", "PD"},
          {"Josán Fernández", "Josan", "Elche CF", "PD"},
          {"Karl Etta Eyong", "Etta Eyong", "Levante UD", "PD"},
          {"Kike Barja", "Enrique Barja", "CA Osasuna", "PD"},
          {"Lopez Nogueras", "Carlos López", "Málaga CF", "PD"},
          {"Luiz Lúcio Reis Júnior", "Luíz Júnior", "Villarreal CF", "PD"},
          {"Maty Ryan", "Mathew Ryan", "Levante UD", "PD"},
          {"Nathan-Dylan Saliba", "Nathan Saliba", "Villarreal CF", "PD"},
          {"Nsongo Tonfack", "Bil Nsongo", "RC Deportivo La Coruña", "PD"},
          {"Orri Steinn Óskarsson", "Orri Óskarsson", "Real Sociedad de Fútbol", "PD"},
          {"Pablo Cuñat", "Pablo Campos", "Levante UD", "PD"},
          {"Pablo Ibáñez Tébar", "Pablo Ibáñez", "Deportivo Alavés", "PD"},
          {"Ramón Enríquez Rodríguez", "Ramón Enríquez", "Málaga CF", "PD"},
          {"RamónTerrats Espacio", "Ramón Terrats", "Getafe CF", "PD"},
          {"Abdul Issahaku", "Abdul Fatawu", "Ipswich Town FC", "PL"},
          {"Carlos Alcaraz", "Charly Alcaraz", "Everton FC", "PL"},
          {"Eddie Nketiah", "Edward Nketiah", "Crystal Palace FC", "PL"},
          {"El Hadji Malick Diouf", "Malick Diouf", "Brentford FC", "PL"},
          {"Eli Kroupi", "Junior Kroupi", "AFC Bournemouth", "PL"},
          {"Gabriel Magalhães", "Gabriel", "Arsenal FC", "PL"},
          {"Jamie Bynoe-Gittens", "Jamie Gittens", "Chelsea FC", "PL"},
          {"Jean Bahoya", "Jean-Mattéo Bahoya", "Leeds United FC", "PL"},
          {"Joe Willock", "Joseph Willock", "Newcastle United FC", "PL"},
          {"Kostas Tsimikas", "Konstantinos Tsimikas", "Liverpool FC", "PL"},
          {"Matt O'Riley", "Matthew O'Riley", "Brighton & Hove Albion FC", "PL"},
          {"Oliver McBurnie", "Oli McBurnie", "Hull City AFC", "PL"},
          {"Promise Akinpelu", "Promise David", "Brighton & Hove Albion FC", "PL"},
          {"Ryan John Giles", "Ryan Giles", "Hull City AFC", "PL"},
          {"Yegor Yarmolyuk", "Yehor Yarmoliuk", "Brentford FC", "PL"},
          {"Alexsandro Amorim", "Amorim", "Genoa CFC", "SA"},
          {"André Zambo Anguissa", "Frank Anguissa", "SSC Napoli", "SA"},
          {"Ben Lhassine Kone", "Benjamin Lhassine Kone", "Frosinone Calcio", "SA"},
          {"Benjamín Domínguez", "Benja Domínguez", "US Sassuolo Calcio", "SA"},
          {"Christ Ravynel Inao Oulaï", "Christ Inao Oulaï", "ACF Fiorentina", "SA"},
          {"Dany Mota Carvalho", "Dany Mota", "AC Monza", "SA"},
          {"Ethan Meichtry", "Franz-Ethan Meichtry", "Genoa CFC", "SA"},
          {"João Mário Lopes", "João Mário", "ACF Fiorentina", "SA"},
          {"Juan Martín Rodriguez", "Juan Rodríguez", "Cagliari Calcio", "SA"},
          {"Lamine Dabo", "Lamine Fanne", "Venezia FC", "SA"},
          {"Manga Foe Ondoa", "Foe Ondoa", "AC Monza", "SA"},
          {"Marcus Thuram-Ulien", "Marcus Thuram", "FC Internazionale Milano", "SA"},
          {"Mohamed Malang Touré", "Mohamed Toure", "Venezia FC", "SA"},
          {"Mohamed Salim Fares", "Mohamed Fares", "SS Lazio", "SA"},
          {"Nikita Contini Baranovsky", "Nikita Contini", "SSC Napoli", "SA"},
          {"Rafa Obrador", "Rafael Obrador", "US Sassuolo Calcio", "SA"},
          {"Zé Pedro Figueiredo", "Zé Pedro", "Cagliari Calcio", "SA"},
          {"Þórir Jóhann Helgason", "Thórir Helgason", "Venezia FC", "SA"},
          {"Mamadou Usman Simbakoli", "Usman Simbakoli", "Angers SCO", "FL1"},
          {"Maximillian Oyedele", "Maxi Oyedele", "RC Strasbourg Alsace", "FL1"},
          {"Musa Al Taamari", "Mousa Al Tamari", "Stade Rennais FC 1901", "FL1"},
          {"David Daiber", "David Santos Daiber", "FC Bayern München", "BL1"},
          {"Jeremy", "Jeremy Arévalo", "VfB Stuttgart", "BL1"},
          {"Luka Đurić", "Luka Djuric", "SC Paderborn 07", "BL1"},
          {"Diogo Lobão", "Diogo Lobo", "RC Strasbourg Alsace", "FL1"},
          {"Francis Abu", "Abu Francis", "Toulouse FC", "FL1"},
          {"Marius Louãr", "Marius Louër", "Angers SCO", "FL1"},
          {"Chrisantus", "Christantus Uche", "Getafe CF", "PD"},
          {"Fernando Niño", "Fer Niño", "Elche CF", "PD"},
          {"Ilya Voloshyn", "Ilia Voloshyn", "Real Madrid CF", "PD"},
          {"Kang-in Lee", "Lee Kang-In", "Club Atlético de Madrid", "PD"},
          {"Miguel Ángel Sierra", "Miguel Sierra", "Sevilla FC", "PD"},
          {"Morro", "Miguel Morro", "Rayo Vallecano de Madrid", "PD"},
          {"Muñeco", "Alejandro Santiago", "RCD Espanyol de Barcelona", "PD"},
          {"Pablo Gavira", "Gavi", "FC Barcelona", "PD"},
          {"Rafa Garrido", "Rafita", "Málaga CF", "PD"},
          {"Yvan Neyou", "Yvan Neyou Noupa", "Getafe CF", "PD"},
          {"Álex Balde", "Alejandro Balde", "FC Barcelona", "PD"},
          {"Ben Doak", "Ben Gannon-Doak", "AFC Bournemouth", "PL"},
          {"Briaden Graham", "Braiden Graham", "Everton FC", "PL"},
          {"Dan Burn", "Daniel Burn", "Newcastle United FC", "PL"},
          {"Jair Paula", "Jair Cunha", "Nottingham Forest FC", "PL"},
          {"Mateo Fernandez", "Mateo Joseph", "Leeds United FC", "PL"},
          {"Thomas King", "Tom King", "Everton FC", "PL"},
          {"Enzo dos Santos", "Enzo Duarte", "Borussia Dortmund", "BL1"},
          {"Ifechukwu Ogbus", "Bruno Ogbus", "SC Freiburg", "BL1"},
          {"Suleman Sani", "Sani Suleiman", "RB Leipzig", "BL1"},
          {"Andy Logbo", "Élysée Logbo", "Le Havre AC", "FL1"},
          {"Brad Mantsounga", "Brad-Hamilton Mantsounga", "OGC Nice", "FL1"},
          {"Elijah Olaniyi Odede", "Elijah Odede", "ES Troyes AC", "FL1"},
          {"Xiangxin Wei", "Wei Xiangxin", "AJ Auxerre", "FL1"},
          {"Femenía Far", "Kiko", "Getafe CF", "PD"},
          {"Ibra Danfakha", "Ibrahima Danfakha", "Getafe CF", "PD"},
          {"Nicolás Guillén", "Nico Guillen", "Sevilla FC", "PD"},
          {"Aji Alese", "Ajibola Alese", "Sunderland AFC", "PL"},
          {"Josh Dasilva", "Joshua Dasilva", "Brentford FC", "PL"},
          {"Calixte Ligue", "Junior Ligue", "Venezia FC", "SA"},
          {"Faustino Anjorin", "Tino Anjorin", "Torino FC", "SA"},
          {"Suliman Mustapha", "Marlon Mustapha", "Como 1907", "SA"},
          {"Víctor Valdepeñas", "Valde", "ACF Fiorentina", "SA"},
          {"Raúl", "Raúl García", "CA Osasuna", "PD"},
          {"Arthur Augusto", "Arthur", "SV Werder Bremen", "BL1"},
          {"Kauã Santos", "Kauã", "Eintracht Frankfurt", "BL1"},
          {"Alejandro Rodriguez", "Alejandro Gomes Rodríguez", "Olympique Lyonnais", "FL1"},
          {"Bilal Brahimi", "Billal Brahimi", "Le Mans FC", "FL1"},
          {"Habib Diallo", "Habibou Mouhamadou Diallo", "Le Mans FC", "FL1"},
          {"Pedro Fernández", "Dro Fernández", "Paris Saint-Germain FC", "FL1"},
          {"Pierre Ganiou", "Ismaëlo Ganiou", "Racing Club de Lens", "FL1"},
          {"Rémy Labeau Lascary", "Rémy Lascary", "AJ Auxerre", "FL1"},
          {"Alexandre Alemão", "Alemão", "Rayo Vallecano de Madrid", "PD"},
          {"Castrin", "Andrés López", "Sevilla FC", "PD"},
          {"Daniel Martínez", "Dani Martínez", "Club Atlético de Madrid", "PD"},
          {"Francisco Garcia", "Fran García", "Real Betis Balompié", "PD"},
          {"José Manuel", "Manu", "Real Racing Club de Santander", "PD"},
          {"Santiago Comesaña", "Santi Comesaña", "Villarreal CF", "PD"},
          {"Álvaro Vallés Rosa", "Álvaro Vallés", "Real Betis Balompié", "PD"},
          {"Ángel Fortuño Viñas", "Ángel Fortuño", "RCD Espanyol de Barcelona", "PD"},
          {"Jesús Morales", "Jesús Cruz", "Sevilla FC", "PD"},
          {"Gustavo Gomes", "Gustavo Nunes", "Brentford FC", "PL"},
          {"Kevin Santos", "Kevin", "Fulham FC", "PL"},
          {"José Romero", "David Romero", "Parma Calcio 1913", "SA"},
          {"Oliver Nielsen", "Oliver Provstgaard", "SS Lazio", "SA"},
          {"Pedro Gonçalves", "Pote", "ACF Fiorentina", "SA"},
          {"Vitor Oliveira", "Vítinha", "Genoa CFC", "SA"},
          {"Peke", "Yeremay Hernández", "RC Deportivo La Coruña", "PD"},
          {"Noé Carrillo", "Noé", "RC Deportivo La Coruña", "PD"},
          {"Chupete", "Chupe", "Málaga CF", "PD"},
          {"Tiago Fonseca Morais", "Tiago Morais", "Lille OSC", "FL1"},
          {"Souleymane Isaak Toure", "Souleymane Touré", "FC Lorient", "FL1"},
          {"Đorđe Petrović", "Djordje Petrović", "AFC Bournemouth", "PL"},
          {"Abdoulaye N'Diaye", "Abdoulaye Ndiaye", "Parma", "SA"},
          {"Abde Rebbach", "Abderrahman Rebbach", "Deportivo Alavés", "PD"},
          {"Adam", "Adam Boayar", "Elche CF", "PD"},
          {"Yusi", "Youssef Enríquez", "Deportivo Alavés", "PD"},
          {"Albert Gronbaek Erlykke", "Albert Grønbæk", "Hamburger SV", "BL1"},
          {"Min-Jae Kim", "Kim Min-Jae", "FC Bayern München", "BL1"},
          {"Iaia Danfa", "Iaia Manco Danfa", "Borussia Mönchengladbach", "BL1"},
          {"Linus Güther", "Linus Guether", "1. FC Union Berlin", "BL1"},
          {"Kenan Yıldız", "Kenan Yildiz", "Juventus FC", "SA"},
          {"Alexander Røssing", "Alexander Rossing", "Hamburger SV", "BL1"},
          {"Hwang Heechan", "Hwang Hee-Chan", "FC Schalke 04", "BL1"},
          {"Jeong Wooyeong", "Jeong Woo-Yeong", "1. FC Union Berlin", "BL1"},
          {"Lee Jaesung", "Lee Jae-Sung", "1. FSV Mainz 05", "BL1"},
          {"Ngal'ayel Mukau", "Ngal Ayel Mukau", "Lille OSC", "FL1"},
          {"Kamal Deen Sulemana", "Kamaldeen Sulemana", "Atalanta BC", "SA"}
        ] do
      {c, state, profile, match} = audit_player_sample(league)
      profile = Map.put(profile, "name", source_name)

      profile =
        case FootballMarket.Providers.PlayerIdentity.birth_date(catalog_name, league, team) do
          nil -> profile
          date -> Map.put(profile, "birthDate", %{"utcTime" => date <> "T00:00:00.000Z"})
        end

      match = put_in(match, ["content", "playerStats", "p1", "name"], source_name)

      search_name =
        FootballMarket.Providers.PlayerIdentity.search_name(catalog_name, league, team)

      candidate = %{"type" => "player", "id" => "p1", "name" => source_name, "teamName" => team}

      state =
        state
        |> Map.delete(:player_source_id)
        |> Map.put(:player_name, catalog_name)
        |> Map.put(:player_team_name, team)

      for {candidates, expected} <- [
            {[candidate], :accepted},
            {[Map.put(candidate, "teamName", team <> " B")], :rejected},
            {[Map.put(candidate, "name", source_name <> " Other")], :rejected},
            {[candidate, Map.put(candidate, "id", "p2")], :rejected}
          ] do
        search = %{
          state.portions["match:m1"]
          | body: Jason.encode!([%{"suggestions" => candidates}])
        }

        discovery = put_in(state.portions["player_search:" <> search_name], search)
        result = audit_player_result(c, discovery, profile, match)

        if expected == :accepted,
          do: assert({:ok, _} = result),
          else: assert({:error, _} = result)
      end
    end

    refute FootballMarket.Providers.PlayerIdentity.equivalent?(
             "Adam",
             "Adam Boayar",
             "PL",
             "Elche CF"
           )

    refute FootballMarket.Providers.PlayerIdentity.equivalent?(
             "Adam",
             "Adam Boayar",
             "PD",
             "Other Club"
           )

    refute FootballMarket.Providers.PlayerIdentity.equivalent?(
             "Abde Rebbach",
             "Abderrahman Rebbach",
             "PD",
             "Other Club"
           )

    for {left, right} <- [
          {"Hwang Heechan", "Hee-Chan Hwang"},
          {"Lee Jaesung", "Lee Jae-Sung Other"},
          {"Kamal Deen Sulemana", "Kamal Deen Suliman"},
          {nil, nil}
        ] do
      refute FootballMarket.Providers.PlayerIdentity.equivalent?(left, right, "PL", "Alpha")
    end
  end

  test "club aliases never escape their assessed league" do
    {c, state, profile, match} = audit_player_sample()

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.put(:player_name, "Alex Example")
      |> Map.put(:player_team_name, "Stade Rennais FC 1901")

    search = %{
      state.portions["match:m1"]
      | body:
          Jason.encode!([
            %{
              "suggestions" => [
                %{
                  "type" => "player",
                  "id" => "p1",
                  "name" => "Alex Example",
                  "teamName" => "Rennes"
                }
              ]
            }
          ])
    }

    state = put_in(state.portions["player_search:Alex Example"], search)

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, profile, match)

    assert_received {:scraping_fetch, "player_data:p1", _}
  end

  test "a changed current club requires dated exact career identity and does not prove season coverage" do
    {c, state, profile, match} = audit_player_sample()

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.put(:player_name, "Alex Example")
      |> Map.put(:player_team_name, "Alpha")

    search = %{
      state.portions["match:m1"]
      | body:
          Jason.encode!([
            %{
              "suggestions" => [
                %{
                  "type" => "player",
                  "id" => "p1",
                  "name" => "Alex Example",
                  "teamName" => "New Club"
                }
              ]
            }
          ])
    }

    state = put_in(state.portions["player_search:Alex Example"], search)

    entry = %{
      "participantId" => "p1",
      "teamId" => "a",
      "team" => "Alpha",
      "hasUncertainData" => false,
      "startDate" => "2024-07-01T00:00:00Z",
      "endDate" => "2024-09-01T00:00:00Z"
    }

    profile =
      Map.put(profile, "careerHistory", %{
        "careerItems" => %{"senior" => %{"teamEntries" => [entry]}}
      })

    assert {:ok, _} = audit_player_result(c, state, profile, match)

    calendar =
      entry
      |> Map.put("startDate", "2024-07-01T00:00:00")
      |> Map.put("endDate", "2024-09-01T00:00:00")

    calendar_profile =
      put_in(profile, ["careerHistory", "careerItems", "senior", "teamEntries"], [calendar])

    assert {:ok, _} = audit_player_result(c, state, calendar_profile, match)

    # Career calendar dates do not relax actual kickoff timestamp parsing.
    ambiguous_match = put_in(match, ["general", "matchTimeUTCDate"], "2024-10-01T12:00:00")
    assert {:error, _} = audit_player_result(c, state, calendar_profile, ambiguous_match)

    for changed <- [
          Map.put(entry, "participantId", "other"),
          Map.put(entry, "team", "Alpha B"),
          Map.put(entry, "hasUncertainData", true),
          Map.put(entry, "endDate", "2024-06-01T00:00:00Z"),
          Map.put(entry, "startDate", "2025-08-01T00:00:00Z"),
          Map.put(calendar, "startDate", "2024-07-01T12:00:00"),
          Map.put(calendar, "startDate", "2024-02-30T00:00:00"),
          Map.put(calendar, "endDate", ""),
          Map.put(calendar, "endDate", "2024-06-01T00:00:00"),
          Map.delete(calendar, "participantId"),
          Map.delete(calendar, "hasUncertainData")
        ] do
      rejected =
        put_in(profile, ["careerHistory", "careerItems", "senior", "teamEntries"], [changed])

      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, rejected, match)
    end

    unsupported =
      profile
      |> Map.put("statSeasons", [])
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "leagueId"], "other")

    assert {:error, %{category: :unsupported_capability}} =
             audit_player_result(c, state, unsupported, match)
  end

  test "historical match links cannot substitute another match or unfinished facts" do
    {c, state, profile, match} = audit_player_sample()

    for changed <- [
          put_in(match, ["general", "matchId"], "other-match"),
          match
          |> put_in(["general", "matchId"], "other-match")
          |> put_in(["general", "finished"], false),
          put_in(match, ["general", "finished"], false)
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, profile, changed)
    end
  end

  test "current directory position stays separate from dated verified match roles" do
    {c, state, profile, match} = audit_player_sample()
    [first] = profile["initialMatchesPage"]["matches"]

    older =
      first
      |> Map.put("id", "m2")
      |> Map.put("matchDate", %{"utcTime" => "2024-09-01T12:00:00Z"})
      |> Map.put("lineupPositionId", 21)
      |> Map.put("matchPageUrl", "/matches/alpha-beta/m2")

    profile = put_in(profile["initialMatchesPage"]["matches"], [first, older])

    older_match =
      match
      |> put_in(["general", "matchId"], "m2")
      |> put_in(["general", "matchTimeUTCDate"], "2024-09-01T12:00:00Z")
      |> put_in(["content", "playerStats", "p1", "positionId"], 21)
      |> put_in(["content", "playerStats", "p1", "usualPosition"], "keeper")
      |> put_in(["content", "lineup", "homeTeam", "starters"], [
        %{"id" => "p1", "positionId" => 21, "usualPlayingPositionId" => "keeper"}
      ])

    state =
      put_in(state.portions["match_details:m2"], %{
        state.portions["match:m1"]
        | body: Jason.encode!(older_match)
      })

    assert {:ok, result} =
             audit_player_result(c, Map.put(state, :player_position_code, "GK"), profile, match)

    assert [directory_player] = result.facts.players
    assert directory_player.position_ref == "GK"
    assert Enum.map(result.facts.performances, & &1.position_ref) == ["FW", "GK"]

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, profile, match)
  end

  test "unknown catalog role stays unknown while the historical role still needs evidence" do
    {c, state, profile, match} = audit_player_sample()
    positions = Map.put(Data.positions(), "UNK", "Unknown")
    state = Map.put(state, :player_position_code, "UNK")
    assert {:ok, result} = audit_player_result(c, state, profile, match, positions)
    assert [%{position_ref: "UNK"}] = result.facts.players
    assert Enum.any?(result.facts.positions, &(&1.code == "UNK"))
    assert [%{position_ref: "FW"}] = result.facts.performances

    unknown =
      match
      |> put_in(["content", "playerStats", "p1", "positionId"], "unknown")
      |> put_in(["content", "playerStats", "p1", "usualPosition"], "unknown")
      |> put_in(["content", "lineup"], nil)

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, profile, unknown, positions)
  end

  test "anchored consistent histories retain filtered matches and reject contradictory evidence" do
    {c, state, profile, match} = audit_player_sample()
    [first] = profile["initialMatchesPage"]["matches"]

    older =
      first
      |> Map.put("id", "older")
      |> Map.put("matchDate", %{"utcTime" => "2024-06-30T12:00:00Z"})

    profile =
      profile
      |> Map.put("recentMatches", [first])
      |> put_in(["initialMatchesPage", "matches"], [first, older])
      |> put_in(["initialMatchesPage", "previous"], "still-older-history")

    assert {:ok, result} = audit_player_result(c, state, profile, match)
    assert Enum.map(result.facts.matches, & &1.ref) == ["match:m1"]

    for summary <- [
          [Map.put(first, "minutesPlayed", 1)],
          [Map.put(first, "id", "unrelated")],
          [first, first]
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, Map.put(profile, "recentMatches", summary), match)
    end

    for summary <- [[older], [Map.put(first, "ratingProps", %{"rating" => "8.1"})]] do
      assert {:ok, accepted} =
               audit_player_result(c, state, Map.put(profile, "recentMatches", summary), match)

      assert Enum.map(accepted.facts.matches, & &1.ref) == ["match:m1"]
    end

    incomplete = put_in(profile, ["initialMatchesPage", "matches"], [first])

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, state, incomplete, match)
  end

  test "absent season metadata needs independent complete match or unused bench proof" do
    {c, state, profile, match} = audit_player_sample()

    for profile <- [Map.put(profile, "statSeasons", nil), Map.delete(profile, "statSeasons")] do
      assert {:ok, result} = audit_player_result(c, state, profile, match)
      assert length(result.facts.performances) == 1

      other =
        put_in(profile, ["initialMatchesPage", "matches", Access.at(0), "leagueId"], "other")

      assert {:error, %{category: :unsupported_capability}} =
               audit_player_result(c, state, other, match)

      incomplete = put_in(profile, ["initialMatchesPage", "previous"], "older")

      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, incomplete, match)
    end

    for invalid <- [false, %{}, "2024/2025"] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, Map.put(profile, "statSeasons", invalid), match)
    end
  end

  test "corroborated current directory identity preserves dated names and transfer teams" do
    {c, state, profile, match} = audit_player_sample()
    state = Map.merge(state, %{player_team_name: "Alpha", player_position_code: "FW"})

    match =
      match
      |> put_in(["general", "homeTeam", "name"], "Alpha")
      |> put_in(["general", "awayTeam", "name"], "Beta")
      |> put_in(["content", "playerStats", "p1", "currentTeamId"], "a")

    [first] = profile["initialMatchesPage"]["matches"]

    older =
      first
      |> Map.put("id", "m2")
      |> Map.put("teamId", "b")
      |> Map.put("teamName", "Beta")
      |> Map.put("opponentTeamId", "a")
      |> Map.put("opponentTeamName", "Alpha")
      |> Map.put("isHomeTeam", false)
      |> Map.put("matchDate", %{"utcTime" => "2024-09-01T12:00:00Z"})
      |> Map.put("matchPageUrl", "/matches/alpha-beta/m2")

    profile =
      profile
      |> Map.put("primaryTeam", %{"teamId" => "a", "teamName" => "Alpha"})
      |> put_in(["initialMatchesPage", "matches"], [first, older])

    older_match =
      match
      |> put_in(["general", "matchId"], "m2")
      |> put_in(["general", "matchTimeUTCDate"], "2024-09-01T12:00:00Z")
      |> put_in(["content", "playerStats", "p1", "name"], "Alex Full Example")
      |> put_in(["content", "playerStats", "p1", "teamId"], "b")
      |> put_in(["content", "playerStats", "p1", "currentTeamId"], "b")
      |> put_in(["content", "lineup", "homeTeam", "starters"], [])
      |> put_in(["content", "lineup", "awayTeam", "starters"], [
        %{"id" => "p1", "positionId" => 115, "usualPlayingPositionId" => 3}
      ])

    state =
      put_in(state.portions["match_details:m2"], %{
        state.portions["match:m1"]
        | body: Jason.encode!(older_match)
      })

    assert {:ok, result} = audit_player_result(c, state, profile, match)

    assert [%{display_name: "Alex Example", team_ref: "team:a", position_ref: "FW"}] =
             result.facts.players

    assert Enum.map(result.facts.performances, & &1.team_ref) == ["team:a", "team:b"]
    assert Enum.map(result.facts.performances, & &1.position_ref) == ["FW", "FW"]

    for primary <- [
          nil,
          %{"teamId" => "wrong", "teamName" => "Alpha"},
          %{"teamId" => "b", "teamName" => "Alpha"},
          %{"teamId" => "a", "teamName" => "Unknown"}
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, Map.put(profile, "primaryTeam", primary), match)
    end

    wrong_id = put_in(older_match, ["content", "playerStats", "p1", "id"], "other")
    changed = put_in(state, [:portions, "match_details:m2", :body], Jason.encode!(wrong_id))

    assert {:error, %{category: :invalid_response}} =
             audit_player_result(c, changed, profile, match)
  end

  test "secondary search terms retain exact identity and never select a nearby club name" do
    {c, state, profile, match} = audit_player_sample()

    candidate = %{
      "type" => "player",
      "id" => "p1",
      "name" => "Alex Example",
      "teamName" => "Alpha"
    }

    observation = state.portions["match:m1"].observation

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.merge(%{player_name: "Alex Example", player_team_name: "Alpha"})
      |> put_in([:portions, "player_search:Alex Example"], %{
        body: Jason.encode!([%{"suggestions" => []}]),
        observation: observation
      })

    for {candidates, succeeds} <- [
          {[candidate], true},
          {[Map.put(candidate, "name", "Other Example")], false},
          {[Map.put(candidate, "teamName", "Alpha B")], false},
          {[candidate, Map.put(candidate, "id", "p2")], false}
        ] do
      fallback = %{
        body: Jason.encode!([%{"suggestions" => candidates}]),
        observation: observation
      }

      changed = put_in(state, [:portions, "player_search:Example"], fallback)
      result = audit_player_result(c, changed, profile, match)
      if succeeds, do: assert({:ok, _} = result), else: assert({:error, _} = result)
    end
  end

  test "dated career proof disambiguates exact names at other clubs without choosing by coverage" do
    {c, state, profile, match} = audit_player_sample()

    entry = %{
      "participantId" => "p1",
      "hasUncertainData" => false,
      "team" => "Alpha",
      "startDate" => "2024-07-01T00:00:00Z",
      "endDate" => nil
    }

    profile =
      put_in(profile, ["careerHistory"], %{
        "careerItems" => %{"senior" => %{"teamEntries" => [entry]}}
      })

    other =
      profile
      |> Map.put("id", "p2")
      |> put_in(
        ["careerHistory", "careerItems", "senior", "teamEntries"],
        [%{entry | "participantId" => "p2", "team" => "Unrelated"}]
      )
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "leagueId"], "OTHER")

    observation = state.portions["match:m1"].observation

    candidates =
      for {id, team} <- [{"p1", "Gamma"}, {"p2", "Delta"}],
          do: %{"type" => "player", "id" => id, "name" => "Alex Example", "teamName" => team}

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.merge(%{player_name: "Alex Example", player_team_name: "Alpha"})
      |> put_in([:portions, "player_search:Alex Example"], %{
        body: Jason.encode!([%{"suggestions" => candidates}]),
        observation: observation
      })
      |> put_in([:portions, "player_data:p2"], %{
        body: Jason.encode!(other),
        observation: observation
      })

    assert {:ok, _} = audit_player_result(c, state, profile, match)

    for mutate <- [
          fn value -> value end,
          &Map.delete(&1, "initialMatchesPage")
        ] do
      ambiguous =
        other
        |> mutate.()
        |> put_in(["careerHistory", "careerItems", "senior", "teamEntries"], [
          %{entry | "participantId" => "p2"}
        ])

      changed = put_in(state, [:portions, "player_data:p2", :body], Jason.encode!(ambiguous))

      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, changed, profile, match)
    end

    for mutate <- [
          &Map.put(&1, "hasUncertainData", true),
          &Map.put(&1, "startDate", "2025-07-01T00:00:00Z"),
          &Map.put(&1, "endDate", "2024-06-30T00:00:00Z"),
          &Map.put(&1, "participantId", "other")
        ] do
      missing =
        put_in(profile, ["careerHistory", "careerItems", "senior", "teamEntries"], [
          mutate.(entry)
        ])

      assert {:error, _} = audit_player_result(c, state, missing, match)
    end

    wrong_id = Map.put(other, "id", "other")
    changed = put_in(state, [:portions, "player_data:p2", :body], Jason.encode!(wrong_id))
    assert {:error, _} = audit_player_result(c, changed, profile, match)
  end

  test "official scoped birth dates disambiguate homonyms and still reject duplicate identities" do
    for {name, team, league, date} <- [
          {"Fabio Gruber", "1. FSV Mainz 05", "BL1", "2002-09-03"},
          {"Djibril Sidibé", "Le Mans FC", "FL1", "1992-07-29"},
          {"Mamadou Diop", "AJ Auxerre", "FL1", "2000-01-03"},
          {"Ibrahima Konaté", "Real Madrid CF", "PD", "1999-05-25"},
          {"Djordje Petrović", "AFC Bournemouth", "PL", "1999-10-08"},
          {"Kauã", "Eintracht Frankfurt", "BL1", "2003-04-11"},
          {"Fran García", "Real Betis Balompié", "PD", "1999-08-14"},
          {"Andrés López", "Sevilla FC", "PD", "2003-05-26"},
          {"Manu", "Real Racing Club de Santander", "PD", "1998-07-19"}
        ] do
      {c, state, profile, match} = audit_player_sample(league)

      profile =
        profile
        |> Map.put("name", name)
        |> Map.put("birthDate", %{"utcTime" => date <> "T00:00:00.000Z", "timezone" => "UTC"})

      match = put_in(match, ["content", "playerStats", "p1", "name"], name)

      other =
        profile
        |> Map.put("id", "p2")
        |> Map.put("birthDate", %{"utcTime" => "1980-01-01T00:00:00.000Z", "timezone" => "UTC"})

      observation = state.portions["match:m1"].observation

      candidates =
        for id <- ["p1", "p2"],
            do: %{"type" => "player", "id" => id, "name" => name, "teamName" => team}

      state =
        state
        |> Map.delete(:player_source_id)
        |> Map.merge(%{player_name: name, player_team_name: team})
        |> put_in([:portions, "player_search:" <> name], %{
          body: Jason.encode!([%{"suggestions" => candidates}]),
          observation: observation
        })
        |> put_in([:portions, "player_data:p2"], %{
          body: Jason.encode!(other),
          observation: observation
        })

      assert {:ok, _} = audit_player_result(c, state, profile, match)

      for invalid_date <- [nil, %{}, %{"utcTime" => "invalid"}, other["birthDate"]] do
        assert {:error, _} =
                 audit_player_result(c, state, Map.put(profile, "birthDate", invalid_date), match)
      end

      duplicate = Map.put(other, "birthDate", profile["birthDate"])
      changed = put_in(state, [:portions, "player_data:p2", :body], Jason.encode!(duplicate))
      assert {:error, _} = audit_player_result(c, changed, profile, match)

      female = Map.put(profile, "gender", "female")
      assert {:error, _} = audit_player_result(c, state, female, match)
    end
  end

  test "reviewed source identity bypasses a duplicate index but still requires exact profile and match evidence" do
    for {name, source_name, team, league, id, date} <- [
          {"Mohamed Kaba", "Mohamed Kaba", "US Lecce", "SA", "1299869", "2001-10-27"},
          {"Patric", "Patric", "SS Lazio", "SA", "358149", "1993-04-17"},
          {"Ji-soo Kim", "Kim Ji-Soo", "Brentford FC", "PL", "1341538", "2004-12-24"}
        ] do
      {c, state, profile, match} = audit_player_sample(league)
      observation = state.portions["match:m1"].observation

      profile =
        profile
        |> Map.put("id", id)
        |> Map.put("name", source_name)
        |> Map.put("birthDate", %{"utcTime" => date <> "T00:00:00.000Z"})

      match =
        match
        |> Jason.encode!()
        |> String.replace("\"p1\"", "\"#{id}\"")
        |> Jason.decode!()
        |> put_in(["content", "playerStats", id, "name"], source_name)

      state =
        state
        |> Map.delete(:player_source_id)
        |> Map.merge(%{player_name: name, player_team_name: team})
        |> put_in([:portions, "match_details:m1"], %{
          body: Jason.encode!(match),
          observation: observation
        })
        |> put_in([:portions, "player_data:" <> id], %{
          body: Jason.encode!(profile),
          observation: observation
        })

      assert {:ok, _} = player_result(c, state)
      assert_received {:scraping_fetch, "player_data:" <> ^id, _}
      refute_received {:scraping_fetch, "player_search:" <> ^name, _}

      for changed <- [
            Map.put(profile, "id", "659036"),
            Map.put(profile, "name", "Other Kaba"),
            Map.put(profile, "birthDate", %{"utcTime" => "1980-01-01T00:00:00Z"}),
            Map.delete(profile, "birthDate")
          ] do
        bad = put_in(state, [:portions, "player_data:" <> id, :body], Jason.encode!(changed))
        assert {:error, _} = player_result(c, bad)
      end

      wrong = put_in(match, ["content", "playerStats", id, "id"], "659036")
      bad = put_in(state, [:portions, "match_details:m1", :body], Jason.encode!(wrong))
      assert {:error, _} = player_result(c, bad)
      assert {:error, _} = player_result(c, Map.put(state, :player_team_name, "Other Club"))
    end
  end

  test "first-team identity needs an independent dated match when discovery lists a reserve club" do
    {c, state, profile, match} = audit_player_sample()
    observation = state.portions["match:m1"].observation

    candidate = %{
      "type" => "player",
      "id" => "p1",
      "name" => "Alex Example",
      "teamName" => "Alpha B"
    }

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.merge(%{player_name: "Alex Example", player_team_name: "Alpha"})
      |> put_in([:portions, "player_search:Alex Example"], %{
        body: Jason.encode!([%{"suggestions" => [candidate]}]),
        observation: observation
      })

    profile = Map.put(profile, "primaryTeam", %{"teamId" => "reserves", "teamName" => "Alpha B"})

    match =
      match
      |> put_in(["general", "homeTeam", "name"], "Alpha")
      |> put_in(["general", "awayTeam", "name"], "Beta")
      |> put_in(["content", "playerStats", "p1", "currentTeamId"], "a")

    assert {:ok, result} = audit_player_result(c, state, profile, match)
    assert Enum.map(result.facts.performances, & &1.team_ref) == ["team:a"]

    [played] = profile["initialMatchesPage"]["matches"]

    outside =
      played
      |> Map.put("id", "outside")
      |> Map.put("leagueId", nil)
      |> Map.put("playedInMatch", false)
      |> Map.put("minutesPlayed", nil)
      |> Map.put("matchDate", %{"utcTime" => "2024-09-01T12:00:00Z"})

    mixed = put_in(profile, ["initialMatchesPage", "matches"], [played, outside])
    assert {:ok, _} = audit_player_result(c, state, mixed, match)

    for mutate <- [
          &put_in(&1, ["general", "homeTeam", "name"], "Alpha B"),
          &put_in(&1, ["general", "finished"], false),
          &put_in(&1, ["general", "matchId"], "wrong"),
          &put_in(&1, ["content", "playerStats", "p1", "id"], "wrong")
        ] do
      assert {:error, _} = audit_player_result(c, state, profile, mutate.(match))
    end

    for mutate <- [
          &put_in(&1, ["initialMatchesPage", "matches", Access.at(0), "teamName"], "Alpha B"),
          &put_in(&1, ["initialMatchesPage", "matches", Access.at(0), "matchPageUrl"], nil),
          &put_in(&1, ["initialMatchesPage", "previous"], "incomplete")
        ] do
      assert {:error, _} = audit_player_result(c, state, mutate.(profile), match)
    end
  end

  test "an empty terminal history without requested season evidence is unsupported, never verified empty" do
    {c, state, profile, match} = audit_player_sample()

    empty =
      profile
      |> Map.put("statSeasons", [])
      |> Map.put("recentMatches", [])
      |> Map.put("initialMatchesPage", %{"matches" => [], "previous" => nil})

    for seasons <- [nil, []] do
      assert {:error, %{category: :unsupported_capability}} =
               audit_player_result(c, state, Map.put(empty, "statSeasons", seasons), match)
    end

    # Explicit requested-season membership and a pending cursor still contradict
    # an empty terminal history; neither can publish an accepted empty check.
    for changed <- [
          Map.put(empty, "statSeasons", profile["statSeasons"]),
          put_in(empty, ["initialMatchesPage", "previous"], "more-history")
        ] do
      assert {:error, %{category: :invalid_response}} =
               audit_player_result(c, state, changed, match)
    end
  end

  test "an independently verified first-team unused substitute proves reserve-profile identity" do
    {c, state, profile, match} = audit_player_sample()
    observation = state.portions["match:m1"].observation

    profile =
      profile
      |> Map.put("primaryTeam", %{"teamId" => "reserves", "teamName" => "Alpha B"})
      |> Map.put("statSeasons", [])
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "playedInMatch"], false)
      |> put_in(["initialMatchesPage", "matches", Access.at(0), "minutesPlayed"], nil)

    match =
      match
      |> put_in(["general", "homeTeam", "name"], "Alpha")
      |> put_in(["content", "playerStats", "p1", "stats"], [])
      |> put_in(["content", "lineup", "homeTeam", "starters"], [])
      |> put_in(["content", "lineup", "homeTeam", "subs"], [
        %{"id" => "p1", "performance" => %{}}
      ])

    state =
      state
      |> Map.delete(:player_source_id)
      |> Map.merge(%{player_name: "Alex Example", player_team_name: "Alpha"})
      |> put_in([:portions, "player_search:Alex Example"], %{
        body:
          Jason.encode!([
            %{
              "suggestions" => [
                %{
                  "id" => "p1",
                  "name" => "Alex Example",
                  "teamName" => "Alpha B",
                  "type" => "player"
                }
              ]
            }
          ]),
        observation: observation
      })

    assert {:ok, result} = audit_player_result(c, state, profile, match)
    assert result.completeness.complete_empty
    assert result.facts.matches == []
    assert result.facts.performances == []

    for mutate <- [
          &put_in(&1, ["general", "homeTeam", "name"], "Alpha B"),
          &put_in(&1, ["general", "homeTeam", "id"], "other"),
          &put_in(&1, ["general", "matchId"], "other"),
          &put_in(&1, ["general", "finished"], false),
          &put_in(&1, ["general", "matchTimeUTCDate"], "2024-10-02T12:00:00Z"),
          &put_in(&1, ["content", "lineup", "homeTeam", "subs"], []),
          &put_in(&1, ["content", "lineup", "homeTeam", "starters"], [%{"id" => "p1"}]),
          &put_in(&1, ["content", "playerStats", "p1", "stats"], [%{"stats" => []}])
        ] do
      assert {:error, _} = audit_player_result(c, state, profile, mutate.(match))
    end

    for {key, value} <- [{"leagueId", "other"}, {"minutesPlayed", 1}, {"yellowCards", 1}] do
      changed = put_in(profile, ["initialMatchesPage", "matches", Access.at(0), key], value)
      assert {:error, _} = audit_player_result(c, state, changed, match)
    end

    # Two different player IDs independently on the same bench remain ambiguous.
    other = Map.put(profile, "id", "p2")

    candidates =
      for id <- ["p1", "p2"],
          do: %{
            "id" => id,
            "name" => "Alex Example",
            "teamName" => "Alpha B",
            "type" => "player"
          }

    ambiguous =
      state
      |> put_in(
        [:portions, "player_search:Alex Example", :body],
        Jason.encode!([
          %{"suggestions" => candidates}
        ])
      )
      |> put_in([:portions, "player_data:p2"], %{
        body: Jason.encode!(other),
        observation: observation
      })

    match =
      match
      |> put_in(["content", "playerStats", "p2"], %{
        "id" => "p2",
        "teamId" => "a",
        "name" => "Alex Example",
        "stats" => []
      })
      |> put_in(["content", "lineup", "homeTeam", "subs"], [
        %{"id" => "p1", "performance" => %{}},
        %{"id" => "p2", "performance" => %{}}
      ])

    assert {:error, _} = audit_player_result(c, ambiguous, profile, match)
  end

  defp audit_player_sample(league \\ "PL") do
    c = Data.case!("performance-#{league}-2024")
    state = Data.state(c, %{owner: self(), player_source_id: "p1"})
    key = {:performances, league, 2024, 2025}
    state = put_in(state.assessment.scopes[key].positions, %{"keeper" => "GK", "3" => "FW"})
    match = Jason.decode!(state.portions["match:m1"].body)

    match =
      match
      |> put_in(["content", "playerStats", "p1", "positionId"], 115)
      |> put_in(["content", "playerStats", "p1", "usualPosition"], 3)
      |> put_in(["content", "lineup"], %{
        "homeTeam" => %{
          "id" => "a",
          "starters" => [
            %{"id" => "p1", "positionId" => 115, "usualPlayingPositionId" => 3}
          ],
          "subs" => []
        },
        "awayTeam" => %{"id" => "b", "starters" => [], "subs" => []}
      })

    profile = %{
      "id" => "p1",
      "name" => "Alex Example",
      "statSeasons" => [
        %{"seasonName" => "2024/2025", "tournaments" => [%{"tournamentId" => league}]}
      ],
      "initialMatchesPage" => %{
        "previous" => nil,
        "matches" => [
          %{
            "id" => "m1",
            "leagueId" => league,
            "teamId" => "a",
            "teamName" => "Alpha",
            "opponentTeamId" => "b",
            "opponentTeamName" => "Beta",
            "isHomeTeam" => true,
            "matchDate" => %{"utcTime" => "2024-10-01T12:00:00Z"},
            "playedInMatch" => true,
            "minutesPlayed" => 90,
            "lineupPositionId" => 105,
            "matchPageUrl" => "/matches/alpha-beta/m1"
          }
        ]
      }
    }

    {c, state, profile, match}
  end

  defp audit_player_result(c, state, profile, match, positions \\ Data.positions()) do
    observation = state.portions["match:m1"].observation

    portions =
      state.portions
      |> Map.put("player_data:p1", %{body: Jason.encode!(profile), observation: observation})
      |> Map.put("match_details:m1", %{body: Jason.encode!(match), observation: observation})

    player_result(c, %{state | portions: portions}, positions)
  end

  defp player_result(c, state, positions \\ Data.positions()) do
    FootballMarket.Providers.performances(Data.request(c),
      provider: {FootballMarket.Providers.Scraping, state},
      positions: positions,
      runtime: {FootballMarket.Providers.FixtureRuntime, %{}}
    )
  end
end
