defmodule FootballMarket.Catalog.DevelopmentSeed do
  @moduledoc "Reconciles the fixed development-only catalog manifest."

  import Ecto.Query

  alias Ecto.Multi
  alias FootballMarket.Catalog
  alias FootballMarket.Catalog.Team
  alias FootballMarket.Catalog.DevelopmentSeed.Manifest
  alias FootballMarket.Repo

  @type seed_error :: %{
          required(:category) => atom(),
          required(:entity) => atom(),
          required(:identity) => String.t(),
          optional(:cause) => atom()
        }

  @fallback_error %{
    category: :persistence,
    entity: :seed,
    identity: "development-seed",
    cause: :write_failed
  }

  @spec run() :: {:ok, map()} | {:error, seed_error()}
  def run do
    with :ok <- authorize(),
         manifest <- Manifest.definition(),
         :ok <- validate(manifest) do
      manifest
      |> build_multi()
      |> Repo.transaction()
      |> transaction_result(manifest)
    end
  end

  @spec enabled?() :: boolean()
  def enabled?,
    do: Application.get_env(:football_market, :development_seed_enabled, false) == true

  @doc """
  Reduces an internal seed failure to the stable, non-sensitive command contract.

  Unknown categories, causes, entities, identities, and malformed values collapse to
  a generic write failure rather than crossing the command boundary.
  """
  @spec public_error(term()) :: seed_error()
  def public_error(%{} = candidate) do
    category = Map.get(candidate, :category)
    entity = Map.get(candidate, :entity)
    identity = Map.get(candidate, :identity)
    cause = Map.get(candidate, :cause)

    if allowed_error_shape?(category, entity, cause) and public_identity?(entity, identity) do
      error(category, entity, identity, cause)
    else
      @fallback_error
    end
  end

  def public_error(_candidate), do: @fallback_error

  defp authorize do
    if enabled?(), do: :ok, else: {:error, error(:disabled, :seed, "development-seed")}
  end

  defp validate(manifest) do
    case Manifest.validate(manifest) do
      :ok ->
        :ok

      {:error, _errors} ->
        {:error, error(:validation, :manifest, "development-seed", :invalid_manifest)}
    end
  end

  defp build_multi(manifest) do
    Multi.new()
    |> add_leagues(manifest.leagues)
    |> add_seasons(manifest.seasons, manifest.leagues)
    |> add_teams(manifest.teams, manifest.seasons, manifest.leagues)
    |> add_positions(manifest.positions)
    |> add_players(manifest.players, manifest.teams, manifest.seasons, manifest.leagues)
  end

  defp add_leagues(multi, leagues) do
    Enum.reduce(leagues, multi, fn league, acc ->
      Multi.run(acc, step(:league, league.code), fn _repo, _changes ->
        reconcile_dual(
          Catalog.get_league_by_code(league.code),
          Catalog.get_league_by_name(league.name),
          :league,
          league.code,
          fn -> Catalog.create_league(%{code: league.code, name: league.name}) end
        )
      end)
    end)
  end

  defp add_seasons(multi, seasons, leagues) do
    Enum.reduce(seasons, multi, fn season, acc ->
      league = fetch!(leagues, season.league)
      identity = season_identity(league, season)

      Multi.run(acc, step(:season, identity), fn _repo, changes ->
        league_record = record!(changes, step(:league, league.code))

        case Catalog.get_season(league_record.id, season.start_year, season.end_year) do
          {:ok, record} ->
            reused(record)

          {:error, :not_found} ->
            created(:season, identity, fn ->
              Catalog.create_season(%{
                league_id: league_record.id,
                start_year: season.start_year,
                end_year: season.end_year
              })
            end)
        end
      end)
    end)
  end

  defp add_teams(multi, teams, seasons, leagues) do
    Enum.reduce(teams, multi, fn team, acc ->
      season = fetch!(seasons, team.season)
      league = fetch!(leagues, season.league)

      Multi.run(acc, step(:team, team_identity(team, league, season)), fn _repo, changes ->
        season_record = record!(changes, step(:season, season_identity(league, season)))
        identity = team_identity(team, league, season)

        reconcile_team(
          Catalog.get_team_by_code(season_record.id, team.code),
          Catalog.get_team_by_name(season_record.id, team.name),
          season_record.id,
          team,
          identity,
          fn ->
            Catalog.create_team(%{
              season_id: season_record.id,
              code: team.code,
              name: team.name
            })
          end
        )
      end)
    end)
  end

  defp add_positions(multi, positions) do
    Enum.reduce(positions, multi, fn position, acc ->
      Multi.run(acc, step(:position, position.code), fn _repo, _changes ->
        reconcile_dual(
          Catalog.get_position_by_code(position.code),
          Catalog.get_position_by_name(position.name),
          :position,
          position.code,
          fn -> Catalog.create_position(%{code: position.code, name: position.name}) end
        )
      end)
    end)
  end

  defp add_players(multi, players, teams, seasons, leagues) do
    Enum.reduce(players, multi, fn player, acc ->
      team = fetch!(teams, player.team)
      season = fetch!(seasons, player.season)
      league = fetch!(leagues, season.league)

      Multi.run(acc, step(:player, player.catalog_identity), fn _repo, changes ->
        team_record = record!(changes, step(:team, team_identity(team, league, season)))
        position_record = record!(changes, step(:position, position_code(player.position)))

        case Catalog.get_player(team_record.season_id, player.catalog_identity) do
          {:ok, existing} ->
            cond do
              existing.display_name != player.display_name ->
                {:error, error(:conflict, :player, player.catalog_identity, :attribute_mismatch)}

              existing.team_id != team_record.id or existing.position_id != position_record.id ->
                {:error,
                 error(:conflict, :player, player.catalog_identity, :relationship_mismatch)}

              true ->
                reused(existing)
            end

          {:error, :not_found} ->
            created(:player, player.catalog_identity, fn ->
              Catalog.create_player(%{
                team_id: team_record.id,
                position_id: position_record.id,
                catalog_identity: player.catalog_identity,
                display_name: player.display_name
              })
            end)
        end
      end)
    end)
  end

  defp reconcile_dual(code_result, name_result, entity, identity, create_fun) do
    case {code_result, name_result} do
      {{:error, :not_found}, {:error, :not_found}} ->
        created(entity, identity, create_fun)

      {{:ok, code_record}, {:ok, name_record}} when code_record.id == name_record.id ->
        reused(code_record)

      _other ->
        {:error, error(:conflict, entity, identity, :alternate_identity)}
    end
  end

  defp reconcile_team(code_result, name_result, season_id, team, identity, create_fun) do
    case {code_result, name_result} do
      {{:error, :not_found}, {:error, :not_found}} ->
        if misplaced_team?(season_id, team.code, team.name) do
          {:error, error(:conflict, :team, identity, :misplaced_relationship)}
        else
          created(:team, identity, create_fun)
        end

      {{:ok, code_record}, {:ok, name_record}} when code_record.id == name_record.id ->
        reused(code_record)

      _other ->
        {:error, error(:conflict, :team, identity, :alternate_identity)}
    end
  end

  defp misplaced_team?(season_id, code, name) do
    Team
    |> where([team], team.season_id != ^season_id)
    |> where(
      [team],
      fragment("lower(btrim(?))", team.code) == fragment("lower(btrim(?))", ^code) or
        fragment("lower(btrim(?))", team.name) == fragment("lower(btrim(?))", ^name)
    )
    |> Repo.exists?()
  end

  defp created(entity, identity, fun) do
    try do
      case fun.() do
        {:ok, record} ->
          {:ok, %{record: record, status: :created}}

        {:error, %Ecto.Changeset{}} ->
          {:error, error(:persistence, entity, identity, :concurrent_write)}

        {:error, _reason} ->
          {:error, error(:persistence, entity, identity, :database)}
      end
    rescue
      _exception -> {:error, error(:persistence, entity, identity, :database)}
    catch
      _kind, _reason -> {:error, error(:persistence, entity, identity, :database)}
    end
  end

  defp reused(record), do: {:ok, %{record: record, status: :reused}}

  defp transaction_result({:ok, changes}, manifest) do
    created = Enum.count(changes, fn {_step, result} -> result.status == :created end)
    reused = map_size(changes) - created

    {:ok,
     %{
       total: map_size(changes),
       created: created,
       reused: reused,
       totals: %{
         leagues: length(manifest.leagues),
         seasons: length(manifest.seasons),
         teams: length(manifest.teams),
         positions: length(manifest.positions),
         players: length(manifest.players)
       }
     }}
  end

  defp transaction_result(
         {:error, _operation, %{category: _, entity: _, identity: _} = error, _changes_so_far},
         _manifest
       ),
       do: {:error, public_error(error)}

  defp transaction_result({:error, {entity, identity}, _reason, _changes_so_far}, _manifest) do
    {:error, error(:persistence, entity, identity, :write_failed)}
  end

  defp step(entity, identity), do: {entity, identity}
  defp record!(changes, operation), do: changes |> Map.fetch!(operation) |> Map.fetch!(:record)
  defp fetch!(items, key), do: Enum.find(items, &(Map.fetch!(&1, :key) == key))

  defp season_identity(league, season),
    do: "#{league.code}:#{season.start_year}-#{season.end_year}"

  defp team_identity(team, league, season),
    do: "#{league.code}:#{season.start_year}-#{season.end_year}:#{team.code}"

  defp position_code(key), do: Manifest.definition().positions |> fetch!(key) |> Map.fetch!(:code)

  defp allowed_error_shape?(:disabled, :seed, nil), do: true
  defp allowed_error_shape?(:validation, :manifest, :invalid_manifest), do: true

  defp allowed_error_shape?(:conflict, entity, :alternate_identity)
       when entity in [:league, :team, :position],
       do: true

  defp allowed_error_shape?(:conflict, :team, :misplaced_relationship), do: true
  defp allowed_error_shape?(:conflict, :player, :attribute_mismatch), do: true
  defp allowed_error_shape?(:conflict, :player, :relationship_mismatch), do: true

  defp allowed_error_shape?(:persistence, entity, cause)
       when entity in [:league, :season, :team, :position, :player] and
              cause in [:database, :write_failed, :concurrent_write],
       do: true

  defp allowed_error_shape?(:persistence, :seed, :database_unavailable), do: true
  defp allowed_error_shape?(_category, _entity, _cause), do: false

  defp public_identity?(:seed, "development-seed"), do: true
  defp public_identity?(:manifest, "development-seed"), do: true

  defp public_identity?(entity, identity) when is_binary(identity) do
    manifest = Manifest.definition()

    case entity do
      :league ->
        Enum.any?(manifest.leagues, &(&1.code == identity))

      :season ->
        Enum.any?(manifest.seasons, fn season ->
          league = fetch!(manifest.leagues, season.league)
          season_identity(league, season) == identity
        end)

      :team ->
        Enum.any?(manifest.teams, fn team ->
          season = fetch!(manifest.seasons, team.season)
          league = fetch!(manifest.leagues, season.league)
          team_identity(team, league, season) == identity
        end)

      :position ->
        Enum.any?(manifest.positions, &(&1.code == identity))

      :player ->
        Enum.any?(manifest.players, &(&1.catalog_identity == identity))

      _other ->
        false
    end
  end

  defp public_identity?(_entity, _identity), do: false

  defp error(category, entity, identity, cause \\ nil) do
    %{category: category, entity: entity, identity: identity}
    |> maybe_put(:cause, cause)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
