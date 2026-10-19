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
    case definition_problem(d) do
      :ok -> bind(d)
      error -> error
    end
  end

  def definition(_), do: Error.new(:validation, :invalid_definition, [:definition])

  defp definition_problem(d) do
    cond do
      not exact_definition_fields?(d) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not valid_definition_metadata?(d) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not available?(d.module) ->
        Error.new(:unsupported_strategy, :unavailable_module)

      true ->
        :ok
    end
  end

  defp exact_definition_fields?(definition),
    do: Enum.sort(Map.keys(definition)) == Enum.sort([:module, :strategy_id, :version, :config])

  defp valid_definition_metadata?(definition) do
    is_binary(definition.strategy_id) and definition.strategy_id != "" and
      is_binary(definition.version) and definition.version != "" and
      is_map(definition.config) and Evidence.valid_config?(definition.config)
  end

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
          Enum.filter(prepared.scopes, &nonempty_scope?/1),
          &scope_features/1
        )

      with {:ok, result} <-
             score_callback(definition, features),
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

  defp decimal_feature({metric, value}), do: {metric, Decimal.new(value)}

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

  defp scope_features({scope, inputs}), do: {scope, Map.new(inputs.features, &decimal_feature/1)}

  defp nonempty_scope?({_, inputs}) do
    map_size(inputs.features) > 0
  end

  defp score_callback(definition, features) do
    callback(fn ->
      definition.module.score(%FeatureView{features: features}, definition.config)
    end)
  end
end
