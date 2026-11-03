defmodule FootballMarket.PurchasesCase do
  @moduledoc false
  alias FootballMarket.{Market, MarketCase, Repo}

  def fixture do
    f = Map.merge(MarketCase.private_schema(), MarketCase.fixture())
    cleanup(f.schema)
    {:ok, _} = Market.initialize_player(f.player.id)
    performance_quote!(f.player)
    f
  end

  def performance_quote!(player, price \\ "1.00") do
    alias FootballMarket.Quotes.{Calculation, Mappings, Store}
    alias FootballMarket.Valuation.Configurations

    {:ok, configuration} =
      Configurations.create(FootballMarket.ValuationConfigurationCase.rules(player.position_id))

    {:ok, mapping} = Mappings.save("purchase-fixture", Ecto.UUID.generate(), Decimal.new("1"))
    id = Ecto.UUID.generate()
    effective_at = Repo.query!("SELECT clock_timestamp()").rows |> hd() |> hd()
    week_start = DateTime.add(effective_at, -7 * 24 * 60 * 60, :second)
    week_end = DateTime.add(effective_at, -6 * 24 * 60 * 60, :second)
    unit_price = Decimal.new(price)

    calculation = %Calculation{
      id: id,
      player_id: player.id,
      season_id: player.season_id,
      week_start: week_start,
      week_end: week_end,
      configuration_version_id: configuration.id,
      mapping_id: mapping.id,
      membership: [Ecto.UUID.generate()],
      canonical_identity: %{"purchase_fixture" => id},
      status: "successful",
      score: Decimal.new("1"),
      unit_price: unit_price,
      effective_at: effective_at,
      evidence: %{},
      inserted_at: effective_at
    }

    managed = %{
      strategy_id: configuration.strategy_id,
      formula_version: configuration.formula_version,
      configuration_version_id: configuration.id
    }

    {:ok, _event} =
      Repo.transaction(fn ->
        Repo.insert!(calculation)
        Store.lock_player!(player.id)
        Store.confirm!(calculation, player, managed, mapping, unit_price, effective_at)
      end)

    Repo.get_by!(FootballMarket.Market.Quote, calculation_id: id)
  end

  def cleanup(schema) do
    true = Regex.match?(~r/^market_test_[a-f0-9]+$/, schema)

    ExUnit.Callbacks.on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Repo.query!("DROP SCHEMA IF EXISTS #{schema} CASCADE")
      end)
    end)
  end

  def fund(user, amount) do
    {funded, ""} = Decimal.parse(amount, max_digits: :infinity)

    Repo.query!(
      "INSERT INTO market_credit_balances(user_id,amount,updated_at) VALUES($1,$2,now()) ON CONFLICT(user_id) DO UPDATE SET amount=excluded.amount",
      [Ecto.UUID.dump!(user.id), funded]
    )
  end

  def request(f, key \\ "purchase-key", quantity \\ 3),
    do: %{player_id: f.player.id, quantity: quantity, request_key: key}

  def actor(user),
    do: %FootballMarket.Accounts.AuthenticatedActor{
      account_id: user.id,
      authentication_method: :jwt,
      credential_id: Ecto.UUID.generate()
    }

  def purchase(f, key \\ "purchase-key", quantity \\ 3),
    do: Market.purchase(actor(f.buyer), request(f, key, quantity))

  def snapshot do
    Map.new(
      ~w(market_credit_balances market_purchases market_credit_entries market_token_transfers market_holdings),
      fn table ->
        {table,
         Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows}
      end
    )
  end
end
