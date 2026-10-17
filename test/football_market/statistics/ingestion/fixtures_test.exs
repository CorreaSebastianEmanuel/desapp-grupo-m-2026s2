defmodule FootballMarket.Statistics.Ingestion.FixturesTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Providers.Request
  alias FootballMarket.StatisticsIngestion.Fixtures

  test "offline provider helper counts adapter reads in the calling test process" do
    Fixtures.reset_transport_counter()
    {:ok, request} = Request.normalize(:performances, Fixtures.scope())

    assert {:ok, %{scope: scope}} =
             FootballMarket.IngestionFixtureAdapter.read(request, %{}, %{scope: nil})

    assert scope == request.scope
    assert Fixtures.transport_counter() == 1
  end
end
