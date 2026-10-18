defmodule FootballMarket.Valuation do
  @moduledoc """
  Deterministic weekly preparation over accepted immutable local facts.
  Production market consumers use managed entrypoints to bind saved versions.
  Explicit prepare/score/evaluate/replay remain formula and conformance helpers.
  """
  alias FootballMarket.Valuation.{Request, StatisticsReader, Preparation}

  def evaluate_managed(subject_week, selector),
    do: FootballMarket.Valuation.Managed.evaluate(subject_week, selector)

  def evaluate_managed_membership(subject_week, selector, facts),
    do: FootballMarket.Valuation.Managed.evaluate_membership(subject_week, selector, facts)

  def replay_managed(envelope), do: FootballMarket.Valuation.Managed.replay(envelope)

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
