defmodule FootballMarket.Providers.Scraping.FixtureTransport do
  @moduledoc "Explicit synchronous synthetic documents; no addresses, credentials or external work."
  @behaviour FootballMarket.Providers.Scraping.Transport
  alias FootballMarket.Providers.Scraping.Budget

  defdelegate acquire(request, context, state), to: Budget
  defdelegate release(lease, state), to: Budget

  def fetch(key, context, state) do
    if state[:owner], do: send(state.owner, {:scraping_fetch, key, self()})
    if is_function(state[:on_fetch], 1), do: state.on_fetch.(key)
    if state[:sleep_ms], do: Process.sleep(state.sleep_ms)

    advance_elapsed(context, state, key)

    case Map.get(state[:portions] || %{}, key) do
      %{failure: failure} -> {:error, failure}
      %{body: body, observation: observation} -> {:ok, %{body: body, observation: observation}}
      _ -> {:error, %{category: :invalid_response}}
    end
  end

  defp advance_elapsed(context, state, key) do
    if state[:elapsed_us] && key in ["catalog", "schedule"] do
      {runtime, _} = context.runtime
      if function_exported?(runtime, :advance, 1), do: runtime.advance(state.elapsed_us)
    end
  end
end
