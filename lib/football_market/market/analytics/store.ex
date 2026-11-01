defmodule FootballMarket.Market.Analytics.Store do
  @moduledoc false
  import Ecto.Query

  alias FootballMarket.{Catalog.Player, Market.PortfolioStore, Market.Quote, Repo}
  alias FootballMarket.Market.Analytics.Input

  def read(owner, mode, options) do
    if Repo.in_transaction?() do
      {:error, :temporarily_unavailable}
    else
      Repo.transaction(fn -> snapshot(owner, mode, options) end)
    end
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] -> {:error, :temporarily_unavailable}
  end

  defp snapshot(owner, mode, options) do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
    %{rows: [[as_of]]} = Repo.query!("SELECT transaction_timestamp()")
    range = range!(mode, options, DateTime.to_date(as_of))
    cutoff = if mode == :allocation, do: as_of, else: min_time(day_end(range.to), as_of)

    opening =
      if mode == :allocation, do: as_of, else: DateTime.new!(range.from, ~T[00:00:00], "Etc/UTC")

    transactions =
      from(t in subquery(PortfolioStore.transaction_query(owner)),
        where: t.completed_at <= ^cutoff
      )
      |> Repo.all()

    ids = transactions |> Enum.map(& &1.player_id) |> Enum.uniq()

    players =
      Repo.all(from p in Player, where: p.id in ^ids, select: {p.id, p.display_name}) |> Map.new()

    %{
      as_of: as_of,
      range: range,
      transactions: transactions,
      players: players,
      quotes: opening_quotes(ids, opening) ++ changes(ids, opening, cutoff)
    }
  end

  defp range!(:allocation, _, _), do: nil

  defp range!(:history, options, today) do
    case Input.range(options, today) do
      {:ok, range} -> range
      {:error, reason} -> Repo.rollback(reason)
    end
  end

  # Exactly the dated-reader ordering: effective time admits a quote, while
  # performance sequence remains authoritative among admitted candidates.
  defp opening_quotes(ids, opening) do
    Repo.all(
      from q in Quote,
        where: q.player_id in ^ids and q.effective_at < ^opening,
        distinct: q.player_id,
        order_by: [
          asc: q.player_id,
          desc: fragment("COALESCE(?, 0)", q.performance_sequence),
          desc: q.effective_at,
          desc: q.inserted_at,
          desc: q.id
        ]
    )
  end

  defp changes(ids, opening, cutoff) do
    Repo.all(
      from q in Quote,
        where: q.player_id in ^ids and q.effective_at >= ^opening and q.effective_at <= ^cutoff
    )
  end

  defp day_end(date), do: DateTime.new!(date, ~T[23:59:59.999999], "Etc/UTC")
  defp min_time(left, right), do: if(DateTime.compare(left, right) == :gt, do: right, else: left)
end
