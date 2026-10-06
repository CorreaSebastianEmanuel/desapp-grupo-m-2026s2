defmodule FootballMarket.Providers.FixtureSourceB do
  @moduledoc "Synthetic source B; no I/O, application startup or credentials."
  @behaviour FootballMarket.Providers.Adapter
  @keys %{
    "TEAM_GOALS" => :team_goals,
    "CANDIDATE" => :candidate,
    "FAILURE" => :failure,
    "CATEGORY" => :category,
    "RETRY_AFTER_MS" => :retry_after_ms,
    "ELAPSED_US" => :elapsed_us,
    "PORTIONS" => :portions,
    "OPERATION" => :operation,
    "SCOPE" => :scope,
    "LEAGUE_CODE" => :league_code,
    "START_YEAR" => :start_year,
    "END_YEAR" => :end_year,
    "FROM" => :from,
    "TO" => :to,
    "FACTS" => :facts,
    "LEAGUE" => :league,
    "SEASON" => :season,
    "TEAMS" => :teams,
    "POSITIONS" => :positions,
    "PLAYERS" => :players,
    "MATCHES" => :matches,
    "PERFORMANCES" => :performances,
    "BINDINGS" => :bindings,
    "FIXTURE_ID" => :fixture_id,
    "REF" => :ref,
    "CODE" => :code,
    "NAME" => :name,
    "LEAGUE_REF" => :league_ref,
    "SEASON_REF" => :season_ref,
    "DISPLAY_NAME" => :display_name,
    "TEAM_REF" => :team_ref,
    "POSITION_REF" => :position_ref,
    "KIND" => :kind,
    "SOURCE_ID" => :source_id,
    "STATUS" => :status,
    "KICKOFF_AT" => :kickoff_at,
    "HOME_TEAM_REF" => :home_team_ref,
    "AWAY_TEAM_REF" => :away_team_ref,
    "MATCH_REF" => :match_ref,
    "PLAYER_REF" => :player_ref,
    "MINUTES_PLAYED" => :minutes_played,
    "COUNTS" => :counts,
    "GOALS" => :goals,
    "ASSISTS" => :assists,
    "SHOTS_ON_TARGET" => :shots_on_target,
    "TACKLES" => :tackles,
    "INTERCEPTIONS" => :interceptions,
    "SAVES" => :saves,
    "GOALS_CONCEDED" => :goals_conceded,
    "YELLOW_CARDS" => :yellow_cards,
    "RED_CARDS" => :red_cards,
    "RATING" => :rating,
    "THROW" => :throw,
    "DELAY_US" => :delay_us
  }
  @external_resource "test/fixtures/providers/source_b.exs"
  @examples "test/fixtures/providers/source_b.exs" |> Code.eval_file() |> elem(0)
  def provider_label, do: "synthetic-b"
  def source_key, do: :b
  def example_ids, do: Map.keys(@examples)

  def read(request, context, id) do
    raw = Map.fetch!(@examples, id)
    {:packet, cells, _ignored_totals_and_rating} = raw
    data = decode(cells)
    FootballMarket.Providers.FixtureRuntime.advance(data.elapsed_us)
    candidate = data.candidate
    if Map.has_key?(candidate, :throw), do: raise("FAKE_SENTINEL")
    portions = Enum.reverse(data.portions)

    outcome =
      if Map.has_key?(candidate, :failure),
        do: {:error, candidate.failure},
        else: {:ok, candidate}

    outcome =
      Enum.reduce_while(portions, outcome, fn portion, {:ok, accumulated} ->
        FootballMarket.Providers.FixtureRuntime.advance(portion.delay_us)

        if Map.has_key?(portion, :failure) do
          {:halt, {:error, portion.failure}}
        else
          facts =
            Enum.reduce(Map.get(portion, :facts, %{}), accumulated.facts, fn {kind, rows},
                                                                             facts ->
              Map.update!(facts, kind, &(&1 ++ rows))
            end)

          {:cont, {:ok, %{accumulated | facts: facts}}}
        end
      end)

    _ = context.deadline_us

    case outcome do
      {:ok, response} -> {:ok, Map.put(response, :scope, request.scope)}
      {:error, error} -> {:error, error}
    end
  end

  defp decode({:cells, pairs}),
    do: Map.new(pairs, fn {k, v} -> {Map.fetch!(@keys, k), decode(v)} end)

  defp decode({:rows, rows}), do: Enum.map(rows, &decode/1)
  defp decode(value), do: value
end
