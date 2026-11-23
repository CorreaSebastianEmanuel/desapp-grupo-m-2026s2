defmodule FootballMarket.TestRankingCache do
  @moduledoc false
  @state_key {__MODULE__, :state}

  def reset,
    do:
      :persistent_term.put(@state_key, %{
        values: %{},
        gets: 0,
        writes: [],
        unavailable: false,
        expires: %{},
        now: 0,
        get_failure: nil,
        put_failure: nil,
        put_hook: nil
      })

  def advance(seconds), do: update(&%{&1 | now: &1.now + seconds})
  def fail(operation, failure), do: update(&Map.put(&1, operation, failure))
  def before_put(hook), do: update(&%{&1 | put_hook: hook})

  def state, do: :persistent_term.get(@state_key)

  def expire_all, do: update(&%{&1 | values: %{}})

  def corrupt(key, payload),
    do: update(&%{&1 | values: Map.put(&1.values, key, payload)})

  def set_unavailable(value), do: update(&%{&1 | unavailable: value})

  def get(key) do
    state = update(&%{&1 | gets: &1.gets + 1})
    maybe_fail(state.get_failure)

    cond do
      state.unavailable -> {:error, :unavailable}
      state.now >= Map.get(state.expires, key, 0) -> {:ok, nil}
      true -> {:ok, state.values[key]}
    end
  end

  def put(key, value, ttl) do
    maybe_fail(state().put_failure)

    if hook = state().put_hook do
      before_put(nil)
      hook.()
    end

    if state().unavailable do
      {:error, :unavailable}
    else
      update(fn state ->
        %{
          state
          | values: Map.put(state.values, key, value),
            expires: Map.put(state.expires, key, state.now + ttl),
            writes: [{key, ttl} | state.writes]
        }
      end)

      :ok
    end
  end

  defp maybe_fail(:raise), do: raise("Redis unavailable")
  defp maybe_fail(:exit), do: exit(:disconnected)
  defp maybe_fail(nil), do: :ok

  defp update(fun) do
    state = state() |> fun.()
    :persistent_term.put(@state_key, state)
    state
  end
end
