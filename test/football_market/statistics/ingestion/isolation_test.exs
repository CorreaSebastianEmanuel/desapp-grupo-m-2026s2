defmodule FootballMarket.Statistics.Ingestion.IsolationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "provider failure leaves accepted facts intact and does not interrupt local history reads" do
    scope = Fixtures.scope(2090)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    context = Case.delivery_context!(scope)

    assert {:ok, _} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    player_id =
      Repo.one!(
        from p in FootballMarket.Statistics.Performance,
          where: p.season_id == ^season_id,
          select: p.player_id
      )

    before = Statistics.list_player_history(player_id)

    Process.put(:statistics_ingestion_transport_calls, 0)
    failure_context = Case.delivery_context!(scope)

    assert {:error, %{status: :provider_failure}} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options({:error, %{category: :unavailable}}) ++
                 [delivery_context: failure_context]
             )

    assert Process.get(:statistics_ingestion_transport_calls) == 1
    assert ^before = Statistics.list_player_history(player_id)

    assert Repo.aggregate(
             from(p in FootballMarket.Statistics.Performance, where: p.season_id == ^season_id),
             :count
           ) == 1
  end
end
