defmodule FootballMarket.Quotes.CalculationTest do
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

  test "calculates from the fixed saved strategy and accepted local facts", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()

    assert {:ok, %{request_id: ^request_id, calculation: calculation}} =
             Quotes.request(f.subject, :active, f.mapping.id, request_id)

    assert calculation.status == "successful"
    assert calculation.configuration_version_id == f.configuration.id
    assert calculation.membership == [f.performance.id]
    assert Decimal.equal?(calculation.score, Decimal.new("1.000000"))
    assert Decimal.equal?(calculation.unit_price, Decimal.new("1.25"))
    assert calculation.evidence["mapping_id"] == f.mapping.id
    assert calculation.evidence["scale"] == "1.25"

    assert {:ok, history} = Quotes.list_history(f.player.id)
    assert Enum.map(history, & &1.rule_id) == ["initial_issuance", f.configuration.strategy_id]
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert latest.calculation_id == calculation.id
    assert {:ok, replay} = Quotes.replay(calculation.id)
    assert replay.outcome.status == "successful"
    assert Decimal.equal?(replay.outcome.price, calculation.unit_price)

    assert Repo.query!("SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1", [
             Ecto.UUID.dump!(calculation.id)
           ]).rows == [[1]]
  end

  test "an exact retry returns its immutable result without duplicate quote or follow-up", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()
    assert {:ok, first} = Quotes.request(f.subject, :active, f.mapping.id, request_id)
    assert {:ok, second} = Quotes.request(f.subject, :active, f.mapping.id, request_id)

    assert first.calculation.id == second.calculation.id
    assert {:ok, history} = Quotes.list_history(f.player.id)
    assert Enum.count(history, &(&1.calculation_id == first.calculation.id)) == 1

    assert Repo.query!(
             "SELECT count(*) FROM quote_evaluation_requests WHERE calculation_id=$1",
             [Ecto.UUID.dump!(first.calculation.id)]
           ).rows == [[1]]
  end

  test "an admitted request keeps its saved strategy after the active selection changes", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    request_id = Ecto.UUID.generate()
    assert {:ok, original} = Quotes.request(f.subject, :active, f.mapping.id, request_id)

    {:ok, replacement} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{goals: 4})
      )

    assert {:ok, _} = Configurations.activate(replacement.id, f.configuration.id)
    assert {:ok, retried} = Quotes.request(f.subject, :active, f.mapping.id, request_id)

    assert retried.calculation.id == original.calculation.id
    assert retried.calculation.configuration_version_id == f.configuration.id

    {:ok, other_mapping} = FootballMarket.Quotes.Mappings.save("other", "1", Decimal.new("2"))

    assert {:error, :request_conflict} =
             Quotes.request(f.subject, :active, other_mapping.id, request_id)
  end
end
