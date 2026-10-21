defmodule FootballMarket.Valuation.PositionAware do
  @moduledoc "Explicit historical-group weighted performance formula, version 1."
  @behaviour FootballMarket.Valuation.Scorer
  alias FootballMarket.Valuation.{DecimalMath, FeatureView, Request}
  @groups [:goalkeeper, :defender, :midfielder, :forward]

  @impl true
  def identity, do: {"position_aware", "1"}

  @impl true
  def validate_config(%{weights: weights} = config)
      when is_map(config) and not is_struct(config) and map_size(config) == 1 and
             is_map(weights) and not is_struct(weights) and map_size(weights) == 4 do
    if Enum.all?(@groups, &valid_weights?(Map.get(weights, &1))),
      do: {:ok, config},
      else: {:error, :invalid_weights}
  end

  def validate_config(_), do: {:error, :invalid_config}

  defp valid_weights?(weights)
       when is_map(weights) and not is_struct(weights) and map_size(weights) > 0 do
    Enum.all?(weights, fn {metric, weight} ->
      metric in Request.metrics() and DecimalMath.finite?(weight)
    end)
  end

  defp valid_weights?(_), do: false

  @impl true
  def requirements(config) do
    with {:ok, %{weights: weights}} <- validate_config(config) do
      {:ok,
       Map.new(@groups, fn g ->
         {g, Enum.filter(Request.metrics(), &Map.has_key?(weights[g], &1))}
       end)}
    end
  end

  @impl true
  def score(%FeatureView{features: features} = view, config)
      when map_size(view) == 2 and is_map(features) and not is_struct(features) and
             map_size(features) > 0 do
    with {:ok, required} <- requirements(config) do
      score_features(features, required, config)
    end
  end

  def score(_, _), do: {:error, :invalid_features}

  defp score_features(features, required, config) do
    if Enum.all?(features, fn {group, values} ->
         valid_features?(values, Map.get(required, group))
       end) do
      terms =
        for {group, values} <- features,
            metric <- required[group],
            do: {Map.fetch!(values, metric), Map.fetch!(config.weights[group], metric)}

      {:ok, DecimalMath.weighted(terms)}
    else
      {:error, :missing_or_invalid_feature}
    end
  end

  defp valid_features?(features, metrics)
       when is_map(features) and not is_struct(features) and is_list(metrics) do
    Enum.sort(Map.keys(features)) == Enum.sort(metrics) and
      Enum.all?(metrics, &DecimalMath.finite?(Map.get(features, &1)))
  end

  defp valid_features?(_, _), do: false
end
