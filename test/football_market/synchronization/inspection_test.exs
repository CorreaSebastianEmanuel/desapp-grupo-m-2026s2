defmodule FootballMarket.Synchronization.InspectionTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.Fixtures

  setup do
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
  end

  test "inspection exposes durable original and coalesced triggers without raw source state" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               trigger: :initial
             )

    assert {:ok, _} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    assert {:ok, run} = Synchronization.get_run(accepted.run_id)
    assert run.state == "queued"
    assert run.attempts == []
    assert Enum.sort(Enum.map(run.triggers, & &1.kind)) == ["initial", "manual"]
    assert run.original_trigger == "initial"
    refute inspect(run) =~ "display_name"
    assert {:ok, [listed]} = Synchronization.list_runs(Fixtures.scope())
    assert listed.id == accepted.run_id

    assert {:error, %{category: :invalid_request}} =
             Synchronization.list_runs(Fixtures.scope(), limit: 101)

    assert {:error, %{category: :invalid_request}} = Synchronization.get_run("invalid")
    assert {:error, %{category: :not_found}} = Synchronization.get_run(Ecto.UUID.generate())
  end

  test "worker confirms acceptance and replay with separate historical/applied counts" do
    FootballMarket.IngestionFixtures.positions!()

    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    run = Repo.get!(FootballMarket.Synchronization.Run, accepted.run_id)

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
             })

    assert {:ok, completed} = Synchronization.get_run(run.id)
    assert completed.state == "succeeded"
    assert completed.outcome["status"] == "accepted_with_changes"
    assert completed.outcome["counts"] == Fixtures.expected().initial_counts
    assert [attempt] = completed.attempts
    assert attempt.number == 1
    assert attempt.status == "succeeded"

    assert {:ok, replay} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    next = Repo.get!(FootballMarket.Synchronization.Run, replay.run_id)
    assert next.id != run.id

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => next.id, "delivery_id" => next.delivery_id}
             })

    assert {:ok, replayed} = Synchronization.get_run(next.id)
    assert replayed.outcome["status"] == "replay"
    assert replayed.outcome["applied_new_bindings_count"] == 0
  end

  test "unchanged and complete empty imports retain attribution and historical replay counts" do
    FootballMarket.IngestionFixtures.positions!()
    candidate = FootballMarket.IngestionFixtures.candidate("PL", 2090)

    empty = %{
      candidate
      | facts: %{candidate.facts | teams: [], players: []},
        bindings: Enum.filter(candidate.bindings, &(&1.kind in [:league, :season]))
    }

    expected = ["accepted_with_changes", "accepted_unchanged", "accepted_unchanged", "replay"]

    imports = [
      {candidate, ~U[2026-10-15 12:00:00.000000Z]},
      {candidate, ~U[2026-10-15 12:00:01.000000Z]},
      {empty, ~U[2026-10-15 12:00:02.000000Z]},
      {empty, ~U[2026-10-15 12:00:02.000000Z]}
    ]

    for {{facts, instant}, status} <- Enum.zip(imports, expected) do
      source = %{
        Fixtures.source()
        | provider: {FootballMarket.IngestionFixtureAdapter, facts},
          runtime: {FootballMarket.IngestionFixtureRuntime, %{instant: instant}}
      }

      Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
      {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
      run = Repo.get!(FootballMarket.Synchronization.Run, accepted.run_id)

      :ok =
        FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
          args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
        })

      assert {:ok, result} = Synchronization.get_run(run.id)
      assert result.state == "succeeded"
      assert result.outcome["status"] == status
      assert result.outcome["provider"] == "synthetic-a"
      assert result.outcome["fixture_id"] == "independent-catalog"
      assert result.outcome["acceptance_reference"]

      if facts == empty,
        do:
          assert(
            result.outcome["counts"]["player"] == %{
              "created" => 0,
              "updated" => 0,
              "unchanged" => 0
            }
          )

      if status == "replay", do: assert(result.outcome["counts_historical"])
    end

    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == 1
    assert {:ok, history} = Synchronization.list_runs(Fixtures.scope(), limit: 2)
    assert length(history) == 2
    assert {:ok, older} = Synchronization.list_runs(Fixtures.scope(), limit: 2, offset: 2)
    assert length(older) == 2

    assert MapSet.disjoint?(
             MapSet.new(Enum.map(history, & &1.id)),
             MapSet.new(Enum.map(older, & &1.id))
           )
  end
end
