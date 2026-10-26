defmodule FootballMarket.QuotesCase do
  @moduledoc false
  alias FootballMarket.{Repo, ValuationCase, ValuationConfigurationCase}

  def fixture do
    f = ValuationCase.fixture()
    old_recipients = Application.get_env(:football_market, :initial_issuance_recipients)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(:football_market, :initial_issuance_recipients, old_recipients)
    end)

    {:ok, user} =
      FootballMarket.Accounts.register_user(%{
        email: "quote-fixture-#{System.unique_integer([:positive])}@example.test",
        password: "quote-fixture-password"
      })

    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])

    {:ok, %{outcome: :issued, issuance: issuance}} =
      FootballMarket.Market.initialize_player(hd(f.players).id)

    {match, performance} =
      ValuationCase.record(f, "task026-quote-#{Ecto.UUID.generate()}", %{goals: 1})

    {:ok, configuration} = FootballMarket.Valuation.Configurations.create(rules(f))

    {:ok, mapping} =
      FootballMarket.Quotes.Mappings.save(
        "task026-fixture",
        Ecto.UUID.generate(),
        mapping_scale()
      )

    %{
      base: f,
      subject: ValuationConfigurationCase.subject(f),
      player: hd(f.players),
      match: match,
      performance: performance,
      issuance: issuance,
      user: Repo.get!(FootballMarket.Accounts.User, user.id),
      configuration: configuration,
      mapping: mapping
    }
  end

  # Read fixtures deliberately supply dates and prices; the real confirmation
  # store enforces calculation/quote/event linkage without rewriting history.
  def dated_quote(f, effective_at, price \\ "1.25") do
    id = Ecto.UUID.generate()

    {:ok, quote} =
      Repo.transaction(fn ->
        calculation =
          Repo.insert!(%FootballMarket.Quotes.Calculation{
            id: id,
            player_id: f.player.id,
            season_id: f.subject.season_id,
            week_start: %{
              elem(DateTime.from_iso8601(f.subject.week_start), 1)
              | microsecond: {0, 6}
            },
            week_end: %{elem(DateTime.from_iso8601(f.subject.week_end), 1) | microsecond: {0, 6}},
            configuration_version_id: f.configuration.id,
            mapping_id: f.mapping.id,
            membership: [f.performance.id],
            canonical_identity: %{"read_fixture" => id},
            status: "successful",
            score: Decimal.new("1"),
            unit_price: Decimal.new(price),
            effective_at: effective_at,
            evidence: %{},
            inserted_at: effective_at
          })

        managed = %{
          strategy_id: f.configuration.strategy_id,
          formula_version: f.configuration.formula_version,
          configuration_version_id: f.configuration.id
        }

        FootballMarket.Quotes.Store.lock_player!(f.player.id)

        FootballMarket.Quotes.Store.confirm!(
          calculation,
          f.player,
          managed,
          f.mapping,
          Decimal.new(price),
          effective_at
        )

        Repo.get_by!(FootballMarket.Market.Quote, calculation_id: id)
      end)

    quote
  end

  def mapping_scale, do: Decimal.new("1.25")

  # Compare all persisted financial/history fields and protected inputs. Hash
  # rows so assertion output cannot disclose account credential material.
  def protected_snapshot do
    Map.new(
      ~w(market_initial_recipients market_quotes market_holdings market_issuances
         users password_credentials api_keys matches player_match_performances
         valuation_configuration_versions valuation_selection_changes
         quote_conversion_mappings quote_evaluation_requests),
      fn table ->
        rows =
          Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows

        {table, Enum.map(rows, fn [row] -> :crypto.hash(:sha256, row) end)}
      end
    )
  end

  def rules(%{position: position}),
    do: FootballMarket.ValuationConfigurationCase.rules(position.id)
end
