defmodule FootballMarket.Quotes.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo, ValuationCase}
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

  test "replay fails explicitly when retained evidence references a missing original", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)
    missing_id = Ecto.UUID.generate()

    # Simulate storage loss/corruption in the isolated schema. Production rows
    # remain write-once; this test checks replay's fail-closed behavior when an
    # original referenced by otherwise well-shaped evidence is unavailable.
    Repo.query!("ALTER TABLE quote_calculations DISABLE TRIGGER quote_calculations_immutable", [])

    try do
      Repo.query!(
        """
        UPDATE quote_calculations
        SET evidence=jsonb_set(evidence, '{facts,0,match_id}', to_jsonb($1::text))
        WHERE id=$2
        """,
        [missing_id, Ecto.UUID.dump!(calculation.id)]
      )
    after
      Repo.query!(
        "ALTER TABLE quote_calculations ENABLE TRIGGER quote_calculations_immutable",
        []
      )
    end

    assert {:error, :unreproducible} = Quotes.replay(calculation.id)
  end
end
