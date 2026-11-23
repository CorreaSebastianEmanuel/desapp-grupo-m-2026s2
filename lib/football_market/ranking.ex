defmodule FootballMarket.Ranking do
  @moduledoc """
  Read-only player ranking under the currently active valuation strategy.

  Reads one consistent `REPEATABLE READ, READ ONLY` PostgreSQL snapshot joining
  the active strategy version with each issued player's latest confirmed
  performance quote, ordered by unit price descending (player ID ascending on ties).
  Redis keys include the snapshot's committed selection and quote revision, so
  invalidation requires no external side effect in financial transactions.
  """

  import Ecto.Query

  alias FootballMarket.Market.{Issuance, Quote}
  alias FootballMarket.Quotes.Calculation
  alias FootballMarket.Ranking.Cache
  alias FootballMarket.Repo
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.{SelectionChange, Version}

  @spec read() :: {:ok, map()} | {:error, :no_active_configuration | :storage_unavailable}
  def read do
    if Repo.in_transaction?(), do: {:error, :storage_unavailable}, else: read_active_ranking()
  rescue
    _ in [DBConnection.ConnectionError, Postgrex.Error, Ecto.NoResultsError] ->
      {:error, :storage_unavailable}
  end

  defp read_active_ranking do
    case Repo.transaction(&read_transaction/0) do
      {:ok, {ranking, revision, :miss}} ->
        Cache.put(ranking.configuration, ranking.entries, revision)
        {:ok, ranking}

      {:ok, {ranking, _revision, :hit}} ->
        {:ok, ranking}

      {:error, :no_active_configuration} ->
        {:error, :no_active_configuration}

      {:error, _} ->
        {:error, :storage_unavailable}
    end
  end

  defp read_transaction do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")

    case Configurations.active() do
      {:ok, %Version{} = active} ->
        revision = revision(active)

        case Cache.get(active, revision) do
          {:ok, entries} -> {%{configuration: active, entries: entries}, revision, :hit}
          :miss -> {%{configuration: active, entries: entries(active)}, revision, :miss}
        end

      {:error, %{reason: :no_active_configuration}} ->
        Repo.rollback(:no_active_configuration)
    end
  end

  # Both tables are append-only. A revision changes only when the surrounding
  # writer transaction commits, including when a caller owns an outer transaction.
  # Late cache fills keep their snapshot revision and cannot revive stale entries.
  defp revision(active) do
    selection = Repo.one(from c in SelectionChange, select: max(c.change_order))
    quotes = Repo.aggregate(eligible_quotes_query(active), :count)
    "#{selection}:#{quotes}"
  end

  defp entries(%Version{} = active) do
    Repo.all(
      from row in subquery(active_quotes_query(active)),
        order_by: [desc: row.unit_price, asc: row.player_id],
        select: row
    )
    |> Enum.with_index(1)
    |> Enum.map(fn {row, position} -> Map.put(row, :position, position) end)
  end

  defp active_quotes_query(active) do
    from q in eligible_quotes_query(active),
      distinct: q.player_id,
      order_by: [asc: q.player_id, desc: q.effective_at, desc: q.performance_sequence],
      select: %{
        player_id: q.player_id,
        quote_id: q.id,
        unit_price: q.unit_price,
        effective_at: q.effective_at
      }
  end

  defp eligible_quotes_query(active) do
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
          c.unit_price == q.unit_price and c.effective_at == q.effective_at
  end
end
