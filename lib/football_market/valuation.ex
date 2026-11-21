defmodule FootballMarket.Valuation do
  @moduledoc """
  Public facade for the Valuation domain (weekly player performance scoring).

  Production consumers use the managed entrypoints (`evaluate_managed/2`,
  `evaluate_managed_membership/3`, `replay_managed/1`), which bind to saved
  immutable strategy versions. Explicit `prepare/1`, `score/2`, `evaluate/2`,
  and `replay/2` remain available for formula conformance testing.

  Sub-modules under `lib/football_market/valuation/` (1 file = 1 module):
    * `Request` (`request.ex`) — weekly window, metric, and position-mapping validation
    * `StatisticsReader` (`statistics_reader.ex`) — reads accepted local match performances
    * `Preparation` (`preparation.ex`) — deterministic feature normalization
    * `Scoring` (`scoring.ex`) — strategy binding, scoring, and replay verification
    * `Balanced` / `PositionAware` (`balanced.ex`, `position_aware.ex`) — concrete formulas
    * `Configurations` (`configurations.ex`) & `Configurations.Store` (`configuration_store.ex`)
    * `Managed` (`managed.ex`) — version-bound evaluation & replay envelope
    * `CalculationRequests` (`calculation_requests.ex`) — idempotent stats-intent handoff
    * `DecimalMath` (`decimal_math.ex`), `Evidence` (`evidence.ex`), `types.ex`, `schemas.ex`
  """

  alias FootballMarket.Valuation.{Managed, Preparation, Request, Scoring, StatisticsReader}

  def evaluate_managed(subject_week, selector),
    do: Managed.evaluate(subject_week, selector)

  def evaluate_managed_membership(subject_week, selector, facts),
    do: Managed.evaluate_membership(subject_week, selector, facts)

  def replay_managed(envelope), do: Managed.replay(envelope)

  def prepare(request) do
    with {:ok, validated} <- Request.validate(request),
         {:ok, rows} <- StatisticsReader.select(validated),
         do: Preparation.build(validated, rows)
  end

  def score(prepared, definition) do
    with {:ok, bound} <- Scoring.definition(definition),
         {:ok, authenticated} <- Scoring.authenticate(prepared),
         do: Scoring.calculate(authenticated, bound)
  end

  def evaluate(request, definition) do
    with {:ok, bound} <- Scoring.definition(definition),
         {:ok, prepared} <- prepare(request),
         do: Scoring.calculate(prepared, bound)
  end

  def replay(descriptor, definition), do: Scoring.replay(descriptor, definition)
end
