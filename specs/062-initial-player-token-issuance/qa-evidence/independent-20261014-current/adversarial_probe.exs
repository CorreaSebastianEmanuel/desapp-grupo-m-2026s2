ExUnit.start()

defmodule Task028IndependentAcceptanceProbe do
  use ExUnit.Case, async: false
  import FootballMarket.MarketCase
  alias FootballMarket.{Market, Repo}

  test "DB-time initialization without provider/statistics/strategy, then absent original holding" do
    f = Map.merge(private_schema(), fixture())
    old_provider = Application.get_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)
    on_exit(fn -> Application.put_env(:football_market, FootballMarket.Providers, old_provider) end)

    for table <- ~w(player_match_performances valuation_configuration_versions valuation_selection_changes) do
      assert Repo.query!("SELECT count(*) FROM #{table}").rows == [[0]]
    end

    accounts = snapshot() |> Map.take(~w(users password_credentials api_keys balance_sentinels))
    [[before_time]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    assert {:ok, %{outcome: :issued, issuance: evidence}} = Market.initialize_player(f.player.id)
    [[after_time]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    instant = DateTime.to_naive(evidence.effective_at)
    assert NaiveDateTime.compare(instant, before_time) in [:eq, :gt]
    assert NaiveDateTime.compare(instant, after_time) in [:eq, :lt]
    assert evidence.effective_at == evidence.completed_at
    assert Decimal.equal?(evidence.initial_inventory_value, Decimal.new("100"))
    assert accounts == snapshot() |> Map.take(~w(users password_credentials api_keys balance_sentinels))
    IO.puts("QA_PROBE no_provider_statistics_strategy=true initialization_date_within_db_call=true exact_value=100 unchanged_accounts=true")

    assert {:ok, _} = transfer(f, 100)
    assert {:ok, _} = Repo.transaction(fn ->
      Repo.query!("DELETE FROM market_holdings WHERE user_id=$1", [Ecto.UUID.dump!(f.owner.id)])
    end)
    before_retry = snapshot()
    assert {:ok, %{outcome: :already_completed, issuance: ^evidence}} = Market.initialize_player(f.player.id)
    assert snapshot() == before_retry
    assert Repo.query!("SELECT count(*) FROM market_holdings WHERE user_id=$1", [Ecto.UUID.dump!(f.owner.id)]).rows == [[0]]
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]
    IO.puts("QA_PROBE absent_original_holding=true retry_preserves_snapshot=true supply=100")

    for price <- [Decimal.new("Infinity"), Decimal.new("-Infinity"), Decimal.new("NaN"), "1", nil] do
      assert_error(Market.initialize_player(f.player.id, %{unit_price: price}), :invalid_input)
      assert snapshot() == before_retry
    end
    IO.puts("QA_PROBE nonfinite_and_nonmoney_assertions_rejected=true no_retry_effects=true")
  end
end
