defmodule FootballMarket.Synchronization.Dispatcher do
  @moduledoc "Supervised recovery and UTC scheduling tick; startup never implies import."
  use GenServer
  require Logger
  alias FootballMarket.Synchronization.{Clock, Recovery, Scheduler, Store}

  @calculation_orphan_after_seconds 300

  def start_link(options \\ []),
    do: GenServer.start_link(__MODULE__, options, name: Keyword.get(options, :name, __MODULE__))

  def tick(server \\ __MODULE__), do: GenServer.call(server, :tick, 60_000)

  @impl true
  def init(options) do
    if repo = Keyword.get(options, :repo), do: FootballMarket.Repo.put_dynamic_repo(repo)

    config = Application.get_env(:football_market, FootballMarket.Synchronization, [])
    automatic = Keyword.get(options, :automatic, Keyword.get(config, :automatic, true))
    interval = Keyword.get(config, :tick_ms, 15_000)

    if FootballMarket.Synchronization.Policy.validate_runtime(config) == :ok do
      if automatic, do: send(self(), :tick)
      {:ok, %{automatic: automatic, interval: interval, last_result: nil}}
    else
      {:stop, :invalid_configuration}
    end
  end

  @impl true
  def handle_call(:tick, _from, state) do
    result = dispatch()
    {:reply, result, %{state | last_result: result}}
  end

  @impl true
  def handle_info(:tick, state) do
    result = dispatch()

    if match?({:error, _}, result),
      do: Logger.warning("catalog synchronization tick failed; inspect dispatcher last_result")

    if state.automatic, do: Process.send_after(self(), :tick, state.interval)
    {:noreply, %{state | last_result: result}}
  end

  defp dispatch do
    config = Application.get_env(:football_market, FootballMarket.Synchronization, [])
    schedules = Keyword.get(config, :schedules, [])

    with {:ok, _} <- Recovery.reconcile(Clock.now()),
         :ok <- dispatch_calculation_intents() do
      enabled = Keyword.get(config, :enabled, false)
      if not is_boolean(enabled), do: throw(:invalid_configuration)
      disabled = if enabled, do: {:ok, 0}, else: Scheduler.disable_all(Clock.now())
      if match?({:error, _}, disabled), do: throw(:store_unavailable)

      valid_schedules =
        is_list(schedules) and
          Enum.all?(schedules, fn
            {key, definition} -> is_binary(key) and is_map(definition)
            _ -> false
          end)

      unless valid_schedules, do: throw(:invalid_schedule_configuration)

      if enabled do
        case Scheduler.disable_unconfigured(Enum.map(schedules, &elem(&1, 0)), Clock.now()) do
          {:ok, _} -> :ok
          _ -> throw(:store_unavailable)
        end
      end

      configured =
        for {key, definition} <- schedules do
          Scheduler.configure(
            key,
            Map.put(definition, :enabled, enabled && Map.get(definition, :enabled, true))
          )
        end

      cond do
        Enum.any?(configured, &match?({:error, _}, &1)) ->
          {:error, :invalid_schedule_configuration}

        not enabled ->
          {:ok, []}

        true ->
          Scheduler.tick(Clock.now())
      end
    end
  rescue
    _ -> Store.unavailable()
  catch
    :invalid_configuration -> {:error, :invalid_configuration}
    :invalid_schedule_configuration -> {:error, :invalid_schedule_configuration}
    :store_unavailable -> Store.unavailable()
  end

  defp dispatch_calculation_intents do
    import Ecto.Query
    now = Clock.now()
    orphan_cutoff = DateTime.add(now, -@calculation_orphan_after_seconds, :second)

    intents =
      FootballMarket.Repo.all(
        from i in FootballMarket.Statistics.Ingestion.CalculationIntent,
          where:
            i.state == "pending" and i.attempts < 3 and
              (is_nil(i.next_attempt_at) or i.next_attempt_at <= ^now),
          order_by: i.requested_at,
          limit: 50
      )

    Enum.each(intents, fn intent ->
      active =
        FootballMarket.Repo.exists?(
          from j in Oban.Job,
            where:
              j.worker == "FootballMarket.Workers.CalculationDispatch" and
                (j.state in ["available", "scheduled", "retryable"] or
                   (j.state == "executing" and j.attempted_at >= ^orphan_cutoff)) and
                fragment("?->>'intent_id' = ?", j.args, ^intent.id)
        )

      unless active do
        job = FootballMarket.Workers.CalculationDispatch.new(%{"intent_id" => intent.id})

        oban_name =
          :football_market
          |> Application.get_env(FootballMarket.Synchronization, [])
          |> Keyword.get(:oban_name, Oban)

        Oban.insert(oban_name, job)
      end
    end)

    :ok
  rescue
    _ -> {:error, :calculation_dispatch_unavailable}
  end
end
