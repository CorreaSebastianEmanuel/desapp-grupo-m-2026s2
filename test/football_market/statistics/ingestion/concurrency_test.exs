defmodule FootballMarket.Statistics.Ingestion.ConcurrencyTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion.{Check, FactProvenance}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "independent committed PostgreSQL callers serialize identical publication without duplicate facts" do
    year =
      DateTime.utc_now().year +
        rem(System.unique_integer([:positive]) + System.os_time(:millisecond), 7_000)

    scope = Fixtures.scope(year)

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Case.seed_catalog!(scope)
    end)

    parent = self()
    request = Fixtures.request(scope)

    tasks =
      for index <- 1..2 do
        token = {:statistics_race, index}

        Task.async(fn ->
          Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
            context = Case.delivery_context!(scope, run_state: "failed")
            candidate = Case.candidate(request)
            candidate = {:barrier, parent, token, candidate}

            result =
              Statistics.Ingestion.import_scope(
                scope,
                Case.provider_options(candidate) ++ [delivery_context: context]
              )

            {token, result}
          end)
        end)
      end

    ready =
      for index <- 1..2 do
        token = {:statistics_race, index}

        assert_receive {^token, pid, backend}, 5000
        {token, pid, backend}
      end

    assert length(Enum.uniq(Enum.map(ready, &elem(&1, 2)))) == 2
    Enum.each(ready, fn {token, pid, _backend} -> send(pid, {token, :go}) end)
    results = Enum.map(tasks, &Task.await(&1, 15_000))

    assert Enum.all?(results, fn {_token, result} -> match?({:ok, _}, result) end)

    assert Enum.count(results, fn {_token, {:ok, outcome}} ->
             outcome.status == :accepted_changes
           end) == 1

    assert Enum.count(results, fn {_token, {:ok, outcome}} -> outcome.status == :replay end) == 1

    season_id =
      Repo.one!(
        from(s in FootballMarket.Catalog.Season, where: s.start_year == ^scope.start_year)
      ).id

    run_ids = Enum.map(results, fn {_token, {:ok, outcome}} -> outcome.run_id end)
    check_ids = Repo.all(from(c in Check, where: c.run_id in ^run_ids, select: c.id))

    assert Repo.aggregate(from(m in Statistics.Match, where: m.season_id == ^season_id), :count) ==
             1

    assert Repo.aggregate(
             from(p in Statistics.Performance, where: p.season_id == ^season_id),
             :count
           ) == 1

    assert length(check_ids) == 2
    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id in ^run_ids), :count) == 2
  end
end
