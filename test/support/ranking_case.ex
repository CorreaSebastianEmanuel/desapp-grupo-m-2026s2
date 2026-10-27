defmodule FootballMarket.RankingCase do
  @moduledoc false
  alias FootballMarket.{Quotes, Repo, Valuation.Configurations}

  def fixture(opts \\ []) do
    alias FootballMarket.Market.Quote

    owned = FootballMarket.ValuationConfigurationCase.private_schema()
    fixture = FootballMarket.QuotesCase.fixture()

    if Keyword.get(opts, :active, true) do
      {:ok, _} = Configurations.activate(fixture.configuration.id, nil)
    end

    quote =
      if Keyword.get(opts, :quote, true) do
        {:ok, result} =
          Quotes.request(fixture.subject, :active, fixture.mapping.id, Ecto.UUID.generate())

        Repo.get_by!(Quote, calculation_id: result.calculation.id)
      end

    Map.merge(fixture, %{quote: quote, schema: owned.schema, repo: owned.repo})
  end

  def add_performance_quote(fixture, identity \\ "ranking-followup") do
    {_match, _performance} =
      FootballMarket.ValuationConfigurationCase.record(
        fixture.base,
        identity <> "-" <> Ecto.UUID.generate(),
        %{goals: 2}
      )

    subject = %{
      player_id: fixture.player.id,
      season_id: fixture.base.season.id,
      week_start: "2026-10-05T00:00:00Z",
      week_end: "2026-10-12T00:00:00Z"
    }

    {:ok, %{calculation: calculation}} =
      Quotes.request(subject, :active, fixture.mapping.id, Ecto.UUID.generate())

    Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
  end

  def add_equal_time_quote(fixture) do
    alias FootballMarket.{Catalog.Player, Repo}
    alias FootballMarket.Quotes.{Calculation, Store}

    original = Repo.get!(Calculation, fixture.quote.calculation_id)
    id = Ecto.UUID.generate()

    calculation = %{
      original
      | id: id,
        canonical_identity: Map.put(original.canonical_identity, "ranking_fixture_id", id),
        effective_at: fixture.quote.effective_at,
        inserted_at: fixture.quote.effective_at
    }

    player = Repo.get!(Player, fixture.player.id)

    managed = %{
      strategy_id: fixture.configuration.strategy_id,
      formula_version: fixture.configuration.formula_version,
      configuration_version_id: fixture.configuration.id
    }

    {:ok, _evaluation} =
      Repo.transaction(fn ->
        Repo.insert!(calculation)

        Store.confirm!(
          calculation,
          player,
          managed,
          fixture.mapping,
          fixture.quote.unit_price,
          fixture.quote.effective_at
        )
      end)

    Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
  end

  def add_issued_player(fixture, scale \\ Decimal.new("1.25")) do
    player_fixture = new_issued_fixture(fixture)

    {_match, _performance} =
      FootballMarket.ValuationCase.record(
        player_fixture.base,
        "ranking-issued-" <> Ecto.UUID.generate(),
        %{goals: 2}
      )

    mapping = save_mapping(scale)

    {:ok, %{calculation: calculation}} =
      Quotes.request(player_fixture.subject, {:version, fixture.configuration.id}, mapping.id)

    quote = Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
    Map.merge(player_fixture, %{mapping: mapping, quote: quote})
  end

  def add_no_quote_player(fixture) do
    player_fixture = new_issued_fixture(fixture)

    {_match, _performance} =
      FootballMarket.ValuationConfigurationCase.record(
        player_fixture.base,
        "ranking-no-quote-" <> Ecto.UUID.generate(),
        %{goals: 0}
      )

    {:ok, %{calculation: %{status: "no_quote"}}} =
      Quotes.request(
        player_fixture.subject,
        {:version, fixture.configuration.id},
        fixture.mapping.id
      )

    player_fixture
  end

  def add_no_history_player(fixture), do: new_issued_fixture(fixture)

  defp new_issued_fixture(fixture) do
    alias FootballMarket.{Market, StatisticsCase}

    base = StatisticsCase.unique_fixture()
    player = hd(base.players)
    {:ok, %{outcome: :issued}} = Market.initialize_player(player.id)

    %{
      base: base,
      player: player,
      subject: FootballMarket.ValuationConfigurationCase.subject(base),
      configuration: fixture.configuration,
      mapping: fixture.mapping,
      user: fixture.user,
      repo: fixture.repo,
      schema: fixture.schema
    }
  end

  def save_mapping(scale) do
    {:ok, mapping} =
      Quotes.Mappings.save("ranking-" <> Ecto.UUID.generate(), Ecto.UUID.generate(), scale)

    mapping
  end

  def rules(fixture), do: FootballMarket.QuotesCase.rules(fixture.base)

  def select_invalid_configuration(fixture) do
    version =
      Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
        strategy_id: "balanced",
        formula_version: "1",
        rules: %{}
      })

    Repo.insert!(%FootballMarket.Valuation.Configurations.SelectionChange{
      previous_version_id: fixture.configuration.id,
      new_version_id: version.id
    })

    version
  end

  def protected_snapshot do
    Map.new(
      ~w(market_initial_recipients market_quotes market_holdings market_issuances
         users password_credentials api_keys matches player_match_performances
         valuation_configuration_versions valuation_selection_changes
         quote_conversion_mappings quote_calculations quote_calculation_requests
         quote_evaluation_requests quote_evaluation_delivery_attempts oban_jobs),
      fn table ->
        rows =
          Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows

        {table, Enum.map(rows, fn [row] -> :crypto.hash(:sha256, row) end)}
      end
    )
  end
end
