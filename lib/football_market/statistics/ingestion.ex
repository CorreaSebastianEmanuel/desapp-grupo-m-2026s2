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
             &(&1 in [
                 :provider,
                 :runtime,
                 :mappings,
                 :new_players,
                 :delivery_context,
                 :player_id,
                 :player_source_id,
                 :player_name,
                 :player_team_name,
                 :player_position_code
               ])
           ),
         {:ok, request} <- Request.normalize(:performances, scope),
         true <- is_nil(request.scope.from) and is_nil(request.scope.to),
         positions <- Repo.all(FootballMarket.Catalog.Position) |> Map.new(&{&1.code, &1.name}),
         provider_options <-
           player_provider(options)
           |> Keyword.merge(Keyword.take(options, [:runtime]))
           |> Keyword.put(:positions, positions),
         {:ok, result} <-
           Providers.performances(
             Map.put(request.scope, :timeout_ms, request.timeout_ms),
             provider_options
           ),
         :ok <-
           complete_scope?(
             result,
             Keyword.get(options, :player_source_id) || Keyword.get(options, :player_id)
           ),
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

  defp complete_scope?(result, player_source_id) do
    with :ok <- validate_scope_kind(result, player_source_id),
         do: validate_complete_evidence(result.completeness)
  end

  defp validate_scope_kind(
         %{completeness: %{full_scope: "player"} = completeness, facts: facts},
         target_id
       )
       when is_binary(target_id) do
    player_ref = "player:" <> target_id

    performances = Map.get(facts, :performances, [])
    players = Map.get(facts, :players, [])

    exact_source_match =
      Enum.all?(performances, &(&1.player_ref == player_ref)) and
        Enum.all?(players, &(&1.ref == player_ref))

    single_discovered_player =
      players != [] and length(Enum.uniq_by(players, & &1.ref)) == 1 and
        Enum.all?(performances, &(&1.player_ref == hd(players).ref))

    complete_empty_player_scope =
      players == [] and performances == [] and completeness.complete_empty == true

    if exact_source_match or single_discovered_player or complete_empty_player_scope,
      do: :ok,
      else: {:error, :incomplete_evidence}
  end

  defp validate_scope_kind(%{completeness: %{full_scope: true}}, nil), do: :ok
  defp validate_scope_kind(_, _), do: {:error, :incomplete_evidence}

  defp validate_complete_evidence(%{
         full_scope: full_scope,
         complete_empty: empty,
         eligible_match_identities: ids,
         detail_coverage: details
       })
       when full_scope in [true, "player"] and is_boolean(empty) and is_list(ids) and
              is_list(details),
       do:
         if(empty == (ids == []) and Enum.sort(ids) == Enum.sort(details),
           do: :ok,
           else: {:error, :incomplete_evidence}
         )

  defp validate_complete_evidence(_), do: {:error, :incomplete_evidence}

  defp player_provider(options) do
    case Keyword.get(options, :provider) do
      {adapter, state} when is_map(state) and adapter == FootballMarket.Providers.Scraping ->
        state =
          state
          |> maybe_put_state(:player_source_id, Keyword.get(options, :player_source_id))
          |> maybe_put_state(:player_name, Keyword.get(options, :player_name))
          |> maybe_put_state(:player_team_name, Keyword.get(options, :player_team_name))
          |> maybe_put_state(:player_position_code, Keyword.get(options, :player_position_code))

        Keyword.put(Keyword.take(options, [:provider]), :provider, {adapter, state})

      provider ->
        Keyword.put(Keyword.take(options, [:provider]), :provider, provider)
    end
  end

  defp maybe_put_state(state, _key, nil), do: state
  defp maybe_put_state(state, key, value), do: Map.put(state, key, value)
end
