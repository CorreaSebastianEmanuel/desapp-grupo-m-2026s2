defmodule FootballMarket.Workers.CatalogSync do
  @moduledoc "Catalog delivery adapter for durable synchronization execution."
  use Oban.Worker, queue: :catalog_sync, max_attempts: 1

  @impl Oban.Worker
  def perform(job), do: FootballMarket.Synchronization.Execution.perform(job)

  @impl Oban.Worker
  def timeout(job), do: FootballMarket.Synchronization.Execution.timeout(job)
end

defmodule FootballMarket.Workers.StatisticsImport do
  @moduledoc "One-shot Oban delivery for statistics imports; shared synchronization policy owns retries."
  use Oban.Worker, queue: :statistics_import, max_attempts: 1

  @impl Oban.Worker
  def perform(job), do: FootballMarket.Synchronization.Execution.perform(job)

  @impl Oban.Worker
  def timeout(job), do: FootballMarket.Synchronization.Execution.timeout(job)
end

defmodule FootballMarket.Workers.StatisticsPreload do
  @moduledoc "Durable wake for stale configured player statistics refreshes."
  use Oban.Worker,
    queue: :statistics_import,
    max_attempts: 3,
    unique: [
      period: 3_600,
      fields: [:worker],
      keys: [],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  @impl Oban.Worker
  def perform(_job) do
    _ = FootballMarket.Statistics.Freshness.preload()
    :ok
  end

  def startup do
    Oban.insert(new(%{}))
  rescue
    _ -> {:error, :unavailable}
  catch
    :exit, _ -> {:error, :unavailable}
  end
end

defmodule FootballMarket.Workers.CatalogScout do
  @moduledoc "Coordinates bounded catalog synchronizations for one validated search name."
  use Oban.Worker, queue: :catalog_scout, max_attempts: 3

  alias FootballMarket.{Catalog, Repo, Synchronization}
  alias FootballMarket.Catalog.{Scouting, ScoutRun}

  @poll_seconds 5
  @active_states ["queued", "executing", "retry_wait"]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scout_id" => id}}) do
    case Repo.get(ScoutRun, id) do
      %ScoutRun{state: "queued"} = scout -> start_syncs(scout)
      %ScoutRun{state: "scouting"} = scout -> check_syncs(scout)
      _ -> :ok
    end
  rescue
    _ -> {:error, :scout_unavailable}
  end

  defp start_syncs(scout) do
    {run_ids, errors} =
      Enum.reduce(scout.scope_inputs, {[], []}, fn {_league, input}, {ids, errors} ->
        scope = %{
          league_code: input["league_code"],
          start_year: input["start_year"],
          end_year: input["end_year"]
        }

        case Synchronization.request_catalog(scope, source_ref: input["source_ref"]) do
          {:ok, %{run_id: run_id}} -> {[run_id | ids], errors}
          {:error, error} -> {ids, [failure_category(error) | errors]}
        end
      end)

    run_ids = Enum.reverse(run_ids)

    if run_ids == [] do
      finish(scout, "provider_failure", List.first(errors) || "source_unavailable")
    else
      {:ok, updated} = Scouting.attach_sync_runs(scout.id, run_ids, List.first(errors))

      if errors == [] do
        {:snooze, @poll_seconds}
      else
        check_syncs(updated)
      end
    end
  end

  defp check_syncs(scout) do
    runs = Enum.map(scout.synchronization_run_ids, &Synchronization.get_run/1)

    if Enum.any?(runs, &active_run?/1) do
      {:snooze, @poll_seconds}
    else
      failed = Enum.any?(runs, &failed_run?/1) or not is_nil(scout.error_category)

      found? =
        case Catalog.search_local_players(scout.display_name) do
          {:ok, players} ->
            Enum.any?(players, &(normalize(&1.display_name) == scout.normalized_name))

          _ ->
            false
        end

      state =
        cond do
          found? -> "found"
          failed -> "provider_failure"
          true -> "not_found"
        end

      finish(scout, state, if(failed, do: "provider_failure"))
    end
  end

  defp active_run?({:ok, %{state: state}}), do: state in @active_states
  defp active_run?(_), do: false
  defp failed_run?({:ok, %{state: "failed"}}), do: true
  defp failed_run?({:error, _}), do: true
  defp failed_run?(_), do: false

  defp failure_category(%{category: category}) when is_atom(category),
    do: Atom.to_string(category)

  defp failure_category(_), do: "provider_failure"

  defp finish(scout, state, category) do
    case Scouting.finish(scout, state, category) do
      {:ok, _updated} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize(value), do: FootballMarket.Catalog.Scouting.normalize_identity(value)
end
