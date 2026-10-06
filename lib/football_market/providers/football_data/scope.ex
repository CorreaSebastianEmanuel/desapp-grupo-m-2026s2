defmodule FootballMarket.Providers.FootballData.Scope do
  @moduledoc "Exact source scope and corroborated affiliations; no historical inference."
  alias FootballMarket.Providers.FootballData.Configuration
  def require!(condition), do: if(not condition, do: throw({:source_error, :invalid_response}))

  def id!(id, token) do
    require!(is_integer(id) and id > 0)
    require!(Configuration.clean?(Integer.to_string(id), token))
    id
  end

  def text!(text, token) do
    require!(Configuration.clean?(text, token))
    String.trim(text)
  end

  def rows!(rows) do
    require!(is_list(rows) and Enum.all?(rows, &is_map/1))
    rows
  end

  def unique!(rows, token) do
    ids = Enum.map(rows, &id!(&1["id"], token))
    require!(length(ids) == length(Enum.uniq(ids)))
    rows
  end

  def season!(season, token) do
    require!(is_map(season))
    id = id!(season["id"], token)
    {:ok, start} = Date.from_iso8601(season["startDate"])
    {:ok, ending} = Date.from_iso8601(season["endDate"])
    require!(Date.compare(start, ending) != :gt and ending.year in [start.year, start.year + 1])
    %{id: id, start: start, ending: ending}
  end

  def discovery!(source, request, token) do
    require!(source["code"] == request.scope.league_code)
    competition = id!(source["id"], token)
    seasons = rows!(source["seasons"]) |> unique!(token) |> Enum.map(&season!(&1, token))
    require!(length(seasons) == length(Enum.uniq_by(seasons, &{&1.start.year, &1.ending.year})))
    current = season!(source["currentSeason"], token)
    require!(current in seasons)

    requested =
      Enum.find(
        seasons,
        &(&1.start.year == request.scope.start_year and &1.ending.year == request.scope.end_year)
      )

    if is_nil(requested), do: throw({:source_error, :not_found})
    if requested != current, do: throw({:source_error, :unsupported_capability})
    %{competition: competition, code: source["code"], season: requested, current: current}
  end

  def competition!(source, evidence) do
    require!(
      is_map(source) and source["id"] == evidence.competition and source["code"] == evidence.code
    )
  end

  def memberships!(source, evidence) do
    rows = rows!(source)
    require!(Enum.any?(rows, &(&1["id"] == evidence.competition and &1["code"] == evidence.code)))

    Enum.each(rows, fn row ->
      if row["id"] == evidence.competition or row["code"] == evidence.code,
        do: competition!(row, evidence)
    end)
  end

  def teams!(source, evidence, request, token) do
    teams = rows!(source["teams"]) |> unique!(token)
    if Map.has_key?(source, "count"), do: require!(source["count"] === length(teams))
    if Map.has_key?(source, "competition"), do: competition!(source["competition"], evidence)

    if Map.has_key?(source, "season"),
      do: require!(season!(source["season"], token) == evidence.season)

    if Map.has_key?(source, "filters") do
      require!(is_map(source["filters"]))

      if Map.has_key?(source["filters"], "season"),
        do:
          require!(
            source["filters"]["season"] in [
              request.scope.start_year,
              Integer.to_string(request.scope.start_year)
            ]
          )
    end

    for key <- ["next", "nextPage", "pagination", "limit", "offset"],
        do: require!(not Map.has_key?(source, key))

    teams
  end

  def team!(detail, listed, evidence, token) do
    require!(id!(detail["id"], token) == listed["id"])

    for key <- ["name", "tla"] do
      value = text!(detail[key], token)
      if Map.has_key?(listed, key), do: require!(text!(listed[key], token) == value)
    end

    memberships!(detail["runningCompetitions"], evidence)
    rows!(detail["squad"]) |> unique!(token)
  end

  def person!(person, player, team, evidence, token) do
    require!(id!(person["id"], token) == player["id"])

    require!(
      is_map(person["currentTeam"]) and id!(person["currentTeam"]["id"], token) == team["id"]
    )

    if Map.has_key?(person["currentTeam"], "runningCompetitions"),
      do: memberships!(person["currentTeam"]["runningCompetitions"], evidence)
  end
end
