defmodule FootballMarket.Valuation.Managed do
  @moduledoc false
  alias FootballMarket.Valuation

  alias FootballMarket.Valuation.{
    Request,
    Definition,
    Evidence,
    Error,
    ManagedResult,
    ManagedDescriptor,
    Descriptor,
    Scoring
  }

  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.{Rules, Registry}

  def evaluate(subject, selector) do
    with {:ok, subject} <- Request.subject_week(subject),
         {:ok, version} <- resolve(selector),
         {:ok, definition} <- definition(version),
         {:ok, result} <- Valuation.evaluate(Map.merge(subject, fields(version)), definition) do
      {:ok, wrap(result, version)}
    end
  end

  def replay(%ManagedDescriptor{schema_version: 1} = envelope) do
    with :ok <- envelope_shape(envelope),
         {:ok, version} <- original(envelope.configuration_version_id),
         {:ok, definition} <- definition(version),
         {:ok, bound} <- Scoring.definition(definition),
         :ok <- binding(envelope.evidence, version, bound),
         {:ok, result} <- Valuation.replay(envelope.evidence, definition) do
      {:ok, wrap(result, version)}
    end
  end

  def replay(_), do: Error.new(:validation, :invalid_managed_descriptor)

  defp envelope_shape(envelope) do
    if Evidence.shape?(envelope, ManagedDescriptor),
      do: :ok,
      else: Error.new(:validation, :invalid_managed_descriptor)
  end

  defp original(id) do
    case Configurations.get(id) do
      {:ok, %{version: v}} -> {:ok, v}
      {:error, %{kind: :not_found}} -> Error.new(:unavailable_replay, :original_rules_unavailable)
      error -> error
    end
  end

  defp binding(%Descriptor{} = e, version, bound) do
    if Evidence.shape?(e, Descriptor) and Evidence.shape?(e.request, Request) do
      case Request.validate(e.request) do
        {:ok, request} ->
          # Scoring already canonicalizes config into typed tuples; compare them
          # directly. Mapping pairs likewise retain UUID/group identity directly.
          validate_bound_rules(e, request, version, bound)

        _ ->
          Error.new(:inconsistent_replay, :rules_mismatch)
      end
    else
      Error.new(:inconsistent_replay, :invalid_descriptor)
    end
  end

  defp binding(_, _, _), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp validate_bound_rules(e, request, version, bound) do
    if e.strategy == Scoring.strategy(bound) and fields(request) == fields(version),
      do: :ok,
      else: Error.new(:inconsistent_replay, :rules_mismatch)
  end

  defp resolve(:active), do: Configurations.active()

  defp resolve({:version, id}) do
    with {:ok, %{version: v}} <- Configurations.get(id), do: {:ok, v}
  end

  defp resolve(_), do: Error.new(:validation, :invalid_configuration_selector)

  defp definition(v) do
    with {:ok, module} <- Registry.resolve(v.strategy_id, v.formula_version),
         {:ok, rules} <-
           Rules.validate(
             Map.take(v, [:strategy_id, :formula_version, :config, :references, :position_mapping])
           ) do
      if Evidence.canonical(rules.requirements) == Evidence.canonical(v.requirements) do
        {:ok,
         %Definition{
           module: module,
           strategy_id: v.strategy_id,
           version: v.formula_version,
           config: v.config
         }}
      else
        raise "valuation stored requirements integrity failure"
      end
    end
  end

  defp fields(v), do: Map.take(v, [:requirements, :references, :position_mapping])

  defp wrap(result, v) do
    %ManagedResult{
      configuration_version_id: v.id,
      strategy_id: v.strategy_id,
      formula_version: v.formula_version,
      score: result.score,
      prepared: result.prepared,
      descriptor: %ManagedDescriptor{configuration_version_id: v.id, evidence: result.descriptor}
    }
  end
end
