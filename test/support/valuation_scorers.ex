defmodule FootballMarket.ValuationScorers.Common do
  defmacro __using__(_) do
    quote do
      @behaviour FootballMarket.Valuation.Scorer
      alias FootballMarket.Valuation.{Request, DecimalMath, FeatureView}
      def identity, do: {"illustrative", "1"}

      def validate_config(%{weights: weights, policy: policy} = config)
          when map_size(config) == 2 and is_map(weights) and map_size(weights) > 0 and
                 policy in [:require_all, :populated_only] do
        valid =
          Enum.all?(weights, fn {scope, metrics} ->
            scope in Request.scopes() and is_map(metrics) and map_size(metrics) > 0 and
              Enum.all?(metrics, fn {m, w} ->
                m in Request.metrics() and DecimalMath.finite?(w)
              end)
          end)

        if valid, do: {:ok, config}, else: {:error, :invalid_weights}
      end

      def validate_config(_), do: {:error, :invalid_config}

      def requirements(config),
        do: Request.requirements(Map.new(config.weights, fn {s, w} -> {s, Map.keys(w)} end))

      def score(%FeatureView{features: features}, config) do
        terms =
          for scope <- Request.scopes(),
              Map.has_key?(config.weights, scope),
              metric <- Request.metrics(),
              Map.has_key?(config.weights[scope], metric) do
            case get_in(features, [scope, metric]) do
              nil -> :missing
              value -> {value, config.weights[scope][metric]}
            end
          end

        if :missing in terms and config.policy == :require_all,
          do: {:error, :missing_contribution},
          else: {:ok, DecimalMath.weighted(Enum.reject(terms, &(&1 == :missing)))}
      end

      defoverridable identity: 0, validate_config: 1, requirements: 1, score: 2
    end
  end
end

defmodule FootballMarket.ValuationScorers.Weighted do
  use FootballMarket.ValuationScorers.Common
end

defmodule FootballMarket.ValuationScorers.Restricted do
  use FootballMarket.ValuationScorers.Common

  def score(view, config) do
    if Enum.sort(Map.keys(view)) != [:__struct__, :features], do: raise("raw evidence exposed")

    if not Enum.all?(Map.keys(view.features), &Map.has_key?(config.weights, &1)),
      do: raise("unrequired scope exposed")

    for {_, metrics} <- view.features, {_, value} <- metrics do
      if not match?(%Decimal{exp: -6}, value), do: raise("unrounded feature exposed")
    end

    super(view, config)
  end
end

defmodule FootballMarket.ValuationScorers.Version2 do
  use FootballMarket.ValuationScorers.Common
  def identity, do: {"illustrative", "2"}
end

defmodule FootballMarket.ValuationScorers.Failure do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:error, :illustrative_failure}
end

defmodule FootballMarket.ValuationScorers.Exception do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: raise("private callback detail")
end

defmodule FootballMarket.ValuationScorers.IntegerResult do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:ok, 1}
end

defmodule FootballMarket.ValuationScorers.FloatResult do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:ok, 1.0}
end

defmodule FootballMarket.ValuationScorers.Nonfinite do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:ok, Decimal.new("NaN")}
end

defmodule FootballMarket.ValuationScorers.Malformed do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: :wrong_return
end

defmodule FootballMarket.ValuationScorers.MustNotScore do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: raise("requirements must be checked before invoking scorer")
end

defmodule FootballMarket.ValuationScorers.MalformedDecimal do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:ok, %Decimal{sign: 0, coef: 1, exp: 0}}
end

defmodule FootballMarket.ValuationScorers.Infinity do
  use FootballMarket.ValuationScorers.Common
  def score(_, _), do: {:ok, Decimal.new("Infinity")}
end
