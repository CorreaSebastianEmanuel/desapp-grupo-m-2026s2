defmodule FootballMarket.Providers.FootballData.RecordingTransport do
  @moduledoc false
  import ExUnit.Assertions
  alias FootballMarket.Providers.{FixtureRuntime, FootballData.FixtureData}

  def request(route, credential, context, c) do
    assert credential == "FD_SYNTHETIC_SENTINEL"

    assert match?({:discovery, _}, route) or match?({:teams, _, _}, route) or
             match?({:team, _}, route) or match?({:person, _}, route)

    if c[:owner], do: send(c.owner, :fd_external_attempt)
    n = Process.get(:fd_calls, 0) + 1
    Process.put(:fd_calls, n)
    Process.put(:fd_routes, Process.get(:fd_routes, []) ++ [route])
    FixtureRuntime.advance(Map.get(c, :per_call_us, 0))
    if n == 1, do: FixtureRuntime.advance(Map.get(c, :elapsed_us, 0))
    if c[:raise_secret], do: raise("FD_SYNTHETIC_SENTINEL")
    result = FixtureData.response(route, c, n)

    case result do
      {:ok, %{status: status} = response} when status != 200 ->
        receipt =
          if Map.has_key?(c, :receipt_override) do
            c.receipt_override
          else
            {runtime, state} = context.runtime
            received = runtime.now_us(state)
            %{received_us: received, received_utc: runtime.utc_now(state)}
          end

        FixtureRuntime.advance(Map.get(c, :parse_us, 0))
        {:ok, Map.merge(response, receipt)}

      other ->
        other
    end
  end
end
