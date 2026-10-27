defmodule FootballMarket.Ranking.Reader do
  @moduledoc false
  import Ecto.Query

  alias FootballMarket.{Repo, Market.Quote, Quotes.Calculation}
  alias FootballMarket.Market.Issuance
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.Version

  def read do
    if Repo.in_transaction?(), do: {:error, :storage_unavailable}, else: read_snapshot()
  rescue
    _ in [DBConnection.ConnectionError, Postgrex.Error, Ecto.NoResultsError] ->
      {:error, :storage_unavailable}

    error in RuntimeError ->
      if Exception.message(error) in [
           "valuation serialization anchor missing",
           "valuation rule storage integrity failure",
           "valuation selection integrity failure"
         ],
         do: {:error, :storage_unavailable},
         else: reraise(error, __STACKTRACE__)
  end

  defp read_snapshot do
    case Repo.transaction(&read_transaction/0) do
      {:ok, result} -> {:ok, result}
      {:error, :no_active_configuration} -> {:error, :no_active_configuration}
      {:error, _} -> {:error, :storage_unavailable}
    end
  end

  defp read_transaction do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")

    case Configurations.active() do
      {:ok, %Version{} = active} -> %{configuration: active, entries: entries(active)}
      {:error, %{reason: :no_active_configuration}} -> Repo.rollback(:no_active_configuration)
    end
  end

  defp entries(%Version{} = active) do
    Repo.all(
      from row in subquery(active_quotes(active)),
        order_by: [desc: row.unit_price, asc: row.player_id],
        select: row
    )
    |> Enum.with_index(1)
    |> Enum.map(fn {row, position} -> Map.put(row, :position, position) end)
  end

  defp active_quotes(active) do
    from q in Quote,
      join: i in Issuance,
      on: i.player_id == q.player_id,
      join: c in Calculation,
      on: c.id == q.calculation_id,
      where: ^active_version_predicate(active),
      where: ^successful_positive_predicate(),
      where: ^calculation_match_predicate(),
      distinct: q.player_id,
      order_by: [asc: q.player_id, desc: q.effective_at, desc: q.performance_sequence],
      select: %{
        player_id: q.player_id,
        quote_id: q.id,
        unit_price: q.unit_price,
        effective_at: q.effective_at
      }
  end

  defp active_version_predicate(active) do
    dynamic(
      [q, _i, c],
      q.configuration_version_id == ^active.id and q.rule_id == ^active.strategy_id and
        q.rule_version == ^active.formula_version and c.configuration_version_id == ^active.id
    )
  end

  defp successful_positive_predicate do
    dynamic(
      [q, _i, c],
      q.performance_sequence > 0 and q.unit_price > 0 and c.status == "successful"
    )
  end

  defp calculation_match_predicate do
    dynamic(
      [q, _i, c],
      c.mapping_id == q.mapping_id and c.player_id == q.player_id and
        c.unit_price == q.unit_price and c.effective_at == q.effective_at
    )
  end
end
