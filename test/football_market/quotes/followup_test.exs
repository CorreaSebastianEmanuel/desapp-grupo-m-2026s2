defmodule FootballMarket.Quotes.FollowupTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "one quote-keyed pending event survives duplicate delivery and matching acknowledgement",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()
    assert event.calculation_id == calculation.id
    assert event.idempotency_key == "quote-evaluation:" <> event.quote_id

    assert {:ok, claim} = Quotes.claim_evaluation(event.id)
    assert claim.key == event.idempotency_key
    receipt = "fixture-consumed-" <> event.quote_id
    assert :ok = Quotes.acknowledge_evaluation(event.id, claim.fence, receipt)
    assert :ok = Quotes.acknowledge_evaluation(event.id, claim.fence, receipt)
    assert {:ok, []} = Quotes.pending_evaluations()

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[1]]
  end
end
