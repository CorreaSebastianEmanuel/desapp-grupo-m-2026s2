defmodule FootballMarket.Providers.Scraping.Source do
  @moduledoc "Synchronous portion reader with assessed completeness and one absolute deadline."
  alias FootballMarket.Providers.Scraping.{Assessment, Translator}

  def read(request, context, state, revision) do
    with {:ok, _, row} <- Assessment.admit(request, state, revision) do
      try do
        {facts, complete_empty} =
          case request.operation do
            :catalog -> {catalog(request, context, state, revision, row), false}
            :performances -> performances(request, context, state, revision, row)
          end

        bindings = Translator.bindings(facts, row)

        with {:ok, _, _} <- Assessment.admit(request, state, revision) do
          budget!(context)

          completeness =
            if request.operation == :performances and
                 is_nil(request.scope.from) and is_nil(request.scope.to) and
                 (Map.get(facts, :matches, []) != [] or complete_empty) do
              matches = Map.get(facts, :matches, [])

              identities =
                for match <- matches do
                  Enum.find_value(bindings, fn binding ->
                    if binding.kind == :match and binding.ref == match.ref, do: binding.source_id
                  end)
                end

              %{
                version: 1,
                scope: request.scope,
                full_scope: is_nil(request.scope.from) and is_nil(request.scope.to),
                terminal_witness: row.witness,
                eligible_match_identities: identities,
                detail_coverage: identities,
                assessment_revision: to_string(revision),
                assessment_reference: state.fixture_id || "assessment:" <> to_string(revision),
                complete_empty: identities == [] and complete_empty
              }
            end

          {:ok,
           %{
             operation: request.operation,
             scope: request.scope,
             facts: facts,
             bindings: bindings,
             fixture_id: state.fixture_id,
             completeness: completeness
           }}
        end
      rescue
        _ -> {:error, %{category: :invalid_response}}
      catch
        {:source_failure, failure} -> {:error, failure}
        {:invalid, _} -> {:error, %{category: :invalid_response}}
      end
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

  def portion!(key, request, context, state, revision, row) do
    budget!(context)

    case Assessment.admit(request, state, revision) do
      {:ok, _, _} -> :ok
      {:error, failure} -> throw({:source_failure, failure})
    end

    require!(state[:repeat] != true)
    # Fixtures are the sole enabled transport in this delivery.
    transport = FootballMarket.Providers.Scraping.FixtureTransport

    case fetch(transport, key, context, state) do
      {:error, failure} ->
        throw({:source_failure, failure})

      {:ok, %{body: body, observation: o}} ->
        budget!(context)

        case Assessment.admit(request, state, revision) do
          {:ok, _, _} -> :ok
          {:error, failure} -> throw({:source_failure, failure})
        end

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
    require!(is_map(decoded))

    if Map.has_key?(decoded, "props"),
      do: get_in(decoded, ["props", "pageProps"]) |> map!(),
      else: decoded
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
end
