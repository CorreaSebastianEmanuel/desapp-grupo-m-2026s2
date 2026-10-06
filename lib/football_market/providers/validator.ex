defmodule FootballMarket.Providers.Validator do
  @moduledoc "Validate a complete candidate before exposing its single outcome."
  alias FootballMarket.Providers.{Catalog, Performances, Provenance, Error, Result, Instant}

  def validate(candidate, request, context, label) do
    try do
      Catalog.require!(is_map(candidate) and not is_struct(candidate), :scope)

      Catalog.require!(
        Enum.all?(
          Map.keys(candidate),
          &(&1 in [:operation, :scope, :facts, :bindings, :fixture_id])
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
         provenance: provenance
       }}
    rescue
      _ -> {:error, Error.new(:invalid_response, request.operation, request.scope)}
    catch
      {:invalid, field} ->
        {:error, Error.new(:invalid_response, request.operation, request.scope, field)}
    end
  end
end
