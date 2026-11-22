defmodule FootballMarket.TestRankingCache do
  @moduledoc false
  @state_key {__MODULE__, :state}

  def reset,
    do: :persistent_term.put(@state_key, %{values: %{}, gets: 0, writes: [], unavailable: false})

  def state, do: :persistent_term.get(@state_key)

  def expire_all, do: update(&%{&1 | values: %{}})

  def corrupt(key, payload),
    do: update(&%{&1 | values: Map.put(&1.values, key, payload)})

  def set_unavailable(value), do: update(&%{&1 | unavailable: value})

  def get(key) do
    state = update(&%{&1 | gets: &1.gets + 1})
    if state.unavailable, do: {:error, :unavailable}, else: {:ok, state.values[key]}
  end

  def put(key, value, ttl) do
    if state().unavailable do
      {:error, :unavailable}
    else
      update(fn state ->
        %{state | values: Map.put(state.values, key, value), writes: [{key, ttl} | state.writes]}
      end)

      :ok
    end
  end

  defp update(fun) do
    state = state() |> fun.()
    :persistent_term.put(@state_key, state)
    state
  end
end
