defmodule FootballMarket.Providers.Validator do
  @moduledoc "Validate a complete candidate before exposing its single outcome."
  alias FootballMarket.Providers.{Catalog, Performances, Provenance, Error, Result, Instant}

  def validate(candidate, request, context, label) do
    try do
      Catalog.require!(is_map(candidate) and not is_struct(candidate), :scope)

      Catalog.require!(
        Enum.all?(
          Map.keys(candidate),
          &(&1 in [:operation, :scope, :facts, :bindings, :fixture_id, :completeness])
        ),
        :scope
      )

      Catalog.require!(
        Enum.all?([:operation, :scope, :facts, :bindings], &Map.has_key?(candidate, &1)),
        :scope
      )

      Catalog.require!(
        candidate.operation == request.operation and candidate.scope == request.scope,
        :scope
      )

      {facts, bindings} =
        case request.operation do
          :catalog ->
            {Catalog.validate(candidate.facts, request, context.positions), candidate.bindings}

          :performances ->
            Performances.validate(candidate.facts, candidate.bindings, request, context.positions)
        end

      {runtime, state} = context.runtime
      {:ok, retrieved} = Instant.normalize(runtime.utc_now(state))

      provenance =
        Provenance.validate(
          bindings,
          Map.get(candidate, :fixture_id),
          facts,
          request,
          label,
          retrieved
        )

      {:ok,
       %Result{
         operation: request.operation,
         scope: request.scope,
         facts: facts,
         provenance: provenance,
         completeness:
           validate_completeness(Map.get(candidate, :completeness), request, facts, bindings)
       }}
    rescue
      _ -> {:error, Error.new(:invalid_response, request.operation, request.scope)}
    catch
      {:invalid, field} ->
        {:error, Error.new(:invalid_response, request.operation, request.scope, field)}
    end
  end

  defp validate_completeness(nil, _request, _facts, _bindings), do: nil

  defp validate_completeness(evidence, request, facts, bindings) do
    fields = [
      :version,
      :scope,
      :full_scope,
      :terminal_witness,
      :eligible_match_identities,
      :detail_coverage,
      :assessment_revision,
      :assessment_reference,
      :complete_empty
    ]

    Catalog.require!(is_map(evidence) and not is_struct(evidence), :completeness)
    Catalog.require!(Enum.sort(Map.keys(evidence)) == Enum.sort(fields), :completeness)
    Catalog.require!(evidence.version == 1 and evidence.scope == request.scope, :completeness)
    Catalog.require!(evidence.full_scope == true, :completeness)
    Catalog.require!(is_nil(request.scope.from) and is_nil(request.scope.to), :completeness)
    Catalog.require!(Provenance.safe_text?(evidence.terminal_witness), :completeness)
    Catalog.require!(Provenance.safe_text?(evidence.assessment_reference), :completeness)
    Catalog.require!(Provenance.safe_text?(evidence.assessment_revision), :completeness)
    Catalog.require!(is_list(evidence.eligible_match_identities), :completeness)
    Catalog.require!(is_list(evidence.detail_coverage), :completeness)

    match_source_ids =
      Enum.map(Map.get(facts, :matches, []), fn match ->
        case Enum.find(bindings, &(&1.kind == :match and &1.ref == match.ref)) do
          %{source_id: source_id} -> source_id
          _ -> nil
        end
      end)

    Catalog.require!(
      Enum.sort(evidence.eligible_match_identities) == Enum.sort(match_source_ids),
      :completeness
    )

    Catalog.require!(
      evidence.complete_empty == (evidence.eligible_match_identities == []),
      :completeness
    )

    Catalog.require!(
      length(evidence.eligible_match_identities) ==
        length(Enum.uniq(evidence.eligible_match_identities)),
      :completeness
    )

    Catalog.require!(
      Enum.all?(evidence.detail_coverage, &(&1 in evidence.eligible_match_identities)),
      :completeness
    )

    Catalog.require!(
      Enum.sort(evidence.detail_coverage) == Enum.sort(evidence.eligible_match_identities),
      :completeness
    )

    evidence
  end
end
