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
end
