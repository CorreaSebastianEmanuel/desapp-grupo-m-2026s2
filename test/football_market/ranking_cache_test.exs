defmodule FootballMarket.Ranking.CacheTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Market, Ranking}
  alias FootballMarket.Valuation.Configurations

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

  test "quote invalidation waits for outer commit and ignores rollback" do
    market = create_tradable_market!()
    assert {:ok, initial} = Ranking.read()
    initial_writes = TestRankingCache.state().writes

    for decision <- [:rollback, :commit] do
      {writer, published} =
        pending_transaction(fn ->
          record_performance_and_quote!(market, market.mapping.id, %{goals: 3})
        end)

      assert {:ok, ^initial} = Ranking.read()
      assert TestRankingCache.state().writes == initial_writes
      send(writer.pid, decision)
      result = Task.await(writer)

      if decision == :rollback do
        assert {:error, :cancelled} = result
        assert {:ok, ^initial} = Ranking.read()
        assert TestRankingCache.state().writes == initial_writes
      else
        assert {:ok, _} = result
        assert {:ok, %{entries: [entry]}} = Ranking.read()
        assert entry.quote_id == published.quote.id
        assert length(TestRankingCache.state().writes) == 2
      end
    end
  end

  test "strategy invalidation waits for commit and reactivation uses a fresh key" do
    market = create_tradable_market!()
    assert {:ok, initial} = Ranking.read()
    [initial_key] = Map.keys(TestRankingCache.state().values)
    {:ok, [_, _] = presets} = Configurations.ensure_presets()
    target = Enum.find(presets, &(&1.id != market.version.id))

    for decision <- [:rollback, :commit] do
      {writer, _} =
        pending_transaction(fn ->
          assert {:ok, result} = Configurations.activate(target.id, market.version.id)
          result
        end)

      assert {:ok, ^initial} = Ranking.read()
      assert length(TestRankingCache.state().writes) == 1
      send(writer.pid, decision)
      Task.await(writer)

      if decision == :rollback do
        assert {:ok, ^initial} = Ranking.read()
      end
    end

    assert {:ok, %{configuration: %{id: id}, entries: []}} = Ranking.read()
    assert id == target.id
    assert {:ok, _} = Configurations.activate(market.version.id, target.id)
    assert {:ok, ^initial} = Ranking.read()
    [{reactivated_key, 30} | _] = TestRankingCache.state().writes
    refute reactivated_key == initial_key
    assert length(TestRankingCache.state().writes) == 3

    assert {:error, :already_active} =
             Configurations.activate(market.version.id, market.version.id)

    assert {:ok, ^initial} = Ranking.read()
    assert length(TestRankingCache.state().writes) == 3
  end

  test "quotes for an inactive configuration leave the active cache intact" do
    market = create_tradable_market!()
    {:ok, presets} = Configurations.ensure_presets()
    target = Enum.find(presets, &(&1.id != market.version.id))
    assert {:ok, _} = Configurations.activate(target.id, market.version.id)
    assert {:ok, initial} = Ranking.read()
    writes = TestRankingCache.state().writes

    assert {:ok, published} =
             FootballMarket.Quotes.calculate_and_publish(
               %{
                 player_id: market.player.id,
                 season_id: market.season.id,
                 week_start: market.calculation.week_start,
                 week_end: DateTime.add(market.calculation.week_end, 1, :second)
               },
               {:version, market.version.id},
               market.mapping.id
             )

    refute published.quote.id == market.quote.id
    assert {:ok, ^initial} = Ranking.read()
    assert TestRankingCache.state().writes == writes
  end

  test "late fills cannot revive an older ranking and hits never renew expiry" do
    market = create_tradable_market!()
    owner = self()

    TestRankingCache.before_put(fn ->
      send(owner, {:filling, self()})

      receive do
        :continue -> :ok
      after
        5_000 -> raise "cache fill barrier timed out"
      end
    end)

    reader = Task.async(fn -> Ranking.read() end)
    assert_receive {:filling, pid}, 5_000
    published = record_performance_and_quote!(market, market.mapping.id, %{goals: 3})
    assert {:ok, fresh} = Ranking.read()
    assert hd(fresh.entries).quote_id == published.quote.id
    send(pid, :continue)
    assert {:ok, old} = Task.await(reader)
    assert hd(old.entries).quote_id == market.quote.id
    assert {:ok, ^fresh} = Ranking.read()
    assert length(TestRankingCache.state().writes) == 2

    TestRankingCache.advance(29)
    assert {:ok, ^fresh} = Ranking.read()
    assert length(TestRankingCache.state().writes) == 2
    TestRankingCache.advance(1)
    assert {:ok, ^fresh} = Ranking.read()
    assert length(TestRankingCache.state().writes) == 3
    assert Enum.all?(TestRankingCache.state().writes, &(elem(&1, 1) == 30))
  end

  test "Redis failure during publication and recovery cannot reuse stale entries" do
    market = create_tradable_market!()
    assert {:ok, _} = Ranking.read()
    TestRankingCache.set_unavailable(true)
    published = record_performance_and_quote!(market, market.mapping.id, %{goals: 3})
    assert {:ok, expected} = Ranking.read()
    assert hd(expected.entries).quote_id == published.quote.id
    TestRankingCache.set_unavailable(false)
    assert {:ok, ^expected} = Ranking.read()

    for failure <- [:raise, :exit] do
      TestRankingCache.expire_all()
      TestRankingCache.fail(:get_failure, failure)
      TestRankingCache.fail(:put_failure, failure)
      assert {:ok, ^expected} = Ranking.read()
    end

    TestRankingCache.fail(:get_failure, nil)
    TestRankingCache.fail(:put_failure, nil)
    assert {:ok, ^expected} = Ranking.read()

    {:ok, presets} = Configurations.ensure_presets()
    target = Enum.find(presets, &(&1.id != market.version.id))
    TestRankingCache.set_unavailable(true)
    assert {:ok, _} = Configurations.activate(target.id, market.version.id)
    assert {:ok, %{entries: []}} = Ranking.read()
    TestRankingCache.set_unavailable(false)
    assert {:ok, %{configuration: %{id: id}, entries: []}} = Ranking.read()
    assert id == target.id
  end

  test "trading ignores cached ranking prices and uses the latest PostgreSQL quote" do
    market = create_tradable_market!()
    assert {:ok, _} = Ranking.read()
    [key] = Map.keys(TestRankingCache.state().values)
    [row] = Jason.decode!(TestRankingCache.state().values[key])
    TestRankingCache.corrupt(key, Jason.encode!([Map.put(row, "unit_price", "0.01")]))
    assert {:ok, %{entries: [cached]}} = Ranking.read()
    assert Decimal.eq?(cached.unit_price, "0.01")

    assert {:ok, purchase} =
             Market.purchase(actor_for(market.investor), %{
               player_id: market.player.id,
               quantity: 1,
               request_key: "cache-independent"
             })

    assert purchase.quote_id == market.quote.id
    assert Decimal.eq?(purchase.unit_price, market.quote.unit_price)
  end

  defp pending_transaction(fun) do
    owner = self()

    writer =
      Task.async(fn ->
        Repo.transaction(fn ->
          value = fun.()
          send(owner, {:pending, self(), value})

          receive do
            :commit -> value
            :rollback -> Repo.rollback(:cancelled)
          after
            5_000 -> Repo.rollback(:barrier_timeout)
          end
        end)
      end)

    assert_receive {:pending, pid, value}, 5_000
    assert pid == writer.pid
    {writer, value}
  end
end
