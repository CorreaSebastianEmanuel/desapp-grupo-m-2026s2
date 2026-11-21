defmodule FootballMarket.Valuation.Scoring do
  @moduledoc """
  Strategy binding, deterministic score calculation, and tamper-evident replay verification.

  Owns:
    * Strategy definition validation & binding (`definition/1`, `strategy/1`)
    * Deterministic 6-decimal score calculation (`calculate/2`)
    * Authentication of prepared feature bundles (`authenticate/1`)
    * Independent replay verification against stored local statistics (`replay/2`)
  """

  alias FootballMarket.Statistics.Input

  alias FootballMarket.Valuation.{
    DecimalMath,
    Definition,
    Descriptor,
    Error,
    Evidence,
    Fact,
    FeatureView,
    Preparation,
    Prepared,
    Request,
    ScopeInputs,
    ScoreResult,
    StatisticsReader
  }

  # --- Strategy Definition Binding ---

  def definition(%Definition{} = definition), do: definition(Map.from_struct(definition))

  def definition(definition) when is_map(definition) and not is_struct(definition) do
    case check_definition_shape(definition) do
      :ok -> bind_definition(definition)
      error -> error
    end
  end

  def definition(_), do: Error.new(:validation, :invalid_definition, [:definition])

  def strategy(definition) do
    %{
      strategy_id: definition.strategy_id,
      version: definition.version,
      config: Evidence.canonical(definition.config),
      requirements: definition.requirements
    }
  end

  # --- Deterministic Scoring ---

  def calculate(prepared, definition) do
    if prepared.request.requirements != definition.requirements do
      Error.new(:validation, :definition_requirements_mismatch, [:requirements])
    else
      features = build_decimal_features(prepared.scopes)

      with {:ok, raw_result} <- run_score_callback(definition, features),
           {:ok, decimal} <- validate_score_result(raw_result) do
        score = DecimalMath.round(decimal)
        descriptor = %{prepared.descriptor | strategy: strategy(definition), score: score}
        {:ok, %ScoreResult{score: score, prepared: prepared, descriptor: descriptor}}
      end
    end
  end

  defp build_decimal_features(scopes) do
    scopes
    |> Enum.filter(fn {_scope, inputs} -> map_size(inputs.features) > 0 end)
    |> Map.new(fn {scope, inputs} -> {scope, convert_features_to_decimals(inputs.features)} end)
  end

  defp convert_features_to_decimals(features),
    do: Map.new(features, fn {metric, val} -> {metric, Decimal.new(val)} end)

  # --- Replay & Integrity Verification ---

  def authenticate(%Prepared{} = prepared) do
    with :ok <- verify_shape(prepared, Prepared),
         {:ok, rebuilt} <- restore_descriptor(prepared.descriptor) do
      if Evidence.canonical(rebuilt) == Evidence.canonical(prepared),
        do: {:ok, rebuilt},
        else: Error.new(:inconsistent_replay, :altered_derived_values)
    end
  end

  def authenticate(_), do: Error.new(:validation, :invalid_prepared)

  def replay(%Descriptor{} = descriptor, definition) do
    with {:ok, prepared} <- restore_descriptor(descriptor) do
      case {descriptor.strategy, descriptor.score, definition} do
        {nil, nil, nil} -> {:ok, prepared}
        {nil, _, _} -> Error.new(:inconsistent_replay, :rules_mismatch)
        {_, _, nil} -> Error.new(:unavailable_replay, :original_rules_unavailable)
        _ -> replay_scored(descriptor, prepared, definition)
      end
    end
  end

  def replay(_, _), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  # --- Private Helpers ---

  defp check_definition_shape(definition) do
    cond do
      not exact_definition_fields?(definition) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not valid_definition_metadata?(definition) ->
        Error.new(:validation, :invalid_definition, [:definition])

      not scorer_module_available?(definition.module) ->
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

  defp scorer_module_available?(module) when is_atom(module) do
    required_callbacks = [identity: 0, validate_config: 1, requirements: 1, score: 2]

    Code.ensure_loaded?(module) and
      Enum.all?(required_callbacks, fn {name, arity} ->
        function_exported?(module, name, arity)
      end)
  end

  defp scorer_module_available?(_), do: false

  defp bind_definition(definition) do
    with {:ok, identity} <- invoke_callback(fn -> definition.module.identity() end),
         :ok <- verify_identity(identity, definition),
         {:ok, config_result} <-
           invoke_callback(fn -> definition.module.validate_config(definition.config) end),
         {:ok, config} <- validate_config_result(config_result),
         {:ok, req_result} <-
           invoke_callback(fn -> definition.module.requirements(config) end),
         {:ok, requirements} <- validate_requirements_result(req_result) do
      {:ok,
       %{
         module: definition.module,
         strategy_id: definition.strategy_id,
         version: definition.version,
         config: config,
         requirements: requirements
       }}
    end
  end

  defp verify_identity({id, version}, %{strategy_id: id, version: version}), do: :ok
  defp verify_identity(_, _), do: Error.new(:unsupported_strategy, :unknown_identity_version)

  defp validate_config_result({:ok, config}) when is_map(config) and not is_struct(config) do
    if Evidence.valid_config?(config),
      do: {:ok, Evidence.normalize_config(config)},
      else: Error.new(:validation, :invalid_config, [:config])
  end

  defp validate_config_result(_), do: Error.new(:validation, :invalid_config, [:config])

  defp validate_requirements_result({:ok, requirements}), do: Request.requirements(requirements)

  defp validate_requirements_result(_),
    do: Error.new(:validation, :invalid_requirements, [:requirements])

  defp validate_score_result({:ok, %Decimal{} = decimal}) do
    if DecimalMath.finite?(decimal),
      do: {:ok, decimal},
      else: Error.new(:strategy_failure, :invalid_result)
  end

  defp validate_score_result({:error, _}), do: Error.new(:strategy_failure, :scorer_error)
  defp validate_score_result(_), do: Error.new(:strategy_failure, :invalid_result)

  defp invoke_callback(fun) do
    {:ok, fun.()}
  rescue
    _ -> Error.new(:strategy_failure, :callback_exception)
  catch
    _, _ -> Error.new(:strategy_failure, :callback_exception)
  end

  defp run_score_callback(definition, features) do
    invoke_callback(fn ->
      definition.module.score(%FeatureView{features: features}, definition.config)
    end)
  end

  defp replay_scored(descriptor, prepared, definition) do
    case definition(definition) do
      {:ok, bound} ->
        verify_and_recalculate(descriptor, prepared, bound)

      {:error, %{kind: :unsupported_strategy}} ->
        Error.new(:unavailable_replay, :original_rules_unavailable)

      _ ->
        Error.new(:inconsistent_replay, :rules_mismatch)
    end
  end

  defp verify_and_recalculate(descriptor, prepared, bound) do
    if descriptor.strategy == strategy(bound) do
      recalculate_and_compare(descriptor, prepared, bound)
    else
      Error.new(:inconsistent_replay, :rules_mismatch)
    end
  end

  defp recalculate_and_compare(descriptor, prepared, bound) do
    with {:ok, result} <- calculate(prepared, bound) do
      if Evidence.canonical(result.descriptor) == Evidence.canonical(descriptor),
        do: {:ok, result},
        else: Error.new(:inconsistent_replay, :altered_derived_values)
    end
  end

  defp restore_descriptor(%Descriptor{} = descriptor) do
    with :ok <- verify_shape(descriptor, Descriptor), do: restore_valid_descriptor(descriptor)
  end

  defp restore_descriptor(_), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp verify_shape(value, module) do
    if Evidence.shape?(value, module),
      do: :ok,
      else: Error.new(:inconsistent_replay, :invalid_shape)
  end

  defp restore_valid_descriptor(
         %Descriptor{
           schema_version: 1,
           normalization: "weekly-count-reference-cap-v1",
           rounding: "six-half-away-v1",
           facts: facts
         } = descriptor
       )
       when is_list(facts) and facts != [] do
    with {:ok, request} <- Request.validate(descriptor.request),
         :ok <- validate_facts(facts),
         :ok <- validate_memberships(descriptor.scopes),
         :ok <- StatisticsReader.subject(request),
         {:ok, originals} <- StatisticsReader.originals(facts),
         {:ok, prepared} <- Preparation.build(request, originals) do
      rebuilt_core = Map.drop(Map.from_struct(prepared.descriptor), [:strategy, :score])
      given_core = Map.drop(Map.from_struct(descriptor), [:strategy, :score])

      if Evidence.canonical(rebuilt_core) == Evidence.canonical(given_core),
        do: {:ok, prepared},
        else: Error.new(:inconsistent_replay, :altered_derived_values)
    else
      {:error, %Error{kind: kind}} = error
      when kind in [:inconsistent_replay, :unavailable_replay] ->
        error

      _ ->
        Error.new(:inconsistent_replay, :invalid_membership)
    end
  end

  defp restore_valid_descriptor(_), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp validate_facts(facts) do
    if Evidence.proper_list?(facts) and Enum.all?(facts, &valid_fact?/1),
      do: :ok,
      else: Error.new(:inconsistent_replay, :invalid_fact)
  end

  defp valid_fact?(%Fact{} = fact),
    do: Evidence.shape?(fact, Fact) and valid_fact_fields?(fact)

  defp valid_fact?(_), do: false

  defp validate_memberships(scopes) when is_map(scopes) and not is_struct(scopes) do
    valid? =
      Enum.all?(scopes, fn {scope, inputs} ->
        scope in Request.scopes() and
          Evidence.shape?(inputs, ScopeInputs) and
          Evidence.proper_list?(inputs.membership) and
          Enum.all?(inputs.membership, fn id -> match?({:ok, _}, Ecto.UUID.cast(id)) end)
      end)

    if valid?, do: :ok, else: Error.new(:inconsistent_replay, :invalid_membership)
  end

  defp validate_memberships(_), do: Error.new(:inconsistent_replay, :invalid_membership)

  defp valid_fact_fields?(fact) do
    ids = [
      fact.performance_id,
      fact.match_id,
      fact.player_id,
      fact.season_id,
      fact.team_id,
      fact.position_id,
      fact.home_team_id,
      fact.away_team_id
    ]

    Enum.all?(ids, fn id -> match?({:ok, _}, Ecto.UUID.cast(id)) end) and
      valid_fact_metadata?(fact) and
      valid_fact_metrics?(fact.metrics)
  end

  defp valid_fact_metadata?(fact) do
    is_binary(fact.match_identity) and
      is_integer(fact.minutes) and fact.minutes >= 0 and
      match?({:ok, _}, Input.instant(fact.kickoff, :kickoff)) and
      fact.group in [nil | tl(Request.scopes())]
  end

  defp valid_fact_metrics?(metrics) do
    is_map(metrics) and
      Enum.sort(Map.keys(metrics)) == Enum.sort(Request.metrics()) and
      Enum.all?(Map.values(metrics), fn val -> is_nil(val) or (is_integer(val) and val >= 0) end)
  end
end
