defmodule FootballMarket.Catalog.DevelopmentSeed.Manifest do
  @moduledoc false

  @positions [
    %{key: :goalkeeper, code: "GK", name: "Goalkeeper"},
    %{key: :defender, code: "DEF", name: "Defender"},
    %{key: :midfielder, code: "MID", name: "Midfielder"},
    %{key: :forward, code: "FWD", name: "Forward"}
  ]

  @leagues [
    %{key: :premier_league, code: "PL", name: "Premier League"},
    %{key: :bundesliga, code: "BL1", name: "Bundesliga"},
    %{key: :la_liga, code: "PD", name: "La Liga"},
    %{key: :serie_a, code: "SA", name: "Serie A"},
    %{key: :ligue_1, code: "FL1", name: "Ligue 1"}
  ]

  @seasons [
    %{key: :pl_2026, league: :premier_league, start_year: 2026, end_year: 2027},
    %{key: :bl1_2026, league: :bundesliga, start_year: 2026, end_year: 2027},
    %{key: :pd_2026, league: :la_liga, start_year: 2026, end_year: 2027},
    %{key: :sa_2026, league: :serie_a, start_year: 2026, end_year: 2027},
    %{key: :fl1_2026, league: :ligue_1, start_year: 2026, end_year: 2027}
  ]

  @teams [
    %{key: :pl_alpha, season: :pl_2026, code: "DEMO-PL-A", name: "Demo PL Alpha FC"},
    %{key: :pl_beta, season: :pl_2026, code: "DEMO-PL-B", name: "Demo PL Beta FC"},
    %{key: :bl1_alpha, season: :bl1_2026, code: "DEMO-BL1-A", name: "Demo BL1 Alpha FC"},
    %{key: :bl1_beta, season: :bl1_2026, code: "DEMO-BL1-B", name: "Demo BL1 Beta FC"},
    %{key: :pd_alpha, season: :pd_2026, code: "DEMO-PD-A", name: "Demo PD Alpha FC"},
    %{key: :pd_beta, season: :pd_2026, code: "DEMO-PD-B", name: "Demo PD Beta FC"},
    %{key: :sa_alpha, season: :sa_2026, code: "DEMO-SA-A", name: "Demo SA Alpha FC"},
    %{key: :sa_beta, season: :sa_2026, code: "DEMO-SA-B", name: "Demo SA Beta FC"},
    %{key: :fl1_alpha, season: :fl1_2026, code: "DEMO-FL1-A", name: "Demo FL1 Alpha FC"},
    %{key: :fl1_beta, season: :fl1_2026, code: "DEMO-FL1-B", name: "Demo FL1 Beta FC"}
  ]

  @players [
    %{
      season: :pl_2026,
      team: :pl_alpha,
      position: :goalkeeper,
      catalog_identity: "demo-2026-27-pl-gk",
      display_name: "Demo PL Goalkeeper"
    },
    %{
      season: :pl_2026,
      team: :pl_alpha,
      position: :defender,
      catalog_identity: "demo-2026-27-pl-def",
      display_name: "Demo PL Defender"
    },
    %{
      season: :pl_2026,
      team: :pl_beta,
      position: :midfielder,
      catalog_identity: "demo-2026-27-pl-mid",
      display_name: "Demo PL Midfielder"
    },
    %{
      season: :pl_2026,
      team: :pl_beta,
      position: :forward,
      catalog_identity: "demo-2026-27-pl-fwd",
      display_name: "Demo PL Forward"
    },
    %{
      season: :bl1_2026,
      team: :bl1_alpha,
      position: :goalkeeper,
      catalog_identity: "demo-2026-27-bl1-gk",
      display_name: "Demo BL1 Goalkeeper"
    },
    %{
      season: :bl1_2026,
      team: :bl1_alpha,
      position: :defender,
      catalog_identity: "demo-2026-27-bl1-def",
      display_name: "Demo BL1 Defender"
    },
    %{
      season: :bl1_2026,
      team: :bl1_beta,
      position: :midfielder,
      catalog_identity: "demo-2026-27-bl1-mid",
      display_name: "Demo BL1 Midfielder"
    },
    %{
      season: :bl1_2026,
      team: :bl1_beta,
      position: :forward,
      catalog_identity: "demo-2026-27-bl1-fwd",
      display_name: "Demo BL1 Forward"
    },
    %{
      season: :pd_2026,
      team: :pd_alpha,
      position: :goalkeeper,
      catalog_identity: "demo-2026-27-pd-gk",
      display_name: "Demo PD Goalkeeper"
    },
    %{
      season: :pd_2026,
      team: :pd_alpha,
      position: :defender,
      catalog_identity: "demo-2026-27-pd-def",
      display_name: "Demo PD Defender"
    },
    %{
      season: :pd_2026,
      team: :pd_beta,
      position: :midfielder,
      catalog_identity: "demo-2026-27-pd-mid",
      display_name: "Demo PD Midfielder"
    },
    %{
      season: :pd_2026,
      team: :pd_beta,
      position: :forward,
      catalog_identity: "demo-2026-27-pd-fwd",
      display_name: "Demo PD Forward"
    },
    %{
      season: :sa_2026,
      team: :sa_alpha,
      position: :goalkeeper,
      catalog_identity: "demo-2026-27-sa-gk",
      display_name: "Demo SA Goalkeeper"
    },
    %{
      season: :sa_2026,
      team: :sa_alpha,
      position: :defender,
      catalog_identity: "demo-2026-27-sa-def",
      display_name: "Demo SA Defender"
    },
    %{
      season: :sa_2026,
      team: :sa_beta,
      position: :midfielder,
      catalog_identity: "demo-2026-27-sa-mid",
      display_name: "Demo SA Midfielder"
    },
    %{
      season: :sa_2026,
      team: :sa_beta,
      position: :forward,
      catalog_identity: "demo-2026-27-sa-fwd",
      display_name: "Demo SA Forward"
    },
    %{
      season: :fl1_2026,
      team: :fl1_alpha,
      position: :goalkeeper,
      catalog_identity: "demo-2026-27-fl1-gk",
      display_name: "Demo FL1 Goalkeeper"
    },
    %{
      season: :fl1_2026,
      team: :fl1_alpha,
      position: :defender,
      catalog_identity: "demo-2026-27-fl1-def",
      display_name: "Demo FL1 Defender"
    },
    %{
      season: :fl1_2026,
      team: :fl1_beta,
      position: :midfielder,
      catalog_identity: "demo-2026-27-fl1-mid",
      display_name: "Demo FL1 Midfielder"
    },
    %{
      season: :fl1_2026,
      team: :fl1_beta,
      position: :forward,
      catalog_identity: "demo-2026-27-fl1-fwd",
      display_name: "Demo FL1 Forward"
    }
  ]

  @spec definition() :: map()
  def definition do
    %{
      leagues: @leagues,
      seasons: @seasons,
      teams: @teams,
      positions: @positions,
      players: @players
    }
  end

  @spec validate(map()) :: :ok | {:error, [atom()]}
  def validate(manifest) when is_map(manifest) do
    errors =
      []
      |> require_count(manifest, :leagues, 5, :invalid_league_count)
      |> require_count(manifest, :seasons, 5, :invalid_season_count)
      |> require_count(manifest, :teams, 10, :invalid_team_count)
      |> require_count(manifest, :positions, 4, :invalid_position_count)
      |> require_count(manifest, :players, 20, :invalid_player_count)
      |> validate_leagues(manifest)
      |> validate_seasons(manifest)
      |> validate_teams(manifest)
      |> validate_positions(manifest)
      |> validate_players(manifest)

    case Enum.uniq(errors) do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  def validate(_), do: {:error, [:invalid_manifest]}

  defp require_count(errors, manifest, key, count, error) do
    if is_list(manifest[key]) and length(manifest[key]) == count,
      do: errors,
      else: [error | errors]
  end

  defp validate_leagues(errors, manifest) do
    leagues = records(manifest, :leagues)

    if valid_collection?(manifest, :leagues, [:key, :code, :name]) do
      pairs = Enum.map(leagues, &{Map.get(&1, :code), Map.get(&1, :name)})

      errors
      |> add_unless(pairs == FootballMarket.Catalog.supported_leagues(), :invalid_leagues)
      |> add_unless(unique?(leagues, &Map.get(&1, :key)), :duplicate_league_key)
    else
      [:invalid_league_structure | errors]
    end
  end

  defp validate_seasons(errors, manifest) do
    seasons = records(manifest, :seasons)
    league_keys = key_set(manifest, :leagues)

    if valid_collection?(manifest, :seasons, [:key, :league, :start_year, :end_year]) do
      errors
      |> add_unless(unique?(seasons, &Map.get(&1, :key)), :duplicate_season_key)
      |> add_unless(
        Enum.all?(seasons, fn season ->
          Map.get(season, :start_year) == 2026 and Map.get(season, :end_year) == 2027
        end),
        :invalid_season_years
      )
      |> add_unless(
        Enum.all?(seasons, &MapSet.member?(league_keys, Map.get(&1, :league))),
        :unknown_season_league
      )
      |> add_unless(
        exact_distribution?(seasons, :league, league_keys, 1),
        :invalid_season_distribution
      )
    else
      [:invalid_season_structure | errors]
    end
  end

  defp validate_teams(errors, manifest) do
    teams = records(manifest, :teams)
    season_keys = key_set(manifest, :seasons)

    if valid_collection?(manifest, :teams, [:key, :season, :code, :name]) do
      errors
      |> add_unless(unique?(teams, &Map.get(&1, :key)), :duplicate_team_key)
      |> add_unless(
        unique?(teams, &{Map.get(&1, :season), normalized(Map.get(&1, :code))}),
        :duplicate_team_code
      )
      |> add_unless(
        unique?(teams, &{Map.get(&1, :season), normalized(Map.get(&1, :name))}),
        :duplicate_team_name
      )
      |> add_unless(
        Enum.all?(teams, &MapSet.member?(season_keys, Map.get(&1, :season))),
        :unknown_team_season
      )
      |> add_unless(
        Enum.all?(teams, &(present?(Map.get(&1, :code)) and present?(Map.get(&1, :name)))),
        :invalid_team_value
      )
      |> add_unless(
        exact_distribution?(teams, :season, season_keys, 2),
        :invalid_team_distribution
      )
    else
      [:invalid_team_structure | errors]
    end
  end

  defp validate_positions(errors, manifest) do
    positions = records(manifest, :positions)

    if valid_collection?(manifest, :positions, [:key, :code, :name]) do
      pairs = Enum.map(positions, &{Map.get(&1, :code), Map.get(&1, :name)})

      errors
      |> add_unless(pairs == Enum.map(@positions, &{&1.code, &1.name}), :invalid_positions)
      |> add_unless(unique?(positions, &Map.get(&1, :key)), :duplicate_position_key)
    else
      [:invalid_position_structure | errors]
    end
  end

  defp validate_players(errors, manifest) do
    players = records(manifest, :players)
    season_keys = key_set(manifest, :seasons)
    team_keys = key_set(manifest, :teams)
    position_keys = key_set(manifest, :positions)

    if valid_collection?(manifest, :players, [
         :season,
         :team,
         :position,
         :catalog_identity,
         :display_name
       ]) do
      errors
      |> add_unless(
        unique?(
          players,
          &{
            Map.get(&1, :season),
            normalized(Map.get(&1, :catalog_identity))
          }
        ),
        :duplicate_player_identity
      )
      |> add_unless(
        Enum.all?(players, &MapSet.member?(season_keys, Map.get(&1, :season))),
        :unknown_player_season
      )
      |> add_unless(
        Enum.all?(players, &MapSet.member?(team_keys, Map.get(&1, :team))),
        :unknown_player_team
      )
      |> add_unless(
        Enum.all?(players, &MapSet.member?(position_keys, Map.get(&1, :position))),
        :unknown_player_position
      )
      |> add_unless(
        Enum.all?(players, fn player ->
          present?(Map.get(player, :catalog_identity)) and
            present?(Map.get(player, :display_name))
        end),
        :invalid_player_value
      )
      |> add_unless(
        players_match_team_seasons?(players, records(manifest, :teams)),
        :player_team_season_mismatch
      )
      |> add_unless(
        exact_distribution?(players, :season, season_keys, 4),
        :invalid_player_distribution
      )
      |> add_unless(
        exact_distribution?(players, :team, team_keys, 2),
        :invalid_team_player_distribution
      )
      |> add_unless(
        positions_complete_per_season?(players, season_keys, position_keys),
        :invalid_position_distribution
      )
    else
      [:invalid_player_structure | errors]
    end
  end

  defp players_match_team_seasons?(players, teams) do
    team_seasons =
      teams
      |> Enum.filter(&is_map/1)
      |> Map.new(&{Map.get(&1, :key), Map.get(&1, :season)})

    Enum.all?(players, &(Map.get(team_seasons, Map.get(&1, :team)) == Map.get(&1, :season)))
  end

  defp exact_distribution?(items, field, expected_keys, expected_count) do
    Enum.all?(expected_keys, fn key ->
      Enum.count(items, &(Map.get(&1, field) == key)) == expected_count
    end)
  end

  defp positions_complete_per_season?(players, season_keys, position_keys) do
    Enum.all?(season_keys, fn season_key ->
      players
      |> Enum.filter(&(Map.get(&1, :season) == season_key))
      |> MapSet.new(&Map.get(&1, :position))
      |> MapSet.equal?(position_keys)
    end)
  end

  defp key_set(manifest, key) do
    manifest
    |> records(key)
    |> Enum.filter(&is_map/1)
    |> MapSet.new(&Map.get(&1, :key))
  end

  defp records(manifest, key) do
    case Map.get(manifest, key) do
      records when is_list(records) -> records
      _other -> []
    end
  end

  defp valid_collection?(manifest, key, fields) do
    case Map.get(manifest, key) do
      records when is_list(records) ->
        Enum.all?(records, fn
          record when is_map(record) -> Enum.all?(fields, &Map.has_key?(record, &1))
          _other -> false
        end)

      _other ->
        false
    end
  end

  defp unique?(items, fun),
    do: items |> Enum.map(fun) |> then(&(length(&1) == length(Enum.uniq(&1))))

  defp present?(value), do: is_binary(value) and String.trim(value) != ""
  defp normalized(value) when is_binary(value), do: value |> String.trim() |> String.downcase()
  defp normalized(value), do: value
  defp add_unless(errors, true, _error), do: errors
  defp add_unless(errors, false, error), do: [error | errors]
end
