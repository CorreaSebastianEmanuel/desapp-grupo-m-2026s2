%{
  "source-equivalence-performances" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-duplicate-match" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"},{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-FL1-2024" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"FL1\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-wrong-match" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"other\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "status-abandoned" => %{
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"abandoned\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":\"0\"}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-fraction-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0.5}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-cross-season" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "bounds-outside" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-equal" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "access-unsupported-performance" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unavailable-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-partial-discovery" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "completed-empty" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-4294968000" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-SA-2024" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"SA\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-fraction-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0.5}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "minutes-151" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":151}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":\"0\"}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-fraction-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0.5}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-BL1-2025" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"BL1\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"BL1\",\"selectedSeason\":\"2025/2026\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-publication-revoked" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "minutes-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":0}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unverified-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":-1}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-unmapped" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"unknown\"}]}"
  },
  "metric-negative-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":-1}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unverified-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-wrong-operation" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-empty" => %{
    "catalog" => "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[]}"
  },
  "access-missing" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-boolean-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":true}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-absent" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unverified-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unverified-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-performances-10000000000000" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-SA-2024" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"SA\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"SA\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":\"0\"}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-PL-2024" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-scoped" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-missing-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":\"0\"}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "assessment-inventory" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "access-withdrawn" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-missing-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "later-failure" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "access-coverage" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-negative-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":-1}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-nonterminal" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-missing-roster" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}"
  },
  "malformed-html" => %{"catalog" => "<html>challenge password=FAKE_SENTINEL</html>"},
  "metric-string-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":\"0\"}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":-1}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-FL1-2025" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"FL1\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"FL1\",\"selectedSeason\":\"2025/2026\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-10000000000000" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-boolean-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":true}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-performances-equal" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-late" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-FL1-2025" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"FL1\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "access-switch" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-schedule-only" => %{
    "catalog" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-wrong-league" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PD\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "status-postponed" => %{
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"postponed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "failure-rate_limited" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unavailable-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "status-scheduled" => %{
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"scheduled\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-boolean-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":true}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-duplicate" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"},{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "deadline-performances-late" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-boolean-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":true}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-wrong-team" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"b\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-boolean-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":true}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-performances-before" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":-1}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-fraction-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0.5}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-default" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "failure-delay" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-wrong-roster" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-fraction-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0.5}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":-1}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-conflicting" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-fraction-7" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0.5}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-before" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-BL1-2025" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"BL1\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-nonterminal" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-PD-2024" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PD\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "access-wrong-scope" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-PL-2025" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "malformed-ambiguous" => %{
    "catalog" =>
      "<script id=\"__NEXT_DATA__\">{}</script><script id=\"__NEXT_DATA__\">{}</script>"
  },
  "performance-missing-detail" => %{
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-PD-2024" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PD\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PD\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-expired" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-fraction-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0.5}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "deadline-catalog-17" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-BL1-2024" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"BL1\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"BL1\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "keeper-change" => %{
    "match:m1" =>
      "{\"content\":{\"matchFacts\":{\"events\":{\"complete\":false,\"events\":[{\"inPlayerId\":\"p2\",\"minute\":45,\"outPlayerId\":\"p1\",\"teamId\":\"a\",\"type\":\"substitution\"}]},\"teamGoalsConceded\":7},\"playerStats\":{\"p1\":{\"currentTeamId\":\"b\",\"id\":\"p1\",\"name\":\"Alex Example\",\"positionId\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":45}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":2}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":7}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}],\"teamId\":\"a\",\"usualPosition\":\"keeper\"},\"p2\":{\"currentTeamId\":\"a\",\"id\":\"p2\",\"name\":\"Alex Example\",\"positionId\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":45}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":3}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":7}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}],\"teamId\":\"a\",\"usualPosition\":\"keeper\"}}},\"general\":{\"awayTeam\":{\"id\":\"b\"},\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"matchId\":\"m1\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\"}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "required-unmapped-position" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"unknown\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-wrong-season" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "deadline-performances-17" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "source-equivalence-catalog" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-missing-stats" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-conditions" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-boolean-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":true}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-later-failure" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-SA-2025" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"SA\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "catalog-BL1-2024" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"BL1\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "deadline-performances-4294968000" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "required-position" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":\"0\"}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-unsupported" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unverified-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "historical-affiliation" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-duplicate-pair" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]},\"p2\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-boolean-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":true}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-missing-witness" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unverified-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-PL-2025" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2025/2026\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-4" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "status-live" => %{
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"live\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":\"0\"}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "failure-authentication_failed" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "own-goal" => %{
    "match:m1" =>
      "{\"content\":{\"matchFacts\":{\"events\":{\"complete\":false,\"events\":[{\"minute\":45,\"ownGoal\":true,\"playerId\":\"p1\",\"teamId\":\"a\",\"type\":\"goal\"}]},\"teamGoals\":7,\"unverifiedShotCount\":1},\"playerStats\":{\"p1\":{\"currentTeamId\":\"b\",\"id\":\"p1\",\"name\":\"Alex Example\",\"positionId\":\"attack\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}],\"teamId\":\"a\",\"usualPosition\":\"keeper\"}}},\"general\":{\"awayTeam\":{\"id\":\"b\"},\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"matchId\":\"m1\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\"}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-PD-2025" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PD\",\"season\":\"2025/2026\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2025/2026\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-wrong-season" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-unknown-status" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"unknown\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-PD-2025" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PD\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PD\",\"selectedSeason\":\"2025/2026\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-PL-2024" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "bounds-inclusive" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "failure-unavailable" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-negative-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":-1}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-missing-collection" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" => "{\"teamId\":\"b\",\"season\":\"2024/2025\"}"
  },
  "metric-boolean-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":true}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unverified-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "offline-repeat-isolation" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "html-schedule" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "<script id=\"__NEXT_DATA__\">{\"props\":{\"pageProps\":{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"away\":\"b\",\"home\":\"a\",\"id\":\"m1\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"status\":\"completed\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}}}</script>"
  },
  "metric-fraction-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0.5}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-3" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":-1}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "catalog-repeated" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-FL1-2024" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"FL1\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"FL1\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "required-minutes" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "performance-missing-kickoff" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":\"0\"}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-string-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":\"0\"}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "failure-invalid-delay" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-boolean-6" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":true}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-missing-2" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "profile-no-match-fallback" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "malformed-json" => %{"catalog" => "{broken"},
  "performance-no-witness" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "access-invalid-input" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "performance-SA-2025" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"SA\",\"season\":\"2025/2026\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"SA\",\"selectedSeason\":\"2025/2026\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "failure-not_found" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "failure-invalid_response" => %{
    "catalog" =>
      "{\"competition\":{\"id\":\"PL\",\"season\":\"2024/2025\"},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}",
    "roster:a" =>
      "{\"teamId\":\"a\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p1\",\"name\":\"Alex Example\",\"positionCode\":\"attack\"}]}",
    "roster:b" =>
      "{\"teamId\":\"b\",\"season\":\"2024/2025\",\"players\":[{\"id\":\"p2\",\"name\":\"Alex Example\",\"positionCode\":\"keeper\"}]}"
  },
  "metric-unverified-1" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unverified-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-0" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-unavailable-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "required-duplicate-stat" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}},{\"key\":\"minutes_played\",\"stat\":{\"value\":90}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-fraction-8" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":0}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0.5}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  },
  "metric-negative-5" => %{
    "match:m1" =>
      "{\"general\":{\"matchId\":\"m1\",\"parentLeagueId\":\"PL\",\"season\":\"2024/2025\",\"matchTimeUTCDate\":\"2024-10-01T12:00:00Z\",\"finished\":true,\"homeTeam\":{\"id\":\"a\"},\"awayTeam\":{\"id\":\"b\"}},\"content\":{\"playerStats\":{\"p1\":{\"id\":\"p1\",\"name\":\"Alex Example\",\"teamId\":\"a\",\"currentTeamId\":\"b\",\"positionId\":\"attack\",\"usualPosition\":\"keeper\",\"stats\":[{\"stats\":[{\"key\":\"minutes_played\",\"stat\":{\"value\":90}},{\"key\":\"goals\",\"stat\":{\"value\":0}},{\"key\":\"assists\",\"stat\":{\"value\":0}},{\"key\":\"ShotsOnTarget\",\"stat\":{\"value\":0}},{\"key\":\"matchstats.headers.tackles\",\"stat\":{\"value\":0}},{\"key\":\"interceptions\",\"stat\":{\"value\":0}},{\"key\":\"saves\",\"stat\":{\"value\":-1}},{\"key\":\"goals_conceded\",\"stat\":{\"value\":0}},{\"key\":\"yellow_cards\",\"stat\":{\"value\":0}},{\"key\":\"red_cards\",\"stat\":{\"value\":0}}]}]}}}}",
    "schedule" =>
      "{\"details\":{\"leagueId\":\"PL\",\"selectedSeason\":\"2024/2025\"},\"fixtures\":{\"allMatches\":[{\"id\":\"m1\",\"status\":\"completed\",\"kickoff\":\"2024-10-01T12:00:00Z\",\"home\":\"a\",\"away\":\"b\"}]},\"teams\":[{\"id\":\"a\",\"name\":\"Alpha\",\"shortCode\":\"ALP\"},{\"id\":\"b\",\"name\":\"Beta\",\"shortCode\":\"BET\"}]}"
  }
}
