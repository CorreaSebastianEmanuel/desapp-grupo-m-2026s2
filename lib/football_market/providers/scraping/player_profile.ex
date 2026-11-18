defmodule FootballMarket.Providers.Scraping.PlayerProfile do
  @moduledoc "Player discovery, profile coverage and historical performance interpretation."
  import FootballMarket.Providers.Scraping.Document
  alias FootballMarket.Providers.Scraping.Translator

  def read(request, context, state, revision, row) do
    state = reviewed_identity(state, request)

    {player_id, discovered_profile} =
      case state[:player_source_id] do
        nil -> discover_player_id!(request, context, state, revision, row)
        id -> {id, nil}
      end

    state = Map.put(state, :player_source_id, player_id)

    {profile_data, recent} =
      player_profile(player_id, discovered_profile, request, context, state, revision, row)

    scoped_rows = scoped_profile_rows(recent, row, request)

    details =
      profile_match_details(
        scoped_rows,
        profile_data,
        player_id,
        state,
        {request, context, revision, row}
      )

    {facts, eligible_ids} =
      translate_profile_details(
        details,
        scoped_rows,
        profile_data,
        state,
        request,
        context,
        row
      )

    empty_verified =
      details == [] and not profile_covers_season?(profile_data, request, row) and
        verify_unused_history!(recent, player_id, state, {request, context, revision, row})

    validate_profile_season!(profile_data, request, row, details, empty_verified)

    {facts, eligible_ids == [], state}
  end

  defp reviewed_identity(state, request) do
    id =
      state[:player_source_id] ||
        FootballMarket.Providers.PlayerIdentity.source_id(
          state[:player_name],
          request.scope.league_code,
          state[:player_team_name]
        )

    Map.put(state, :player_source_id, id)
  end

  defp player_profile(player_id, cached, request, context, state, revision, row) do
    profile =
      cached || portion!("player_data:" <> player_id, request, context, state, revision, row)

    profile_data = map!(profile["data"] || profile)
    require!(source_id!(profile_data["id"]) == player_id)
    require!(profile_identity?(profile_data, request, state))

    if is_nil(profile_data["initialMatchesPage"]),
      do: validate_profile_season!(profile_data, request, row, [])

    page = map!(profile_data["initialMatchesPage"])
    recent = complete_profile_rows!(page, profile_data["recentMatches"])
    profile_data = Map.put(profile_data, "recentMatches", recent)

    if recent == [] and is_nil(page["previous"]),
      do: validate_profile_season!(profile_data, request, row, [])

    require!(recent != [] and length(recent) <= 200)
    require!(Enum.all?(recent, &is_boolean(&1["playedInMatch"])))
    recent_ids = Enum.map(recent, &source_id!(&1["id"]))
    require!(length(recent_ids) == length(Enum.uniq(recent_ids)))

    profile_kickoffs =
      Enum.map(recent, fn match ->
        {:ok, kickoff} =
          FootballMarket.Providers.Instant.normalize(get_in(match, ["matchDate", "utcTime"]))

        kickoff
      end)

    require!(profile_kickoffs == Enum.sort(profile_kickoffs, {:desc, DateTime}))
    oldest_profile_kickoff = List.last(profile_kickoffs)
    season_boundary = Date.new!(request.scope.start_year, 7, 1)
    boundary = DateTime.new!(season_boundary, ~T[00:00:00], "Etc/UTC")
    cursor = page["previous"]

    require!(is_nil(cursor) or DateTime.compare(oldest_profile_kickoff, boundary) == :lt)

    {profile_data, recent}
  end

  defp complete_profile_rows!(page, summary) do
    page_rows = list!(page["matches"])
    summary_rows = if is_nil(summary), do: page_rows, else: list!(summary)
    Enum.each([page_rows, summary_rows], &validate_history_rows!/1)
    page_ids = Enum.map(page_rows, &source_id!(&1["id"]))
    summary_ids = Enum.map(summary_rows, &source_id!(&1["id"]))
    shared = Enum.filter(page_ids, &(&1 in summary_ids))
    require!(page_rows == [] or summary_rows == [] or shared != [])
    require!(shared == Enum.filter(summary_ids, &(&1 in page_ids)))

    for entry <- summary_rows, source_id!(entry["id"]) in shared do
      other = Enum.find(page_rows, &(source_id!(&1["id"]) == source_id!(entry["id"])))
      require!(history_identity(entry) == history_identity(other))
    end

    # Recent summaries omit some friendlies/youth matches and may use a different
    # visual rating. Preserve all anchored rows, without repairing bad input order
    # or ignoring disagreements in identity, participation or measured counts.
    (page_rows ++ summary_rows)
    |> Enum.uniq_by(&source_id!(&1["id"]))
    |> Enum.sort_by(&history_kickoff!/1, {:desc, DateTime})
  end

  defp validate_history_rows!(rows) do
    ids = Enum.map(rows, &source_id!(&1["id"]))
    require!(length(ids) == length(Enum.uniq(ids)))
    times = Enum.map(rows, &history_kickoff!/1)
    require!(times == Enum.sort(times, {:desc, DateTime}))
  end

  defp history_identity(entry) do
    fields = ~w(id leagueId teamId opponentTeamId isHomeTeam playedInMatch onBench
                lineupPositionId minutesPlayed goals assists yellowCards redCards matchPageUrl)
    Map.new(fields, &{&1, entry[&1]}) |> Map.put("kickoff", history_kickoff!(entry))
  end

  defp history_kickoff!(entry) do
    {:ok, kickoff} =
      FootballMarket.Providers.Instant.normalize(get_in(entry, ["matchDate", "utcTime"]))

    kickoff
  end

  defp scoped_profile_rows(recent, row, request) do
    Enum.filter(recent, fn match ->
      match["playedInMatch"] == true and
        source_id!(match["leagueId"]) == source_id!(row.competition) and
        in_season_window?(get_in(match, ["matchDate", "utcTime"]), request.scope)
    end)
  end

  defp profile_match_details(scoped_profile_rows, profile_data, player_id, state, acquisition) do
    Enum.map(scoped_profile_rows, fn profile_row ->
      match_id = source_id!(profile_row["id"])

      {:ok, kickoff} =
        FootballMarket.Providers.Instant.normalize(get_in(profile_row, ["matchDate", "utcTime"]))

      require!(is_boolean(profile_row["isHomeTeam"]))
      home = profile_row["isHomeTeam"]

      team = %{
        "id" => source_id!(profile_row["teamId"]),
        "name" => id!(profile_row["teamName"])
      }

      opponent = %{
        "id" => source_id!(profile_row["opponentTeamId"]),
        "name" => id!(profile_row["opponentTeamName"])
      }

      general = %{
        "matchId" => match_id,
        "parentLeagueId" => source_id!(profile_row["leagueId"]),
        "finished" => true,
        "matchTimeUTCDate" => get_in(profile_row, ["matchDate", "utcTime"]),
        "homeTeam" => if(home, do: team, else: opponent),
        "awayTeam" => if(home, do: opponent, else: team)
      }

      stats = %{
        "id" => player_id,
        "name" => id!(profile_data["name"]),
        "teamId" => team["id"],
        "currentTeamId" => team["id"],
        "usualPosition" => profile_position_id(profile_row, state),
        "positionId" => profile_position_id(profile_row, state),
        "stats" =>
          [
            {"minutes_played", profile_row["minutesPlayed"]},
            {"goals", profile_row["goals"]},
            {"assists", profile_row["assists"]},
            {"yellow_cards", profile_row["yellowCards"]},
            {"red_cards", profile_row["redCards"]}
          ]
          |> Enum.flat_map(fn {key, value} ->
            case value do
              nil ->
                []

              count when is_integer(count) ->
                [%{"stats" => [%{"key" => key, "stat" => %{"value" => count}}]}]

              _ ->
                throw({:invalid, :profile_metric})
            end
          end)
      }

      case profile_row["matchPageUrl"] do
        nil -> {match_id, general, %{player_id => stats}, kickoff}
        path -> match_details!(match_id, path, general, stats, kickoff, state, acquisition)
      end
    end)
  end

  defp match_details!(
         match_id,
         path,
         expected,
         profile_player,
         kickoff,
         state,
         {request, context, revision, row}
       ) do
    data =
      validated_match_data!(
        match_id,
        path,
        expected,
        kickoff,
        state,
        {request, context, revision, row}
      )

    general = data["general"]
    players = map!(data["content"]["playerStats"])
    player_id = profile_player["id"]
    player = map!(players[player_id])
    require!(source_id!(player["id"]) == player_id)
    require!(source_id!(player["teamId"]) == profile_player["teamId"])

    player =
      player
      |> merge_profile_stats!(profile_player)
      |> corroborate_lineup!(data["content"]["lineup"], expected, row)
      |> historical_position!(profile_player, row)

    {match_id, general, %{player_id => player}, kickoff}
  end

  defp validated_match_data!(
         match_id,
         path,
         expected,
         kickoff,
         state,
         {request, context, revision, row}
       ) do
    state = Map.put(state, :match_page_urls, %{match_id => path})
    data = portion!("match_details:" <> match_id, request, context, state, revision, row)
    general = map!(data["general"])
    require!(source_id!(general["matchId"]) == match_id)
    require!(source_id!(general["parentLeagueId"]) == source_id!(row.competition))
    require!(general["finished"] == true)

    require!(
      is_nil(general["season"]) or
        season_matches?(
          general["season"],
          request.scope.start_year,
          request.scope.end_year,
          row.season
        )
    )

    {:ok, actual} = FootballMarket.Providers.Instant.normalize(general["matchTimeUTCDate"])
    require!(DateTime.compare(actual, kickoff) == :eq)

    for side <- ["homeTeam", "awayTeam"] do
      require!(source_id!(general[side]["id"]) == expected[side]["id"])
    end

    data
  end

  defp verify_unused_history!(recent, player_id, state, {request, _, _, row} = acquisition) do
    unused = unused_profile_rows(recent, row, request)
    Enum.each(unused, &verified_unused_match!(&1, player_id, state, acquisition))
    unused != []
  end

  defp unused_profile_rows(recent, row, request) do
    Enum.filter(recent, fn match ->
      match["playedInMatch"] == false and
        source_id!(match["leagueId"]) == source_id!(row.competition) and
        in_season_window?(get_in(match, ["matchDate", "utcTime"]), request.scope)
    end)
  end

  defp verified_unused_match!(profile, player_id, state, acquisition) do
    require!(is_boolean(profile["isHomeTeam"]))

    require!(
      Enum.all?(
        ~w(minutesPlayed goals assists yellowCards redCards),
        &(profile[&1] in [nil, 0])
      )
    )

    side = if profile["isHomeTeam"], do: "homeTeam", else: "awayTeam"
    other = if profile["isHomeTeam"], do: "awayTeam", else: "homeTeam"
    team_id = source_id!(profile["teamId"])

    expected = %{
      side => %{"id" => team_id},
      other => %{"id" => source_id!(profile["opponentTeamId"])}
    }

    {:ok, kickoff} =
      FootballMarket.Providers.Instant.normalize(get_in(profile, ["matchDate", "utcTime"]))

    data =
      validated_match_data!(
        source_id!(profile["id"]),
        id!(profile["matchPageUrl"]),
        expected,
        kickoff,
        state,
        acquisition
      )

    player = map!(data["content"]["playerStats"][player_id])
    require!(source_id!(player["id"]) == player_id and source_id!(player["teamId"]) == team_id)
    require!(list!(player["stats"]) == [])
    lineup = map!(data["content"]["lineup"][side])
    require!(source_id!(lineup["id"]) == team_id)
    require!(Enum.all?(list!(lineup["starters"]), &(source_id!(&1["id"]) != player_id)))
    bench = Enum.filter(list!(lineup["subs"]), &(source_id!(&1["id"]) == player_id))
    require!(length(bench) == 1)
    [entry] = bench
    require!(entry["positionId"] == nil and map!(entry["performance"]) == %{})
    data
  end

  defp historical_position!(player, profile_player, row) do
    position = normalized_role!(player, row)
    expected = row.positions[to_string(profile_player["positionId"])]
    require!(is_nil(expected) or expected == row.positions[position])
    Map.put(player, "positionId", position)
  end

  defp normalized_role!(player, row) do
    position = optional_position(player["positionId"])
    role = optional_position(player["usualPosition"])
    mapped = row.positions[position]
    fallback = row.positions[role]
    require!(is_nil(mapped) or is_nil(fallback) or mapped == fallback)

    cond do
      mapped -> position
      fallback -> role
      true -> throw({:invalid, :historical_position})
    end
  end

  defp optional_position(nil), do: nil
  defp optional_position(value), do: source_id!(value)

  defp corroborate_lineup!(player, nil, _expected, _row) do
    require!(not is_nil(player["positionId"]))
    player
  end

  defp corroborate_lineup!(player, lineup, expected, row) do
    entries = lineup_entries(lineup, source_id!(player["id"]))

    require!(length(entries) == 1)
    [{side, team, group, entry}] = entries
    require!(expected[side]["id"] == source_id!(player["teamId"]))
    require!(is_nil(team["id"]) or source_id!(team["id"]) == expected[side]["id"])

    if entry["positionId"] && player["positionId"],
      do: require!(source_id!(entry["positionId"]) == source_id!(player["positionId"]))

    require!(
      is_nil(entry["teamId"]) or source_id!(entry["teamId"]) == source_id!(player["teamId"])
    )

    lineup_role = entry["usualPlayingPositionId"]

    if is_nil(player["positionId"]) do
      require!(group == "subs" and is_nil(entry["positionId"]) and not is_nil(lineup_role))
      require!(not is_nil(row.positions[source_id!(lineup_role)]))
    end

    if lineup_role do
      require!(
        row.positions[source_id!(lineup_role)] == row.positions[normalized_role!(player, row)]
      )
    end

    player
  end

  defp lineup_entries(lineup, player_id) do
    for side <- ["homeTeam", "awayTeam"],
        team = map!(lineup[side]),
        group <- ["starters", "subs"],
        entry <- list!(team[group] || []),
        source_id!(entry["id"]) == player_id,
        do: {side, team, group, entry}
  end

  defp merge_profile_stats!(player, profile) do
    measured = fn p ->
      for group <- list!(p["stats"]),
          stat <- stat_entries!(group["stats"]),
          into: %{},
          do: {stat["key"], stat["stat"]["value"]}
    end

    values = measured.(player)

    extras =
      Enum.flat_map(measured.(profile), fn {key, value} ->
        require!(is_nil(values[key]) or values[key] == value)
        if is_nil(values[key]), do: [%{"key" => key, "stat" => %{"value" => value}}], else: []
      end)

    Map.update!(player, "stats", &(&1 ++ [%{"stats" => extras}]))
  end

  defp translate_profile_details(
         details,
         scoped_profile_rows,
         profile_data,
         state,
         request,
         context,
         row
       ) do
    player_id = source_id!(profile_data["id"])
    kickoffs = Enum.map(details, &elem(&1, 3))
    require!(kickoffs == Enum.sort(kickoffs, {:desc, DateTime}))

    season_name = "#{row.season}"

    selected =
      Enum.filter(details, fn {_id, general, _stats, _kickoff} ->
        source_id!(general["parentLeagueId"]) == source_id!(row.competition) and
          (is_nil(general["season"]) or
             season_matches?(
               general["season"],
               request.scope.start_year,
               request.scope.end_year,
               season_name
             ))
      end)

    translated = translate_selected(selected, scoped_profile_rows, player_id)
    teams = translated_teams(selected)

    directory = %{display_name: id!(profile_data["name"])}

    directory =
      case state[:player_position_code] do
        code when is_binary(code) ->
          require!(Map.has_key?(context.positions, code))
          Map.put(directory, :position_ref, code)

        _ ->
          directory
      end

    directory = directory_team(directory, profile_data["primaryTeam"], teams, state, request)
    overrides = %{("player:" <> player_id) => directory}
    facts = Translator.performances(request, context, row, teams, translated, overrides)
    eligible_ids = Enum.map(selected, fn {match_id, _, _, _} -> match_id end)

    {facts, eligible_ids}
  end

  defp directory_team(directory, nil, _teams, _state, _request), do: directory

  defp directory_team(directory, primary, teams, state, request) do
    primary = map!(primary)
    league = request.scope.league_code

    if teams != [] and is_binary(state[:player_team_name]) and
         normalized_team(primary["teamName"], league) ==
           normalized_team(state.player_team_name, league) do
      source_id = source_id!(primary["teamId"])

      matching =
        Enum.filter(teams, fn team ->
          team["id"] == source_id and
            normalized_team(team["name"], league) == normalized_team(primary["teamName"], league)
        end)

      # Current directory identity needs the same club ID/name in validated matches.
      require!(length(matching) == 1)
      Map.put(directory, :team_ref, Translator.ref(:team, source_id))
    else
      directory
    end
  end

  defp translate_selected(selected, profile_rows, player_id) do
    numeric_player_id = numeric_id(player_id)

    Enum.map(selected, fn {match_id, general, player_stats, _kickoff} ->
      match = %{
        "id" => match_id,
        "status" => "completed",
        "kickoff" => general["matchTimeUTCDate"],
        "home" => source_id!(general["homeTeam"]["id"]),
        "away" => source_id!(general["awayTeam"]["id"])
      }

      players = Map.get(player_stats, player_id) || Map.get(player_stats, numeric_player_id)
      {match, translate_player(players, match_id, profile_rows, player_id)}
    end)
  end

  defp numeric_id(player_id) do
    case Integer.parse(player_id) do
      {value, ""} -> value
      _ -> nil
    end
  end

  defp translate_player(players, match_id, profile_rows, player_id) when is_map(players) do
    profile_row = Enum.find(profile_rows, &(source_id!(&1["id"]) == match_id))

    player =
      players
      |> Map.put_new("id", player_id)
      |> Map.put_new("currentTeamId", players["teamId"])
      |> Map.put_new("positionId", profile_row["lineupPositionId"])
      |> put_profile_metric(profile_row, "yellow_cards", "yellowCards")
      |> put_profile_metric(profile_row, "red_cards", "redCards")
      |> Map.update!("id", &source_id!/1)
      |> Map.update!("teamId", &source_id!/1)
      |> Map.update!("currentTeamId", &source_id!/1)
      |> maybe_normalize_position()

    [player]
  end

  defp translate_player(_players, _match_id, _profile_rows, _player_id), do: []

  defp translated_teams(selected) do
    selected
    |> Enum.flat_map(fn {_id, general, _stats, _kickoff} ->
      [general["homeTeam"], general["awayTeam"]]
    end)
    |> Enum.uniq_by(& &1["id"])
    |> Enum.map(fn team ->
      %{
        "id" => source_id!(team["id"]),
        "name" => team["name"] || team["shortName"] || source_id!(team["id"]),
        "shortCode" => team["shortName"] || team["name"] || source_id!(team["id"])
      }
    end)
  end

  defp profile_position_id(profile_row, state) do
    case profile_row["lineupPositionId"] do
      nil ->
        position_code = state[:player_position_code]

        if is_binary(position_code) and position_code != "" and
             FootballMarket.Providers.Provenance.safe_text?(position_code),
           do: "catalog-position:" <> position_code

      position_id ->
        optional_source_id(position_id)
    end
  end

  defp discover_player_id!(request, context, state, revision, row) do
    player_name = id!(state[:player_name])
    team_name = id!(state[:player_team_name])
    league = request.scope.league_code

    candidates =
      player_name
      |> FootballMarket.Providers.PlayerIdentity.search_terms(league, team_name)
      |> Enum.reduce_while([], fn term, _acc ->
        matches =
          portion!("player_search:" <> term, request, context, state, revision, row)
          |> list!()
          |> Enum.flat_map(fn group -> list!(group["suggestions"] || []) end)
          |> Enum.filter(fn candidate ->
            candidate["type"] == "player" and
              FootballMarket.Providers.PlayerIdentity.equivalent?(
                candidate["name"],
                player_name,
                league,
                team_name
              )
          end)
          |> Enum.uniq_by(&source_id!(&1["id"]))

        if matches == [], do: {:cont, []}, else: {:halt, matches}
      end)

    require!(length(candidates) <= 50)

    if FootballMarket.Providers.PlayerIdentity.birth_date(player_name, league, team_name) do
      verified = verified_profiles(candidates, request, context, state, revision, row)

      current =
        Enum.filter(verified, fn {candidate, _, _} ->
          normalized_team(candidate["teamName"], league) == normalized_team(team_name, league)
        end)

      case current do
        [{_, id, document}] -> {id, document}
        [] -> historical_discovery!(verified, team_name, request, context, state, revision, row)
        _ -> throw({:invalid, :player_identity})
      end
    else
      discover_without_birth_date(candidates, team_name, request, context, state, revision, row)
    end
  end

  defp discover_without_birth_date(candidates, team_name, request, context, state, revision, row) do
    league = request.scope.league_code

    current =
      Enum.filter(
        candidates,
        &(normalized_team(&1["teamName"], league) == normalized_team(team_name, league))
      )

    case {current, candidates} do
      {[candidate], _} ->
        {source_id!(candidate["id"]), nil}

      {[], [_ | _]} ->
        verified = verified_profiles(candidates, request, context, state, revision, row)
        historical_discovery!(verified, team_name, request, context, state, revision, row)

      _ ->
        throw({:invalid, :player_identity})
    end
  end

  defp verified_profiles(candidates, request, context, state, revision, row) do
    Enum.flat_map(candidates, fn candidate ->
      id = source_id!(candidate["id"])
      document = portion!("player_data:" <> id, request, context, state, revision, row)
      profile = map!(document["data"] || document)
      require!(source_id!(profile["id"]) == id)
      if profile_identity?(profile, request, state), do: [{candidate, id, document}], else: []
    end)
  end

  defp historical_discovery!(verified, team_name, request, context, state, revision, row) do
    matching =
      Enum.filter(verified, fn {_, id, document} ->
        profile = document["data"] || document
        entries = get_in(profile, ["careerHistory", "careerItems", "senior", "teamEntries"]) || []

        Enum.any?(list!(entries), &career_team_matches?(&1, id, team_name, request.scope)) or
          historical_match_identity?(
            profile,
            id,
            team_name,
            state,
            {request, context, revision, row}
          )
      end)

    case matching do
      [{_, id, document}] -> {id, document}
      _ -> throw({:invalid, :player_identity})
    end
  end

  defp profile_identity?(profile, request, state) do
    name = state[:player_name]
    team = state[:player_team_name]
    league = request.scope.league_code
    expected_date = FootballMarket.Providers.PlayerIdentity.birth_date(name, league, team)

    profile["gender"] in [nil, "male"] and
      (is_nil(name) or
         FootballMarket.Providers.PlayerIdentity.equivalent?(profile["name"], name, league, team)) and
      (is_nil(expected_date) or profile_birth_date(profile) == expected_date)
  end

  defp profile_birth_date(profile) do
    with %{"utcTime" => time} <- profile["birthDate"],
         {:ok, instant} <- FootballMarket.Providers.Instant.normalize(time) do
      instant |> DateTime.to_date() |> Date.to_iso8601()
    else
      _ -> nil
    end
  end

  defp historical_match_identity?(
         profile,
         id,
         team_name,
         state,
         {request, _, _, row} = acquisition
       ) do
    rows =
      list!(profile["recentMatches"] || []) ++
        list!(get_in(profile, ["initialMatchesPage", "matches"]) || [])

    linked =
      Enum.filter(rows, fn match ->
        is_binary(match["matchPageUrl"]) and
          normalized_team(match["teamName"], request.scope.league_code) ==
            normalized_team(team_name, request.scope.league_code)
      end)

    played = linked |> scoped_profile_rows(row, request) |> List.first()
    candidate = played || List.first(unused_profile_rows(linked, row, request))

    if candidate do
      general =
        if played do
          [{_, general, _, _}] = profile_match_details([played], profile, id, state, acquisition)
          general
        else
          verified_unused_match!(candidate, id, state, acquisition)["general"]
        end

      side = if candidate["isHomeTeam"], do: "homeTeam", else: "awayTeam"

      normalized_team(general[side]["name"], request.scope.league_code) ==
        normalized_team(team_name, request.scope.league_code)
    else
      false
    end
  end

  defp career_team_matches?(entry, id, team, scope) do
    entry["hasUncertainData"] == false and source_id!(entry["participantId"]) == id and
      normalized_team(entry["team"], scope.league_code) ==
        normalized_team(team, scope.league_code) and
      career_overlaps?(entry, scope)
  end

  defp career_overlaps?(entry, scope) do
    boundary = DateTime.new!(Date.new!(scope.start_year, 7, 1), ~T[00:00:00], "Etc/UTC")
    ending = DateTime.new!(Date.new!(scope.end_year, 7, 1), ~T[00:00:00], "Etc/UTC")

    with {:ok, started} <- career_instant(entry["startDate"]),
         {:ok, finished} <- career_end(entry["endDate"], ending) do
      DateTime.compare(started, ending) == :lt and DateTime.compare(finished, boundary) != :lt and
        DateTime.compare(finished, started) != :lt
    else
      _ -> false
    end
  end

  defp career_end(nil, ending), do: {:ok, ending}
  defp career_end(value, _), do: career_instant(value)

  # Career boundaries are calendar dates. This source also renders their midnight
  # without a timezone; only that observed form is interpreted as a UTC day.
  # Match kickoffs still require their original explicit timezone.
  defp career_instant(<<date::binary-size(10), "T00:00:00">>) do
    with {:ok, day} <- Date.from_iso8601(date),
         do: DateTime.new(day, ~T[00:00:00], "Etc/UTC")
  end

  defp career_instant(value), do: FootballMarket.Providers.Instant.normalize(value)

  defp normalized_team(value, league),
    do: FootballMarket.Providers.TeamIdentity.normalize(value, league)

  defp source_id!(value) when is_integer(value) and value >= 0,
    do: Integer.to_string(value)

  defp source_id!(value), do: id!(value)

  defp optional_source_id(value), do: source_id!(value)

  defp season_matches?(value, start_year, end_year, expected) do
    value = to_string(value)

    value == expected or
      case Regex.run(~r/\A(\d{4})[-\/](\d{2}|\d{4})\z/, value) do
        [_, start, ending] ->
          ending_year =
            if byte_size(ending) == 2,
              do: div(start_year, 100) * 100 + String.to_integer(ending),
              else: String.to_integer(ending)

          String.to_integer(start) == start_year and ending_year == end_year

        _ ->
          false
      end
  end

  defp in_season_window?(value, scope) do
    {:ok, instant} = FootballMarket.Providers.Instant.normalize(value)
    boundary = DateTime.new!(Date.new!(scope.start_year, 7, 1), ~T[00:00:00], "Etc/UTC")
    ending = DateTime.new!(Date.new!(scope.end_year, 7, 1), ~T[00:00:00], "Etc/UTC")

    DateTime.compare(instant, boundary) != :lt and DateTime.compare(instant, ending) == :lt and
      (is_nil(scope.from) or DateTime.compare(instant, scope.from) != :lt) and
      (is_nil(scope.to) or DateTime.compare(instant, scope.to) != :gt)
  end

  defp profile_covers_season?(profile, request, row) do
    seasons = if is_nil(profile["statSeasons"]), do: [], else: list!(profile["statSeasons"])

    Enum.any?(seasons, fn season ->
      season_matches?(
        season["seasonName"],
        request.scope.start_year,
        request.scope.end_year,
        "#{row.season}"
      ) and
        Enum.any?(list!(season["tournaments"]), fn tournament ->
          source_id!(tournament["tournamentId"]) == source_id!(row.competition)
        end)
    end)
  end

  defp validate_profile_season!(profile, request, row, details, empty_verified \\ false) do
    # A complete profile history plus independently acquired match evidence can
    # supersede a stale summary; summary absence alone never proves an empty season.
    corroborated =
      details != [] and
        Enum.all?(details, fn {id, _, _, _} ->
          Enum.any?(
            profile["recentMatches"] || get_in(profile, ["initialMatchesPage", "matches"]) || [],
            &(source_id!(&1["id"]) == id and is_binary(&1["matchPageUrl"]))
          )
        end)

    unless profile_covers_season?(profile, request, row) or corroborated or empty_verified do
      throw({:source_failure, %{category: :unsupported_capability}})
    end
  end

  defp put_profile_metric(player, profile_row, key, profile_key) do
    existing =
      Enum.any?(list!(player["stats"]), fn group ->
        group
        |> then(&(&1["stats"] || []))
        |> stat_entries!()
        |> Enum.any?(&(&1["key"] == key))
      end)

    value = Map.get(profile_row, profile_key)

    if existing or not is_integer(value) do
      player
    else
      group = %{
        "stats" => [%{"key" => key, "stat" => %{"value" => value}}]
      }

      Map.update!(player, "stats", &(&1 ++ [group]))
    end
  end

  defp stat_entries!(entries) when is_list(entries), do: entries
  defp stat_entries!(entries) when is_map(entries), do: Map.values(entries)
  defp stat_entries!(entries), do: list!(entries)

  defp maybe_normalize_position(%{"positionId" => position} = player) when not is_nil(position),
    do: Map.put(player, "positionId", source_id!(position))

  defp maybe_normalize_position(player), do: player
end
