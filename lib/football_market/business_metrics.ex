defmodule FootballMarket.BusinessMetrics do
  @moduledoc """
  Administrator-only aggregates of currently retained local records.

  This is a database snapshot, not lifetime instrumentation. In particular,
  Oban pruning removes job history. No provider calls or mutations occur.
  """
  import Ecto.Query

  alias FootballMarket.{Accounts, Repo}
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{ConditionalOrder, Purchase, Quote, Sale}
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Statistics.{Performance, ScopeCheck}

  @request_states ~w(pending running retrying successful no_quote validation_failed unsupported_strategy unreproducible exhausted)
  @order_states ~w(pending executed cancelled expired rejected)
  @job_states ~w(suspended available scheduled executing retryable completed discarded cancelled)
  @sections ~w(quotes conditional_orders portfolio_activity ingestion jobs)a

  def snapshot(%AuthenticatedActor{} = actor) do
    if Accounts.administrator?(actor), do: {:ok, read_snapshot()}, else: {:error, :forbidden}
  end

  def snapshot(_), do: {:error, :unauthenticated}

  defp read_snapshot do
    if Repo.in_transaction?() do
      unavailable()
    else
      case Repo.transaction(&query_snapshot!/0) do
        {:ok, result} -> result
        {:error, _reason} -> unavailable()
      end
    end
  rescue
    _ in [Postgrex.Error, DBConnection.ConnectionError] -> unavailable()
  end

  defp query_snapshot! do
    Repo.query!("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
    %{rows: [[as_of]]} = Repo.query!("SELECT transaction_timestamp()")

    quotes = %{
      performance_quotes:
        Repo.aggregate(from(q in Quote, where: not is_nil(q.calculation_id)), :count),
      requests_by_state: grouped_counts(CalculationRequest, :state, @request_states)
    }

    orders = %{by_status: grouped_counts(ConditionalOrder, :status, @order_states)}
    portfolio = %{purchases: trades(Purchase), sales: trades(Sale)}

    ingestion = %{
      accepted_scopes:
        Repo.aggregate(from(s in ScopeCheck, where: not is_nil(s.last_checked_at)), :count),
      performance_records: Repo.aggregate(Performance, :count)
    }

    jobs = %{by_state: grouped_counts(Oban.Job, :state, @job_states)}

    %{
      basis: "retained_local_records",
      as_of: DateTime.to_iso8601(as_of),
      quotes: section(quotes),
      conditional_orders: section(orders),
      portfolio_activity: section(portfolio),
      ingestion: section(ingestion),
      jobs: section(jobs)
    }
  end

  defp grouped_counts(schema, field_name, states) do
    rows =
      Repo.all(
        from r in schema,
          group_by: field(r, ^field_name),
          select: {field(r, ^field_name), count()}
      )

    # Fixed keys prevent persisted labels or unexpected future states leaking out.
    Map.merge(Map.new(states, &{&1, 0}), Map.take(Map.new(rows), states))
  end

  defp trades(schema) do
    Repo.one(
      from t in schema,
        where: not is_nil(t.completed_at),
        select: %{count: count(), token_quantity: coalesce(sum(t.quantity), 0)}
    )
  end

  defp section(counts),
    do: %{status: if(nonzero?(counts), do: "available", else: "empty"), counts: counts}

  defp nonzero?(counts),
    do:
      Enum.any?(counts, fn {_key, value} ->
        if is_map(value), do: nonzero?(value), else: value > 0
      end)

  defp unavailable do
    Map.new(@sections, &{&1, %{status: "unavailable", counts: nil}})
    |> Map.merge(%{basis: "retained_local_records", as_of: nil})
  end
end
