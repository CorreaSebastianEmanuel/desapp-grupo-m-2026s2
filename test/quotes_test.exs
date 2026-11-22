defmodule FootballMarket.QuotesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Market, Quotes}

  test "saves mappings, calculates and publishes quotes atomically, and serves latest/history/at" do
    _admin = create_admin!()
    fixture = create_catalog_fixture!()
    {:ok, _} = Market.initialize_player(fixture.player.id)
    %{mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)

    published = record_performance_and_quote!(fixture, mapping.id, %{goals: 2, assists: 2})
    assert published.calculation.status == "successful"
    assert published.quote.performance_sequence == 1
    assert Decimal.equal?(published.quote.unit_price, Decimal.new("70.00"))

    # Idempotent repeat returns the exact same calculation and quote
    window = %{
      player_id: fixture.player.id,
      season_id: fixture.season.id,
      week_start: published.calculation.week_start,
      week_end: published.calculation.week_end
    }

    assert {:ok, repeated} = Quotes.calculate_and_publish(window, :active, mapping.id)
    assert repeated.calculation.id == published.calculation.id
    assert repeated.quote.id == published.quote.id

    # Latest, history, and as-of-date queries
    assert {:ok, latest} = Quotes.latest(fixture.player.id)
    assert latest.id == published.quote.id

    assert {:ok, history} = Quotes.list_history(fixture.player.id)
    assert length(history) == 2
    assert hd(history).rule_id == "initial_issuance"
    assert List.last(history).id == published.quote.id

    today = DateTime.to_date(published.quote.effective_at)
    assert {:ok, at_today} = Quotes.at_date(fixture.player.id, today)
    assert at_today.id == published.quote.id

    assert {:error, :quote_not_found} = Quotes.at_date(fixture.player.id, ~D[2020-01-01])
  end

  test "claims and acknowledges pending quote evaluation events and runs nightly close" do
    market = create_tradable_market!()
    events = Quotes.pending_evaluations()
    assert length(events) == 1
    event = hd(events)

    assert {:ok, %{fence: 1}} = Quotes.claim_evaluation(event.id)
    assert {:error, :already_leased} = Quotes.claim_evaluation(event.id)
    assert :ok = Quotes.acknowledge_evaluation(event.id, 1, "receipt-1")
    assert Quotes.pending_evaluations() == []

    assert {:ok, %{calculated: _, skipped: _}} = Quotes.Closing.run_close()
    assert {:ok, _} = Quotes.latest(market.player.id)
  end
end
