defmodule FootballMarket.Synchronization.SchedulerTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization.{Scheduler, Fixtures, Schedule, Occurrence, Run}
  alias FootballMarket.Synchronization

  setup do
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
  end

  test "five missed daily instants produce the latest only and exact boundary never predates enablement" do
    assert {:ok, _} = Scheduler.validate("0 0 * * *")

    assert Scheduler.latest_due("0 0 * * *", ~U[2026-10-15 12:00:00Z], ~U[2026-10-20 12:00:00Z]) ==
             ~U[2026-10-20 00:00:00Z]

    assert Scheduler.latest_due("0 0 * * *", ~U[2026-10-15 12:00:00Z], ~U[2026-10-15 23:00:00Z]) ==
             nil

    assert Scheduler.latest_due("0 0 * * *", ~U[2026-10-16 00:00:00Z], ~U[2026-10-16 00:00:00Z]) ==
             ~U[2026-10-16 00:00:00Z]

    for invalid <- ["@reboot", "invalid", "0 0 31 2 *", "0 0 * *", nil] do
      assert {:error, :recurrence} = Scheduler.validate(invalid)
    end
  end

  test "invalid runtime cannot configure a schedule or admit an existing due occurrence" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    definition = %{enabled: true, scope: Fixtures.scope(), source_ref: "fixture"}
    assert {:ok, schedule} = Scheduler.configure("existing", definition)

    Application.put_env(:football_market, Synchronization,
      sources: %{
        "fixture" => Map.put(Fixtures.source(), :runtime, :invalid_runtime_configuration)
      }
    )

    assert {:error, :invalid_schedule} = Scheduler.configure("invalid", definition)
    assert {:error, _} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    assert Repo.all(Schedule) == [schedule]
    assert Repo.aggregate(Run, :count) == 0
    assert Repo.aggregate(Occurrence, :count) == 0
    assert Repo.aggregate(Oban.Job, :count) == 0

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    assert {:ok, [_]} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    assert Repo.aggregate(Run, :count) == 1
    assert Repo.aggregate(Occurrence, :count) == 1
  end

  test "generation survives ordinary reconfiguration, catch-up is durable and disabling stops admission" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    definition = %{enabled: true, scope: Fixtures.scope(), source_ref: "fixture"}
    assert {:ok, first} = Scheduler.configure("daily", definition)
    assert {:ok, same} = Scheduler.configure("daily", definition)
    assert same.generation == first.generation
    assert {:ok, [_]} = Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])
    assert Repo.aggregate(Run, :count) == 1
    assert Repo.aggregate(Occurrence, :count) == 1
    assert {:ok, []} = Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])
    assert {:ok, disabled} = Scheduler.configure("daily", %{definition | enabled: false})
    assert not disabled.enabled
    assert {:ok, []} = Scheduler.tick(~U[2026-10-21 12:00:00.000000Z])
    assert {:ok, enabled} = Scheduler.configure("daily", definition)
    refute enabled.generation == first.generation
    assert Repo.aggregate(Schedule, :count) == 1
  end

  test "removing a configured schedule disables future admission while accepted work survives" do
    definition = %{
      scope: Fixtures.scope(),
      source_ref: "fixture",
      recurrence: "* * * * *"
    }

    config = [
      sources: %{"fixture" => Fixtures.source()},
      enabled: true,
      schedules: [{"removed", definition}],
      test_now: ~U[2026-10-15 12:00:00.000000Z]
    ]

    Application.put_env(:football_market, Synchronization, config)
    assert {:ok, [accepted]} = FootballMarket.Synchronization.Dispatcher.tick()
    assert Repo.one!(Schedule).enabled

    Application.put_env(
      :football_market,
      Synchronization,
      config
      |> Keyword.put(:schedules, [])
      |> Keyword.put(:test_now, ~U[2026-10-15 12:01:00.000000Z])
    )

    assert {:ok, []} = FootballMarket.Synchronization.Dispatcher.tick()
    refute Repo.one!(Schedule).enabled
    assert Repo.aggregate(Occurrence, :count) == 1
    assert {:ok, %{state: "queued"}} = Synchronization.get_run(accepted.run_id)
  end

  test "incompatible busy scope keeps only the latest candidate and terminal occurrences stay handled" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])

    definition = %{
      enabled: true,
      scope: Fixtures.scope(),
      source_ref: "fixture",
      fixture_ref: "scheduled"
    }

    assert {:ok, _} = Scheduler.configure("busy", definition)

    assert {:ok, active} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               fixture_ref: "manual"
             )

    for day <- 16..20 do
      assert {:ok, []} =
               Scheduler.tick(DateTime.new!(Date.new!(2026, 10, day), ~T[12:00:00.000000]))
    end

    assert Repo.aggregate(Occurrence, :count) == 1
    pending = Repo.one!(Occurrence)
    assert pending.state == "pending"
    assert pending.due_at == ~U[2026-10-20 00:00:00.000000Z]
    assert pending.superseded_from == ~U[2026-10-16 00:00:00.000000Z]
    Repo.get!(Run, active.run_id) |> Ecto.Changeset.change(state: "failed") |> Repo.update!()
    assert {:ok, [admitted]} = Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])
    assert admitted.run_id != active.run_id
    Repo.get!(Run, admitted.run_id) |> Ecto.Changeset.change(state: "failed") |> Repo.update!()
    assert {:ok, []} = Scheduler.tick(~U[2026-10-20 12:00:00.000000Z])
    assert Repo.aggregate(Run, :count) == 2
    assert Repo.one!(Occurrence).state == "handled"
  end

  test "equivalent active work permanently absorbs its due occurrence even if it fails" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])

    assert {:ok, active} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    assert {:ok, _} =
             Scheduler.configure("coalesced", %{
               enabled: true,
               scope: Fixtures.scope(),
               source_ref: "fixture"
             })

    assert {:ok, [due]} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    assert due.run_id == active.run_id
    assert due.disposition == :coalesced
    assert {:ok, inspected} = Synchronization.get_run(active.run_id)
    scheduled = Enum.find(inspected.triggers, &(&1.kind == "scheduled"))
    assert scheduled.due_at == ~U[2026-10-16 00:00:00.000000Z]
    Repo.get!(Run, active.run_id) |> Ecto.Changeset.change(state: "failed") |> Repo.update!()
    assert {:ok, []} = Scheduler.tick(~U[2026-10-16 00:00:00.000000Z])
    assert Repo.aggregate(Run, :count) == 1
  end

  test "definition replacement preserves prior generation recurrence for compressed occurrence audit" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])

    definition = %{
      enabled: true,
      scope: Fixtures.scope(),
      source_ref: "fixture",
      recurrence: "0 0 * * *"
    }

    assert {:ok, first} = Scheduler.configure("history", definition)
    assert {:ok, second} = Scheduler.configure("history", %{definition | recurrence: "0 * * * *"})
    assert second.generation != first.generation

    assert second.definition["previous_generations"][first.generation]["recurrence"] ==
             "0 0 * * *"
  end

  test "concurrent due invocations on distinct connections create one permanent association" do
    FootballMarket.Synchronization.Case.with_store(fn repo ->
      Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])

      {:ok, _} =
        Scheduler.configure("racing", %{
          enabled: true,
          scope: Fixtures.scope(),
          source_ref: "fixture",
          recurrence: "* * * * *"
        })

      results =
        FootballMarket.Synchronization.Case.race(
          2,
          fn -> Scheduler.tick(~U[2026-10-15 12:00:00.000000Z]) end,
          repo
        )

      assert Enum.all?(results, &match?({:ok, _}, &1))
      assert Enum.flat_map(results, fn {:ok, rows} -> rows end) |> length() == 1
      assert Repo.aggregate(Run, :count) == 1
      assert Repo.aggregate(Occurrence, :count) == 1
    end)
  end

  test "editing a disabled definition retains the preceding generation before re-enabling" do
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])

    definition = %{
      enabled: true,
      scope: Fixtures.scope(),
      source_ref: "fixture",
      recurrence: "0 0 * * *"
    }

    {:ok, original} = Scheduler.configure("disabled-edit", definition)
    {:ok, _} = Scheduler.configure("disabled-edit", %{definition | enabled: false})

    {:ok, edited} =
      Scheduler.configure("disabled-edit", %{definition | enabled: false, recurrence: "0 * * * *"})

    assert edited.generation != original.generation

    assert edited.definition["previous_generations"][original.generation]["recurrence"] ==
             "0 0 * * *"

    assert edited.enabled_at == nil
  end
end
