defmodule FootballMarket.Providers.Scraping.Budget do
  @moduledoc """
  Shared in-memory ETS lease table and concurrency/volume/cadence budget enforcement
  for live scraping transports.
  """

  use GenServer

  alias FootballMarket.Providers.Scraping.Assessment

  @table :football_market_scraping_admission

  # --- GenServer (Owns the ETS Admission Table) ---

  def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def table, do: GenServer.call(__MODULE__, :table)

  @impl true
  def init(:ok) do
    {:ok, :ets.new(@table, [:named_table, :public, :set, write_concurrency: true])}
  end

  @impl true
  def handle_call(:table, _from, table), do: {:reply, table, table}

  # --- Lease Acquisition & Release ---

  def acquire(request, context, state, durable_volume \\ false) do
    with {:ok, _, _} <- Assessment.admit(request, state) do
      case state[:admission] do
        nil ->
          {:ok, :unshared}

        table ->
          :ets.insert_new(table, {:budget, %{}, 0, nil})
          {runtime, clock} = context.runtime
          reserve(table, Assessment.current(state).limits, runtime.now_us(clock), durable_volume)
      end
    end
  end

  def release(:unshared, _), do: :ok

  def release({table, lease} = handle, state) do
    [{:budget, leases, used, next}] = :ets.lookup(table, :budget)
    updated = {:budget, Map.delete(leases, lease), used, next}
    if replace(table, leases, used, next, updated) == 1, do: :ok, else: release(handle, state)
  end

  defp reserve(table, limits, now, durable_volume) do
    [{:budget, leases, used, next}] = :ets.lookup(table, :budget)
    live = Map.filter(leases, fn {_ref, owner} -> Process.alive?(owner) end)

    if map_size(live) >= limits.concurrency or
         (not durable_volume and used >= limits.volume) or
         (is_integer(next) and now < next) do
      {:error, %{category: :rate_limited}}
    else
      lease = make_ref()
      updated = {:budget, Map.put(live, lease, self()), used + 1, now + limits.cadence_ms * 1000}

      if replace(table, leases, used, next, updated) == 1,
        do: {:ok, {table, lease}},
        else: reserve(table, limits, now, durable_volume)
    end
  end

  defp replace(table, leases, used, next, updated) do
    :ets.select_replace(table, [
      {{:budget, :"$1", :"$2", :"$3"},
       [
         {:"=:=", :"$1", {:const, leases}},
         {:"=:=", :"$2", used},
         {:"=:=", :"$3", {:const, next}}
       ], [{:const, updated}]}
    ])
  end
end
