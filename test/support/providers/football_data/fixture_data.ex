defmodule FootballMarket.Providers.FootballData.FixtureData do
  @moduledoc false
  @external_resource "test/fixtures/football_data/cases.exs"
  def cases, do: "test/fixtures/football_data/cases.exs" |> Code.eval_file() |> elem(0)
  def expected, do: "test/fixtures/football_data/expected.exs" |> Code.eval_file() |> elem(0)
  def base, do: "test/fixtures/football_data/exchanges.exs" |> Code.eval_file() |> elem(0)

  def request(c),
    do:
      Map.get(c, :request, %{
        league_code: Map.get(c, :league, "PL"),
        start_year: 2026,
        end_year: if(c[:variant] == :calendar, do: 2026, else: 2027)
      })
      |> Map.put(:timeout_ms, Map.get(c, :timeout, 5000))

  def response(route, c, count) do
    b = base()
    code = request(c).league_code
    discovery = b.discovery |> Map.put("code", code)

    discovery =
      if c[:variant] == :calendar,
        do:
          discovery
          |> put_in(["currentSeason", "endDate"], "2026-12-31")
          |> put_in(["seasons", Access.at(0), "endDate"], "2026-12-31"),
        else: discovery

    value =
      case route do
        {:discovery, ^code} ->
          discovery

        {:teams, ^code, 2026} ->
          b.teams |> put_in(["competition", "code"], code)

        {:team, id} ->
          b.team
          |> Map.put("id", id)
          |> put_in(["runningCompetitions", Access.at(0), "code"], code)

        {:person, id} ->
          b.person |> Map.put("id", id)
      end

    value = mutate(value, route, c[:variant], count)

    cond do
      c[:variant] == :quota and count == 11 ->
        {:ok, %{status: 429, headers: [], body: "ignored"}}

      c[:variant] == :multi_late and count == 8 ->
        {:error, :unavailable}

      c[:variant] == :late_failure and count == 5 ->
        {:error, :unavailable}

      c[:transport_error] ->
        {:error, c.transport_error}

      true ->
        {:ok,
         %{
           status: Map.get(c, :status, 200),
           headers: Map.get(c, :headers, []),
           body: if(c[:variant] == :bad_json, do: "{", else: Jason.encode!(value))
         }}
    end
  end

  defp mutate(v, {:teams, _, _}, variant, _)
       when variant in [:multi, :multi_late, :cross_duplicate],
       do: %{
         v
         | "count" => 2,
           "teams" => for(i <- 1..2, do: %{"id" => i, "name" => "Club #{i}", "tla" => "T#{i}"})
       }

  defp mutate(v, {:team, id}, variant, _) when variant in [:multi, :multi_late, :cross_duplicate],
    do: %{
      v
      | "name" => "Club #{id}",
        "tla" => "T#{id}",
        "squad" => [
          %{
            "id" => if(variant == :cross_duplicate and id == 2, do: 1001, else: id * 1000 + 1),
            "name" => "Alex Example",
            "position" => "Goalkeeper"
          },
          %{"id" => id * 1000 + 2, "name" => "Alex Example", "position" => "Defence"}
        ]
    }

  defp mutate(v, {:person, id}, variant, _)
       when variant in [:multi, :multi_late, :cross_duplicate],
       do: put_in(v, ["currentTeam", "id"], div(id, 1000))

  defp mutate(v, {:discovery, _}, :final_absent, n) when n > 1,
    do: Map.put(v, "seasons", [List.last(v["seasons"])])

  defp mutate(v, {:discovery, _}, :discovery_duplicate, _),
    do: Map.put(v, "seasons", v["seasons"] ++ v["seasons"])

  defp mutate(v, {:teams, _, _}, :list_count, _), do: Map.put(v, "count", 2)
  defp mutate(v, {:teams, _, _}, :list_season, _), do: put_in(v, ["filters", "season"], "2025")
  defp mutate(v, {:teams, _, _}, :list_competition, _), do: put_in(v, ["competition", "id"], 99)
  defp mutate(v, {:team, _}, :team_name, _), do: Map.put(v, "name", "Other Club")
  defp mutate(v, {:team, _}, :team_membership, _), do: Map.delete(v, "runningCompetitions")
  defp mutate(v, {:team, _}, :null_name, _), do: put_in(v, ["squad", Access.at(0), "name"], nil)

  defp mutate(v, {:team, _}, :null_position, _),
    do: put_in(v, ["squad", Access.at(0), "position"], nil)

  defp mutate(v, {:team, _}, :blank_position, _),
    do: put_in(v, ["squad", Access.at(0), "position"], " ")

  defp mutate(v, {:team, _}, :zero_id, _), do: put_in(v, ["squad", Access.at(0), "id"], 0)
  defp mutate(v, {:team, _}, :boolean_id, _), do: put_in(v, ["squad", Access.at(0), "id"], true)

  defp mutate(v, {:team, _}, :secret_id, _),
    do: put_in(v, ["squad", Access.at(0), "id"], "FD_SYNTHETIC_SENTINEL")

  defp mutate(v, {:person, _}, :null_current, _), do: Map.put(v, "currentTeam", nil)

  defp mutate(v, {:person, _}, :person_membership, _),
    do: put_in(v, ["currentTeam", "runningCompetitions"], [%{"id" => 99, "code" => "PL"}])

  defp mutate(v, {:discovery, _}, :bad_dates, _),
    do: put_in(v, ["currentSeason", "startDate"], "bad")

  defp mutate(v, {:discovery, _}, :rollover, n) when n > 1,
    do: put_in(v, ["currentSeason", "id"], 49)

  defp mutate(v, {:teams, _, _}, :empty_teams, _), do: %{v | "teams" => [], "count" => 0}
  defp mutate(v, {:teams, _, _}, :missing_teams, _), do: Map.delete(v, "teams")

  defp mutate(v, {:teams, _, _}, :duplicate_team, _),
    do: %{v | "teams" => v["teams"] ++ v["teams"], "count" => 2}

  defp mutate(v, {:teams, _, _}, :truncated, _), do: Map.put(v, "next", "https://evil.example")

  defp mutate(v, {:teams, _, _}, variant, _) when variant in [:large, :quota],
    do: %{
      v
      | "count" => 20,
        "teams" => for(i <- 1..20, do: %{"id" => i, "name" => "Club #{i}", "tla" => "T#{i}"})
    }

  defp mutate(v, {:team, id}, variant, _) when variant in [:large, :quota],
    do: %{
      v
      | "name" => "Club #{id}",
        "tla" => "T#{id}",
        "squad" =>
          for(
            i <- 1..25,
            do: %{"id" => id * 1000 + i, "name" => "Player #{id}-#{i}", "position" => "Midfield"}
          )
    }

  defp mutate(v, {:person, id}, variant, _) when variant in [:large, :quota],
    do: put_in(v, ["currentTeam", "id"], div(id, 1000))

  defp mutate(v, {:team, _}, :empty_squad, _), do: Map.put(v, "squad", [])
  defp mutate(v, {:team, _}, :null_squad, _), do: Map.put(v, "squad", nil)

  defp mutate(v, {:team, _}, :duplicate_player, _),
    do: Map.put(v, "squad", v["squad"] ++ v["squad"])

  defp mutate(v, {:team, _}, :wrong_team, _), do: Map.put(v, "id", 11)

  defp mutate(v, {:team, _}, :wrong_competition, _),
    do: put_in(v, ["runningCompetitions", Access.at(0), "id"], 99)

  defp mutate(v, {:team, _}, :blank_tla, _), do: Map.put(v, "tla", " ")
  defp mutate(v, {:team, _}, :missing_name, _), do: Map.delete(v, "name")

  defp mutate(v, {:team, _}, :missing_position, _),
    do: update_in(v, ["squad", Access.at(0)], &Map.delete(&1, "position"))

  defp mutate(v, {:team, _}, :unknown_position, _),
    do: put_in(v, ["squad", Access.at(0), "position"], "Wizard")

  defp mutate(v, {:team, _}, :staff_row, _),
    do: put_in(v, ["squad", Access.at(0), "type"], "coach")

  defp mutate(v, {:team, _}, :bad_id, _),
    do: put_in(v, ["squad", Access.at(0), "id"], "https://evil.example")

  defp mutate(v, {:team, _}, :secret_name, _), do: Map.put(v, "name", "FD_SYNTHETIC_SENTINEL")
  defp mutate(v, {:person, _}, :stale_transfer, _), do: put_in(v, ["currentTeam", "id"], 11)
  defp mutate(v, {:person, _}, :missing_current_team, _), do: Map.delete(v, "currentTeam")
  defp mutate(v, {:person, _}, :wrong_person, _), do: Map.put(v, "id", 999)
  defp mutate(v, _, _, _), do: v
end
