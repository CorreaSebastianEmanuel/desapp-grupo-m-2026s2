defmodule FootballMarket.Valuation.Balanced do
  @moduledoc "Explicit overall weighted performance formula, version 1."
  @behaviour FootballMarket.Valuation.Scorer
  alias FootballMarket.Valuation.{DecimalMath, FeatureView, Request}

  @impl true
  def identity, do: {"balanced", "1"}

  @impl true
  def validate_config(%{weights: weights} = config)
      when is_map(config) and not is_struct(config) and map_size(config) == 1 and
             is_map(weights) and not is_struct(weights) and map_size(weights) > 0 do
    if Enum.all?(weights, fn {metric, weight} ->
         metric in Request.metrics() and DecimalMath.finite?(weight)
       end),
       do: {:ok, config},
       else: {:error, :invalid_weights}
  end

  def validate_config(_), do: {:error, :invalid_config}

  @impl true
  def requirements(config) do
    with {:ok, %{weights: weights}} <- validate_config(config) do
      {:ok, %{overall: Enum.filter(Request.metrics(), &Map.has_key?(weights, &1))}}
    end
  end

  @impl true
  def score(%FeatureView{features: %{overall: features}}, config)
      when is_map(features) and not is_struct(features) do
    with {:ok, %{overall: metrics}} <- requirements(config) do
      if valid_features?(metrics, features) do
        {:ok,
         DecimalMath.weighted(
           Enum.map(metrics, &{Map.fetch!(features, &1), Map.fetch!(config.weights, &1)})
         )}
      else
        {:error, :missing_or_invalid_feature}
      end
    end
  end

  def score(_, _), do: {:error, :invalid_features}

  defp valid_features?(metrics, features),
    do: Enum.all?(metrics, fn metric -> DecimalMath.finite?(Map.get(features, metric)) end)
end
