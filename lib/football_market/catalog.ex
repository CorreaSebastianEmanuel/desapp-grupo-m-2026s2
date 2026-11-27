defmodule FootballMarket.Catalog.League do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "leagues" do
    field :code, :string
    field :name, :string
    has_many :seasons, FootballMarket.Catalog.Season
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(league, attrs) do
    league
    |> cast(attrs, [:code, :name])
    |> FootballMarket.Catalog.trim_fields([:code, :name])
    |> validate_required([:code, :name])
    |> validate_supported_pair()
    |> check_constraint(:code, name: :leagues_supported_code)
    |> unique_constraint(:code, name: :leagues_normalized_code_index)
    |> unique_constraint(:name, name: :leagues_normalized_name_index)
  end

  defp validate_supported_pair(changeset) do
    pair = {get_field(changeset, :code), get_field(changeset, :name)}

    if pair in FootballMarket.Catalog.supported_leagues(),
      do: changeset,
      else: add_error(changeset, :code, "is not a supported league pair")
  end
end

defmodule FootballMarket.Catalog.Season do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "seasons" do
    field :start_year, :integer
    field :end_year, :integer
    belongs_to :league, FootballMarket.Catalog.League
    has_many :teams, FootballMarket.Catalog.Team
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(season, attrs) do
    season
    |> cast(attrs, [:league_id, :start_year, :end_year])
    |> validate_required([:league_id, :start_year, :end_year])
    |> validate_year_span()
    |> foreign_key_constraint(:league_id)
    |> unique_constraint([:league_id, :start_year, :end_year], name: :seasons_league_years_index)
    |> check_constraint(:end_year, name: :seasons_valid_year_span)
  end

  defp validate_year_span(changeset) do
    start_year = get_field(changeset, :start_year)
    end_year = get_field(changeset, :end_year)

    if is_integer(start_year) and is_integer(end_year) and
         end_year not in [start_year, start_year + 1],
       do: add_error(changeset, :end_year, "must equal start year or the following year"),
       else: changeset
  end
end

defmodule FootballMarket.Catalog.Team do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "teams" do
    field :code, :string
    field :name, :string
    belongs_to :season, FootballMarket.Catalog.Season
    has_many :players, FootballMarket.Catalog.Player
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:season_id, :code, :name])
    |> FootballMarket.Catalog.trim_fields([:code, :name])
    |> validate_required([:season_id, :code, :name])
    |> foreign_key_constraint(:season_id)
    |> unique_constraint(:code, name: :teams_season_normalized_code_index)
    |> unique_constraint(:name, name: :teams_season_normalized_name_index)
  end
end

defmodule FootballMarket.Catalog.Position do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "positions" do
    field :code, :string
    field :name, :string
    has_many :players, FootballMarket.Catalog.Player
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:code, :name])
    |> FootballMarket.Catalog.trim_fields([:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code, name: :positions_normalized_code_index)
    |> unique_constraint(:name, name: :positions_normalized_name_index)
  end
end

defmodule FootballMarket.Catalog.Player do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "players" do
    field :catalog_identity, :string
    field :display_name, :string
    belongs_to :team, FootballMarket.Catalog.Team
    belongs_to :season, FootballMarket.Catalog.Season
    belongs_to :position, FootballMarket.Catalog.Position
    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(player, attrs, season_id) do
    player
    |> cast(attrs, [:team_id, :position_id, :catalog_identity, :display_name])
    |> put_change(:season_id, season_id)
    |> FootballMarket.Catalog.trim_fields([:catalog_identity, :display_name])
    |> validate_required([:team_id, :season_id, :position_id, :catalog_identity, :display_name])
    |> add_constraints()
  end

  def update_changeset(player, attrs, season_id) do
    player
    |> cast(attrs, [:team_id, :position_id, :display_name])
    |> put_change(:season_id, season_id)
    |> FootballMarket.Catalog.trim_fields([:display_name])
    |> validate_required([:team_id, :season_id, :position_id, :catalog_identity, :display_name])
    |> add_constraints()
  end

  defp add_constraints(changeset) do
    changeset
    |> foreign_key_constraint(:position_id)
    |> foreign_key_constraint(:season_id)
    |> foreign_key_constraint(:team_id,
      name: :players_team_season_fkey,
      message: "must belong to the player's season"
    )
    |> unique_constraint(:catalog_identity, name: :players_season_normalized_identity_index)
  end
end

defmodule FootballMarket.Catalog.SourceBinding do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "catalog_source_bindings" do
    field :scope_id, :binary_id
    field :season_scope_id, :binary_id
    field :league_scope_id, :binary_id
    field :provider, :string
    field :kind, :string
    field :source_id, :string
    field :league_id, :binary_id
    field :season_id, :binary_id
    field :team_id, :binary_id
    field :player_id, :binary_id
  end
end

defmodule FootballMarket.Catalog.ScoutRun do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "catalog_scout_runs" do
    field :normalized_name, :string
    field :display_name, :string
    field :state, :string
    field :config_digest, :string
    field :admitted_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
    field :next_attempt_at, :utc_datetime_usec
    field :scope_inputs, :map, default: %{}
    field :synchronization_run_ids, {:array, :binary_id}, default: []
    field :configured_scope_count, :integer
    field :request_count, :integer, default: 0
    field :error_category, :string
    field :job_id, :integer
    timestamps(type: :utc_datetime_usec)
  end
end

defmodule FootballMarket.Catalog do
  @moduledoc """
  Local football catalog: leagues, seasons, teams, positions, and players.

  Everything related to catalog storage, search, cursor pagination, direct
  provider import, and background scouting lives in this file:
    * `FootballMarket.Catalog` — CRUD, filtering, cursor pagination, search, direct import
    * `FootballMarket.Catalog.{League, Season, Team, Position, Player, ScoutRun, SourceBinding}` — schemas
    * `FootballMarket.Catalog.PlayerCursor` — opaque AES-256-GCM pagination cursors
    * `FootballMarket.Catalog.Scouting` — bounded background scouting on search misses
  """

  import Ecto.Changeset
  import Ecto.Query

  alias FootballMarket.Catalog.{
    League,
    Player,
    PlayerCursor,
    Position,
    Scouting,
    Season,
    SourceBinding,
    Team
  }

  alias FootballMarket.{Providers, Repo}

  @supported_leagues [
    {"PL", "Premier League"},
    {"BL1", "Bundesliga"},
    {"PD", "La Liga"},
    {"SA", "Serie A"},
    {"FL1", "Ligue 1"}
  ]

  @standard_positions [
    {"GK", "Goalkeeper"},
    {"DEF", "Defender"},
    {"MID", "Midfielder"},
    {"FWD", "Forward"},
    {"UNK", "Unknown"}
  ]

  def supported_leagues, do: @supported_leagues

  def trim_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      case get_change(cs, field) do
        value when is_binary(value) -> put_change(cs, field, String.trim(value))
        _ -> cs
      end
    end)
  end

  # --- Basic CRUD ---

  def create_league(attrs), do: %League{} |> League.changeset(attrs) |> Repo.insert()
  def create_season(attrs), do: %Season{} |> Season.changeset(attrs) |> Repo.insert()
  def create_team(attrs), do: %Team{} |> Team.changeset(attrs) |> Repo.insert()
  def create_position(attrs), do: %Position{} |> Position.changeset(attrs) |> Repo.insert()

  def create_player(attrs) do
    with {:ok, team} <- existing_team(attrs) do
      %Player{}
      |> Player.create_changeset(attrs, team.season_id)
      |> Repo.insert()
      |> preload_player()
    end
  end

  def update_player(%Player{} = player, attrs) do
    team_id = Map.get(attrs, :team_id, Map.get(attrs, "team_id", player.team_id))

    case find_team(team_id) do
      %Team{season_id: season_id} when season_id == player.season_id ->
        player |> Player.update_changeset(attrs, season_id) |> Repo.update() |> preload_player()

      %Team{} ->
        {:error, player |> change() |> add_error(:team_id, "must belong to the player's season")}

      nil ->
        {:error, player |> change() |> add_error(:team_id, "does not exist")}
    end
  end

  # --- Lookups ---

  def get_league_by_code(code), do: one(by_normalized(League, :code, code))

  def get_season(id), do: one(from s in Season, where: s.id == ^id)

  def get_season(league_id, start_year, end_year) do
    one(
      from s in Season,
        where:
          s.league_id == ^league_id and s.start_year == ^start_year and s.end_year == ^end_year
    )
  end

  def get_team_by_code(season_id, code), do: one(team_by(season_id, :code, code))
  def get_position_by_code(code), do: one(by_normalized(Position, :code, code))

  def get_player(id) do
    Repo.get(Player, id) |> preload_one_player()
  end

  def get_player(season_id, catalog_identity) do
    from(p in base_players(),
      where: p.season_id == ^season_id,
      where:
        fragment("lower(btrim(?))", p.catalog_identity) ==
          fragment("lower(btrim(?))", ^catalog_identity)
    )
    |> Repo.one()
    |> preload_one_player()
  end

  def list_players_for_statistics do
    Repo.all(from p in Player, order_by: p.id)
    |> Repo.preload(team: [season: :league], position: [])
  end

  def get_player_detail(id) do
    with true <- valid_uuid_text?(id),
         {:ok, uuid} <- Ecto.UUID.cast(id),
         %Player{} = player <- Repo.get(Player, uuid) do
      {:ok, Repo.preload(player, team: [season: :league], position: [])}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def player_card(id) do
    with {:ok, player} <- get_player_detail(id),
         {:ok, statistics} <- FootballMarket.Statistics.recorded_summary(player) do
      {:ok,
       %{
         player: player,
         statistics: statistics,
         statistics_status: FootballMarket.Statistics.Freshness.for_player(player)
       }}
    end
  end

  # --- Pagination, Search, Filter Options & Profiles ---

  def list_player_page(opts) when is_map(opts) do
    page_size = Map.fetch!(opts, :page_size)
    filters = Map.get(opts, :filters, %{})

    with {:ok, anchor} <- decode_anchor(Map.get(opts, :cursor), filters) do
      rows =
        anchor
        |> player_page_query(page_size + 1, filters)
        |> Repo.all(if anchor, do: [log: false], else: [])

      {page_rows, extra} = Enum.split(rows, page_size)
      players = Enum.map(page_rows, &elem(&1, 0))
      has_more = extra != []

      next_cursor =
        if has_more do
          {last, normalized_name} = List.last(page_rows)
          PlayerCursor.encode(%{name: normalized_name, id: last.id}, filters)
        end

      {:ok,
       %{
         players: players,
         pagination: %{
           page_size: page_size,
           returned_count: length(players),
           has_more: has_more,
           next_cursor: next_cursor
         }
       }}
    end
  end

  def list_market_player_page(opts) when is_map(opts), do: list_player_page(opts)

  def filter_options do
    leagues =
      Repo.all(from l in League, order_by: l.name, select: %{id: l.id, name: l.name})

    teams =
      Repo.all(
        from t in Team,
          join: s in assoc(t, :season),
          join: l in assoc(s, :league),
          order_by: [asc: l.name, asc: t.name],
          select: %{id: t.id, name: t.name, league_id: l.id, league_name: l.name}
      )

    positions =
      Repo.all(
        from p in Position, order_by: p.name, select: %{id: p.id, code: p.code, name: p.name}
      )

    {:ok, %{leagues: leagues, teams: teams, positions: positions}}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def search_players(term) when is_binary(term), do: Scouting.search(term)

  def search_players(_),
    do: {:ok, [], %{state: :rejected, next_attempt_at: nil, configured_scope_count: 0}}

  def search_local_players(term) when is_binary(term) do
    pattern = "%" <> String.trim(term) <> "%"

    players =
      from(p in base_players(),
        where: ilike(p.display_name, ^pattern),
        order_by: [asc: fragment("lower(btrim(?))", p.display_name), asc: p.id],
        limit: 10
      )
      |> Repo.all()

    {:ok, players}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  @doc "Loads display identity and optional photo/crest URLs for a batch of player IDs."
  def get_profiles([]), do: %{}

  def get_profiles(ids) do
    unique_ids = Enum.uniq(ids)

    players =
      Repo.all(
        from p in Player,
          where: p.id in ^unique_ids,
          preload: [:position, team: [season: :league]]
      )

    team_ids = Enum.map(players, & &1.team_id)

    bindings =
      Repo.all(
        from b in SourceBinding,
          where: b.player_id in ^unique_ids or b.team_id in ^team_ids,
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

  # --- Direct Idempotent Provider Import ---

  @doc """
  Imports a normalized catalog snapshot (league, season, teams, players) directly
  into the local catalog inside a single transaction.

  Idempotent: existing leagues, seasons, teams, positions, and players are reused
  and updated cleanly without duplicates.
  """
  def import_catalog(snapshot, opts \\ []) when is_map(snapshot) do
    provider = Keyword.get(opts, :provider)

    Repo.transaction(fn ->
      league = ensure_league!(snapshot.league_code)
      season = ensure_season!(league.id, snapshot.start_year, snapshot.end_year)
      positions = ensure_positions!()
      teams_by_code = ensure_teams!(season.id, snapshot.teams)

      player_count =
        Enum.reduce(snapshot.players, 0, fn entry, count ->
          team = Map.fetch!(teams_by_code, entry.team_code)
          position = Map.get(positions, entry.position_code) || Map.fetch!(positions, "UNK")
          ensure_player!(season.id, team.id, position.id, entry)
          count + 1
        end)

      %{
        provider: provider,
        league_id: league.id,
        season_id: season.id,
        teams: map_size(teams_by_code),
        players: player_count
      }
    end)
  end

  # --- Private Query & Import Helpers ---

  defp ensure_league!(code) do
    case get_league_by_code(code) do
      {:ok, league} ->
        league

      {:error, :not_found} ->
        {_code, name} = Enum.find(@supported_leagues, fn {c, _} -> c == code end)
        {:ok, league} = create_league(%{code: code, name: name})
        league
    end
  end

  defp ensure_season!(league_id, start_year, end_year) do
    case get_season(league_id, start_year, end_year) do
      {:ok, season} ->
        season

      {:error, :not_found} ->
        {:ok, season} =
          create_season(%{league_id: league_id, start_year: start_year, end_year: end_year})

        season
    end
  end

  defp ensure_positions! do
    Map.new(@standard_positions, fn {code, name} ->
      position =
        case get_position_by_code(code) do
          {:ok, existing} ->
            existing

          {:error, :not_found} ->
            {:ok, created} = create_position(%{code: code, name: name})
            created
        end

      {code, position}
    end)
  end

  defp ensure_teams!(season_id, teams) do
    Map.new(teams, fn entry ->
      team =
        case get_team_by_code(season_id, entry.code) do
          {:ok, existing} ->
            existing

          {:error, :not_found} ->
            {:ok, created} =
              create_team(%{season_id: season_id, code: entry.code, name: entry.name})

            created
        end

      {entry.code, team}
    end)
  end

  defp ensure_player!(season_id, team_id, position_id, entry) do
    case get_player(season_id, entry.catalog_identity) do
      {:ok, existing} ->
        if existing.team_id != team_id or existing.position_id != position_id or
             existing.display_name != entry.display_name do
          {:ok, updated} =
            update_player(existing, %{
              team_id: team_id,
              position_id: position_id,
              display_name: entry.display_name
            })

          updated
        else
          existing
        end

      {:error, :not_found} ->
        {:ok, created} =
          create_player(%{
            team_id: team_id,
            position_id: position_id,
            catalog_identity: entry.catalog_identity,
            display_name: entry.display_name
          })

        created
    end
  end

  defp base_players do
    from p in Player,
      join: t in assoc(p, :team),
      join: s in assoc(t, :season),
      join: l in assoc(s, :league),
      join: pos in assoc(p, :position),
      preload: [team: {t, season: {s, league: l}}, position: pos]
  end

  defp player_page_query(anchor, limit, filters) do
    query =
      from p in Enum.reduce(filters, base_players(), &apply_filter/2),
        order_by: [asc: fragment("lower(btrim(?))", p.display_name), asc: p.id],
        select: {p, fragment("lower(btrim(?))", p.display_name)},
        limit: ^limit

    case anchor do
      nil ->
        query

      %{name: name, id: id} ->
        from [p, _t, _s, _l, _pos] in query,
          where:
            fragment("lower(btrim(?))", p.display_name) > ^name or
              (fragment("lower(btrim(?))", p.display_name) == ^name and p.id > ^id)
    end
  end

  defp apply_filter({:league_id, value}, q),
    do: from([_p, _t, _s, l, _pos] in q, where: l.id == ^value)

  defp apply_filter({:season_id, value}, q),
    do: from([_p, _t, s, _l, _pos] in q, where: s.id == ^value)

  defp apply_filter({:team_id, value}, q),
    do: from([_p, t, _s, _l, _pos] in q, where: t.id == ^value)

  defp apply_filter({:position_id, value}, q),
    do: from([_p, _t, _s, _l, pos] in q, where: pos.id == ^value)

  defp apply_filter({:search_name, value}, q) when is_binary(value) do
    pattern = "%" <> String.trim(value) <> "%"
    from([p, _t, _s, _l, _pos] in q, where: ilike(p.display_name, ^pattern))
  end

  defp by_normalized(schema, field, value) do
    from r in schema,
      where: fragment("lower(btrim(?))", field(r, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  defp team_by(season_id, field, value) do
    from t in Team,
      where: t.season_id == ^season_id,
      where: fragment("lower(btrim(?))", field(t, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  defp existing_team(attrs) do
    team_id = Map.get(attrs, :team_id, Map.get(attrs, "team_id"))

    case find_team(team_id) do
      nil -> {:error, %Player{} |> change() |> add_error(:team_id, "does not exist")}
      team -> {:ok, team}
    end
  end

  defp find_team(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Repo.get(Team, uuid)
      :error -> nil
    end
  end

  defp one(query) do
    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  defp preload_player({:ok, player}),
    do: {:ok, Repo.preload(player, team: [season: :league], position: [])}

  defp preload_player(error), do: error
  defp preload_one_player(nil), do: {:error, :not_found}

  defp preload_one_player(player),
    do: {:ok, Repo.preload(player, team: [season: :league], position: [])}

  defp decode_anchor(nil, _filters), do: {:ok, nil}
  defp decode_anchor(cursor, filters), do: PlayerCursor.decode(cursor, filters)

  defp profile_image(bindings, field, id, kind) do
    Enum.find_value(bindings, fn binding ->
      if Map.get(binding, field) == id and binding.kind == kind,
        do: Providers.media_url(binding.provider, kind, binding.source_id)
    end)
  end

  defp valid_uuid_text?(id) when is_binary(id),
    do: Regex.match?(~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/, id)

  defp valid_uuid_text?(_), do: false
end

# --- Catalog Ecto Schemas ---

# --- Opaque AES-256-GCM Pagination Cursor ---

defmodule FootballMarket.Catalog.PlayerCursor do
  @moduledoc "Encrypts and validates opaque keyset pagination cursors for `/api/players`."

  @scope "players:list"
  @aad "football-market:player-catalog-cursor:v1"
  @filter_keys %{league_id: "league_id", team_id: "team_id", position_id: "position_id"}

  def encode(%{name: name, id: id}, filters \\ %{}) when is_binary(name) and is_binary(id) do
    payload =
      %{"v" => 1, "s" => @scope, "n" => name, "i" => id}
      |> put_filter_fields(filters)
      |> Jason.encode!()

    nonce = :crypto.mac(:hmac, :sha256, key(), payload) |> binary_part(0, 12)

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, payload, @aad, true)

    Base.url_encode64(nonce <> tag <> ciphertext, padding: false)
  end

  def decode(token, filters \\ %{})

  def decode(token, filters) when is_binary(token) and token != "" and is_map(filters) do
    with {:ok, <<nonce::binary-size(12), tag::binary-size(16), ciphertext::binary>>} <-
           Base.url_decode64(token, padding: false),
         payload when is_binary(payload) <-
           :crypto.crypto_one_time_aead(:aes_256_gcm, key(), nonce, ciphertext, @aad, tag, false),
         {:ok, decoded} <- Jason.decode(payload),
         {:ok, name, id} <- validate_payload(decoded, filters),
         true <- is_binary(name) and name != "",
         {:ok, uuid} <- Ecto.UUID.cast(id) do
      {:ok, %{name: name, id: uuid}}
    else
      _ -> {:error, :invalid_cursor}
    end
  rescue
    _ -> {:error, :invalid_cursor}
  end

  def decode(_, _), do: {:error, :invalid_cursor}

  defp validate_payload(%{"v" => 1, "s" => @scope, "n" => name, "i" => id} = payload, filters)
       when map_size(payload) == 4 and map_size(filters) == 0,
       do: {:ok, name, id}

  defp validate_payload(
         %{"v" => 2, "s" => @scope, "n" => name, "i" => id, "f" => stored} = payload,
         filters
       )
       when map_size(payload) == 5 and is_map(stored) and map_size(filters) > 0 and
              not is_map_key(filters, :search_name) do
    if valid_stored_filters?(stored, filters),
      do: {:ok, name, id},
      else: {:error, :invalid_cursor}
  end

  defp validate_payload(
         %{"v" => 3, "s" => @scope, "n" => name, "i" => id, "f" => stored, "q" => query} = payload,
         filters
       )
       when map_size(payload) == 6 and is_map(stored) and is_binary(query) and
              map_size(filters) > 0 do
    if valid_stored_filters?(stored, filters) and Map.get(filters, :search_name) == query,
      do: {:ok, name, id},
      else: {:error, :invalid_cursor}
  end

  defp validate_payload(_, _), do: {:error, :invalid_cursor}

  defp valid_stored_filters?(stored, filters) do
    stored == canonical_filters(filters) and
      Enum.all?(stored, fn {k, v} ->
        k in Map.values(@filter_keys) and match?({:ok, ^v}, Ecto.UUID.cast(v))
      end)
  end

  defp canonical_filters(filters) do
    filters
    |> Enum.reject(fn {key, _} -> key == :search_name end)
    |> Map.new(fn {key, value} -> {Map.fetch!(@filter_keys, key), value} end)
  end

  defp put_filter_fields(payload, filters) when map_size(filters) == 0, do: payload

  defp put_filter_fields(payload, filters) do
    filters = Map.new(filters)
    version = if Map.has_key?(filters, :search_name), do: 3, else: 2
    updated = payload |> Map.put("v", version) |> Map.put("f", canonical_filters(filters))
    if version == 3, do: Map.put(updated, "q", filters.search_name), else: updated
  end

  defp key do
    secret =
      Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]

    :crypto.mac(:hmac, :sha256, secret, "football-market:player-catalog-cursor:key:v1")
  end
end

# --- Background Scouting for Search Misses ---

defmodule FootballMarket.Catalog.Scouting do
  @moduledoc "Bounded, rate-limited background scouting when a local player search misses."

  import Ecto.Query

  alias FootballMarket.Catalog
  alias FootballMarket.Catalog.ScoutRun
  alias FootballMarket.Repo
  alias FootballMarket.Workers.CatalogScout

  @max_name_length 80
  @active_states ["queued", "scouting"]
  @negative_ttl_seconds 86_400
  @hourly_limit 10

  def search(term) do
    case normalize_name(term) do
      {:ok, display_name, normalized_name} -> search_normalized(display_name, normalized_name)
      :error -> {:ok, [], %{state: :rejected, next_attempt_at: nil, configured_scope_count: 0}}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp search_normalized(display_name, normalized_name) do
    with {:ok, players} <- Catalog.search_local_players(display_name) do
      status = if players == [], do: admit(display_name, normalized_name, configured_scopes())
      {:ok, players, status}
    end
  end

  def normalize_name(term) when is_binary(term) do
    if String.valid?(term) do
      display_name = term |> String.trim() |> String.split() |> Enum.join(" ")
      normalized = normalize_identity(display_name)
      if valid_name?(display_name), do: {:ok, display_name, normalized}, else: :error
    else
      :error
    end
  end

  def normalize_name(_), do: :error

  def normalize_identity(value) when is_binary(value) do
    value
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{M}/u, "")
    |> String.downcase()
    |> String.trim()
    |> String.split()
    |> Enum.join(" ")
  end

  def configured_scopes do
    Application.get_env(:football_market, FootballMarket.Synchronization, [])
    |> Keyword.get(:scouting_scopes, [])
    |> Enum.filter(&valid_scope?/1)
    |> Enum.map(fn s ->
      %{
        "league_code" => s.league_code,
        "start_year" => s.start_year,
        "end_year" => s.end_year,
        "source_ref" => s.source_ref
      }
    end)
    |> Enum.sort_by(& &1["league_code"])
  rescue
    _ -> []
  end

  def admit(display_name, normalized_name, scopes, now \\ DateTime.utc_now())
  def admit(_display, _norm, [], _now), do: scout_status(:unavailable, nil, 0)

  def admit(display_name, normalized_name, scopes, now) do
    digest = :crypto.hash(:sha256, Jason.encode!(scopes)) |> Base.encode16(case: :lower)

    case Repo.transaction(fn ->
           admit_locked(display_name, normalized_name, scopes, digest, now)
         end) do
      {:ok, result} -> result
      _ -> scout_status(:unavailable, nil, length(scopes))
    end
  rescue
    _ -> scout_status(:unavailable, nil, 0)
  end

  def get(id), do: Repo.get(ScoutRun, id)

  def finish(%ScoutRun{} = scout, state, error_category \\ nil)
      when state in ["found", "not_found", "provider_failure"] do
    now = DateTime.utc_now()

    retry_at =
      if state == "found", do: nil, else: DateTime.add(now, @negative_ttl_seconds, :second)

    {:ok, updated} =
      scout
      |> Ecto.Changeset.change(
        state: state,
        finished_at: now,
        next_attempt_at: retry_at,
        error_category: error_category
      )
      |> Repo.update()

    Phoenix.PubSub.broadcast(
      FootballMarket.PubSub,
      "catalog_scouts",
      {:catalog_scout_changed, updated.normalized_name}
    )

    {:ok, updated}
  rescue
    _ -> {:error, :unavailable}
  end

  defp admit_locked(display_name, normalized_name, scopes, digest, now) do
    <<lock_key::signed-64, _::binary>> = :crypto.hash(:sha256, "catalog-scout-global-admission")
    Repo.query!("SELECT pg_advisory_xact_lock($1)", [lock_key])

    existing =
      Repo.one(
        from s in ScoutRun, where: s.normalized_name == ^normalized_name, lock: "FOR UPDATE"
      )

    case reusable_status(existing, digest, now) do
      {:reuse, status} -> status
      :new -> admit_or_rate_limit(display_name, normalized_name, scopes, digest, now, existing)
    end
  end

  defp admit_or_rate_limit(display_name, normalized_name, scopes, digest, now, existing) do
    case rate_limit_deadline(now) do
      nil ->
        run = upsert_scout_run!(display_name, normalized_name, scopes, digest, now, existing)
        job = Oban.insert!(oban_name(), CatalogScout.new(%{"scout_id" => run.id}))
        Repo.update!(Ecto.Changeset.change(run, job_id: job.id))
        scout_status(:queued, nil, run.configured_scope_count)

      deadline ->
        scout_status(:rate_limited, deadline, length(scopes))
    end
  end

  defp upsert_scout_run!(display_name, normalized_name, scopes, digest, now, nil) do
    Repo.insert!(%ScoutRun{
      normalized_name: normalized_name,
      display_name: display_name,
      state: "queued",
      config_digest: digest,
      admitted_at: now,
      configured_scope_count: length(scopes),
      scope_inputs: Map.new(scopes, fn s -> {s["league_code"], s} end)
    })
  end

  defp upsert_scout_run!(display_name, _normalized_name, scopes, digest, now, existing) do
    existing
    |> Ecto.Changeset.change(
      display_name: display_name,
      state: "queued",
      config_digest: digest,
      admitted_at: now,
      finished_at: nil,
      next_attempt_at: nil,
      scope_inputs: Map.new(scopes, fn s -> {s["league_code"], s} end),
      synchronization_run_ids: [],
      configured_scope_count: length(scopes),
      request_count: 0,
      error_category: nil
    )
    |> Repo.update!()
  end

  defp reusable_status(%ScoutRun{config_digest: d, state: s} = run, d, _now)
       when s in @active_states,
       do: {:reuse, scout_status(:scouting, nil, run.configured_scope_count)}

  defp reusable_status(%ScoutRun{config_digest: d, state: "found"} = run, d, _now),
    do: {:reuse, scout_status(:found, nil, run.configured_scope_count)}

  defp reusable_status(%ScoutRun{config_digest: d, state: s} = run, d, now)
       when s in ["not_found", "provider_failure"] do
    retry_at =
      run.next_attempt_at || DateTime.add(run.finished_at, @negative_ttl_seconds, :second)

    if DateTime.compare(now, retry_at) == :lt do
      reason = if s == "not_found", do: :cached_miss, else: :provider_failure
      {:reuse, scout_status(reason, retry_at, run.configured_scope_count)}
    else
      :new
    end
  end

  defp reusable_status(_, _, _), do: :new

  defp rate_limit_deadline(now) do
    cutoff = DateTime.add(now, -3_600, :second)

    recent =
      Repo.all(
        from s in ScoutRun,
          where: s.admitted_at >= ^cutoff,
          order_by: s.admitted_at,
          select: s.admitted_at
      )

    if length(recent) >= @hourly_limit,
      do: recent |> Enum.at(length(recent) - @hourly_limit) |> DateTime.add(3_600, :second)
  end

  defp oban_name do
    Application.get_env(:football_market, FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  defp scout_status(state, retry_at, scope_count),
    do: %{state: state, next_attempt_at: retry_at, configured_scope_count: scope_count}

  defp valid_scope?(%{league_code: code, start_year: sy, end_year: ey, source_ref: ref}) do
    supported = Enum.map(Catalog.supported_leagues(), &elem(&1, 0))
    code in supported and is_integer(sy) and ey in [sy, sy + 1] and is_binary(ref)
  end

  defp valid_scope?(_), do: false

  defp valid_name?(value) do
    letters = Regex.scan(~r/\p{L}/u, value) |> length()

    String.length(value) in 2..@max_name_length and letters >= 2 and
      Regex.match?(~r/\A[\p{L}\p{M}][\p{L}\p{M}0-9 .’'-]*\z/u, value)
  end
end
