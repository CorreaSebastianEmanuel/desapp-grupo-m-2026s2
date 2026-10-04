defmodule FootballMarket.Statistics do
  @moduledoc "Provider-neutral, immutable local completed-match facts."
  alias FootballMarket.{Repo, Catalog.Player, Catalog.Team, Catalog.Season, Catalog.Position}
  alias FootballMarket.Statistics.{Input, Error, Match, Performance, Query}

  def record_match(attrs),
    do: transact(fn -> with {:ok, attrs} <- Input.match(attrs), do: insert_match(attrs) end)

  def record_performance(attrs),
    do:
      transact(fn ->
        with {:ok, attrs} <- Input.performance(attrs), do: insert_performance(attrs)
      end)

  defp insert_match(attrs) do
    with {:ok, season} <- reference(Season, attrs.season_id, :season_id),
         {:ok, home} <- reference(Team, attrs.home_team_id, :home_team_id),
         {:ok, away} <- reference(Team, attrs.away_team_id, :away_team_id),
         :ok <- same_season(home, season.id, :home_team_id),
         :ok <- same_season(away, season.id, :away_team_id),
         :ok <- distinct(home, away) do
      attrs = Map.put(attrs, :match_identity, Query.trim_identity(attrs.match_identity))
      attrs |> Match.changeset(season) |> Repo.insert() |> inserted()
    end
  end

  defp insert_performance(attrs) do
    with {:ok, match} <- reference(Match, attrs.match_id, :match_id),
         {:ok, player} <- reference(Player, attrs.player_id, :player_id),
         {:ok, team} <- reference(Team, attrs.team_id, :team_id),
         {:ok, _} <- reference(Position, attrs.position_id, :position_id),
         :ok <- same_season(player, match.season_id, :player_id),
         :ok <- same_season(team, match.season_id, :team_id),
         :ok <- participant(team.id, match) do
      attrs |> Performance.changeset(match) |> Repo.insert() |> inserted()
    end
  end

  defp inserted({:ok, record}), do: {:ok, record}
  defp inserted({:error, cs}), do: Error.changeset(cs)

  defp reference(schema, id, field) do
    case Repo.get(schema, id) do
      nil -> Error.validation(field, :missing_reference)
      row -> {:ok, row}
    end
  end

  defp same_season(%{season_id: id}, id, _), do: :ok
  defp same_season(_, _, field), do: Error.validation(field, :season_mismatch)
  defp distinct(%{id: id}, %{id: id}), do: Error.validation(:away_team_id, :identical_teams)
  defp distinct(_, _), do: :ok

  defp participant(id, %{home_team_id: home, away_team_id: away}) do
    if id in [home, away], do: :ok, else: Error.validation(:team_id, :nonparticipant)
  end

  defp transact(fun) do
    multi = Ecto.Multi.new() |> Ecto.Multi.run(:result, fn _, _ -> fun.() end)

    case Repo.transaction(multi) do
      {:ok, %{result: record}} -> {:ok, record}
      {:error, :result, error, _} -> {:error, error}
    end
  end

  def get_match(id), do: get(Match, id, :match_id)

  def get_match(season_id, identity) do
    with {:ok, season_id} <- Input.identifier(season_id, :season_id),
         {:ok, identity} <- Input.identity(identity),
         {:ok, _} <- get(Season, season_id, :season_id) do
      case Repo.one(Query.match_identity(season_id, identity)) do
        nil -> {:error, :not_found}
        match -> {:ok, match}
      end
    end
  end

  def get_performance(player_id, match_id) do
    with {:ok, player_id} <- Input.identifier(player_id, :player_id),
         {:ok, match_id} <- Input.identifier(match_id, :match_id),
         {:ok, player} <- get(Player, player_id, :player_id),
         {:ok, match} <- get(Match, match_id, :match_id) do
      case Repo.one(Query.pair(player.id, match.id)) do
        nil -> {:error, :absent_performance}
        performance -> {:ok, performance}
      end
    end
  end

  defp get(schema, id, field) do
    with {:ok, id} <- Input.identifier(id, field) do
      case Repo.get(schema, id) do
        nil -> {:error, :not_found}
        record -> {:ok, record}
      end
    end
  end

  def record_batch(envelopes) when is_list(envelopes) do
    transact(fn ->
      Enum.with_index(envelopes)
      |> Enum.reduce_while({:ok, []}, fn {envelope, index}, {:ok, results} ->
        case batch_envelope(envelope, index) do
          {:ok, result} -> {:cont, {:ok, [result | results]}}
          error -> {:halt, error}
        end
      end)
      |> case do
        {:ok, results} -> {:ok, Enum.reverse(results)}
        error -> error
      end
    end)
  end

  def record_batch(_), do: Error.validation(:batch, :invalid_shape)

  defp batch_envelope(envelope, index) do
    with {:ok, envelope} <- Input.keys(envelope, [:match, :performances]),
         :ok <- batch_shape(envelope),
         {:ok, attrs} <- Input.match(envelope.match),
         {:ok, match} <- insert_match(attrs) do
      Enum.with_index(envelope.performances)
      |> Enum.reduce_while({:ok, []}, fn {performance, pi}, {:ok, rows} ->
        with {:ok, attrs} <-
               Input.keys(
                 performance,
                 [:player_id, :team_id, :position_id, :minutes_played] ++ Input.metrics()
               ),
             {:ok, attrs} <- Input.performance(Map.put(attrs, :match_id, match.id)),
             {:ok, row} <- insert_performance(attrs) do
          {:cont, {:ok, [row | rows]}}
        else
          error -> {:halt, Error.at(error, index, pi)}
        end
      end)
      |> case do
        {:ok, rows} -> {:ok, %{match: match, performances: Enum.reverse(rows)}}
        error -> error
      end
    else
      error -> Error.at(error, index, nil)
    end
  end

  defp batch_shape(%{match: _, performances: rows}) when is_list(rows), do: :ok
  defp batch_shape(_), do: Error.validation(:batch, :invalid_shape)

  def update_match(id, _attrs), do: immutable(Match, id, :match_id)
  def delete_match(id), do: immutable(Match, id, :match_id)
  def update_performance(id, _attrs), do: immutable(Performance, id, :performance_id)
  def delete_performance(id), do: immutable(Performance, id, :performance_id)

  defp immutable(schema, id, field) do
    with {:ok, _} <- get(schema, id, field), do: {:error, :immutable}
  end

  def list_player_history(player_id, opts \\ []) do
    with {:ok, id} <- Input.identifier(player_id, :player_id),
         {:ok, bounds} <- Input.bounds(opts),
         {:ok, _} <- get(Player, id, :player_id) do
      {:ok, Repo.all(Query.history(id, bounds))}
    end
  end
end
