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
