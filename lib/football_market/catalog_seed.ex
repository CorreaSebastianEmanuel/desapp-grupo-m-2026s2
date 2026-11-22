defmodule FootballMarket.Catalog.DevelopmentSeed do
  @moduledoc """
  Idempotent demo catalog seeder used by `mix catalog.seed` in dev/test.

  Seeds 5 leagues, 5 seasons (2026-2027), 10 demo teams, 4 standard positions,
  and 20 demo players (one per position per league). Safe to run repeatedly.
  """

  alias FootballMarket.{Catalog, Repo}

  @positions [
    %{code: "GK", name: "Goalkeeper"},
    %{code: "DEF", name: "Defender"},
    %{code: "MID", name: "Midfielder"},
    %{code: "FWD", name: "Forward"}
  ]

  @leagues [
    {"PL", "Premier League"},
    {"BL1", "Bundesliga"},
    {"PD", "La Liga"},
    {"SA", "Serie A"},
    {"FL1", "Ligue 1"}
  ]

  @doc "Returns true only when `development_seed_enabled: true` is configured."
  def enabled?,
    do: Application.get_env(:football_market, :development_seed_enabled, false) == true

  @doc "Seeds the demo catalog inside a single transaction."
  def run do
    if enabled?() do
      Repo.transaction(&seed_all/0)
      |> case do
        {:ok, summary} -> {:ok, summary}
        {:error, error} -> {:error, error}
      end
    else
      {:error, %{category: :disabled, entity: :seed, identity: "development-seed"}}
    end
  end

  defp seed_all do
    {positions, pos_counts} = seed_positions()

    {counts, _} =
      Enum.reduce(@leagues, {pos_counts, positions}, fn {code, name}, {acc, pos_map} ->
        {league, acc} = ensure_league(code, name, acc)
        {season, acc} = ensure_season(league, acc)
        {team_a, acc} = ensure_team(season, "DEMO-#{code}-A", "Demo #{code} Alpha FC", acc)
        {team_b, acc} = ensure_team(season, "DEMO-#{code}-B", "Demo #{code} Beta FC", acc)

        demo_players = [
          {team_a, pos_map["GK"], "demo-2026-27-#{String.downcase(code)}-gk",
           "Demo #{code} Goalkeeper"},
          {team_a, pos_map["DEF"], "demo-2026-27-#{String.downcase(code)}-def",
           "Demo #{code} Defender"},
          {team_b, pos_map["MID"], "demo-2026-27-#{String.downcase(code)}-mid",
           "Demo #{code} Midfielder"},
          {team_b, pos_map["FWD"], "demo-2026-27-#{String.downcase(code)}-fwd",
           "Demo #{code} Forward"}
        ]

        acc =
          Enum.reduce(demo_players, acc, fn {team, pos, identity, display_name}, counts ->
            ensure_player(team, pos, identity, display_name, counts)
          end)

        {acc, pos_map}
      end)

    %{
      total: counts.created + counts.reused,
      created: counts.created,
      reused: counts.reused,
      totals: %{leagues: 5, seasons: 5, teams: 10, positions: 4, players: 20}
    }
  end

  defp seed_positions do
    Enum.reduce(@positions, {%{}, %{created: 0, reused: 0}}, fn pos, {map, counts} ->
      case Catalog.get_position_by_code(pos.code) do
        {:ok, existing} ->
          {Map.put(map, pos.code, existing), inc(counts, :reused)}

        {:error, :not_found} ->
          {:ok, created} = Catalog.create_position(pos)
          {Map.put(map, pos.code, created), inc(counts, :created)}
      end
    end)
  end

  defp ensure_league(code, name, counts) do
    case Catalog.get_league_by_code(code) do
      {:ok, existing} ->
        {existing, inc(counts, :reused)}

      {:error, :not_found} ->
        {:ok, created} = Catalog.create_league(%{code: code, name: name})
        {created, inc(counts, :created)}
    end
  end

  defp ensure_season(league, counts) do
    case Catalog.get_season(league.id, 2026, 2027) do
      {:ok, existing} ->
        {existing, inc(counts, :reused)}

      {:error, :not_found} ->
        {:ok, created} =
          Catalog.create_season(%{league_id: league.id, start_year: 2026, end_year: 2027})

        {created, inc(counts, :created)}
    end
  end

  defp ensure_team(season, code, name, counts) do
    case Catalog.get_team_by_code(season.id, code) do
      {:ok, existing} ->
        {existing, inc(counts, :reused)}

      {:error, :not_found} ->
        {:ok, created} = Catalog.create_team(%{season_id: season.id, code: code, name: name})
        {created, inc(counts, :created)}
    end
  end

  defp ensure_player(team, position, identity, display_name, counts) do
    case Catalog.get_player(team.season_id, identity) do
      {:ok, _existing} ->
        inc(counts, :reused)

      {:error, :not_found} ->
        {:ok, _created} =
          Catalog.create_player(%{
            team_id: team.id,
            position_id: position.id,
            catalog_identity: identity,
            display_name: display_name
          })

        inc(counts, :created)
    end
  end

  defp inc(counts, key), do: Map.update!(counts, key, &(&1 + 1))
end
