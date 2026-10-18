defmodule FootballMarket.Quotes.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, ValuationCase}
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = ValuationConfigurationCase.private_schema()
    {:ok, Map.put(QuotesCase.fixture(), :namespace, namespace)}
  end

  test "successful calculation replays after a fresh application restart", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)

    {_match, later} =
      ValuationCase.record(f.base, "task026-replay-late-#{Ecto.UUID.generate()}", %{goals: 4})

    code = """
    assert {:ok, result} = FootballMarket.Quotes.replay(payload)
    assert result.calculation.membership == [#{inspect(f.performance.id)}]
    assert Decimal.equal?(result.calculation.unit_price, Decimal.new(\"1.25\"))
    """

    ValuationConfigurationCase.fresh(f.namespace.schema, code, calculation.id)
    refute later.id in calculation.membership
  end
end
