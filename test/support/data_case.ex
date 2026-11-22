defmodule FootballMarket.DataCase do
  @moduledoc """
  Shared database setup and domain factories for integration and e2e tests.

  Uses real committed PostgreSQL transactions (`sandbox: false`) with fast
  per-test cleanup so deferred PostgreSQL triggers, `REPEATABLE READ` snapshots,
  and live Oban/LiveView processes are exercised identically to production.
  """

  use ExUnit.CaseTemplate

  alias FootballMarket.{Accounts, Catalog, Market, Quotes, Repo, Statistics, Valuation}
  alias FootballMarket.Accounts.AuthenticatedActor

  @data_tables ~w(
    market_order_evaluation_members
    market_conditional_buy_orders
    market_credit_entries
    market_token_transfers
    market_purchases
    market_sales
    market_credit_balances
    market_holdings
    market_issuances
    market_initial_recipients
    quote_evaluation_requests
    quote_calculation_requests
    market_quotes
    quote_calculations
    quote_conversion_mappings
    valuation_presets
    valuation_selection_changes
    valuation_configuration_versions
    performance_enrichments
    statistics_position_basis
    player_match_performances
    matches
    statistics_import_scopes
    catalog_scout_runs
    catalog_source_bindings
    players
    teams
    seasons
    leagues
    positions
    browser_sessions
    api_keys
    password_credentials
    users
    oban_jobs
  )

  using do
    quote do
      alias FootballMarket.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import FootballMarket.DataCase
    end
  end

  setup _tags do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, :auto)
    reset_database!()

    previous_recipients = Application.get_env(:football_market, :initial_issuance_recipients)
    previous_mapping = Application.get_env(:football_market, :quote_mapping_id)
    previous_sync = Application.get_env(:football_market, FootballMarket.Synchronization)

    previous_freshness =
      Application.get_env(:football_market, FootballMarket.Statistics.Freshness)

    on_exit(fn ->
      restore_env(:initial_issuance_recipients, previous_recipients)
      restore_env(:quote_mapping_id, previous_mapping)
      restore_env(FootballMarket.Synchronization, previous_sync)
      restore_env(FootballMarket.Statistics.Freshness, previous_freshness)
      reset_database!()
    end)

    :ok
  end

  def reset_database! do
    Repo.transaction(fn ->
      Repo.query!("SET LOCAL session_replication_role = 'replica'")

      Enum.each(@data_tables, fn table ->
        Repo.query!("DELETE FROM #{table}")
      end)

      Repo.query!(
        "UPDATE market_order_evaluation_passes SET state = 'idle', generation = 0, cursor_ordinal = 0, rescan_requested = false, upper_created_at = NULL, upper_order_id = NULL, started_at = NULL, updated_at = NULL WHERE id = 1"
      )
    end)

    :ok
  end

  # --- Reusable Domain Factories ---

  def create_user!(email \\ nil, password \\ "SuperSecretPassword123!") do
    email = email || "user-#{System.unique_integer([:positive])}@example.com"
    {:ok, user} = Accounts.register_user(%{email: email, password: password})
    Map.put(user, :password, password)
  end

  def create_admin!(email \\ nil) do
    admin = create_user!(email || "admin-#{System.unique_integer([:positive])}@example.com")
    Application.put_env(:football_market, :initial_issuance_recipients, [admin.id])
    admin
  end

  def actor_for(user, method \\ :jwt) do
    %AuthenticatedActor{
      account_id: user.id,
      authentication_method: method,
      credential_id: Ecto.UUID.generate()
    }
  end

  def create_catalog_fixture! do
    {:ok, league} = Catalog.create_league(%{code: "PL", name: "Premier League"})

    {:ok, season} =
      Catalog.create_season(%{league_id: league.id, start_year: 2026, end_year: 2027})

    {:ok, home} = Catalog.create_team(%{season_id: season.id, code: "ARS", name: "Arsenal FC"})
    {:ok, away} = Catalog.create_team(%{season_id: season.id, code: "LIV", name: "Liverpool FC"})
    {:ok, gk} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})
    {:ok, def_pos} = Catalog.create_position(%{code: "DEF", name: "Defender"})
    {:ok, mid} = Catalog.create_position(%{code: "MID", name: "Midfielder"})
    {:ok, fwd} = Catalog.create_position(%{code: "FWD", name: "Forward"})

    {:ok, player} =
      Catalog.create_player(%{
        team_id: home.id,
        position_id: fwd.id,
        catalog_identity: "pl-fwd-#{System.unique_integer([:positive])}",
        display_name: "Bukayo Saka"
      })

    %{
      league: league,
      season: season,
      home_team: home,
      away_team: away,
      positions: %{gk: gk, def: def_pos, mid: mid, fwd: fwd},
      player: player
    }
  end

  def create_active_strategy_and_mapping!(positions) do
    mapping = [
      {positions.gk.id, :goalkeeper},
      {positions.def.id, :defender},
      {positions.mid.id, :midfielder},
      {positions.fwd.id, :forward}
    ]

    {:ok, version} =
      Valuation.Configurations.create(Valuation.Configurations.preset_rules("balanced", mapping))

    {:ok, _} = Valuation.Configurations.activate(version.id, nil)
    {:ok, quote_mapping} = Quotes.save_mapping("standard", "v1", Decimal.new("10.00"))
    Application.put_env(:football_market, :quote_mapping_id, quote_mapping.id)
    %{version: version, mapping: quote_mapping}
  end

  def record_performance_and_quote!(fixture, mapping_id, attrs \\ %{}) do
    kickoff =
      Map.get(
        attrs,
        :kickoff_at,
        DateTime.add(DateTime.utc_now(), -3600, :second) |> DateTime.truncate(:microsecond)
      )

    {:ok, match} =
      Statistics.record_match(%{
        season_id: fixture.season.id,
        home_team_id: fixture.home_team.id,
        away_team_id: fixture.away_team.id,
        match_identity: "match-#{System.unique_integer([:positive])}",
        kickoff_at: kickoff
      })

    perf_attrs =
      Map.merge(
        %{
          match_id: match.id,
          player_id: fixture.player.id,
          team_id: fixture.home_team.id,
          position_id: fixture.player.position_id,
          minutes_played: 90,
          goals: 2,
          assists: 1,
          shots_on_target: 4,
          tackles: 2,
          interceptions: 1,
          saves: 0,
          goals_conceded: 0,
          yellow_cards: 0,
          red_cards: 0
        },
        Map.drop(attrs, [:kickoff_at])
      )

    {:ok, perf} = Statistics.record_performance(perf_attrs)

    week_start = DateTime.add(kickoff, -86_400, :second) |> DateTime.truncate(:microsecond)
    week_end = DateTime.add(kickoff, 86_400, :second) |> DateTime.truncate(:microsecond)

    {:ok, published} =
      Quotes.calculate_and_publish(
        %{
          player_id: fixture.player.id,
          season_id: fixture.season.id,
          week_start: week_start,
          week_end: week_end
        },
        :active,
        mapping_id
      )

    Map.merge(published, %{match: match, performance: perf})
  end

  def create_tradable_market!(investor_balance \\ "500.00") do
    admin = create_admin!()
    investor = create_user!()
    fixture = create_catalog_fixture!()
    {:ok, issuance} = Market.initialize_player(fixture.player.id)
    %{version: version, mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)
    published = record_performance_and_quote!(fixture, mapping.id)
    {:ok, _} = Market.credit_account(investor.id, Decimal.new(investor_balance))
    {:ok, _} = Market.credit_account(admin.id, Decimal.new("1000.00"))

    Map.merge(fixture, %{
      admin: admin,
      investor: investor,
      issuance: issuance,
      version: version,
      mapping: mapping,
      quote: published.quote,
      calculation: published.calculation
    })
  end

  defp restore_env(key, nil), do: Application.delete_env(:football_market, key)
  defp restore_env(key, value), do: Application.put_env(:football_market, key, value)
end
