defmodule FootballMarket.Observability.JobContext do
  @moduledoc "Durable logging lineage adapter, kept out of telemetry callbacks."
  import Ecto.Query
  alias FootballMarket.{Repo, Observability.Context}
  alias FootballMarket.Statistics.Ingestion.{CalculationIntent, Check}
  alias FootballMarket.Synchronization.Run
  alias FootballMarket.Quotes.CalculationRequest

  def for_run(run), do: Context.id(run.correlation_id, run.id)

  def annotate(changeset, correlation_id) do
    meta = Ecto.Changeset.get_field(changeset, :meta) || %{}
    Ecto.Changeset.put_change(changeset, :meta, Map.put(meta, "correlation_id", correlation_id))
  end

  def for_intents([]), do: %{}

  def for_intents(ids) do
    from(i in CalculationIntent,
      left_join: c in Check,
      on: c.id == i.accepted_check_id,
      left_join: r in Run,
      on: r.id == c.run_id,
      where: i.id in ^ids,
      select: {i.id, r.correlation_id, r.id}
    )
    |> contexts()
  end

  def for_calculations([]), do: %{}

  def for_calculations(ids) do
    from(q in CalculationRequest,
      left_join: i in CalculationIntent,
      on: i.id == q.intent_id,
      left_join: c in Check,
      on: c.id == i.accepted_check_id,
      left_join: r in Run,
      on: r.id == c.run_id,
      where: q.id in ^ids,
      select: {q.id, r.correlation_id, r.id}
    )
    |> contexts()
  end

  defp contexts(query) do
    query
    |> Repo.all()
    |> Map.new(fn {id, correlation, run_id} -> {id, Context.id(correlation, run_id || id)} end)
  rescue
    _ -> %{}
  end
end
