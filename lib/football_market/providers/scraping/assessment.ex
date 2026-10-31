defmodule FootballMarket.Providers.Scraping.Assessment do
  @moduledoc "Dated scoped permission and semantic evidence. Fixtures cannot promote actual access."
  alias FootballMarket.Providers.{Request, Performances}

  @meanings %{
    goals: "ordinary player goals excluding own goals",
    assists: "player match assists",
    shots_on_target: "ordinary player attempts on target",
    tackles: "successful player tackles",
    interceptions: "opposition passes intercepted",
    saves: "goalkeeper saves",
    goals_conceded: "opposition goals while player on field",
    yellow_cards: "player yellow cards",
    red_cards: "player red cards"
  }
  def actual do
    rows =
      for code <- Map.keys(Request.leagues()),
          year <- [2024, 2025],
          operation <- [:catalog, :performances],
          into: %{} do
        {{operation, code, year, year + 1},
         %{
           required: :unverified,
           witness: nil,
           documents: %{},
           metrics:
             Map.new(
               Performances.count_keys(),
               &{&1, %{status: :unverified, meaning: @meanings[&1], evidence: nil}}
             )
         }}
      end

    %{
      mode: :live,
      revision: "blocked-1",
      permission: :missing,
      withdrawn: false,
      conditions: :unreviewed,
      evidence: nil,
      reviewed_at: ~U[2026-10-07 00:00:00Z],
      expires_at: nil,
      destinations: [],
      limits: %{concurrency: 1, volume: 1, cadence_ms: 60_000},
      scopes: rows
    }
  end

  def current(state) do
    cond do
      is_function(state[:assessment_reader], 0) -> state.assessment_reader.()
      not is_nil(state[:assessment]) -> state[:assessment]
      true -> Application.get_env(:football_market, :scraping_assessment, actual())
    end
  end

  def admit(request, state, revision \\ nil) do
    case admit_snapshot(request, state, revision) do
      {:ok, _assessment, admitted_revision, row} -> {:ok, admitted_revision, row}
      {:error, _} = error -> error
    end
  end

  def admit_snapshot(request, state, revision \\ nil) do
    a = current(state)
    now = assessment_now(state)

    s = request.scope
    key = {request.operation, s.league_code, s.start_year, s.end_year}

    with true <- is_map(a),
         true <- state[:mode] in [:fixture, :live] and a[:mode] == state[:mode],
         true <-
           permitted?(a),
         true <- is_binary(a[:evidence]) and a.evidence != "",
         %DateTime{} <- a[:reviewed_at],
         %DateTime{} <- a[:expires_at],
         true <- current_dates?(a, now),
         true <- compatible_revision?(a, revision),
         %{concurrency: n, volume: v, cadence_ms: c} <- a[:limits],
         true <- valid_limits?(n, v, c),
         true <- valid_destinations?(a[:destinations]),
         %{required: :verified, witness: w, positions: p, metrics: m} = row <-
           Map.get(a[:scopes] || %{}, key),
         true <- is_binary(w) and w != "" and is_map(p) and map_size(p) > 0,
         true <- valid_participation?(Map.get(row, :participation)),
         true <-
           valid_metrics?(m) do
      {:ok, a, a.revision, row}
    else
      _ -> {:error, %{category: :unsupported_capability}}
    end
  rescue
    _ -> {:error, %{category: :unsupported_capability}}
  catch
    _, _ -> {:error, %{category: :unsupported_capability}}
  end

  defp assessment_now(state) do
    cond do
      is_function(state[:assessment_clock], 0) -> state.assessment_clock.()
      state[:mode] == :fixture -> ~U[2026-10-07 00:00:00Z]
      true -> DateTime.utc_now()
    end
  end

  defp valid_participation?(nil), do: true
  defp valid_participation?(%{status: :unverified}), do: true

  defp valid_participation?(%{
         status: :verified,
         field: field,
         substitute_value: value,
         evidence: evidence
       }) do
    is_binary(field) and field in ["substitute", "participantRole"] and
      is_binary(value) and value == "substitute_entered" and
      is_binary(evidence) and String.trim(evidence) != ""
  end

  defp valid_participation?(_), do: false

  defp permitted?(assessment),
    do:
      assessment[:permission] == :granted and assessment[:withdrawn] == false and
        assessment[:conditions] == :satisfied

  defp valid_limits?(n, v, c),
    do: is_integer(n) and n > 0 and is_integer(v) and v > 0 and is_integer(c) and c >= 0

  defp valid_destinations?(destinations) when is_list(destinations) and destinations != [],
    do: Enum.all?(destinations, &valid_destination?/1)

  defp valid_destinations?(_), do: false

  defp valid_destination?("fixture"), do: true

  defp valid_destination?(destination) when is_binary(destination) do
    case URI.parse(destination) do
      %URI{scheme: "https", host: host, userinfo: nil, path: path, query: nil, fragment: nil}
      when is_binary(host) and host != "" and path in [nil, ""] ->
        true

      _ ->
        false
    end
  end

  defp valid_destination?(_), do: false

  defp valid_metrics?(metrics),
    do: Enum.all?(Performances.count_keys(), &valid_metric?(metrics[&1]))

  defp valid_metric?(%{status: :verified, evidence: evidence, meaning: meaning}),
    do: is_binary(evidence) and evidence != "" and is_binary(meaning) and meaning != ""

  defp valid_metric?(%{status: status}) when status in [:unavailable, :unverified], do: true
  defp valid_metric?(_), do: false

  defp current_dates?(assessment, now),
    do:
      DateTime.compare(now, assessment.expires_at) == :lt and
        DateTime.compare(assessment.reviewed_at, now) != :gt

  defp compatible_revision?(assessment, revision) do
    not is_nil(assessment[:revision]) and (is_nil(revision) or revision == assessment.revision)
  end
end
