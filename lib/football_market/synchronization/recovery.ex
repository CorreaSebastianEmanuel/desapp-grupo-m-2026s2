defmodule FootballMarket.Synchronization.Recovery do
  @moduledoc "Guard-coordinated orphan recovery with fenced confirmed publication evidence."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Synchronization.{Run, Store, ExecutionGuard}
  alias FootballMarket.Workers.CatalogSync

  def reconcile(now) do
    runs =
      Repo.all(
        from r in Run,
          where: r.state in ["queued", "executing", "retry_wait"],
          order_by: r.requested_at
      )

    results =
      Enum.map(runs, fn run ->
        case ExecutionGuard.acquire(Store.scope(run)) do
          {:ok, guard} ->
            try do
              if run.state == "executing",
                do: Store.complete(run.id, run.delivery_id, {:error, :interrupted}, now),
                else: repair(run, now)
            after
              if Process.alive?(guard), do: GenServer.stop(guard)
            end

          {:error, :busy} ->
            :busy

          _ ->
            Store.unavailable()
        end
      end)

    if Enum.any?(results, &match?({:error, _}, &1)), do: Store.unavailable(), else: {:ok, results}
  rescue
    _ -> Store.unavailable()
  end

  defp repair(run, now) do
    Repo.transaction(fn ->
      current = Repo.one!(from r in Run, where: r.id == ^run.id, lock: "FOR UPDATE")
      job = Repo.get(Oban.Job, current.job_id)

      if current.state in ["queued", "retry_wait"] &&
           (is_nil(job) || job.state in ["completed", "discarded", "cancelled", "executing"]) do
        eligible = current.next_retry_at || now

        job =
          %{"run_id" => current.id, "delivery_id" => current.delivery_id}
          |> CatalogSync.new(scheduled_at: eligible)
          |> Store.insert_job!()

        Repo.update!(Ecto.Changeset.change(current, job_id: job.id))
      end
    end)
  end
end
