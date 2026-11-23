#!/usr/bin/env elixir

Code.require_file("ranking_benchmark_helpers.exs", __DIR__)

defmodule RankingBenchmarkBaseline do
  @moduledoc false

  import Ecto.Query

  alias FootballMarket.Market.{Issuance, Quote}
  alias FootballMarket.Quotes.Calculation
  alias FootballMarket.Repo
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.Version

  def read do
    case Repo.transaction(fn ->
           Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")

           case Configurations.active() do
             {:ok, %Version{} = active} ->
               %{configuration: active, entries: entries(active)}

             {:error, %{reason: :no_active_configuration}} ->
               Repo.rollback(:no_active_configuration)
           end
         end) do
      {:ok, ranking} -> {:ok, ranking}
      error -> error
    end
  end

  def explain(active) do
    Repo.explain(:all, ranking_query(active), analyze: true, buffers: true)
  end

  def explain_revision(active) do
    Repo.explain(:all, revision_query(active), analyze: true, buffers: true)
  end

  def eligible_quote_count(active), do: Repo.one(revision_query(active))

  def players_with_unexpected_quote_counts(active) do
    Repo.all(
      from q in Quote,
        join: i in Issuance,
        on: i.player_id == q.player_id,
        join: c in Calculation,
        on: c.id == q.calculation_id,
        where:
          q.configuration_version_id == ^active.id and q.rule_id == ^active.strategy_id and
            q.rule_version == ^active.formula_version and c.configuration_version_id == ^active.id,
        where: q.performance_sequence > 0 and q.unit_price > 0 and c.status == "successful",
        where:
          c.mapping_id == q.mapping_id and c.player_id == q.player_id and
            c.unit_price == q.unit_price and c.effective_at == q.effective_at,
        group_by: q.player_id,
        having: count(q.id) != 4,
        select: q.player_id
    )
  end

  defp entries(active) do
    Repo.all(ranking_query(active))
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, position} -> Map.put(entry, :position, position) end)
  end

  defp ranking_query(active) do
    from row in subquery(active_quotes_query(active)),
      order_by: [desc: row.unit_price, asc: row.player_id],
      select: row
  end

  defp active_quotes_query(active) do
    from q in Quote,
      join: i in Issuance,
      on: i.player_id == q.player_id,
      join: c in Calculation,
      on: c.id == q.calculation_id,
      where:
        q.configuration_version_id == ^active.id and q.rule_id == ^active.strategy_id and
          q.rule_version == ^active.formula_version and c.configuration_version_id == ^active.id,
      where: q.performance_sequence > 0 and q.unit_price > 0 and c.status == "successful",
      where:
        c.mapping_id == q.mapping_id and c.player_id == q.player_id and
          c.unit_price == q.unit_price and c.effective_at == q.effective_at,
      distinct: q.player_id,
      order_by: [asc: q.player_id, desc: q.effective_at, desc: q.performance_sequence],
      select: %{
        player_id: q.player_id,
        quote_id: q.id,
        unit_price: q.unit_price,
        effective_at: q.effective_at
      }
  end

  defp revision_query(active) do
    from q in Quote,
      join: i in Issuance,
      on: i.player_id == q.player_id,
      join: c in Calculation,
      on: c.id == q.calculation_id,
      where:
        q.configuration_version_id == ^active.id and q.rule_id == ^active.strategy_id and
          q.rule_version == ^active.formula_version and c.configuration_version_id == ^active.id,
      where: q.performance_sequence > 0 and q.unit_price > 0 and c.status == "successful",
      where:
        c.mapping_id == q.mapping_id and c.player_id == q.player_id and
          c.unit_price == q.unit_price and c.effective_at == q.effective_at,
      select: count(q.id)
  end
end

unless Mix.env() == :test do
  Mix.raise("run the ranking benchmark with MIX_ENV=test")
end

import Ecto.Query

repo_config = Application.fetch_env!(:football_market, FootballMarket.Repo)

Application.put_env(
  :football_market,
  FootballMarket.Repo,
  Keyword.merge(repo_config, pool: DBConnection.ConnectionPool, pool_size: 20)
)

Mix.Task.run("app.start")

alias FootballMarket.{Catalog, Market, Ranking, Repo}
alias FootballMarket.DataCase
alias RankingBenchmarkHelpers, as: Helpers

database = Repo.config()[:database]

unless is_binary(database) and String.starts_with?(database, "football_market_test") do
  Mix.raise("refusing to benchmark outside an isolated football_market_test database")
end

DataCase.reset_database!()

try do
  admin = DataCase.create_admin!("ranking-benchmark@example.test")
  catalog = DataCase.create_catalog_fixture!()

  %{version: _version, mapping: mapping} =
    DataCase.create_active_strategy_and_mapping!(catalog.positions)

  players =
    [
      catalog.player
      | for index <- 2..100 do
          {:ok, player} =
            Catalog.create_player(%{
              team_id: catalog.home_team.id,
              position_id: catalog.positions.fwd.id,
              catalog_identity: "ranking-benchmark-#{index}",
              display_name: "Benchmark Player #{index}"
            })

          player
        end
    ]

  Enum.each(players, fn player ->
    {:ok, _issuance} = Market.initialize_player(player.id)
  end)

  base_time = DateTime.utc_now() |> DateTime.add(-27, :day) |> DateTime.truncate(:microsecond)

  Enum.each(players, fn player ->
    fixture = %{catalog | player: player}

    Enum.each(0..4, fn quote_index ->
      kickoff = DateTime.add(base_time, quote_index * 6 * 86_400, :second)

      DataCase.record_performance_and_quote!(fixture, mapping.id, %{
        kickoff_at: kickoff,
        goals: rem(quote_index, 3),
        assists: rem(quote_index + 1, 2)
      })
    end)
  end)

  handler_id = "ranking-benchmark-sql-#{System.unique_integer([:positive])}"

  :ok =
    :telemetry.attach(
      handler_id,
      [:football_market, :repo, :query],
      fn _event, _measurements, metadata, counter ->
        query = String.downcase(metadata.query || "")

        if Enum.any?(
             ["market_quotes", "quote_calculations", "valuation_selection_changes"],
             &String.contains?(query, &1)
           ) do
          :atomics.add(counter, 1, 1)
        end

        if String.contains?(query, "market_quotes") and String.contains?(query, "distinct") do
          :atomics.add(counter, 2, 1)
        end
      end,
      :atomics.new(2, [])
    )

  %{config: counter} =
    :telemetry.list_handlers([:football_market, :repo, :query])
    |> Enum.find(&(&1.id == handler_id))

  # The first read warms the post-TASK-041 cache; it is measured separately.
  {cold_us, {:ok, ranking}} = Helpers.timed(fn -> Ranking.read() end)
  unless length(ranking.entries) == 100, do: Mix.raise("benchmark fixture ranking is incomplete")

  ranking_plan = RankingBenchmarkBaseline.explain(ranking.configuration)
  revision_plan = RankingBenchmarkBaseline.explain_revision(ranking.configuration)

  baseline = Helpers.measure_reads(&RankingBenchmarkBaseline.read/0, counter)
  cached = Helpers.measure_reads(&Ranking.read/0, counter)

  unless baseline.ranking_aggregation_statements == 1_000 and
           cached.ranking_aggregation_statements == 0 do
    Mix.raise("benchmark did not observe the expected uncached and warmed ranking query counts")
  end

  postgres_version = Repo.query!("SHOW server_version").rows |> hd() |> hd()

  performance_quotes =
    Repo.one(
      from q in FootballMarket.Market.Quote,
        where: q.performance_sequence > 0,
        select: count(q.id)
    )

  eligible_quotes = RankingBenchmarkBaseline.eligible_quote_count(ranking.configuration)

  unless performance_quotes == 400 and eligible_quotes == 400 do
    Mix.raise("benchmark fixture expected 400 successful eligible performance quotes")
  end

  if RankingBenchmarkBaseline.players_with_unexpected_quote_counts(ranking.configuration) != [] do
    Mix.raise("benchmark fixture expected 4 eligible performance quotes per player")
  end

  IO.puts("ranking benchmark results")
  IO.puts("revision=#{Helpers.git_revision()}")
  IO.puts("database=#{database}")
  IO.puts("postgresql=#{postgres_version}")

  IO.puts(
    "players=#{length(players)} performance_quotes=#{performance_quotes} eligible_quotes=#{eligible_quotes}"
  )

  IO.puts("clients=10 reads_per_client=100")
  IO.puts("post_cache_cold_read_us=#{cold_us}")
  Helpers.print_measurement("pre_TASK_041_behavior", baseline)
  Helpers.print_measurement("current_warm_cache_with_revision_check", cached)

  IO.puts(
    "ranking_query_explain_analyze_buffers=#{inspect(ranking_plan, pretty: true, limit: :infinity)}"
  )

  IO.puts(
    "revision_count_explain_analyze_buffers=#{inspect(revision_plan, pretty: true, limit: :infinity)}"
  )

  :telemetry.detach(handler_id)
  _ = admin
after
  DataCase.reset_database!()
end
