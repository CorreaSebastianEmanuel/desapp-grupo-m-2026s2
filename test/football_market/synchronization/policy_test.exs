defmodule FootballMarket.Synchronization.PolicyTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Synchronization.Policy

  test "defaults are finite with conservative waits" do
    assert {:ok, policy} = Policy.normalize(%{})
    assert policy["attempt_limit"] == 3
    assert policy["waits"] == [60, 300]
    assert policy["worker_timeout_ms"] > 5000
  end

  test "invalid and unbounded policies fail before admission" do
    for policy <- [
          %{attempt_limit: 0},
          %{attempt_limit: :infinity},
          %{waits: [0, 300]},
          %{attempt_limit: 4},
          %{worker_timeout_ms: 1},
          %{unplanned: true},
          nil
        ] do
      assert {:error, :policy} = Policy.normalize(policy)
    end
  end

  test "only closed transient outcomes retry and provider delay rounds up without shortening local waits" do
    {:ok, policy} = Policy.normalize(%{})
    now = ~U[2026-10-15 12:00:00.000000Z]

    outcome = %{
      "status" => "provider_failure",
      "category" => "rate_limited",
      "retryable" => true,
      "retry_after_ms" => 60_001
    }

    assert Policy.decision(outcome, 1, policy, now) == {:retry, ~U[2026-10-15 12:01:01.000000Z]}
    assert Policy.decision(outcome, 2, policy, now) == {:retry, ~U[2026-10-15 12:05:00.000000Z]}
    assert Policy.decision(outcome, 3, policy, now) == {:failed, "exhausted"}

    for category <-
          ~w(invalid_request unsupported_capability not_found authentication_failed invalid_response unknown) do
      assert Policy.decision(%{outcome | "category" => category}, 1, policy, now) ==
               {:failed, "non_retryable"}
    end

    for status <- ~w(stale_observation reconciliation_conflict unclassified) do
      assert Policy.decision(%{"status" => status, "retryable" => true}, 1, policy, now) ==
               {:failed, "non_retryable"}
    end

    for status <- ~w(persistence_failure concurrent_change interrupted) do
      assert Policy.decision(%{"status" => status}, 1, policy, now) ==
               {:retry, ~U[2026-10-15 12:01:00.000000Z]}
    end

    assert Policy.decision(%{"status" => "interrupted"}, 3, policy, now) ==
             {:failed, "exhausted_unconfirmed"}

    assert {:ok, custom} = Policy.normalize(%{attempt_limit: 2, waits: [5]})

    assert Policy.decision(%{"status" => "interrupted"}, 1, custom, now) ==
             {:retry, ~U[2026-10-15 12:00:05.000000Z]}
  end

  test "runtime execution configuration rejects invalid admission settings" do
    assert Policy.validate_runtime([]) == :ok

    for config <- [
          [concurrency: 0],
          [concurrency: :infinity],
          [tick_ms: 0],
          [enabled: :sometimes]
        ] do
      assert {:error, :policy} = Policy.validate_runtime(config)
    end
  end
end
