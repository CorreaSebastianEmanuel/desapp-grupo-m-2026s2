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
      reviewed_at: ~U[2026-10-07 00:00:00Z],
      scopes: rows
    }
  end

  def current(state),
    do:
      if(is_function(state[:assessment_reader], 0),
        do: state.assessment_reader.(),
        else: state[:assessment]
      )

  def admit(request, state, revision \\ nil) do
    a = current(state)

    now =
      if is_function(state[:assessment_clock], 0),
        do: state.assessment_clock.(),
        else: ~U[2026-10-07 00:00:00Z]

    s = request.scope
    key = {request.operation, s.league_code, s.start_year, s.end_year}

    with true <- is_map(a),
         true <- state[:mode] == :fixture and a[:mode] == :fixture,
         true <-
           permitted?(a),
         true <- is_binary(a[:evidence]) and a.evidence != "",
         %DateTime{} <- a[:reviewed_at],
         %DateTime{} <- a[:expires_at],
         true <- current_dates?(a, now),
         true <- compatible_revision?(a, revision),
         %{concurrency: n, volume: v, cadence_ms: c} <- a[:limits],
         true <- valid_limits?(n, v, c),
         true <- "fixture" in Map.get(a, :destinations, []),
         %{required: :verified, witness: w, positions: p, metrics: m} = row <-
           Map.get(a[:scopes] || %{}, key),
         true <- is_binary(w) and w != "" and is_map(p) and map_size(p) > 0,
         true <- valid_participation?(Map.get(row, :participation)),
         true <-
           valid_metrics?(m) do
      {:ok, a.revision, row}
    else
      _ -> {:error, %{category: :unsupported_capability}}
    end
  rescue
    _ -> {:error, %{category: :unsupported_capability}}
  catch
    _, _ -> {:error, %{category: :unsupported_capability}}
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
