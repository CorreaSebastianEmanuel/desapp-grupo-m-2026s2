defmodule FootballMarket.Providers.Scraping.FixtureTransport do
  @moduledoc "Explicit synchronous synthetic documents; no addresses, credentials or external work."
  @behaviour FootballMarket.Providers.Scraping.Transport
  alias FootballMarket.Providers.Scraping.Assessment

  def acquire(request, context, state) do
    with {:ok, _, _} <- Assessment.admit(request, state) do
      case state[:admission] do
        nil ->
          {:ok, :unshared}

        table ->
          :ets.insert_new(table, {:budget, %{}, 0, nil})
          {runtime, clock} = context.runtime
          reserve(table, Assessment.current(state).limits, runtime.now_us(clock))
      end
    end
  end

  defp reserve(table, limits, now) do
    [{:budget, leases, used, next}] = :ets.lookup(table, :budget)
    live = Map.filter(leases, fn {_, owner} -> Process.alive?(owner) end)

    if map_size(live) >= limits.concurrency or used >= limits.volume or
         (is_integer(next) and now < next) do
      {:error, %{category: :rate_limited}}
    else
      lease = make_ref()
      new = {:budget, Map.put(live, lease, self()), used + 1, now + limits.cadence_ms * 1000}

      if replace(table, leases, used, next, new) == 1,
        do: {:ok, {table, lease}},
        else: reserve(table, limits, now)
    end
  end

  defp replace(table, leases, used, next, new) do
    :ets.select_replace(table, [
      {{:budget, :"$1", :"$2", :"$3"},
       [
         {:"=:=", :"$1", {:const, leases}},
         {:"=:=", :"$2", used},
         {:"=:=", :"$3", {:const, next}}
       ], [{:const, new}]}
    ])
  end

  def release(:unshared, _), do: :ok

  def release({table, lease} = handle, state) do
    [{:budget, leases, used, next}] = :ets.lookup(table, :budget)
    new = {:budget, Map.delete(leases, lease), used, next}
    if replace(table, leases, used, next, new) == 1, do: :ok, else: release(handle, state)
  end

  def fetch(key, context, state) do
    if state[:owner], do: send(state.owner, {:scraping_fetch, key, self()})
    if is_function(state[:on_fetch], 1), do: state.on_fetch.(key)
    if state[:sleep_ms], do: Process.sleep(state.sleep_ms)

    if state[:elapsed_us] && key in ["catalog", "schedule"] do
      {runtime, _} = context.runtime
      if function_exported?(runtime, :advance, 1), do: runtime.advance(state.elapsed_us)
    end

    case Map.get(state[:portions] || %{}, key) do
      %{failure: failure} -> {:error, failure}
      %{body: body, observation: observation} -> {:ok, %{body: body, observation: observation}}
      _ -> {:error, %{category: :invalid_response}}
    end
  end
end
