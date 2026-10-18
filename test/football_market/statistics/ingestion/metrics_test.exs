defmodule FootballMarket.Statistics.Ingestion.MetricsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  import Ecto.Query
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.{Input, Performance}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "all nine optional metrics retain unknown independently from zero" do
    scope = Fixtures.scope(2120)
    Case.seed_catalog!(scope)
    request = Fixtures.request(scope)
    base = Case.candidate(request)
    metrics = Input.metrics()

    matches =
      for {_metric, index} <- Enum.with_index(metrics) do
        match = hd(base.facts.matches)
        %{match | ref: "match-#{index}", kickoff_at: DateTime.add(match.kickoff_at, index, :day)}
      end

    performances =
      for {metric, index} <- Enum.with_index(metrics) do
        performance = hd(base.facts.performances)
        counts = Map.new(metrics, &{&1, nil}) |> Map.put(metric, 0)

        %{performance | ref: "performance-#{index}", match_ref: "match-#{index}", counts: counts}
      end

    candidate = Case.candidate(request, matches: matches, performances: performances)
    context = Case.delivery_context!(scope)

    assert {:ok, _} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: context]
             )

    season_id =
      Repo.one!(from s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year).id

    performances = Repo.all(from p in Performance, where: p.season_id == ^season_id)
    assert length(performances) == length(metrics)

    for metric <- metrics do
      assert Enum.count(performances, &(Map.get(&1, metric) == 0)) == 1
      assert Enum.all?(performances, &(is_nil(Map.get(&1, metric)) or Map.get(&1, metric) == 0))
    end

    for performance <- performances do
      assert Enum.count(metrics, &(Map.get(performance, &1) == 0)) == 1

      assert {:ok, read_back} =
               Statistics.get_performance(performance.player_id, performance.match_id)

      assert Map.take(read_back, metrics) == Map.take(performance, metrics)
    end
  end
end
