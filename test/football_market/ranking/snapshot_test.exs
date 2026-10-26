defmodule FootballMarket.Ranking.SnapshotTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Ranking, Repo, Valuation.Configurations}

  test "ranking rejects an enclosing transaction rather than using an incompatible snapshot" do
    _f = FootballMarket.RankingCase.fixture()

    assert {:ok, {:error, :storage_unavailable}} =
             FootballMarket.Repo.transaction(fn -> FootballMarket.Ranking.read() end)
  end

  test "a configuration committed before the first read is visible" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    {:ok, next} = Configurations.create(FootballMarket.RankingCase.rules(f))

    owner = self()

    writer =
      spawn(fn ->
        Repo.put_dynamic_repo(f.repo)
        {:ok, _} = Configurations.activate(next.id, f.configuration.id)

        {:ok, %{calculation: calculation}} =
          FootballMarket.Quotes.request(f.subject, {:version, next.id}, f.mapping.id)

        quote = Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)
        send(owner, {:writer_committed, self(), quote})
      end)

    assert_receive {:writer_committed, ^writer, quote}, 5_000

    reader =
      spawn(fn ->
        Repo.put_dynamic_repo(f.repo)
        send(owner, {:ranking_result, self(), Ranking.read()})
      end)

    assert_receive {:ranking_result, ^reader,
                    {:ok, %{configuration: configuration, entries: [entry]}}},
                   5_000

    assert configuration.id == next.id
    assert entry.quote_id == quote.id
  end

  test "activation committed after snapshot acquisition leaves the complete old result" do
    f = FootballMarket.RankingCase.fixture()
    {:ok, next} = Configurations.create(FootballMarket.RankingCase.rules(f))
    owner = self()
    event = [:football_market, :repo, :query]
    handler_id = "ranking-snapshot-#{Ecto.UUID.generate()}"
    barrier = :ets.new(:ranking_snapshot_barrier, [:set, :public])

    :ok =
      :telemetry.attach(
        handler_id,
        event,
        fn _event, _measurements, metadata, _config ->
          if is_binary(metadata[:query]) and
               String.contains?(metadata.query, "valuation_selection_changes") and
               :ets.insert_new(barrier, {:claimed, true}) do
            send(owner, {:snapshot_selected, self()})

            receive do
              :continue_ranking -> :ok
            after
              5_000 -> raise "ranking snapshot barrier timed out"
            end
          end
        end,
        nil
      )

    reader =
      spawn(fn ->
        Repo.put_dynamic_repo(f.repo)
        send(owner, {:ranking_result, self(), Ranking.read()})
      end)

    try do
      assert_receive {:snapshot_selected, barrier_process}, 5_000
      newer = FootballMarket.RankingCase.add_performance_quote(f, "ranking-after-snapshot")
      assert {:ok, _} = Configurations.activate(next.id, f.configuration.id)
      send(barrier_process, :continue_ranking)

      assert_receive {:ranking_result, ^reader,
                      {:ok, %{configuration: configuration, entries: [entry]}}},
                     5_000

      assert configuration.id == f.configuration.id
      assert entry.quote_id == f.quote.id
      assert entry.player_id == f.player.id
      refute entry.quote_id == newer.id
    after
      :telemetry.detach(handler_id)
      :ets.delete(barrier)
      if Process.alive?(reader), do: Process.exit(reader, :kill)
    end
  end
end
