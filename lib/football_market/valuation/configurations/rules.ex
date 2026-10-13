defmodule FootballMarket.Valuation.Configurations.Rules do
  @moduledoc "Complete reusable rules, validated without fabricated subjects or defaults."
  alias FootballMarket.Valuation.{Error, Request, Evidence}
  alias FootballMarket.Valuation.Configurations.Registry
  @keys [:strategy_id, :formula_version, :config, :references, :position_mapping]

  def validate(r) when is_map(r) and not is_struct(r) do
    if Enum.sort(Map.keys(r)) == Enum.sort(@keys) do
      with {:ok, module} <- Registry.resolve(r.strategy_id, r.formula_version),
           {:ok, config} <- config(module, r.config),
           {:ok, requirements} <- module.requirements(config),
           {:ok, fields} <- Request.rule_fields(requirements, r.references, r.position_mapping),
           :ok <- nonempty(fields.position_mapping) do
        {:ok, Map.merge(r, fields) |> Map.put(:config, Evidence.normalize_config(config))}
      end
    else
      Error.new(:validation, :invalid_rule_keys)
    end
  end

  def validate(_), do: Error.new(:validation, :invalid_rules)

  defp config(module, config) do
    case module.validate_config(config) do
      {:ok, config} -> {:ok, config}
      _ -> Error.new(:validation, :invalid_config)
    end
  end

  defp nonempty([]), do: Error.new(:validation, :invalid_mapping, [:position_mapping])
  defp nonempty(_), do: :ok
end
