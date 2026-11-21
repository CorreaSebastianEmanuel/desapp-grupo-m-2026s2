defmodule FootballMarket.Catalog.Query do
  @moduledoc """
  Composable Ecto queries for local catalog entities and batched player profile cards.
  """

  import Ecto.Query

  alias FootballMarket.Catalog.Ingestion.SourceBinding
  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}
  alias FootballMarket.Providers.Media
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.{Ingestion.ScopeCheck, Performance}
  alias FootballMarket.Synchronization.Run

  @player_filters [:league_id, :season_id, :team_id, :position_id, :search_name]

  def by_id(schema, id), do: from(record in schema, where: record.id == ^id)

  def league_by(field, value) when field in [:code, :name] do
    from league in League,
      where:
        fragment("lower(btrim(?))", field(league, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  def season(league_id, start_year, end_year),
    do:
      from(season in Season,
        where:
          season.league_id == ^league_id and season.start_year == ^start_year and
            season.end_year == ^end_year
      )

  def team_by(season_id, field, value) when field in [:code, :name] do
    from team in Team,
      where: team.season_id == ^season_id,
      where:
        fragment("lower(btrim(?))", field(team, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  def position_by(field, value) when field in [:code, :name] do
    from position in Position,
      where:
        fragment("lower(btrim(?))", field(position, ^field)) ==
          fragment("lower(btrim(?))", ^value)
  end

  def player(season_id, catalog_identity) do
    from player in base_players(),
      where: player.season_id == ^season_id,
      where:
        fragment("lower(btrim(?))", player.catalog_identity) ==
          fragment("lower(btrim(?))", ^catalog_identity)
  end

  def players(filters) do
    unknown = Map.keys(filters) -- @player_filters

    if unknown == [] do
      query = Enum.reduce(filters, base_players(), &apply_filter/2)
      {:ok, from(player in query, order_by: [asc: player.id])}
    else
      {:error, {:unknown_filters, Enum.sort(unknown)}}
    end
  end

  def player_page(anchor, limit, filters \\ %{}) when is_integer(limit) and limit > 0 do
    query =
      from player in Enum.reduce(filters, base_players(), &apply_filter/2),
        order_by: [asc: fragment("lower(btrim(?))", player.display_name), asc: player.id],
        select: {player, fragment("lower(btrim(?))", player.display_name)},
        limit: ^limit

    case anchor do
      nil ->
        query

      %{name: name, id: id} ->
        from [player, _team, _season, _league, _position] in query,
          where:
            fragment("lower(btrim(?))", player.display_name) > ^name or
              (fragment("lower(btrim(?))", player.display_name) == ^name and player.id > ^id)
    end
  end

  def search_players(term, limit) when is_binary(term) and is_integer(limit) and limit > 0 do
    pattern = "%" <> term <> "%"

    from player in base_players(),
      where: ilike(player.display_name, ^pattern),
      order_by: [asc: fragment("lower(btrim(?))", player.display_name), asc: player.id],
      limit: ^limit
  end

  def market_player_page(anchor, limit, filters) do
    hidden =
      from run in Run,
        join: player in Player,
        on: fragment("?->>'player_id'", run.input) == fragment("?::text", player.id),
        join: season in Season,
        on: season.id == player.season_id,
        join: league in League,
        on: league.id == season.league_id,
        left_join: check in ScopeCheck,
        on:
          check.player_id == player.id and check.season_id == player.season_id and
            not is_nil(check.last_checked_at) and not is_nil(check.last_accepted_check_id),
        left_join: performance in Performance,
        on: performance.player_id == player.id and performance.season_id == player.season_id,
        where: run.operation == "statistics",
        where: run.state == "failed",
        where: run.league_code == league.code,
        where: run.start_year == season.start_year,
        where: run.end_year == season.end_year,
        where: fragment("?->>'status'", run.outcome) == "provider_failure",
        where:
          fragment("?->>'category'", run.outcome) in [
            "unsupported_capability",
            "invalid_response"
          ],
        where: is_nil(check.id) and is_nil(performance.id),
        select: player.id,
        distinct: true

    from player in player_page(anchor, limit, filters), where: player.id not in subquery(hidden)
  end

  defp base_players do
    from player in Player,
      join: team in assoc(player, :team),
      join: season in assoc(team, :season),
      join: league in assoc(season, :league),
      join: position in assoc(player, :position),
      preload: [team: {team, season: {season, league: league}}, position: position]
  end

  defp apply_filter({:league_id, value}, query),
    do: from([player, team, season, league, position] in query, where: league.id == ^value)

  defp apply_filter({:season_id, value}, query),
    do: from([player, team, season, league, position] in query, where: season.id == ^value)

  defp apply_filter({:team_id, value}, query),
    do: from([player, team, season, league, position] in query, where: team.id == ^value)

  defp apply_filter({:position_id, value}, query),
    do: from([player, team, season, league, position] in query, where: position.id == ^value)

  defp apply_filter({:search_name, value}, query) when is_binary(value) do
    pattern = "%" <> String.trim(value) <> "%"

    from([player, _team, _season, _league, _position] in query,
      where: ilike(player.display_name, ^pattern)
    )
  end

  # --- Batched Player Profiles ---

  @doc "Loads public identities and optional imagery for a batch of local player IDs."
  def get_profiles([]), do: %{}

  def get_profiles(ids) do
    players =
      Repo.all(
        from p in Player,
          where: p.id in ^Enum.uniq(ids),
          preload: [:position, team: [season: :league]]
      )

    team_ids = Enum.map(players, fn player -> player.team_id end)

    bindings =
      Repo.all(
        from b in SourceBinding,
          where: b.player_id in ^ids or b.team_id in ^team_ids,
          order_by: [asc: b.provider, asc: b.source_id]
      )

    Map.new(players, fn player ->
      {player.id,
       %{
         name: player.display_name,
         team: player.team.name,
         league: player.team.season.league.name,
         position: player.position.code,
         photo: profile_image(bindings, :player_id, player.id, "player"),
         crest: profile_image(bindings, :team_id, player.team_id, "team")
       }}
    end)
  end

  defp profile_image(bindings, field, id, kind) do
    Enum.find_value(bindings, fn binding ->
      if Map.get(binding, field) == id and binding.kind == kind,
        do: Media.url(binding.provider, kind, binding.source_id)
    end)
  end
end
