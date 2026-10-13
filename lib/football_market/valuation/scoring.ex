defmodule FootballMarket.Valuation.Scoring do
  @moduledoc false
  alias FootballMarket.Valuation.{
    Definition,
    Error,
    Request,
    Evidence,
    DecimalMath,
    FeatureView,
    ScoreResult
  }

  def definition(%Definition{} = d), do: definition(Map.from_struct(d))

  def definition(d) when is_map(d) and not is_struct(d) do
    cond do
      Enum.sort(Map.keys(d)) != Enum.sort([:module, :strategy_id, :version, :config]) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not is_binary(d.strategy_id) or d.strategy_id == "" or not is_binary(d.version) or
        d.version == "" or not is_map(d.config) or not Evidence.valid_config?(d.config) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not available?(d.module) ->
        Error.new(:unsupported_strategy, :unavailable_module)

      true ->
        bind(d)
    end
  end

  def definition(_), do: Error.new(:validation, :invalid_definition, [:definition])

  defp available?(module) when is_atom(module) do
    Code.ensure_loaded?(module) and
      Enum.all?([identity: 0, validate_config: 1, requirements: 1, score: 2], fn {name, arity} ->
        function_exported?(module, name, arity)
      end)
  end

  defp available?(_), do: false

  defp bind(d) do
    with {:ok, identity} <- callback(fn -> d.module.identity() end),
         :ok <- identity_matches(identity, d),
         {:ok, config_result} <- callback(fn -> d.module.validate_config(d.config) end),
         {:ok, config} <- config_result(config_result),
         {:ok, requirements_result} <- callback(fn -> d.module.requirements(config) end),
         {:ok, requirements} <- requirements_result(requirements_result) do
      {:ok,
       %{
         module: d.module,
         strategy_id: d.strategy_id,
         version: d.version,
         config: config,
         requirements: requirements
       }}
    end
  end

  defp identity_matches({id, version}, %{strategy_id: id, version: version}), do: :ok
  defp identity_matches(_, _), do: Error.new(:unsupported_strategy, :unknown_identity_version)

  defp config_result({:ok, config}) when is_map(config) and not is_struct(config) do
    if Evidence.valid_config?(config),
      do: {:ok, Evidence.normalize_config(config)},
      else: Error.new(:validation, :invalid_config, [:config])
  end

  defp config_result(_), do: Error.new(:validation, :invalid_config, [:config])
  defp requirements_result({:ok, requirements}), do: Request.requirements(requirements)
  defp requirements_result(_), do: Error.new(:validation, :invalid_requirements, [:requirements])

  def calculate(prepared, definition) do
    if prepared.request.requirements != definition.requirements do
      Error.new(:validation, :definition_requirements_mismatch, [:requirements])
    else
      features =
        Map.new(
          Enum.filter(prepared.scopes, fn {_, inputs} -> map_size(inputs.features) > 0 end),
          fn {scope, inputs} ->
            {scope,
             Map.new(inputs.features, fn {metric, value} -> {metric, Decimal.new(value)} end)}
          end
        )

      with {:ok, result} <-
             callback(fn ->
               definition.module.score(%FeatureView{features: features}, definition.config)
             end),
           {:ok, decimal} <- result(result) do
        score = DecimalMath.round(decimal)
        descriptor = %{prepared.descriptor | strategy: strategy(definition), score: score}
        {:ok, %ScoreResult{score: score, prepared: prepared, descriptor: descriptor}}
      end
    end
  end

  def strategy(d),
    do: %{
      strategy_id: d.strategy_id,
      version: d.version,
      config: Evidence.canonical(d.config),
      requirements: d.requirements
    }

  defp result({:ok, %Decimal{} = decimal}) do
    if DecimalMath.finite?(decimal),
      do: {:ok, decimal},
      else: Error.new(:strategy_failure, :invalid_result)
  end

  defp result({:error, _}), do: Error.new(:strategy_failure, :scorer_error)
  defp result(_), do: Error.new(:strategy_failure, :invalid_result)

  defp callback(fun) do
    {:ok, fun.()}
  rescue
    _ -> Error.new(:strategy_failure, :callback_exception)
  catch
    _, _ -> Error.new(:strategy_failure, :callback_exception)
  end
end
