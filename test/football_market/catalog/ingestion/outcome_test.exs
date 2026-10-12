defmodule FootballMarket.Catalog.Ingestion.OutcomeTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog.Ingestion

  setup do
    positions!()
    :ok
  end

  test "all safe provider categories and valid rate delays propagate without catalog writes" do
    for category <- FootballMarket.Providers.Error.categories() do
      failure =
        if category == :rate_limited,
          do: %{category: category, retry_after_ms: 250},
          else: %{category: category}

      before = snapshot()
      assert {:error, o} = Ingestion.import_catalog(request(), options({:error, failure}))
      assert o.status == :provider_failure
      assert o.provider_error.category == category
      assert o.provider_error.retryable == category in [:rate_limited, :unavailable, :timeout]
      assert o.provider_error.retry_after_ms == if(category == :rate_limited, do: 250, else: nil)
      assert o.counts == nil
      assert snapshot() == before
    end
  end

  test "invalid complete facts are rejected and sensitive input never leaks" do
    c = candidate()
    c = %{c | facts: %{c.facts | players: [%{hd(c.facts.players) | team_ref: "missing"}]}}
    assert {:error, o} = Ingestion.import_catalog(request(), options(c))
    assert o.provider_error.category == :invalid_response

    assert {:error, unsafe} =
             Ingestion.import_catalog(
               %{league_code: "password=hidden", start_year: 2025, end_year: 2026},
               options()
             )

    refute inspect(unsafe) =~ "hidden"
  end

  test "a provider completing at its deadline publishes no late state and performs no retry" do
    opts =
      options({:notify, self(), candidate()})
      |> Keyword.put(:runtime, {FootballMarket.IngestionLateRuntime, nil})

    before = {snapshot(), acceptance_snapshot()}
    assert {:error, o} = Ingestion.import_catalog(request(), opts)
    assert o.status == :provider_failure
    assert o.provider_error.category == :timeout
    assert_receive :source_called
    refute_receive :source_called
    assert {snapshot(), acceptance_snapshot()} == before
  end

  test "malformed trusted instructions fail before source retrieval" do
    assert {:error, o} =
             Ingestion.import_catalog(
               request(),
               options({:notify, self(), candidate()}) ++ [mappings: [%{}]]
             )

    assert o.status == :reconciliation_conflict
    refute_receive :source_called
  end

  test "persistence exceptions expose only safe templates and caller recovery" do
    publication_failpoint(fn _ ->
      raise "password=FAKE_SENSITIVE_DIAGNOSTIC"
    end)

    before = {snapshot(), acceptance_snapshot()}
    assert {:error, outcome} = Ingestion.import_catalog(request(), options())
    assert outcome.status == :persistence_failure
    assert outcome.recovery == :caller_may_retry
    assert outcome.fixture_id == "independent-catalog"
    refute inspect(outcome) =~ "FAKE_SENSITIVE_DIAGNOSTIC"
    assert outcome.counts == nil
    assert {snapshot(), acceptance_snapshot()} == before
    Process.delete(:catalog_ingestion_failpoint)
  end
end
