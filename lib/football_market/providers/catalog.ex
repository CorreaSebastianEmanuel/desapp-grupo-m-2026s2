defmodule FootballMarket.Providers.Catalog do
  @moduledoc "Whole-directory validation without deduplication or persistent identity."
  alias FootballMarket.Providers.{League, Season, Team, Position, Player, Request, Provenance}

  def require!(condition, field) do
    if not condition, do: throw({:invalid, field})
  end

  def shape!(value, fields, field) do
    require!(is_map(value) and not is_struct(value), field)
    require!(Enum.sort(Map.keys(value)) == Enum.sort(fields), field)
    value
  end

  def text!(value, field) do
    require!(Provenance.safe_text?(value), field)
    String.trim(value)
  end

  def ref!(value, field) do
    require!(Provenance.safe_text?(value), field)
    value
  end

  def rows!(value, fields, field, module, normalize) do
    require!(is_list(value), field)

    rows =
      Enum.map(value, fn row ->
        shape!(row, fields, field)
        ref!(row.ref, field)
        struct!(module, normalize.(row))
      end)

    unique!(rows, & &1.ref, field)
    rows
  end

  def unique!(values, key, field) do
    require!(length(values) == length(Enum.uniq_by(values, key)), field)
  end

  def indexed(rows), do: Map.new(rows, &{&1.ref, &1})

  def directory(facts, request, positions) do
    l = shape!(facts.league, [:ref, :code, :name], :league)
    ref!(l.ref, :league)
    require!(l.code == request.scope.league_code, :league)
    require!(text!(l.name, :league) == Request.leagues()[l.code], :league)
    league = struct!(League, %{l | name: String.trim(l.name)})
    s = shape!(facts.season, [:ref, :league_ref, :start_year, :end_year], :season)
    ref!(s.ref, :season)

    require!(
      s.league_ref == league.ref and s.start_year === request.scope.start_year and
        s.end_year === request.scope.end_year,
      :season
    )

    season = struct!(Season, s)

    teams =
      rows!(facts.teams, [:ref, :season_ref, :name, :code], :teams, Team, fn row ->
        require!(row.season_ref == season.ref, :teams)
        %{row | name: text!(row.name, :teams), code: text!(row.code, :teams)}
      end)

    unique!(teams, &String.downcase(&1.name), :teams)
    unique!(teams, &String.downcase(&1.code), :teams)

    roles =
      rows!(facts.positions, [:ref, :name, :code], :positions, Position, fn row ->
        code = text!(row.code, :positions)
        name = text!(row.name, :positions)
        require!(row.ref == code and positions[code] == name, :positions)
        %{row | code: code, name: name}
      end)

    unique!(roles, &String.downcase(&1.code), :positions)
    unique!(roles, &String.downcase(&1.name), :positions)
    team_refs = indexed(teams)
    role_refs = indexed(roles)

    players =
      rows!(
        facts.players,
        [:ref, :season_ref, :display_name, :team_ref, :position_ref],
        :players,
        Player,
        fn row ->
          require!(
            row.season_ref == season.ref and Map.has_key?(team_refs, row.team_ref) and
              Map.has_key?(role_refs, row.position_ref),
            :players
          )

          %{row | display_name: text!(row.display_name, :players)}
        end
      )

    %{league: league, season: season, teams: teams, positions: roles, players: players}
  end

  def validate(facts, request, positions) do
    shape!(facts, [:league, :season, :teams, :positions, :players], :scope)
    directory(facts, request, positions)
  end
end
