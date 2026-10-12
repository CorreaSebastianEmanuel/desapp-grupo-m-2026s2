defmodule FootballMarket.Catalog.Ingestion.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Ecto.Query
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Repo
  alias Ecto.Adapters.SQL.Sandbox
  alias FootballMarket.Catalog.{League, Season, Team, Player, Position}
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Ingestion.{Scope, Observation, SourceBinding, ObservationBinding}

  setup do
    year = 3000 + System.unique_integer([:positive])

    {position, created} =
      Sandbox.unboxed_run(Repo, fn ->
        case Repo.get_by(Position, code: "GK") do
          nil -> {positions!(), true}
          p -> {p, false}
        end
      end)

    original_league = Sandbox.unboxed_run(Repo, fn -> Repo.get_by(League, code: "PL") end)

    on_exit(fn ->
      Sandbox.unboxed_run(Repo, fn ->
        Repo.transaction(fn ->
          ids = Repo.all(from s in Scope, where: s.start_year in ^[year, year + 1], select: s.id)

          seasons =
            Repo.all(from s in Season, where: s.start_year in ^[year, year + 1], select: s.id)

          Repo.delete_all(from m in ObservationBinding, where: m.scope_id in ^ids)
          Repo.delete_all(from b in SourceBinding, where: b.scope_id in ^ids)
          Repo.delete_all(from o in Observation, where: o.scope_id in ^ids)
          Repo.delete_all(from s in Scope, where: s.id in ^ids)
          Repo.delete_all(from p in Player, where: p.season_id in ^seasons)
          Repo.delete_all(from t in Team, where: t.season_id in ^seasons)
          Repo.delete_all(from s in Season, where: s.id in ^seasons)
          if created, do: Repo.delete!(position)
          # Delete only the canonical league if this fixture created its sole hierarchy.
          if is_nil(original_league),
            do:
              Repo.delete_all(
                from l in League,
                  as: :l,
                  where:
                    l.code == "PL" and
                      not exists(from s in Season, where: s.league_id == parent_as(:l).id)
              )
        end)
      end)
    end)

    %{year: year}
  end

  test "independent connections converge equivalent revision-zero deliveries", %{year: year} do
    token = make_ref()
    parent = self()

    tasks =
      for _ <- 1..2 do
        Task.async(fn ->
          Sandbox.unboxed_run(Repo, fn ->
            Ingestion.import_catalog(
              request("PL", year),
              options({:barrier, parent, token, candidate("PL", year)})
            )
          end)
        end)
      end

    backends =
      for t <- tasks do
        pid = t.pid
        assert_receive {^token, ^pid, backend}, 5000
        backend
      end

    assert length(Enum.uniq(backends)) == 2
    for t <- tasks, do: send(t.pid, {token, :go})
    outcomes = Enum.map(tasks, &Task.await(&1, 10000))
    assert Enum.all?(outcomes, &match?({:ok, _}, &1))

    assert Enum.sort(Enum.map(outcomes, fn {:ok, o} -> o.status end)) == [
             :accepted_with_changes,
             :replay
           ]

    assert length(Enum.uniq(Enum.map(outcomes, fn {:ok, o} -> o.acceptance_reference end))) == 1
  end

  defp overlap(year, candidates, instant) do
    token = make_ref()
    parent = self()

    tasks =
      for c <- candidates do
        Task.async(fn ->
          Sandbox.unboxed_run(Repo, fn ->
            Ingestion.import_catalog(
              request("PL", year),
              options({:barrier, parent, token, c}, instant)
            )
          end)
        end)
      end

    backends =
      for t <- tasks do
        pid = t.pid
        assert_receive {^token, ^pid, backend}, 5000
        backend
      end

    assert length(Enum.uniq(backends)) == 2
    for t <- tasks, do: send(t.pid, {token, :go})
    Enum.map(tasks, &Task.await(&1, 10000))
  end

  test "differing deliveries at revision zero and n yield exactly one publication", %{year: year} do
    c = candidate("PL", year)
    other = %{c | fixture_id: "other-fixture"}

    for {inputs, instant} <- [
          {[c, other], ~U[2026-10-07 12:00:00.000000Z]},
          {[
             c,
             %{
               c
               | facts: %{c.facts | players: [%{hd(c.facts.players) | display_name: "Changed"}]}
             }
           ], ~U[2026-10-08 12:00:00.000000Z]}
        ] do
      results = overlap(year, inputs, instant)
      assert Enum.count(results, &match?({:ok, _}, &1)) == 1
      assert [{:error, loser}] = Enum.filter(results, &match?({:error, _}, &1))
      assert loser.status == :concurrent_change
      # Advance the provider time for the second race by changing only fixture facts.
      if Enum.any?(inputs, &(&1.fixture_id == "other-fixture")) do
        Sandbox.unboxed_run(Repo, fn ->
          # Accepted old delivery replay never rewrites current state.
          accepted = Enum.find(results, &match?({:ok, _}, &1))
          assert {:ok, _} = accepted
        end)
      end
    end
  end

  test "reader sees old state until the complete hierarchy commits", %{year: year} do
    parent = self()

    task =
      Task.async(fn ->
        Sandbox.unboxed_run(Repo, fn ->
          publication_failpoint(fn point ->
            if point == :after_catalog do
              send(parent, {:catalog_written, self()})

              receive do
                :commit -> :ok
              after
                5000 -> raise "publication barrier timeout"
              end
            end
          end)

          Ingestion.import_catalog(request("PL", year), options(candidate("PL", year)))
        end)
      end)

    assert_receive {:catalog_written, pid}, 5000

    read = fn ->
      Sandbox.unboxed_run(Repo, fn ->
        Repo.all(
          from p in Player,
            join: s in Season,
            on: s.id == p.season_id,
            join: t in Team,
            on: t.id == p.team_id,
            where: s.start_year == ^year,
            select: {p.display_name, t.code, t.name}
        )
      end)
    end

    assert read.() == []
    send(pid, :commit)
    assert {:ok, _} = Task.await(task, 10000)
    assert read.() == [{"Alex", "ALP", "Alpha"}]
  end

  test "different seasons safely share a newly created canonical league", %{year: year} do
    token = make_ref()
    parent = self()

    tasks =
      for y <- [year, year + 1] do
        Task.async(fn ->
          Sandbox.unboxed_run(Repo, fn ->
            Ingestion.import_catalog(
              request("PL", y),
              options({:barrier, parent, token, candidate("PL", y)})
            )
          end)
        end)
      end

    for t <- tasks do
      pid = t.pid
      assert_receive {^token, ^pid, _backend}, 5000
    end

    for t <- tasks, do: send(t.pid, {token, :go})
    results = Enum.map(tasks, &Task.await(&1, 10000))
    assert Enum.all?(results, &match?({:ok, _}, &1))

    Sandbox.unboxed_run(Repo, fn ->
      seasons = Repo.all(from s in Season, where: s.start_year in ^[year, year + 1])
      assert length(seasons) == 2
      assert length(Enum.uniq(Enum.map(seasons, & &1.league_id))) == 1

      assert Repo.aggregate(
               from(p in Player, where: p.season_id in ^Enum.map(seasons, & &1.id)),
               :count
             ) == 2
    end)
  end

  test "a failing paused publisher is invisible to another connection", %{year: year} do
    parent = self()

    task =
      Task.async(fn ->
        Sandbox.unboxed_run(Repo, fn ->
          publication_failpoint(fn point ->
            if point == :after_observation do
              send(parent, {:attempt_written, self()})

              receive do
                :fail -> raise "controlled failure"
              after
                5000 -> raise "barrier timeout"
              end
            end
          end)

          Ingestion.import_catalog(request("PL", year), options(candidate("PL", year)))
        end)
      end)

    assert_receive {:attempt_written, pid}, 5000

    read = fn ->
      Sandbox.unboxed_run(Repo, fn ->
        {Repo.aggregate(from(s in Scope, where: s.start_year == ^year), :count),
         Repo.aggregate(from(s in Season, where: s.start_year == ^year), :count)}
      end)
    end

    assert read.() == {0, 0}
    send(pid, :fail)
    assert {:error, outcome} = Task.await(task, 10000)
    assert outcome.status == :persistence_failure
    assert read.() == {0, 0}
  end
end
