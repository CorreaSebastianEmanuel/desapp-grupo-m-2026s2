defmodule FootballMarket.Statistics.Ingestion do
  @moduledoc "Trusted worker boundary for complete statistics imports."
  alias FootballMarket.{Providers, Repo}
  alias FootballMarket.Providers.Request
  alias FootballMarket.Statistics.Ingestion.{Publisher, Outcome}

  def import_scope(scope, options \\ []) do
    with true <- Keyword.keyword?(options),
         true <- Keyword.get(options, :new_players, []) == [],
         true <-
           Enum.all?(
             Keyword.keys(options),
             &(&1 in [:provider, :runtime, :mappings, :new_players, :delivery_context])
           ),
         {:ok, request} <- Request.normalize(:performances, scope),
         true <- is_nil(request.scope.from) and is_nil(request.scope.to),
         positions <- Repo.all(FootballMarket.Catalog.Position) |> Map.new(&{&1.code, &1.name}),
         provider_options <-
           Keyword.take(options, [:provider, :runtime]) |> Keyword.put(:positions, positions),
         {:ok, result} <-
           Providers.performances(
             Map.put(request.scope, :timeout_ms, request.timeout_ms),
             provider_options
           ),
         :ok <- complete_scope?(result),
         {:ok, outcome} <- Publisher.publish(result, options) do
      {:ok, outcome}
    else
      {:error, %FootballMarket.Providers.Error{} = error} ->
        Outcome.failure(:provider_failure, error.scope, error.category,
          provider_category: error.category,
          retryable: error.retryable,
          retry_after_ms: error.retry_after_ms
        )

      {:error, %Outcome{} = outcome} ->
        {:error, outcome}

      {:error, reason} ->
        Outcome.failure(:invalid_incomplete, scope, reason)

      _ ->
        Outcome.failure(:invalid_incomplete, scope, :invalid_request)
    end
  rescue
    _ -> Outcome.failure(:persistence_failure, scope, :publication_failed)
  end

  def get_check(id) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         row when not is_nil(row) <- Repo.get(FootballMarket.Statistics.Ingestion.Check, id) do
      {:ok, row}
    else
      _ -> {:error, :not_found}
    end
  end

  def get_fact_provenance(id) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         row when not is_nil(row) <-
           Repo.get(FootballMarket.Statistics.Ingestion.FactProvenance, id) do
      {:ok, row}
    else
      _ -> {:error, :not_found}
    end
  end

  defp complete_scope?(%{
         completeness: %{
           full_scope: true,
           complete_empty: empty,
           eligible_match_identities: ids,
           detail_coverage: details
         }
       })
       when is_boolean(empty) and is_list(ids) and is_list(details),
       do:
         if(empty == (ids == []) and Enum.sort(ids) == Enum.sort(details),
           do: :ok,
           else: {:error, :incomplete_evidence}
         )

  defp complete_scope?(_), do: {:error, :incomplete_evidence}
end
