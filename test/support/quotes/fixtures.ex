defmodule FootballMarket.Quotes.Fixtures do
  @moduledoc false
  alias FootballMarket.{ValuationCase, ValuationConfigurationCase}

  def accepted_week(fixture, identity \\ "task026-quote") do
    {match, performance} = ValuationCase.record(fixture, identity)
    %{match: match, performance: performance, fact: ValuationCase.fact(1)}
  end

  def rules(fixture, attrs \\ %{}) do
    Map.merge(ValuationConfigurationCase.rules(fixture.position.id), attrs)
  end

  def scale, do: Decimal.new("1.25")
end
