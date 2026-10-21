defmodule FootballMarket.Workers.CatalogSync do
  @moduledoc "One-shot transport; durable run policy owns domain attempts."
  use Oban.Worker, queue: :catalog_sync, max_attempts: 1
  alias FootballMarket.{Repo, Synchronization}
  alias Synchronization.{Run, Store, Input, Clock, ExecutionGuard}
  @test Mix.env() == :test

  @impl Oban.Worker
  def timeout(%Oban.Job{args: %{"run_id" => id}}) do
    case Repo.get(Run, id) do
      %Run{policy: %{"worker_timeout_ms" => timeout}} when is_integer(timeout) and timeout > 0 ->
        timeout

      _ ->
        30_000
    end
  rescue
    _ -> 30_000
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"run_id" => run_id, "delivery_id" => delivery_id}}) do
    case Repo.get(Run, run_id) do
      nil ->
        :ok

      run ->
        with_guard(run, run_id, delivery_id)
    end
  rescue
    _ -> :ok
  catch
    _, _ -> :ok
  end

  defp execute(run_id, delivery_id) do
    case Store.claim(run_id, delivery_id, Clock.now()) do
      {:ok, {run, attempt, context}} ->
        result =
          execute_operation(run, attempt, context)

        complete_publication(run, delivery_id, result)

        :ok

      _ ->
        :ok
    end
  end

  defp with_guard(run, run_id, delivery_id) do
    case ExecutionGuard.acquire(Store.execution_scope(run),
           timeout: run.policy["worker_timeout_ms"]
         ) do
      {:ok, guard} ->
        try do
          execute(run_id, delivery_id)
        after
          stop_guard(guard)
        end

      _ ->
        :ok
    end
  end

  defp stop_guard(guard) do
    if Process.alive?(guard), do: GenServer.stop(guard)
  end

  defp execute_operation(run, attempt, context) do
    with {:ok, options} <- Input.execution(run.input) do
      delivery_context =
        if run.operation == "statistics",
          do: Map.put(context, :attempt_id, attempt.id),
          else: context

      options = Keyword.put(options, :delivery_context, delivery_context)

      scope = Map.put(Store.scope(run), :timeout_ms, run.input["timeout_ms"])

      if run.operation == "statistics" do
        FootballMarket.Statistics.Ingestion.import_scope(scope, options)
      else
        FootballMarket.Catalog.Ingestion.import_catalog(scope, options)
      end
    end
  end

  defp complete_publication(run, delivery_id, result) do
    case if(@test, do: Process.get(:synchronization_failpoint), else: nil) do
      {:after_publication, target_run_id} when target_run_id == run.id ->
        :ok

      :after_publication ->
        :ok

      {:pause_after_publication, owner} when is_pid(owner) ->
        send(owner, {:statistics_published, run.id, self()})

        receive do
          :continue -> Store.complete(run.id, delivery_id, result, Clock.now())
        end

      _ ->
        Store.complete(run.id, delivery_id, result, Clock.now())
    end
  end
end
