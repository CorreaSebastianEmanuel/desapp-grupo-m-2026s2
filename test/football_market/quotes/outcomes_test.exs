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

  @failure_classes [
    :no_active,
    :missing_configuration,
    :missing_mapping,
    :empty_week,
    :zero_score,
    :negative_score,
    :insufficient_data,
    :unknown_position,
    :unsupported_strategy,
    :unreproducible
  ]

  test "failure classes preserve the complete financial and protected-input snapshot", f do
    for failure <- @failure_classes do
      {subject, selector, mapping_id, facts, expected} = failure_inputs(failure, f)
      before = QuotesCase.protected_snapshot()

      result =
        if facts do
          Quotes.request_membership(subject, selector, mapping_id, facts, Ecto.UUID.generate())
        else
          Quotes.request(subject, selector, mapping_id)
        end

      case expected do
        {:error, reason} -> assert result == {:error, reason}
        status -> assert {:ok, %{calculation: %{status: ^status}}} = result
      end

      assert QuotesCase.protected_snapshot() == before
    end
  end

  defp failure_inputs(:no_active, f),
    do: {f.subject, :active, f.mapping.id, nil, {:error, :configuration_unavailable}}

  defp failure_inputs(:missing_configuration, f),
    do:
      {f.subject, {:version, Ecto.UUID.generate()}, f.mapping.id, nil,
       {:error, :configuration_unavailable}}

  defp failure_inputs(:missing_mapping, f),
    do:
      {f.subject, {:version, f.configuration.id}, Ecto.UUID.generate(), nil,
       {:error, :mapping_unavailable}}

  defp failure_inputs(:empty_week, f) do
    subject = %{f.subject | week_start: "2026-10-19T00:00:00Z", week_end: "2026-10-26T00:00:00Z"}
    {subject, {:version, f.configuration.id}, f.mapping.id, nil, "no_quote"}
  end

  defp failure_inputs(failure, f) when failure in [:zero_score, :negative_score] do
    weight = if failure == :zero_score, do: 0, else: -2

    {:ok, configuration} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{goals: weight})
      )

    {f.subject, {:version, configuration.id}, f.mapping.id, nil, "no_quote"}
  end

  defp failure_inputs(:insufficient_data, f) do
    {:ok, configuration} =
      Configurations.create(
        ValuationConfigurationCase.rules(f.base.position.id, "balanced", %{saves: 1}, %{saves: 1})
      )

    {f.subject, {:version, configuration.id}, f.mapping.id, nil, "no_quote"}
  end

  defp failure_inputs(:unknown_position, f) do
    {:ok, position} =
      FootballMarket.Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    {:ok, configuration} = Configurations.create(ValuationConfigurationCase.rules(position.id))
    {f.subject, {:version, configuration.id}, f.mapping.id, nil, "validation_failed"}
  end

  defp failure_inputs(:unsupported_strategy, f) do
    configuration =
      Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
        strategy_id: "retired",
        formula_version: "1",
        rules: f.configuration.rules
      })

    {f.subject, {:version, configuration.id}, f.mapping.id, nil, "unsupported_strategy"}
  end

  defp failure_inputs(:unreproducible, f) do
    fact = FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)
    missing = %{fact | match_id: Ecto.UUID.generate(), performance_id: Ecto.UUID.generate()}
    {f.subject, {:version, f.configuration.id}, f.mapping.id, [missing], "unreproducible"}
  end
end
