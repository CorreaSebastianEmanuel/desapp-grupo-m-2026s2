defmodule FootballMarket.Valuation.Replay do
  @moduledoc false
  alias FootballMarket.Valuation.{
    Descriptor,
    Prepared,
    Fact,
    ScopeInputs,
    Request,
    StatisticsReader,
    Preparation,
    Scoring,
    Error,
    Evidence
  }

  def authenticate(%Prepared{} = prepared) do
    with :ok <- shape(prepared, Prepared), {:ok, rebuilt} <- restore(prepared.descriptor) do
      if Evidence.canonical(rebuilt) == Evidence.canonical(prepared),
        do: {:ok, rebuilt},
        else: Error.new(:inconsistent_replay, :altered_derived_values)
    end
  end

  def authenticate(_), do: Error.new(:validation, :invalid_prepared)

  def run(%Descriptor{} = descriptor, definition) do
    with {:ok, prepared} <- restore(descriptor) do
      case {descriptor.strategy, descriptor.score, definition} do
        {nil, nil, nil} -> {:ok, prepared}
        {nil, _, _} -> Error.new(:inconsistent_replay, :rules_mismatch)
        {_, _, nil} -> Error.new(:unavailable_replay, :original_rules_unavailable)
        _ -> scored(descriptor, prepared, definition)
      end
    end
  end

  def run(_, _), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp scored(descriptor, prepared, definition) do
    case Scoring.definition(definition) do
      {:ok, d} ->
        replay_with_strategy(descriptor, prepared, d)

      {:error, %{kind: :unsupported_strategy}} ->
        Error.new(:unavailable_replay, :original_rules_unavailable)

      _ ->
        Error.new(:inconsistent_replay, :rules_mismatch)
    end
  end

  defp replay_with_strategy(descriptor, prepared, definition) do
    if descriptor.strategy == Scoring.strategy(definition) do
      replay_result(descriptor, prepared, definition)
    else
      Error.new(:inconsistent_replay, :rules_mismatch)
    end
  end

  defp replay_result(descriptor, prepared, definition) do
    with {:ok, result} <- Scoring.calculate(prepared, definition) do
      validate_result_descriptor(result, descriptor)
    end
  end

  defp validate_result_descriptor(result, descriptor) do
    if Evidence.canonical(result.descriptor) == Evidence.canonical(descriptor),
      do: {:ok, result},
      else: Error.new(:inconsistent_replay, :altered_derived_values)
  end

  defp restore(%Descriptor{} = descriptor) do
    with :ok <- shape(descriptor, Descriptor), do: restore_valid(descriptor)
  end

  defp restore(_), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp shape(value, module) do
    if Evidence.shape?(value, module),
      do: :ok,
      else: Error.new(:inconsistent_replay, :invalid_shape)
  end

  defp restore_valid(
         %Descriptor{
           schema_version: 1,
           normalization: "weekly-count-reference-cap-v1",
           rounding: "six-half-away-v1",
           facts: facts
         } = descriptor
       )
       when is_list(facts) and facts != [] do
    with {:ok, request} <- Request.validate(descriptor.request),
         :ok <- valid_facts(facts),
         :ok <- valid_memberships(descriptor.scopes),
         :ok <- StatisticsReader.subject(request),
         {:ok, originals} <- StatisticsReader.originals(facts),
         {:ok, prepared} <- Preparation.build(request, originals) do
      if Evidence.canonical(Map.drop(Map.from_struct(prepared.descriptor), [:strategy, :score])) ==
           Evidence.canonical(Map.drop(Map.from_struct(descriptor), [:strategy, :score])),
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

  defp restore_valid(_), do: Error.new(:inconsistent_replay, :invalid_descriptor)

  defp valid_facts(facts) do
    if Evidence.proper_list?(facts) and Enum.all?(facts, &valid_fact?/1),
      do: :ok,
      else: Error.new(:inconsistent_replay, :invalid_fact)
  end

  defp valid_fact?(%Fact{} = fact), do: Evidence.shape?(fact, Fact) and valid_fact_fields?(fact)
  defp valid_fact?(_), do: false

  defp valid_memberships(scopes) when is_map(scopes) and not is_struct(scopes) do
    valid =
      Enum.all?(scopes, fn {scope, inputs} ->
        scope in Request.scopes() and Evidence.shape?(inputs, ScopeInputs) and
          Evidence.proper_list?(inputs.membership) and
          Enum.all?(inputs.membership, &match?({:ok, _}, Ecto.UUID.cast(&1)))
      end)

    if valid, do: :ok, else: Error.new(:inconsistent_replay, :invalid_membership)
  end

  defp valid_memberships(_), do: Error.new(:inconsistent_replay, :invalid_membership)

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

    valid_fact_ids?(ids) and valid_fact_metadata?(fact) and valid_fact_metrics?(fact.metrics)
  end

  defp valid_fact_ids?(ids), do: Enum.all?(ids, &match?({:ok, _}, Ecto.UUID.cast(&1)))

  defp valid_fact_metadata?(fact) do
    is_binary(fact.match_identity) and is_integer(fact.minutes) and fact.minutes >= 0 and
      match?({:ok, _}, FootballMarket.Statistics.Input.instant(fact.kickoff, :kickoff)) and
      fact.group in [nil | tl(Request.scopes())]
  end

  defp valid_fact_metrics?(metrics) do
    is_map(metrics) and Enum.sort(Map.keys(metrics)) == Enum.sort(Request.metrics()) and
      Enum.all?(Map.values(metrics), &(is_nil(&1) or (is_integer(&1) and &1 >= 0)))
  end
end
