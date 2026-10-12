defmodule FootballMarket.Catalog.Ingestion do
  @moduledoc "Trusted internal catalog import; source retrieval precedes atomic publication."
  alias FootballMarket.{Providers, Repo}
  alias FootballMarket.Providers.{Request, Error}
  alias FootballMarket.Catalog.Position
  alias FootballMarket.Catalog.Ingestion.{Publisher, Outcome}

  def import_catalog(input, options \\ []) do
    case Request.normalize(:catalog, input) do
      {:ok, request} ->
        do_import(request, options)

      {:error, field, scope} ->
        provider_failure(Error.new(:invalid_request, :catalog, scope, field))

      {:error, field} ->
        provider_failure(Error.new(:invalid_request, :catalog, nil, field))
    end
  rescue
    _ -> Outcome.failure(:persistence_failure, nil, :publication_failed)
  end

  defp do_import(request, options) do
    if not Keyword.keyword?(options) or
         Enum.any?(
           Keyword.keys(options),
           &(&1 not in [:provider, :runtime, :mappings, :new_players])
         ) do
      Outcome.failure(:reconciliation_conflict, request.scope, :invalid_instructions)
    else
      if not valid_instruction_shapes?(request.scope, options), do: throw(:invalid_instructions)
      captured = Publisher.revision(request.scope)
      positions = Repo.all(Position) |> Map.new(&{&1.code, &1.name})

      provider_options =
        Keyword.take(options, [:provider, :runtime]) |> Keyword.put(:positions, positions)

      case Providers.catalog(
             Map.put(request.scope, :timeout_ms, request.timeout_ms),
             provider_options
           ) do
        {:ok, result} -> Publisher.publish(result, captured, options)
        {:error, error} -> provider_failure(error)
      end
    end
  catch
    :invalid_instructions ->
      Outcome.failure(:reconciliation_conflict, request.scope, :invalid_instructions)
  end

  defp valid_instruction_shapes?(scope, options) do
    Enum.all?([{:mappings, true}, {:new_players, false}], fn {key, mapping} ->
      entries = Keyword.get(options, key, [])

      fields =
        [:provider, :league_code, :start_year, :end_year, :kind, :source_id] ++
          if(mapping, do: [:target_id], else: [])

      is_list(entries) and
        Enum.all?(entries, fn entry ->
          is_map(entry) and not is_struct(entry) and
            Enum.sort(Map.keys(entry)) == Enum.sort(fields) and
            Map.take(entry, [:league_code, :start_year, :end_year]) == scope and
            entry.kind in [:league, :season, :team, :player] and
            (mapping or entry.kind == :player) and
            FootballMarket.Providers.Provenance.safe_text?(entry.provider) and
            FootballMarket.Providers.Provenance.safe_text?(entry.source_id) and
            (not mapping or match?({:ok, _}, Ecto.UUID.cast(entry.target_id)))
        end)
    end)
  end

  defp provider_failure(error),
    do:
      {:error,
       %Outcome{
         status: :provider_failure,
         scope: error.scope,
         provider_error: error,
         recovery: :provider_guidance
       }}
end
