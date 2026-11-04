defmodule FootballMarket.Statistics.Ingestion.FotMobBinding do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.{Repo, Catalog}
  alias FootballMarket.Catalog.Ingestion.SourceBinding

  def maybe_bind(result, kind, ref, source_id, scope, options) do
    maybe_bind_fotmob_scope(result, kind, source_id, scope) ||
      maybe_bind_fotmob_team(result, kind, ref, source_id, scope) ||
      maybe_bind_fotmob_player(result, kind, ref, source_id, scope, options)
  end

  defp maybe_bind_fotmob_scope(result, kind, source_id, scope)
       when result.provenance.provider == "fotmob-public-html-v1" and not is_nil(scope) and
              kind in ["league", "season"] do
    target_id = if kind == "league", do: scope.league_id, else: scope.season_id
    target_field = String.to_existing_atom(kind <> "_id")

    attrs =
      Map.merge(
        %{
          scope_id: scope.id,
          season_scope_id: scope.season_id,
          league_scope_id: scope.league_id,
          provider: result.provenance.provider,
          kind: kind,
          source_id: source_id
        },
        %{target_field => target_id}
      )

    case Repo.insert(SourceBinding.changeset(%SourceBinding{}, attrs)) do
      {:ok, binding} -> binding
      {:error, _changeset} -> nil
    end
  end

  defp maybe_bind_fotmob_scope(_, _, _, _), do: nil

  defp maybe_bind_fotmob_team(result, "team", ref, source_id, scope)
       when result.provenance.provider == "fotmob-public-html-v1" and not is_nil(scope) do
    case Enum.find(result.facts.teams, &(&1.ref == ref)) do
      %{name: name} when is_binary(name) ->
        target = unique_team_by_source_name(name, scope.season_id)

        if target do
          attrs = %{
            scope_id: scope.id,
            season_scope_id: scope.season_id,
            league_scope_id: scope.league_id,
            provider: result.provenance.provider,
            kind: "team",
            source_id: source_id,
            team_id: target.id
          }

          insert_source_binding(attrs)
        end

      _ ->
        nil
    end
  end

  defp maybe_bind_fotmob_team(_, _, _, _, _), do: nil

  defp maybe_bind_fotmob_player(result, "player", ref, source_id, scope, options)
       when result.provenance.provider == "fotmob-public-html-v1" and not is_nil(scope) do
    target_id = Keyword.get(options, :player_id)
    fact = Enum.find(result.facts.players, &(&1.ref == ref))
    target = if is_binary(target_id), do: Repo.get(Catalog.Player, target_id)

    if fact && target && target.season_id == scope.season_id &&
         normalized_player_name(fact.display_name) == normalized_player_name(target.display_name) do
      attrs = %{
        scope_id: scope.id,
        season_scope_id: scope.season_id,
        league_scope_id: scope.league_id,
        provider: result.provenance.provider,
        kind: "player",
        source_id: source_id,
        player_id: target.id
      }

      insert_source_binding(attrs)
    end
  end

  defp maybe_bind_fotmob_player(_, _, _, _, _, _), do: nil

  defp insert_source_binding(attrs) do
    case Repo.insert(SourceBinding.changeset(%SourceBinding{}, attrs)) do
      {:ok, binding} -> binding
      {:error, _changeset} -> nil
    end
  end

  defp unique_team_by_source_name(source_name, season_id) do
    key = normalized_team_name(source_name)

    from(team in FootballMarket.Catalog.Team, where: team.season_id == ^season_id)
    |> Repo.all()
    |> Enum.filter(&(normalized_team_name(&1.name) == key))
    |> case do
      [team] -> team
      _ -> nil
    end
  end

  defp normalized_team_name(name) do
    name
    |> String.downcase()
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.split()
    |> Enum.reject(
      &(&1 in ["fc", "afc", "sc", "sv", "fsv", "tsg", "vfb", "1", "04", "05", "07", "1899"])
    )
    |> Enum.join(" ")
  end

  defp normalized_player_name(name) do
    name
    |> String.downcase()
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^a-z0-9]+/u, " ")
    |> String.split()
    |> Enum.join(" ")
  end
end
