defmodule FootballMarket.Ranking.CacheTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Market, Ranking}

  alias FootballMarket.Ranking.Cache
  alias FootballMarket.TestRankingCache
  alias FootballMarket.Valuation.Configurations.Version

  setup do
    original_adapter = Application.get_env(:football_market, :ranking_cache_adapter)
    Application.put_env(:football_market, :ranking_cache_adapter, TestRankingCache)
    TestRankingCache.reset()

    on_exit(fn ->
      if original_adapter do
        Application.put_env(:football_market, :ranking_cache_adapter, original_adapter)
      else
        Application.delete_env(:football_market, :ranking_cache_adapter)
      end
    end)

    :ok
  end

  test "reuses cached ranking entries and refreshes after expiry" do
    _admin = create_admin!()
    fixture = create_catalog_fixture!()
    {:ok, _} = Market.initialize_player(fixture.player.id)
    %{version: version, mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)
    quote = record_performance_and_quote!(fixture, mapping.id, %{goals: 1, assists: 0})

    assert {:ok, first} = Ranking.read()
    assert {:ok, second} = Ranking.read()
    assert first == second
    assert hd(second.entries).quote_id == quote.quote.id
    assert TestRankingCache.state().gets == 2
    assert [{key, 30}] = TestRankingCache.state().writes
    assert key =~ version.id

    TestRankingCache.expire_all()
    assert {:ok, third} = Ranking.read()
    assert third == first
    assert length(TestRankingCache.state().writes) == 2
    assert Cache.ttl_seconds() == 30
  end

  test "falls back to PostgreSQL when Redis is unavailable" do
    _admin = create_admin!()
    fixture = create_catalog_fixture!()
    {:ok, _} = Market.initialize_player(fixture.player.id)
    %{mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)
    quote = record_performance_and_quote!(fixture, mapping.id, %{goals: 2, assists: 0})
    TestRankingCache.set_unavailable(true)

    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.quote_id == quote.quote.id
    assert TestRankingCache.state().writes == []
  end

  test "uses a separate cache key for each active configuration version" do
    first = %Version{id: Ecto.UUID.generate(), strategy_id: "balanced", formula_version: "1"}
    second = %Version{id: Ecto.UUID.generate(), strategy_id: "balanced", formula_version: "1"}

    assert :ok = Cache.put(first, [])
    assert :ok = Cache.put(second, [])
    assert [{first_key, 30}, {second_key, 30}] = TestRankingCache.state().writes
    refute first_key == second_key
  end

  test "emits cache outcome telemetry for hit, miss, and Redis failure" do
    configuration = %Version{
      id: Ecto.UUID.generate(),
      strategy_id: "balanced",
      formula_version: "1"
    }

    owner = self()
    ref = make_ref()

    events =
      for outcome <- [:hit, :miss, :error], do: [:football_market, :ranking, :cache, outcome]

    :ok =
      :telemetry.attach_many(
        ref,
        events,
        fn event, measurements, _metadata, _config ->
          send(owner, {:ranking_cache_event, event, measurements})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(ref) end)

    assert :miss = Cache.get(configuration)

    assert_receive {:ranking_cache_event, [:football_market, :ranking, :cache, :miss],
                    %{count: 1}}

    assert :ok = Cache.put(configuration, [])
    assert {:ok, []} = Cache.get(configuration)
    assert_receive {:ranking_cache_event, [:football_market, :ranking, :cache, :hit], %{count: 1}}

    TestRankingCache.set_unavailable(true)
    assert :miss = Cache.get(configuration)

    assert_receive {:ranking_cache_event, [:football_market, :ranking, :cache, :error],
                    %{count: 1}}

    metrics = FootballMarketWeb.Telemetry.metrics()
    assert Enum.any?(metrics, &(&1.name == [:football_market, :ranking, :cache, :hit, :count]))

    assert Enum.any?(metrics, &(&1.name == [:football_market, :ranking, :cache, :miss, :count]))

    assert Enum.any?(metrics, &(&1.name == [:football_market, :ranking, :cache, :error, :count]))
  end

  test "treats malformed cached data as a miss and refreshes from PostgreSQL" do
    _admin = create_admin!()
    fixture = create_catalog_fixture!()
    {:ok, _} = Market.initialize_player(fixture.player.id)
    %{mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)
    quote = record_performance_and_quote!(fixture, mapping.id, %{goals: 2, assists: 0})

    assert {:ok, %{configuration: configuration}} = Ranking.read()
    [key] = Enum.map(TestRankingCache.state().writes, &elem(&1, 0))
    [valid_row] = Jason.decode!(TestRankingCache.state().values[key])

    for invalid_price <- ["NaN", "Infinity", "0", "-1"] do
      TestRankingCache.corrupt(
        key,
        Jason.encode!([Map.put(valid_row, "unit_price", invalid_price)])
      )

      assert {:ok, %{configuration: ^configuration, entries: [entry]}} = Ranking.read()
      assert entry.quote_id == quote.quote.id
      assert Decimal.eq?(entry.unit_price, quote.quote.unit_price)
    end

    assert length(TestRankingCache.state().writes) == 5
  end
end
