defmodule FootballMarket.Valuation do
  @moduledoc "Deterministic weekly preparation over accepted immutable local facts."
  alias FootballMarket.Valuation.{Request, StatisticsReader, Preparation}

  def prepare(request) do
    with {:ok, request} <- Request.validate(request),
         {:ok, rows} <- StatisticsReader.select(request),
         do: Preparation.build(request, rows)
  end

  def score(prepared, definition) do
    with {:ok, d} <- FootballMarket.Valuation.Scoring.definition(definition),
         {:ok, prepared} <- FootballMarket.Valuation.Replay.authenticate(prepared),
         do: FootballMarket.Valuation.Scoring.calculate(prepared, d)
  end

  def evaluate(request, definition) do
    with {:ok, d} <- FootballMarket.Valuation.Scoring.definition(definition),
         {:ok, prepared} <- prepare(request),
         do: FootballMarket.Valuation.Scoring.calculate(prepared, d)
  end

  def replay(descriptor, definition),
    do: FootballMarket.Valuation.Replay.run(descriptor, definition)
end
