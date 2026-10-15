defmodule FootballMarket.Synchronization.Fixtures do
  @moduledoc false
  def expected, do: Code.eval_file("test/fixtures/synchronization/expected.exs") |> elem(0)
  def scope(year \\ 2090), do: FootballMarket.IngestionFixtures.request("PL", year)

  def source(year \\ 2090) do
    candidate = FootballMarket.IngestionFixtures.candidate("PL", year)

    %{
      provider: {FootballMarket.IngestionFixtureAdapter, candidate},
      runtime:
        {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-15 12:00:00.000000Z]}},
      fixture_path: "test/fixtures/synchronization/expected.exs"
    }
  end
end

defmodule FootballMarket.Synchronization.ScriptAdapter do
  @moduledoc false
  @behaviour FootballMarket.Providers.Adapter
  def provider_label, do: "synthetic-a"

  def read(_request, _context, %{owner: owner, outcome: outcome}) do
    send(owner, :synchronization_provider_called)
    outcome
  end

  def read(_request, _context, %{owner: owner, script: script}) do
    send(owner, :synchronization_provider_called)

    Agent.get_and_update(script, fn
      [outcome | rest] -> {outcome, rest}
      [] -> {{:error, %{category: :invalid_response}}, []}
    end)
  end
end
