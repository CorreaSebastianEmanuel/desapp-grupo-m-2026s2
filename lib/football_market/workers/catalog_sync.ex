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
        case ExecutionGuard.acquire(Store.scope(run), timeout: run.policy["worker_timeout_ms"]) do
          {:ok, guard} ->
            try do
              execute(run_id, delivery_id)
            after
              if Process.alive?(guard), do: GenServer.stop(guard)
            end

          _ ->
            :ok
        end
    end
  rescue
    _ -> :ok
  catch
    _, _ -> :ok
  end

  defp execute(run_id, delivery_id) do
    case Store.claim(run_id, delivery_id, Clock.now()) do
      {:ok, {run, _attempt, context}} ->
        result =
          with {:ok, options} <- Input.execution(run.input) do
            FootballMarket.Catalog.Ingestion.import_catalog(
              Map.put(Store.scope(run), :timeout_ms, run.input["timeout_ms"]),
              Keyword.put(options, :delivery_context, context)
            )
          end

        unless @test && Process.get(:synchronization_failpoint) == :after_publication do
          Store.complete(run.id, delivery_id, result, Clock.now())
        end

        :ok

      _ ->
        :ok
    end
  end
end
