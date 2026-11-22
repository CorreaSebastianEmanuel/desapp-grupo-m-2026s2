# All Oban background workers live in this single file.
# Module names under `FootballMarket.Workers.*` are preserved so persisted
# `oban_jobs` rows and `config/synchronization.exs` cron entries stay compatible.

defmodule FootballMarket.Workers.CatalogSync do
  @moduledoc "Syncs a league/season catalog from Football-Data.org."
  use Oban.Worker, queue: :catalog_sync, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"league_code" => code, "start_year" => sy, "end_year" => ey}
      }) do
    case FootballMarket.Sync.sync_catalog(code, sy, ey) do
      {:ok, _summary} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def perform(%Oban.Job{}), do: {:discard, :invalid_args}
end

defmodule FootballMarket.Workers.CatalogScout do
  @moduledoc "Scouts external sources for a local player search miss."
  use Oban.Worker, queue: :catalog_scout, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"scout_id" => scout_id}}) when is_binary(scout_id) do
    case FootballMarket.Sync.run_scout(scout_id) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def perform(%Oban.Job{}), do: {:discard, :invalid_args}
end

defmodule FootballMarket.Workers.StatisticsImport do
  @moduledoc "Refreshes match statistics for one player/season scope."
  use Oban.Worker, queue: :statistics_import, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"player_id" => player_id, "season_id" => season_id, "source_ref" => source_ref}
      }) do
    case FootballMarket.Sync.sync_player_statistics(player_id, season_id, source_ref) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def perform(%Oban.Job{}), do: {:discard, :invalid_args}
end

defmodule FootballMarket.Workers.StatisticsPreload do
  @moduledoc "Periodic job that queues stale statistics refreshes for tracked players."
  use Oban.Worker, queue: :statistics_import, max_attempts: 1

  def startup do
    oban_name =
      Application.get_env(:football_market, FootballMarket.Synchronization, [])
      |> Keyword.get(:oban_name, Oban)

    Oban.insert(oban_name, new(%{}))
  end

  @impl Oban.Worker
  def perform(%Oban.Job{}), do: FootballMarket.Statistics.Freshness.preload()
end

defmodule FootballMarket.Workers.QuoteCalculation do
  @moduledoc "Calculates and publishes a quote for a player window."
  use Oban.Worker, queue: :quote_calculation, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "player_id" => player_id,
          "season_id" => season_id,
          "week_start" => week_start,
          "week_end" => week_end,
          "mapping_id" => mapping_id
        }
      }) do
    with {:ok, ws, 0} <- DateTime.from_iso8601(week_start),
         {:ok, we, 0} <- DateTime.from_iso8601(week_end),
         {:ok, _} <-
           FootballMarket.Quotes.calculate_and_publish(
             %{player_id: player_id, season_id: season_id, week_start: ws, week_end: we},
             :active,
             mapping_id
           ) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def perform(%Oban.Job{}), do: {:discard, :invalid_args}
end

defmodule FootballMarket.Workers.QuoteClose do
  @moduledoc "Nightly market close job that recalculates active player quotes."
  use Oban.Worker, queue: :quote_calculation, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    {:ok, _counts} = FootballMarket.Quotes.Closing.run_close()
    :ok
  end
end

defmodule FootballMarket.Workers.QuoteRecovery do
  @moduledoc "Periodic recovery worker that wakes pending conditional-order quote evaluations."
  use Oban.Worker, queue: :quote_calculation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    FootballMarket.Market.OrderEvaluation.recover()
  end
end

defmodule FootballMarket.Workers.ConditionalOrderEvaluation do
  @moduledoc "Evaluates pending conditional buy orders against current quotes."
  use Oban.Worker, queue: :conditional_orders, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"source" => "continuation"}}),
    do: FootballMarket.Market.OrderEvaluation.run(false)

  def perform(%Oban.Job{}),
    do: FootballMarket.Market.OrderEvaluation.run(true)
end

defmodule FootballMarket.Workers.ConditionalOrderRecovery do
  @moduledoc "Periodic recovery sweep for pending quote events and conditional buy orders."
  use Oban.Worker, queue: :conditional_orders, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    FootballMarket.Market.OrderEvaluation.recover(Map.get(args, "after"))
  end
end
