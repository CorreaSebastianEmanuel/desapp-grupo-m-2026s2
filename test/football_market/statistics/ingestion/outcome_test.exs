defmodule FootballMarket.Statistics.Ingestion.OutcomeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.Ingestion.Outcome

  test "accepted outcomes are closed and retain import/calculation separation" do
    for status <- [:accepted_changes, :accepted_unchanged, :replay, :accepted_empty] do
      assert {:ok, outcome} = Outcome.accepted(status, %{league_code: "PL"}, check_id: "check")
      assert outcome.status == status
      assert outcome.check_id == "check"
      assert is_nil(outcome.calculation_intent_id) or status == :accepted_changes
    end

    assert_raise FunctionClauseError, fn -> apply(Outcome, :accepted, [:quote_complete, %{}]) end
  end

  test "failure outcomes contain safe categories without arbitrary diagnostics" do
    {:error, outcome} =
      Outcome.failure(:provider_failure, %{league_code: "PL"}, :timeout,
        provider_category: :timeout,
        retryable: true,
        retry_after_ms: nil
      )

    refute Map.has_key?(outcome, :raw_payload)
    assert outcome.provider_category == :timeout
    assert outcome.retryable
  end
end
