defmodule FootballMarket.Quotes.OutcomesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.Quotes.Mappings
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  test "a positive score that converts to zero is retained without quote or follow-up", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    {:ok, tiny_mapping} = Mappings.save("tiny", "1", Decimal.new("0.004"))

    before_count =
      Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
        Ecto.UUID.dump!(f.player.id)
      ]).rows

    assert {:ok, %{calculation: calculation}} =
             Quotes.request(f.subject, :active, tiny_mapping.id)

    assert calculation.status == "no_quote"
    assert calculation.unit_price == nil
    assert calculation.reason == "nonpositive_converted_result"

    assert Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
             Ecto.UUID.dump!(f.player.id)
           ]).rows == before_count

    assert Repo.query!("SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1", [
             Ecto.UUID.dump!(calculation.id)
           ]).rows == [[0]]

    assert {:ok, replay} = Quotes.replay(calculation.id)
    assert replay.outcome.status == "no_quote"
  end

  test "an empty accepted week is a durable no-quote outcome with no fabricated score", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)

    empty_week = %{
      player_id: f.player.id,
      season_id: f.base.season.id,
      week_start: "2026-10-19T00:00:00Z",
      week_end: "2026-10-26T00:00:00Z"
    }

    assert {:ok, %{calculation: calculation}} = Quotes.request(empty_week, :active, f.mapping.id)
    assert calculation.status == "no_quote"
    assert calculation.reason == "no_recorded_performances"
    assert is_nil(calculation.score)
    assert is_nil(calculation.unit_price)
    assert {:ok, replay} = Quotes.replay(calculation.id)
    assert replay.outcome.reason == calculation.reason
  end

  test "a no-quote result remains reproducible in a fresh application process", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    {:ok, tiny_mapping} = Mappings.save("tiny-restart", "1", Decimal.new("0.004"))

    assert {:ok, %{calculation: calculation}} =
             Quotes.request(f.subject, :active, tiny_mapping.id)

    assert calculation.status == "no_quote"

    code = """
    assert {:ok, replay} = FootballMarket.Quotes.replay(payload)
    assert replay.calculation.status == "no_quote"
    assert replay.calculation.unit_price == nil
    assert replay.outcome.price == nil
    """

    ValuationConfigurationCase.fresh(f.namespace.schema, code, calculation.id)
  end
end
