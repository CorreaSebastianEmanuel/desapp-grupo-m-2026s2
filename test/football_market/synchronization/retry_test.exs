defmodule FootballMarket.Synchronization.RetryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Fixtures, Run}

  setup do
    old = Application.get_env(:football_market, Synchronization)

    source = %{
      Fixtures.source()
      | provider: {FootballMarket.IngestionFixtureAdapter, {:error, %{category: :unavailable}}}
    }

    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
    FootballMarket.IngestionFixtures.positions!()
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    :ok
  end

  test "three begun attempts honor 60/300 second deadlines, stop and retain numbered history" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    id = accepted.run_id
    execute(id)
    assert {:ok, waiting} = Synchronization.get_run(id)
    assert waiting.state == "retry_wait"
    assert waiting.remaining_wait_seconds == 60
    assert waiting.remaining_attempts == 2

    assert {:ok, %{run_id: ^id, status: :retry_wait, disposition: :coalesced}} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    assert waiting.next_retry_at == ~U[2026-10-15 12:01:00.000000Z]
    execute(id)
    assert {:ok, early} = Synchronization.get_run(id)
    assert length(early.attempts) == 1
    Process.put(:synchronization_now, ~U[2026-10-15 12:01:00.000000Z])
    execute(id)
    assert {:ok, second} = Synchronization.get_run(id)
    assert second.next_retry_at == ~U[2026-10-15 12:06:00.000000Z]
    Process.put(:synchronization_now, ~U[2026-10-15 12:06:00.000000Z])
    execute(id)
    execute(id)
    assert {:ok, final} = Synchronization.get_run(id)
    assert final.state == "failed"
    assert final.reason == "exhausted"
    assert Enum.map(final.attempts, & &1.number) == [1, 2, 3]
    assert {:ok, next} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    assert next.run_id != id
  end

  test "a fresh attempt succeeds after transient failure while waits release global capacity" do
    {:ok, script} =
      Agent.start_link(fn ->
        [
          {:error, %{category: :timeout}},
          {:ok, FootballMarket.IngestionFixtures.candidate("PL", 2090)}
        ]
      end)

    on_exit(fn -> if Process.alive?(script), do: Agent.stop(script) end)

    source = %{
      Fixtures.source()
      | provider: {FootballMarket.Synchronization.ScriptAdapter, %{owner: self(), script: script}}
    }

    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    execute(accepted.run_id)
    assert_receive :synchronization_provider_called
    {:ok, guard} = FootballMarket.Synchronization.ExecutionGuard.acquire(Fixtures.scope(2091))
    GenServer.stop(guard)
    Process.put(:synchronization_now, ~U[2026-10-15 12:01:00.000000Z])
    execute(accepted.run_id)
    assert_receive :synchronization_provider_called
    assert {:ok, result} = Synchronization.get_run(accepted.run_id)
    assert result.state == "succeeded"
    assert Enum.map(result.attempts, & &1.status) == ["failed", "succeeded"]
    assert hd(result.attempts).outcome["category"] == "timeout"
  end

  test "each non-retryable provider category stops on the first attempt without fallback" do
    for category <- [
          :invalid_request,
          :unsupported_capability,
          :not_found,
          :authentication_failed,
          :invalid_response
        ] do
      source = %{
        Fixtures.source()
        | provider: {FootballMarket.IngestionFixtureAdapter, {:error, %{category: category}}}
      }

      Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
      {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
      execute(accepted.run_id)
      assert {:ok, result} = Synchronization.get_run(accepted.run_id)
      assert result.state == "failed"
      assert result.reason == "non_retryable"
      assert result.outcome["category"] == to_string(category)
      assert length(result.attempts) == 1
      assert result.source_ref == "fixture"
    end

    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  defp execute(id) do
    run = Repo.get!(Run, id)

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => id, "delivery_id" => run.delivery_id}
             })
  end
end
