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

  test "a redelivered event produces one effective consumer action keyed by quote UUID", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    assert {:ok, [event]} = Quotes.pending_evaluations()

    Repo.query!(
      """
      CREATE TABLE fake_effective_evaluations (
        quote_id uuid PRIMARY KEY,
        applied_count integer NOT NULL DEFAULT 1
      )
      """,
      []
    )

    Repo.query!("CREATE TABLE fake_consumer_receipts (quote_id uuid PRIMARY KEY)")

    consume = fn event ->
      Repo.query!(
        """
        WITH receipt AS (
          INSERT INTO fake_consumer_receipts (quote_id) VALUES ($1)
          ON CONFLICT (quote_id) DO NOTHING RETURNING quote_id
        )
        INSERT INTO fake_effective_evaluations (quote_id) SELECT quote_id FROM receipt
        ON CONFLICT (quote_id) DO UPDATE
          SET applied_count = fake_effective_evaluations.applied_count + 1
        """,
        [Ecto.UUID.dump!(event.quote_id)]
      )
    end

    assert {:ok, first} = Quotes.claim_evaluation(event.id, 1)
    consume.(event)

    # Simulate a consumer that committed its idempotent work but whose
    # acknowledgement was lost, so the same quote key is delivered again.
    expired = DateTime.add(DateTime.utc_now(), -1, :second) |> DateTime.truncate(:microsecond)

    Repo.query!("UPDATE quote_evaluation_requests SET lease_until=$1 WHERE id=$2", [
      expired,
      Ecto.UUID.dump!(event.id)
    ])

    assert {:ok, second} = Quotes.claim_evaluation(event.id, 30)
    assert second.key == first.key
    assert second.event.quote_id == event.quote_id
    consume.(event)

    assert Repo.query!(
             "SELECT count(*), sum(applied_count) FROM fake_effective_evaluations WHERE quote_id=$1",
             [
               Ecto.UUID.dump!(event.quote_id)
             ]
           ).rows == [[1, 1]]

    assert {:error, :stale_fence} =
             Quotes.acknowledge_evaluation(event.id, first.fence, "late-ack")

    assert :ok = Quotes.acknowledge_evaluation(event.id, second.fence, "deduplicated-consumer")

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[2]]
  end
end
