defmodule FootballMarket.Providers.Scraping.Source do
  @moduledoc "Synchronous portion reader with assessed completeness and one absolute deadline."
  alias FootballMarket.Providers.Scraping.{Assessment, Translator}

  def read(request, context, state, revision) do
    with {:ok, _, row} <- Assessment.admit(request, state, revision) do
      try do
        {facts, complete_empty, execution_state} =
          case request.operation do
            :catalog -> {catalog(request, context, state, revision, row), false, state}
            :performances -> performances(request, context, state, revision, row)
          end

        bindings = Translator.bindings(facts, row)

        publish_result(
          request,
          context,
          execution_state,
          revision,
          row,
          facts,
          bindings,
          complete_empty
        )
      rescue
        _error ->
          {:error, %{category: :invalid_response}}
      catch
        {:source_failure, failure} ->
          {:error, failure}

        {:invalid, _field} ->
          {:error, %{category: :invalid_response}}
      end
    end
  end

  defp publish_result(request, context, state, revision, row, facts, bindings, complete_empty) do
    with {:ok, _, _} <- Assessment.admit(request, state, revision) do
      budget!(context)
      completeness = completeness(request, state, revision, row, facts, bindings, complete_empty)

      {:ok,
       %{
         operation: request.operation,
         scope: request.scope,
         facts: facts,
         bindings: bindings,
         fixture_id: state[:fixture_id],
         completeness: completeness
       }}
    end
  end

  defp completeness(request, state, revision, row, facts, bindings, complete_empty) do
    if request.operation == :performances and is_nil(request.scope.from) and
         is_nil(request.scope.to) and (Map.get(facts, :matches, []) != [] or complete_empty) do
      identities = eligible_match_identities(facts, bindings)

      %{
        version: 1,
        scope: request.scope,
        full_scope: if(is_binary(state[:player_source_id]), do: "player", else: true),
        terminal_witness: row.witness,
        eligible_match_identities: identities,
        detail_coverage: identities,
        assessment_revision: to_string(revision),
        assessment_reference: state[:fixture_id] || "assessment:" <> to_string(revision),
        complete_empty: identities == [] and complete_empty
      }
    end
  end

  defp eligible_match_identities(facts, bindings) do
    for match <- Map.get(facts, :matches, []) do
      match_identity(bindings, match)
    end
  end

  defp catalog(request, context, state, revision, row) do
    data = portion!("catalog", request, context, state, revision, row)
    require!(data["competition"] == %{"id" => row.competition, "season" => row.season})
    teams = list!(data["teams"])

    rosters =
      Enum.map(teams, fn team ->
        d = portion!("roster:" <> id!(team["id"]), request, context, state, revision, row)
        require!(d["teamId"] == team["id"] and d["season"] == row.season)
        {team["id"], list!(d["players"])}
      end)

    Translator.catalog(request, context, row, teams, rosters)
  end

  defp performances(request, context, state, revision, row) do
    if is_binary(state[:player_source_id]) or
         (is_binary(state[:player_name]) and is_binary(state[:player_team_name])) do
      player_performances(request, context, state, revision, row)
    else
      {facts, complete_empty} = league_performances(request, context, state, revision, row)
      {facts, complete_empty, state}
    end
  end

  defp league_performances(request, context, state, revision, row) do
    schedule = portion!("schedule", request, context, state, revision, row)

    require!(
      schedule["details"]["leagueId"] == row.competition and
        schedule["details"]["selectedSeason"] == row.season
    )

    matches = list!(schedule["fixtures"]["allMatches"])
    selected = Enum.filter(matches, &Translator.eligible!(&1, request))

    complete_empty = selected == [] and schedule["completeEmpty"] == true

    details =
      Enum.map(selected, fn match ->
        data = portion!("match:" <> id!(match["id"]), request, context, state, revision, row)
        general = map!(data["general"])

        require!(
          general["matchId"] == match["id"] and general["parentLeagueId"] == row.competition and
            general["season"] == row.season and general["finished"] == true and
            general["homeTeam"]["id"] == match["home"] and
            general["awayTeam"]["id"] == match["away"]
        )

        {:ok, actual} = FootballMarket.Providers.Instant.normalize(general["matchTimeUTCDate"])
        {:ok, discovered} = FootballMarket.Providers.Instant.normalize(match["kickoff"])
        require!(DateTime.compare(actual, discovered) == :eq)
        stats = map!(data["content"]["playerStats"])
        {match, Map.values(stats)}
      end)

    {Translator.performances(request, context, row, list!(schedule["teams"]), details),
     complete_empty}
  end

  defp player_performances(request, context, state, revision, row) do
    player_id =
      state[:player_source_id] || discover_player_id!(request, context, state, revision, row)

    state = Map.put(state, :player_source_id, player_id)
    profile = portion!("player_data:" <> player_id, request, context, state, revision, row)
    profile_data = map!(profile["data"] || profile)
    require!(source_id!(profile_data["id"]) == player_id)
    validate_profile_season!(profile_data, request, row)
    page = map!(profile_data["initialMatchesPage"])
    recent = list!(profile_data["recentMatches"] || page["matches"])

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

    scoped_profile_rows =
      Enum.filter(recent, fn match ->
        match["playedInMatch"] == true and
          source_id!(match["leagueId"]) == source_id!(row.competition) and
          in_season_window?(get_in(match, ["matchDate", "utcTime"]), request.scope)
      end)

    details =
      Enum.map(scoped_profile_rows, fn profile_row ->
        match_id = source_id!(profile_row["id"])

        {:ok, kickoff} =
          FootballMarket.Providers.Instant.normalize(
            get_in(profile_row, ["matchDate", "utcTime"])
          )

        home = profile_row["isHomeTeam"] == true

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
              if is_integer(value),
                do: [%{"stats" => [%{"key" => key, "stat" => %{"value" => value}}]}],
                else: []
            end)
        }

        {match_id, general, %{player_id => stats}, kickoff}
      end)

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

    translation_row =
      player_position_row(
        row,
        state[:player_position_code],
        scoped_profile_rows,
        selected,
        player_id
      )

    translated =
      Enum.map(selected, fn {match_id, general, player_stats, _kickoff} ->
        match = %{
          "id" => match_id,
          "status" => "completed",
          "kickoff" => general["matchTimeUTCDate"],
          "home" => source_id!(general["homeTeam"]["id"]),
          "away" => source_id!(general["awayTeam"]["id"])
        }

        numeric_player_id =
          case Integer.parse(player_id) do
            {value, ""} -> value
            _ -> nil
          end

        players = Map.get(player_stats, player_id) || Map.get(player_stats, numeric_player_id)

        if is_map(players) do
          profile_row = Enum.find(scoped_profile_rows, &(source_id!(&1["id"]) == match_id))

          player =
            players
            |> Map.put_new("id", player_id)
            |> Map.put_new("currentTeamId", players["teamId"])
            |> put_historical_position(profile_row["lineupPositionId"])
            |> put_profile_metric(profile_row, "yellow_cards", "yellowCards")
            |> put_profile_metric(profile_row, "red_cards", "redCards")
            |> Map.update!("id", &source_id!/1)
            |> Map.update!("teamId", &source_id!/1)
            |> Map.update!("currentTeamId", &source_id!/1)
            |> maybe_normalize_position()

          {match, [player]}
        else
          {match, []}
        end
      end)

    teams =
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

    facts = Translator.performances(request, context, translation_row, teams, translated)
    eligible_ids = Enum.map(selected, fn {match_id, _, _, _} -> match_id end)

    {facts, eligible_ids == [], state}
  end

  defp player_position_row(row, position_code, profile_rows, details, player_id)
       when is_binary(position_code) do
    ids =
      Enum.flat_map(details, fn {match_id, _general, stats, _kickoff} ->
        profile_row = Enum.find(profile_rows, &(source_id!(&1["id"]) == match_id))
        player = Map.get(stats, player_id)

        [
          profile_row["lineupPositionId"],
          player && player["usualPosition"],
          player && player["positionId"]
        ]
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&source_id!/1)
      |> Enum.uniq()

    positions = Enum.reduce(ids, row.positions, &Map.put_new(&2, &1, position_code))

    positions =
      if FootballMarket.Providers.Provenance.safe_text?(position_code) do
        Map.put_new(positions, "catalog-position:" <> position_code, position_code)
      else
        positions
      end

    %{row | positions: positions}
  end

  defp player_position_row(row, _position_code, _profile_rows, _details, _player_id), do: row

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

    groups =
      portion!("player_search:" <> player_name, request, context, state, revision, row)
      |> list!()

    candidates =
      groups
      |> Enum.flat_map(fn group -> list!(group["suggestions"] || []) end)
      |> Enum.filter(fn candidate ->
        candidate["type"] == "player" and
          normalized_identity(candidate["name"]) == normalized_identity(player_name) and
          normalized_team(candidate["teamName"]) == normalized_team(team_name)
      end)
      |> Enum.uniq_by(&source_id!(&1["id"]))

    case candidates do
      [candidate] -> source_id!(candidate["id"])
      _ -> throw({:invalid, :player_identity})
    end
  end

  defp normalized_identity(value) when is_binary(value) do
    value
    |> String.downcase()
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.split()
    |> Enum.join(" ")
  end

  defp normalized_identity(_), do: ""

  defp normalized_team(value) do
    value
    |> normalized_identity()
    |> String.split()
    |> Enum.reject(
      &(&1 in ["fc", "afc", "sc", "sv", "fsv", "tsg", "vfb", "1", "04", "05", "07", "1899"])
    )
    |> Enum.join(" ")
  end

  def portion!(key, request, context, state, revision, row) do
    budget!(context)

    admit!(request, state, revision)

    require!(state[:repeat] != true)
    transport = state.transport

    fetch_state =
      state
      |> Map.put(:request, request)
      |> Map.put(:assessment_revision, revision)

    case fetch(transport, key, context, fetch_state) do
      {:error, failure} ->
        throw({:source_failure, failure})

      {:ok, %{body: body, observation: o}} ->
        budget!(context)

        admit!(request, state, revision)

        a = Assessment.current(state)

        if o[:destination] not in a.destinations,
          do: throw({:source_failure, %{category: :unsupported_capability}})

        require!(o[:terminal] == true and o[:witness] == row.witness)
        decode!(body)

      _ ->
        throw({:invalid, :scope})
    end
  end

  defp fetch(transport, key, context, state) do
    try do
      transport.fetch(key, context, state)
    rescue
      _ -> {:error, %{category: :unavailable}}
    catch
      _, _ -> {:error, %{category: :unavailable}}
    end
  end

  def decode!(body) when is_binary(body) do
    raw =
      if String.starts_with?(String.trim_leading(body), "<") do
        case Regex.scan(~r/<script\b[^>]*\bid=["']__NEXT_DATA__["'][^>]*>(.*?)<\/script>/s, body) do
          [[_, json]] -> json
          _ -> throw({:invalid, :scope})
        end
      else
        body
      end

    {:ok, decoded} = Jason.decode(raw)

    case decoded do
      %{"props" => _props} -> get_in(decoded, ["props", "pageProps"]) |> map!()
      value when is_map(value) or is_list(value) -> value
      _ -> throw({:invalid, :scope})
    end
  end

  def decode!(_), do: throw({:invalid, :scope})

  def budget!(context) do
    {runtime, state} = context.runtime

    if runtime.now_us(state) >= context.deadline_us,
      do: throw({:source_failure, %{category: :timeout}})
  end

  def require!(v), do: if(v != true, do: throw({:invalid, :scope}))

  def map!(v) do
    require!(is_map(v))
    v
  end

  def list!(v) do
    require!(is_list(v))
    v
  end

  def id!(v) do
    require!(FootballMarket.Providers.Provenance.safe_text?(v))
    v
  end

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

    DateTime.compare(instant, boundary) != :lt and DateTime.compare(instant, ending) == :lt
  end

  defp validate_profile_season!(profile, request, row) do
    seasons = list!(profile["statSeasons"])

    found =
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

    unless found do
      throw({:source_failure, %{category: :unsupported_capability}})
    end
  end

  defp put_historical_position(player, position_id) do
    if not is_nil(position_id),
      do: Map.put(player, "positionId", source_id!(position_id)),
      else: player
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

  defp admit!(request, state, revision) do
    case Assessment.admit(request, state, revision) do
      {:ok, _, _} -> :ok
      {:error, failure} -> throw({:source_failure, failure})
    end
  end

  defp match_identity(bindings, match) do
    Enum.find_value(bindings, fn binding ->
      if binding.kind == :match and binding.ref == match.ref, do: binding.source_id
    end)
  end
end
