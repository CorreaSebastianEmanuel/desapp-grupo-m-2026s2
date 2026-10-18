defmodule FootballMarket.Quotes.RecoveryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.Quotes.{CalculationRequest, Recovery}
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    %{schema: schema} = ValuationConfigurationCase.private_schema()

    start_supervised(
      {Oban,
       name: Oban,
       repo: Repo,
       prefix: schema,
       testing: :manual,
       queues: [],
       plugins: [],
       get_dynamic_repo: fn -> Repo.get_dynamic_repo() end}
    )

    {:ok, QuotesCase.fixture()}
  end

  defp dt!(value) when is_binary(value) do
    {:ok, dt, _} = DateTime.from_iso8601(value)
    usec6(dt)
  end

  defp dt!(value) when is_struct(value, DateTime), do: usec6(value)

  defp dt!(value), do: value

  defp usec6(dt) do
    dt = DateTime.truncate(dt, :microsecond)
    {micros, _} = dt.microsecond
    %{dt | microsecond: {micros, 6}}
  end

  test "due retrying calculations are re-enqueued while future backoffs remain untouched", f do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    due =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 1,
        lease_fence: 1,
        next_attempt_at: DateTime.add(now, -1, :second),
        inserted_at: now
      })

    future =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 1,
        lease_fence: 1,
        next_attempt_at: DateTime.add(now, 60, :second),
        inserted_at: now
      })

    second_backoff =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "retrying",
        attempt_count: 2,
        lease_fence: 2,
        next_attempt_at: DateTime.add(now, 300, :second),
        inserted_at: now
      })

    assert {:ok, 1} = Recovery.recover_pending()

    assert %{success: 1} = Oban.drain_queue(queue: :quote_calculation)

    assert Repo.get!(CalculationRequest, due.id).state == "validation_failed"
    assert %{reason: "configuration_unavailable"} = Repo.get!(CalculationRequest, due.id)
    assert Repo.get!(CalculationRequest, future.id).state == "retrying"
    assert Repo.get!(CalculationRequest, second_backoff.id).state == "retrying"
  end

  test "a request with three reserved attempts exhausts without financial writes", f do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    request =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "active",
        mapping_id: f.mapping.id,
        state: "running",
        attempt_count: 3,
        lease_fence: 3,
        lease_until: DateTime.add(now, -1, :second),
        inserted_at: now
      })

    assert :ok = Quotes.process_import_request(request.id)

    assert Repo.get!(CalculationRequest, request.id).state == "exhausted"

    assert Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
             Ecto.UUID.dump!(f.player.id)
           ]).rows == [[1]]

    assert Repo.query!("SELECT count(*) FROM quote_evaluation_requests").rows == [[0]]
  end

  test "expired delivery lease is recovered with a higher fence and stale acknowledgement fails",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, _} = Quotes.request(f.subject, :active, f.mapping.id)
    {:ok, [event]} = Quotes.pending_evaluations()
    {:ok, first} = Quotes.claim_evaluation(event.id, 1)

    expired = DateTime.add(DateTime.utc_now(), -1, :second) |> DateTime.truncate(:microsecond)

    Repo.query!("UPDATE quote_evaluation_requests SET lease_until=$1 WHERE id=$2", [
      expired,
      Ecto.UUID.dump!(event.id)
    ])

    assert {:ok, [recoverable]} = Quotes.pending_evaluations()
    assert recoverable.id == event.id
    {:ok, second} = Quotes.claim_evaluation(event.id, 30)
    assert second.fence > first.fence

    assert {:error, :stale_fence} =
             Quotes.acknowledge_evaluation(event.id, first.fence, "old-consumer-receipt")

    assert :ok = Quotes.acknowledge_evaluation(event.id, second.fence, "consumer-receipt")

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_delivery_attempts WHERE event_id=$1 AND status='expired'",
             [
               Ecto.UUID.dump!(event.id)
             ]
           ).rows == [[1]]
  end
end
