defmodule FootballMarket.Quotes.HistoryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, ValuationCase}
  alias FootballMarket.QuotesCase
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "a fresh same-price calculation keeps both immutable quote records", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, original} = Quotes.request(f.subject, :active, f.mapping.id)

    {:ok, next_version} =
      Configurations.create(ValuationConfigurationCase.rules(f.base.position.id))

    assert {:ok, later} =
             Quotes.request(f.subject, {:version, next_version.id}, f.mapping.id)

    assert later.calculation.id != original.calculation.id
    assert Decimal.equal?(later.calculation.unit_price, original.calculation.unit_price)
    assert {:ok, history} = Quotes.list_history(f.player.id)
    assert length(history) == 3
    assert Enum.map(history, & &1.rule_id) |> Enum.count(&(&1 == "initial_issuance")) == 1

    assert {:ok, replay} = Quotes.replay(original.calculation.id)
    assert replay.calculation.id == original.calculation.id
    assert replay.calculation.membership == [f.performance.id]
  end

  test "late accepted facts do not change replayed original membership", f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, original} = Quotes.request(f.subject, :active, f.mapping.id)

    {_match, added} =
      ValuationCase.record(f.base, "task026-late-#{Ecto.UUID.generate()}", %{goals: 3})

    assert {:ok, replay} = Quotes.replay(original.calculation.id)
    assert replay.calculation.membership == [f.performance.id]
    refute added.id in replay.calculation.membership
    assert Decimal.equal?(replay.calculation.unit_price, Decimal.new("1.25"))
  end
end
