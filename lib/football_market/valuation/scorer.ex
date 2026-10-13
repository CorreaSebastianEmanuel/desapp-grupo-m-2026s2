defmodule FootballMarket.Valuation.Scorer do
  @moduledoc "Trusted reviewed module contract. Only rounded features enter score/2."
  @callback identity() :: {String.t(), String.t()}
  @callback validate_config(map()) :: {:ok, map()} | {:error, term()}
  @callback requirements(map()) :: {:ok, map()} | {:error, term()}
  @callback score(FootballMarket.Valuation.FeatureView.t(), map()) ::
              {:ok, Decimal.t()} | {:error, term()}
end
