defmodule FootballMarket.E2E.FixtureAdapter do
  @moduledoc "Builds the already allowlisted TASK-019 fixture adapter's release barrier."
  def source(owner, gate) do
    source = FootballMarket.Synchronization.Fixtures.source()

    %{
      source
      | provider:
          {FootballMarket.IngestionFixtureAdapter,
           {:barrier, owner, gate, FootballMarket.IngestionFixtures.candidate("PL", 2090)}}
    }
  end

  def release(worker, gate), do: send(worker, {gate, :go})
end
