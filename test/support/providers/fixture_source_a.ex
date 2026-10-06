defmodule FootballMarket.Providers.FixtureSourceA do
  @moduledoc "Synthetic source A; no I/O, application startup or credentials."
  @behaviour FootballMarket.Providers.Adapter
  @keys %{
    "team_goals" => :team_goals,
    "candidate" => :candidate,
    "failure" => :failure,
    "category" => :category,
    "retry_after_ms" => :retry_after_ms,
    "elapsed_us" => :elapsed_us,
    "portions" => :portions,
    "operation" => :operation,
    "scope" => :scope,
    "league_code" => :league_code,
    "start_year" => :start_year,
    "end_year" => :end_year,
    "from" => :from,
    "to" => :to,
    "facts" => :facts,
    "league" => :league,
    "season" => :season,
    "teams" => :teams,
    "positions" => :positions,
    "players" => :players,
    "matches" => :matches,
    "performances" => :performances,
    "bindings" => :bindings,
    "fixture_id" => :fixture_id,
    "ref" => :ref,
    "code" => :code,
    "name" => :name,
    "league_ref" => :league_ref,
    "season_ref" => :season_ref,
    "display_name" => :display_name,
    "team_ref" => :team_ref,
    "position_ref" => :position_ref,
    "kind" => :kind,
    "source_id" => :source_id,
    "status" => :status,
    "kickoff_at" => :kickoff_at,
    "home_team_ref" => :home_team_ref,
    "away_team_ref" => :away_team_ref,
    "match_ref" => :match_ref,
    "player_ref" => :player_ref,
    "minutes_played" => :minutes_played,
    "counts" => :counts,
    "goals" => :goals,
    "assists" => :assists,
    "shots_on_target" => :shots_on_target,
    "tackles" => :tackles,
    "interceptions" => :interceptions,
    "saves" => :saves,
    "goals_conceded" => :goals_conceded,
    "yellow_cards" => :yellow_cards,
    "red_cards" => :red_cards,
    "rating" => :rating,
    "throw" => :throw,
    "delay_us" => :delay_us
  }
  @external_resource "test/fixtures/providers/source_a.exs"
  @examples "test/fixtures/providers/source_a.exs" |> Code.eval_file() |> elem(0)
  def provider_label, do: "synthetic-a"
  def source_key, do: :a
  def example_ids, do: Map.keys(@examples)

  def read(request, context, id) do
    raw = Map.fetch!(@examples, id)
    data = decode(Map.fetch!(raw, "document"))
    FootballMarket.Providers.FixtureRuntime.advance(data.elapsed_us)
    candidate = data.candidate
    if Map.has_key?(candidate, :throw), do: raise("FAKE_SENTINEL")
    portions = data.portions

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

  defp decode(value) when is_map(value),
    do: Map.new(value, fn {k, v} -> {Map.fetch!(@keys, k), decode(v)} end)

  defp decode(value) when is_list(value), do: Enum.map(value, &decode/1)
  defp decode(value), do: value
end
