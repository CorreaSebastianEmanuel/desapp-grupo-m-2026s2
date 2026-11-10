defmodule FootballMarket.Providers.Scraping.Source do
  @moduledoc "Synchronous portion reader with assessed completeness and one absolute deadline."
  alias FootballMarket.Providers.Scraping.{Assessment, Translator, PlayerProfile}

  alias FootballMarket.Providers.Scraping.Document

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
      Document.budget!(context)
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
    data = Document.portion!("catalog", request, context, state, revision, row)
    Document.require!(data["competition"] == %{"id" => row.competition, "season" => row.season})
    teams = Document.list!(data["teams"])

    rosters =
      Enum.map(teams, fn team ->
        d =
          Document.portion!(
            "roster:" <> Document.id!(team["id"]),
            request,
            context,
            state,
            revision,
            row
          )

        Document.require!(d["teamId"] == team["id"] and d["season"] == row.season)
        {team["id"], Document.list!(d["players"])}
      end)

    Translator.catalog(request, context, row, teams, rosters)
  end

  defp performances(request, context, state, revision, row) do
    if is_binary(state[:player_source_id]) or
         (is_binary(state[:player_name]) and is_binary(state[:player_team_name])) do
      PlayerProfile.read(request, context, state, revision, row)
    else
      {facts, complete_empty} = league_performances(request, context, state, revision, row)
      {facts, complete_empty, state}
    end
  end

  defp league_performances(request, context, state, revision, row) do
    schedule = Document.portion!("schedule", request, context, state, revision, row)

    Document.require!(
      schedule["details"]["leagueId"] == row.competition and
        schedule["details"]["selectedSeason"] == row.season
    )

    matches = Document.list!(schedule["fixtures"]["allMatches"])
    selected = Enum.filter(matches, &Translator.eligible!(&1, request))

    complete_empty = selected == [] and schedule["completeEmpty"] == true

    details =
      Enum.map(selected, fn match ->
        data =
          Document.portion!(
            "match:" <> Document.id!(match["id"]),
            request,
            context,
            state,
            revision,
            row
          )

        general = Document.map!(data["general"])

        Document.require!(
          general["matchId"] == match["id"] and general["parentLeagueId"] == row.competition and
            general["season"] == row.season and general["finished"] == true and
            general["homeTeam"]["id"] == match["home"] and
            general["awayTeam"]["id"] == match["away"]
        )

        {:ok, actual} = FootballMarket.Providers.Instant.normalize(general["matchTimeUTCDate"])
        {:ok, discovered} = FootballMarket.Providers.Instant.normalize(match["kickoff"])
        Document.require!(DateTime.compare(actual, discovered) == :eq)
        stats = Document.map!(data["content"]["playerStats"])
        {match, Map.values(stats)}
      end)

    {Translator.performances(request, context, row, Document.list!(schedule["teams"]), details),
     complete_empty}
  end

  defp match_identity(bindings, match) do
    Enum.find_value(bindings, fn binding ->
      if binding.kind == :match and binding.ref == match.ref, do: binding.source_id
    end)
  end
end
