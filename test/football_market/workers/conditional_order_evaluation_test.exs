defmodule FootballMarket.Workers.ConditionalOrderEvaluationTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Workers.{ConditionalOrderEvaluation, ConditionalOrderRecovery}

  test "workers reject malformed or financial authority args and bound retry policy" do
    for args <- [
          %{},
          %{"source" => "unknown"},
          %{"source" => "quote"},
          %{"source" => "quote", "event_id" => "bad"},
          %{"source" => "recovery", "price" => "0"},
          %{"source" => "order", "order_id" => "bad"},
          %{"price" => "0"},
          %{"event_id" => "bad"},
          %{"wake" => true, "price" => "0"},
          %{"continue" => false}
        ] do
      assert {:discard, :invalid_args} = ConditionalOrderEvaluation.perform(%Oban.Job{args: args})
    end

    assert {:discard, :invalid_args} =
             ConditionalOrderRecovery.perform(%Oban.Job{args: %{"after" => "bad"}})

    for worker <- [ConditionalOrderEvaluation, ConditionalOrderRecovery] do
      assert worker.new(%{}).changes.max_attempts == 3
      assert worker.backoff(%Oban.Job{attempt: 1}) == 5
      assert worker.backoff(%Oban.Job{attempt: 2}) == 30
    end
  end
end
