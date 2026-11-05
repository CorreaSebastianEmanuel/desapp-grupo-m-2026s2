defmodule FootballMarket.Quotes.Admission do
  @moduledoc "Explicit request admission and retained idempotent input identity."
  import Ecto.Query
  alias FootballMarket.{Repo, Valuation}
  alias FootballMarket.Quotes.{Mappings, Store}

  alias FootballMarket.Quotes.{Engine, EvidenceCodec}

  def request(subject_week, selector, mapping_id, request_id \\ Ecto.UUID.generate()) do
    with false <- Repo.in_transaction?(),
         {:ok, subject} <- Valuation.Request.subject_week(subject_week),
         {:ok, request_id} <- Ecto.UUID.cast(request_id),
         {:ok, player} <- Store.initialized_player(subject.player_id, subject.season_id),
         {:ok, selector_name} <- selector_name(selector) do
      existing = Repo.get(FootballMarket.Quotes.CalculationRequest, request_id)
      resolve_request(existing, subject, selector, selector_name, mapping_id, request_id, player)
    else
      true -> {:error, :caller_transaction_not_allowed}
      error -> error
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp resolve_request(nil, subject, selector, _selector_name, mapping_id, request_id, player),
    do: continue_request(subject, selector, mapping_id, request_id, player)

  defp resolve_request(
         %FootballMarket.Quotes.CalculationRequest{} = request,
         subject,
         selector,
         selector_name,
         mapping_id,
         request_id,
         player
       ) do
    resolve_existing_request(
      request,
      subject,
      selector,
      selector_name,
      Mappings.get(mapping_id),
      mapping_id,
      request_id,
      player
    )
  end

  defp resolve_request(
         _request,
         _subject,
         _selector,
         _selector_name,
         mapping_id,
         _request_id,
         _player
       ),
       do: Mappings.get(mapping_id)

  defp resolve_existing_request(
         request,
         subject,
         selector,
         selector_name,
         {:ok, mapping},
         mapping_id,
         request_id,
         player
       ) do
    if explicit_request_matches?(request, subject, selector_name, mapping.id) do
      retained_explicit(request) ||
        continue_request(subject, selector, mapping_id, request_id, player)
    else
      {:error, :request_conflict}
    end
  end

  defp resolve_existing_request(
         request,
         subject,
         _selector,
         selector_name,
         {:error, :mapping_unavailable},
         mapping_id,
         _request_id,
         _player
       ) do
    # The FK is intentionally NULL for an unavailable mapping. Preserve
    # retries of that terminal admission only while the retried mapping
    # identity equals the supplied identity recorded on the persisted
    # request; a different identity conflicts instead of inheriting the
    # retained error.
    retained_mapping_failure(request, subject, selector_name, mapping_id)
  end

  defp resolve_existing_request(
         _request,
         _subject,
         _selector,
         _name,
         error,
         _mapping_id,
         _request_id,
         _player
       ),
       do: error

  defp continue_request(subject, selector, mapping_id, request_id, player) do
    request_terminal_failure = fn reason ->
      case selector_name(selector) do
        {:ok, name} ->
          admit_failure(subject, name, mapping_id, request_id, reason)

        {:error, invalid} ->
          {:error, invalid}
      end
    end

    case Mappings.get(mapping_id) do
      {:ok, mapping} ->
        with {:ok, request, facts} <- admit_explicit(subject, selector, mapping, request_id),
             {:ok, persisted} <-
               Engine.evaluate_and_persist(
                 subject,
                 player,
                 {:version, request.configuration_version_id},
                 mapping,
                 request_id,
                 facts
               ) do
          completed =
            request
            |> Ecto.Changeset.change(
              state: persisted.calculation.status,
              reason: persisted.calculation.reason,
              calculation_id: persisted.calculation.id
            )
            |> Repo.update!()

          {:ok, Map.put(persisted, :request, completed)}
        else
          {:error, :configuration_unavailable} -> {:error, :configuration_unavailable}
          error -> error
        end

      {:error, :mapping_unavailable} ->
        request_terminal_failure.(:mapping_unavailable)

      error ->
        error
    end
  end

  defp admit_explicit(subject, selector, mapping, request_id) do
    case selector_name(selector) do
      {:ok, name} ->
        Repo.transaction(fn ->
          lock_request!(request_id)

          explicit_admission(subject, selector, name, mapping, request_id)
        end)
        |> normalize_admission_result()

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp lock_request!(id),
    do: Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [id])

  defp admit_failure(subject, name, mapping_id, request_id, reason) do
    Repo.transaction(fn ->
      lock_request!(request_id)

      case Repo.get(FootballMarket.Quotes.CalculationRequest, request_id) do
        nil ->
          record_admission_failure!(subject, name, mapping_id, request_id, Atom.to_string(reason))
          {:error, reason}

        existing ->
          retained_mapping_failure(existing, subject, name, mapping_id)
      end
    end)
    |> case do
      {:ok, result} -> result
      {:error, reason} -> {:error, reason}
    end
  end

  defp explicit_admission(subject, selector, name, mapping, request_id) do
    case Repo.get(FootballMarket.Quotes.CalculationRequest, request_id) do
      %FootballMarket.Quotes.CalculationRequest{} = existing ->
        if explicit_request_matches?(existing, subject, name, mapping.id),
          do: retained_explicit(existing) || EvidenceCodec.request_facts(existing),
          else: {:error, :request_conflict}

      nil ->
        result = admit_new_explicit(subject, selector, name, mapping, request_id)
        commit_admission_result(result, subject, name, mapping, request_id)
    end
  end

  defp commit_admission_result({:ok, request, facts}, _subject, _name, _mapping, _request_id),
    do: {:ok, request, facts}

  # A missing/unsupported selection is a durable terminal admission outcome
  # (FR-007/contracts/calculation.md): commit its row instead of rolling the
  # whole admission back into invisible non-existence.
  defp commit_admission_result(
         {:error, :configuration_unavailable} = failure,
         subject,
         name,
         mapping,
         request_id
       ) do
    record_admission_failure!(subject, name, mapping.id, request_id, "configuration_unavailable")
    failure
  end

  defp commit_admission_result({:error, reason}, _subject, _name, _mapping, _request_id),
    do: Repo.rollback(reason)

  defp normalize_admission_result(result) do
    case result do
      {:ok, result} -> result
      {:error, reason} -> {:error, reason}
    end
  end

  # Persists the contract-whitelisted terminal admission failure so the request
  # identity remains observable after the caller returns.
  defp record_admission_failure!(subject, selector_name, mapping_id, request_id, reason) do
    identity =
      case Ecto.UUID.cast(mapping_id) do
        {:ok, id} -> id
        _ -> nil
      end

    persisted_mapping =
      if identity &&
           Repo.exists?(from m in FootballMarket.Quotes.Mapping, where: m.id == ^identity),
         do: identity

    requested_mapping = if is_nil(persisted_mapping), do: identity

    Repo.insert!(%FootballMarket.Quotes.CalculationRequest{
      id: request_id,
      source: "explicit",
      player_id: subject.player_id,
      season_id: subject.season_id,
      week_start: subject.week_start,
      week_end: subject.week_end,
      selector: selector_name,
      mapping_id: persisted_mapping,
      requested_mapping_id: requested_mapping,
      state: "validation_failed",
      reason: reason,
      inserted_at: Store.database_now!()
    })
  end

  defp admit_new_explicit(subject, selector, selector_name, mapping, request_id) do
    with {:ok, configuration, ^selector_name} <- resolve_selector(selector) do
      request = %FootballMarket.Quotes.CalculationRequest{
        id: request_id,
        source: "explicit",
        player_id: subject.player_id,
        season_id: subject.season_id,
        week_start: subject.week_start,
        week_end: subject.week_end,
        selector: selector_name,
        mapping_id: mapping.id,
        configuration_version_id: configuration.id,
        state: "pending",
        inserted_at: Store.database_now!()
      }

      admitted = Repo.insert!(request)

      with {:ok, facts} <- Valuation.StatisticsReader.select(subject) do
        material = %{"facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(facts)}
        membership = Enum.map(facts, & &1.performance_id)

        admitted =
          admitted
          |> Ecto.Changeset.change(
            explicit_membership: membership,
            explicit_fact_material: material
          )
          |> Repo.update!()

        {:ok, admitted, facts}
      end
    end
  end

  defp selector_name(:active), do: {:ok, "active"}

  defp selector_name({:version, id}) do
    with {:ok, id} <- Ecto.UUID.cast(id), do: {:ok, "version:" <> id}
  end

  defp selector_name(_), do: {:error, :invalid_selector}

  defp resolve_selector(:active) do
    case Valuation.Configurations.active() do
      {:ok, configuration} -> {:ok, configuration, "active"}
      _ -> {:error, :configuration_unavailable}
    end
  end

  defp resolve_selector({:version, id}) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         {:ok, %{version: configuration}} <- Valuation.Configurations.get(id) do
      {:ok, configuration, "version:" <> id}
    else
      _ -> {:error, :configuration_unavailable}
    end
  end

  defp resolve_selector(_), do: {:error, :invalid_selector}

  defp explicit_request_matches?(request, subject, selector, mapping_id) do
    explicit_request_scope_matches?(request, subject, selector) and
      request.mapping_id == mapping_id
  end

  defp explicit_request_scope_matches?(request, subject, selector) do
    request.source == "explicit" and request.player_id == subject.player_id and
      request.season_id == subject.season_id and request.week_start == subject.week_start and
      request.week_end == subject.week_end and request.selector == selector
  end

  # The persisted unavailable-mapping identity must equal the retried one.
  # Identity-unknown rows (legacy or malformed input) conflict conservatively
  # instead of silently retaining an unrelated mapping's terminal error.
  defp retained_mapping_failure(request, subject, selector_name, mapping_id) do
    if request.reason == "mapping_unavailable" and
         explicit_mapping_identity?(request, mapping_id) and
         explicit_request_scope_matches?(request, subject, selector_name),
       do: retained_explicit(request),
       else: {:error, :request_conflict}
  end

  defp explicit_mapping_identity?(
         %FootballMarket.Quotes.CalculationRequest{mapping_id: nil} = request,
         mapping_id
       ) do
    case Ecto.UUID.cast(mapping_id) do
      {:ok, identity} -> request.requested_mapping_id == identity
      _ -> false
    end
  end

  defp explicit_mapping_identity?(_, _), do: false

  defp retained_explicit(%FootballMarket.Quotes.CalculationRequest{state: state, reason: reason})
       when state in ~w(successful no_quote validation_failed unsupported_strategy exhausted) and
              reason in ~w(configuration_unavailable mapping_unavailable unsupported_strategy) do
    {:error, String.to_atom(reason)}
  end

  defp retained_explicit(_), do: nil
end
