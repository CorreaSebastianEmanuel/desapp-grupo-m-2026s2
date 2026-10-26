defmodule FootballMarket.Quotes do
  @moduledoc "Trusted internal quote calculation and local history boundary."
  import Ecto.Query
  alias FootballMarket.{Repo, Market.Quote, Valuation}
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Quotes.{
    Calculation,
    Evaluation,
    Mappings,
    Conversion,
    Store
  }

  defdelegate save_mapping(name, version, scale), to: Mappings, as: :save
  defdelegate get_mapping(id), to: Mappings, as: :get

  def request(subject_week, selector, mapping_id, request_id \\ Ecto.UUID.generate()) do
    with false <- Repo.in_transaction?(),
         {:ok, subject} <- Valuation.Request.subject_week(subject_week),
         {:ok, request_id} <- Ecto.UUID.cast(request_id),
         {:ok, player} <- initialized_player(subject.player_id, subject.season_id),
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
               evaluate_and_persist(
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
          do: retained_explicit(existing) || load_explicit_facts(existing),
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

  defp load_explicit_facts(%{explicit_fact_material: %{"facts" => facts}} = request) do
    case FootballMarket.Quotes.EvidenceCodec.decode_facts(facts) do
      {:ok, decoded} ->
        if length(decoded) == length(request.explicit_membership || []),
          do: {:ok, request, decoded},
          else: {:error, :unreproducible}

      _ ->
        {:error, :unreproducible}
    end
  end

  defp load_explicit_facts(_), do: {:error, :unreproducible}

  # FR-010: repeating identical inputs is a retry of the retained logical
  # calculation. A retained TERMINAL admission outcome re-returns itself
  # unchanged instead of claiming `unreproducible` for missing history.
  defp retained_explicit(%FootballMarket.Quotes.CalculationRequest{state: state, reason: reason})
       when state in ~w(successful no_quote validation_failed unsupported_strategy exhausted) and
              reason in ~w(configuration_unavailable mapping_unavailable unsupported_strategy) do
    {:error, String.to_atom(reason)}
  end

  defp retained_explicit(_), do: nil

  def request_membership(subject_week, selector, mapping_id, facts, request_id, lease \\ nil) do
    with {:ok, subject} <- Valuation.Request.subject_week(subject_week),
         {:ok, request_id} <- Ecto.UUID.cast(request_id),
         {:ok, mapping} <- Mappings.get(mapping_id),
         {:ok, player} <- initialized_player(subject.player_id, subject.season_id) do
      evaluate_and_persist(subject, player, selector, mapping, request_id, facts, lease)
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def process_import_request(request_id) do
    case claim_import_request(request_id) do
      {:ok, req, fence} when is_nil(req.mapping_id) ->
        finish_request(req, "validation_failed", "mapping_unavailable", nil, fence)

      {:ok, req, fence} ->
        with {:ok, req, selector} <- fix_request_binding(req),
             {:ok, facts} <- request_recovery_facts(req) do
          process_recovered_request(req, selector, facts, fence)
        else
          {:error, :original_unavailable} ->
            finish_request(req, "unreproducible", "original_unavailable", nil, fence)

          {:error, :unsupported_strategy} ->
            finish_request(req, "unsupported_strategy", "configuration_unavailable", nil, fence)

          {:error, :configuration_unavailable} ->
            finish_request(req, "validation_failed", "configuration_unavailable", nil, fence)

          {:error, _} ->
            retry_request(req, fence)
        end

      :not_due ->
        :ok

      {:error, _} ->
        {:error, :calculation_unavailable}
    end
  rescue
    _ -> {:error, :calculation_unavailable}
  end

  # Recovers the calculation's original accepted facts. Explicit requests
  # retain their own durable fact material (their import intent is nil);
  # import requests still resolve their snapshot row. A missing original row
  # stays a terminal unreproducible outcome while decode failures retry.
  defp request_recovery_facts(%{source: "explicit"} = req) do
    case load_explicit_facts(req) do
      {:ok, _request, facts} -> {:ok, facts}
      error -> error
    end
  end

  defp request_recovery_facts(req) do
    with {:ok, rows} <- FootballMarket.Quotes.Membership.snapshots(req.intent_id),
         row when not is_nil(row) <-
           Enum.find(rows, fn [sid | _] -> Ecto.UUID.load!(sid) == req.snapshot_id end) do
      [_sid, _player, _season, _start, _end, _ids, fact_material, _digest] = row
      FootballMarket.Quotes.Membership.facts(fact_material)
    else
      nil -> {:error, :original_unavailable}
      {:error, _} = error -> error
    end
  end

  defp process_recovered_request(req, selector, facts, fence) do
    result =
      request_membership(
        %{
          player_id: req.player_id,
          season_id: req.season_id,
          week_start: req.week_start,
          week_end: req.week_end
        },
        selector,
        req.mapping_id,
        facts,
        req.id,
        {req.id, fence}
      )

    case result do
      {:ok, %{calculation: calc}} ->
        finish_request(req, calc.status, calc.reason, calc.id, fence)

      {:error, _} ->
        retry_request(req, fence)
    end
  end

  defp fix_request_binding(%{configuration_version_id: id} = req) when not is_nil(id),
    do: {:ok, req, {:version, id}}

  defp fix_request_binding(req) do
    case selector(req.selector) do
      :active ->
        case Valuation.Configurations.active() do
          {:ok, version} -> persist_binding(req, version)
          _ -> {:error, :configuration_unavailable}
        end

      {:version, id} ->
        case Valuation.Configurations.get(id) do
          {:ok, %{version: version}} -> persist_binding(req, version)
          _ -> {:error, :configuration_unavailable}
        end

      :invalid ->
        {:error, :unsupported_strategy}
    end
  end

  defp persist_binding(req, version) do
    Repo.transaction(fn ->
      current = ensure_confirmation_lease!({req.id, req.lease_fence})

      if current.configuration_version_id do
        current
      else
        current
        |> Ecto.Changeset.change(configuration_version_id: version.id)
        |> Repo.update!()
      end
    end)
    |> case do
      {:ok, bound} -> {:ok, bound, {:version, bound.configuration_version_id}}
      {:error, :stale_fence} -> {:error, :stale_worker}
      _ -> {:error, :temporarily_unavailable}
    end
  end

  defp claim_import_request(id) do
    Repo.transaction(fn ->
      req =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^id,
            lock: "FOR UPDATE"
        )

      now = Store.database_clock_now!()
      claim_import_locked(req, now)
    end)
    |> case do
      {:ok, {:claimed, req, fence}} -> {:ok, req, fence}
      {:ok, :not_due} -> :not_due
      {:error, reason} -> {:error, reason}
    end
  end

  defp claim_import_locked(nil, _now), do: Repo.rollback(:not_found)

  defp claim_import_locked(%{state: state}, _now)
       when state in [
              "successful",
              "no_quote",
              "validation_failed",
              "unsupported_strategy",
              "unreproducible",
              "exhausted"
            ],
       do: :not_due

  defp claim_import_locked(req, now) do
    cond do
      import_request_not_due?(req, now) ->
        :not_due

      req.attempt_count >= 3 ->
        exhaust_import_request(req, now)

      true ->
        reserve_import_attempt(req, now)
    end
  end

  defp import_request_not_due?(%{state: "running", lease_until: until_time}, now)
       when not is_nil(until_time),
       do: DateTime.compare(until_time, now) == :gt

  defp import_request_not_due?(%{state: "retrying", next_attempt_at: next_time}, now)
       when not is_nil(next_time),
       do: DateTime.compare(next_time, now) == :gt

  defp import_request_not_due?(_req, _now), do: false

  defp exhaust_import_request(req, now) do
    if req.state == "running" and not is_nil(req.lease_until),
      do: record_attempt!(req, "interrupted", "worker_interrupted", now)

    Repo.update!(
      Ecto.Changeset.change(req,
        state: "exhausted",
        reason: "retry_exhausted",
        lease_until: nil
      )
    )

    :not_due
  end

  defp reserve_import_attempt(req, now) do
    if req.state == "running" and req.attempt_count > 0,
      do: record_attempt!(req, "interrupted", "worker_interrupted", now)

    next =
      req
      |> Ecto.Changeset.change(
        state: "running",
        attempt_count: req.attempt_count + 1,
        lease_fence: req.lease_fence + 1,
        lease_until: DateTime.add(now, 300, :second),
        next_attempt_at: nil
      )
      |> Repo.update!()

    {:claimed, next, next.lease_fence}
  end

  defp finish_request(req, status, reason, calculation_id, fence) do
    Repo.transaction(fn ->
      current =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^req.id,
            lock: "FOR UPDATE"
        )

      if current && current.state == "running" && current.lease_fence == fence do
        now = Store.database_now!()
        record_attempt!(current, status, reason, now)

        Repo.update!(
          Ecto.Changeset.change(current,
            state: status,
            reason: reason,
            calculation_id: calculation_id,
            lease_until: nil
          )
        )
      else
        Repo.rollback(:stale_fence)
      end
    end)
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :stale_worker}
    end
  end

  defp retry_request(req, fence) do
    Repo.transaction(fn ->
      current =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^req.id,
            lock: "FOR UPDATE"
        )

      retry_locked_request(current, fence)
    end)
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :stale_worker}
    end
  end

  defp retry_locked_request(%{state: "running", lease_fence: fence} = request, fence),
    do: persist_retry_transition(request)

  defp retry_locked_request(_request, _fence), do: Repo.rollback(:stale_fence)

  defp persist_retry_transition(request) do
    now = Store.database_now!()
    {state, status, reason, next_attempt_at} = retry_transition(request, now)
    record_attempt!(request, status, reason, now)

    Repo.update!(
      Ecto.Changeset.change(request,
        state: state,
        reason: reason,
        next_attempt_at: next_attempt_at,
        lease_until: nil
      )
    )
  end

  defp retry_transition(%{attempt_count: attempts}, _now) when attempts >= 3,
    do: {"exhausted", "exhausted", "retry_exhausted", nil}

  defp retry_transition(%{attempt_count: attempts}, now) do
    wait = Enum.at([60, 300], attempts - 1, 300)
    {"retrying", "retryable", "temporarily_unavailable", DateTime.add(now, wait, :second)}
  end

  defp record_attempt!(req, status, reason, now) do
    Repo.insert_all("quote_calculation_attempts", [
      %{
        id: Ecto.UUID.dump!(Ecto.UUID.generate()),
        request_id: Ecto.UUID.dump!(req.id),
        attempt_number: req.attempt_count,
        fence: req.lease_fence,
        started_at:
          if(req.lease_until, do: DateTime.add(req.lease_until, -300, :second), else: now),
        finished_at: now,
        status: status,
        reason: reason
      }
    ])
  end

  def get_calculation(id) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         %Calculation{} = calculation <- Repo.get(Calculation, id) do
      {:ok, calculation}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def get_request(id) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         %FootballMarket.Quotes.CalculationRequest{} = request <-
           Repo.get(FootballMarket.Quotes.CalculationRequest, id) do
      {:ok, request}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defdelegate list_history(player_id), to: FootballMarket.Quotes.Reader
  defdelegate latest(player_id), to: FootballMarket.Quotes.Reader
  defdelegate at_date(player_id, date), to: FootballMarket.Quotes.Reader

  def pending_evaluations do
    now = Store.database_now!()

    {:ok,
     Repo.all(
       from e in Evaluation,
         where: e.state == "pending" or (e.state == "leased" and e.lease_until <= ^now),
         order_by: [asc: e.inserted_at, asc: e.id]
     )}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def claim_evaluation(event_id, lease_seconds \\ 300),
    do: FootballMarket.Quotes.Recovery.claim_evaluation(event_id, lease_seconds)

  def acknowledge_evaluation(event_id, fence, consumer_receipt),
    do: FootballMarket.Quotes.Recovery.acknowledge_evaluation(event_id, fence, consumer_receipt)

  def replay(calculation_id) do
    case get_calculation(calculation_id) do
      {:ok, calculation} -> replay_calculation(calculation)
      _ -> {:error, :unreproducible}
    end
  rescue
    _ -> {:error, :unreproducible}
  end

  defp replay_calculation(calculation) do
    subject = %{
      player_id: calculation.player_id,
      season_id: calculation.season_id,
      week_start: calculation.week_start,
      week_end: calculation.week_end
    }

    with {:ok, facts} <-
           FootballMarket.Quotes.EvidenceCodec.decode_facts(calculation.evidence["facts"]),
         {:ok, mapping} <- Mappings.get(calculation.mapping_id),
         :ok <- evidence_mapping(calculation, mapping) do
      replay_evidence(calculation, subject, facts, mapping)
    else
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_evidence(calculation, subject, facts, mapping) do
    case Valuation.evaluate_managed_membership(
           subject,
           {:version, calculation.configuration_version_id},
           facts
         ) do
      {:ok, managed} -> replay_success(calculation, managed, mapping)
      {:error, %Valuation.Error{} = error} -> replay_failure(calculation, error)
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_success(calculation, managed, mapping) do
    with {:ok, result} <- outcome(managed.score, mapping.scale),
         :ok <- same_result(calculation, result.score, result) do
      {:ok, %{calculation: calculation, score: result.score, outcome: result}}
    else
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_failure(calculation, error) do
    case safe_failure(error) do
      {:ok, status, reason}
      when calculation.status == status and calculation.reason == reason and
             is_nil(calculation.score) ->
        {:ok,
         %{
           calculation: calculation,
           score: nil,
           outcome: %{status: status, reason: reason, price: nil}
         }}

      _ ->
        {:error, :unreproducible}
    end
  end

  defp evidence_mapping(calculation, mapping) do
    evidence = calculation.evidence

    if evidence["mapping_id"] == mapping.id and evidence["mapping_name"] == mapping.name and
         evidence["mapping_version"] == mapping.version and
         evidence["scale"] == Decimal.to_string(mapping.scale) and
         evidence["rounding_rule"] == mapping.rounding_rule and
         evidence["configuration_version_id"] == calculation.configuration_version_id,
       do: :ok,
       else: {:error, :evidence_mismatch}
  end

  defp initialized_player(player_id, season_id) do
    case Repo.get(Player, player_id) do
      %Player{season_id: ^season_id} = player ->
        if Repo.exists?(
             from q in Quote, where: q.player_id == ^player.id and q.rule_id == "initial_issuance"
           ), do: {:ok, player}, else: {:error, :player_not_initialized}

      _ ->
        {:error, :player_not_found}
    end
  end

  defp outcome(score, scale) do
    with {:ok, exact_score} <- exact_score(score) do
      case Conversion.convert(exact_score, scale) do
        {:ok, price} ->
          {:ok, %{status: "successful", reason: nil, price: price, score: exact_score}}

        {:no_quote, reason} ->
          {:ok,
           %{status: "no_quote", reason: Atom.to_string(reason), price: nil, score: exact_score}}

        error ->
          error
      end
    end
  end

  defp exact_score(%Decimal{} = score), do: {:ok, score}

  defp exact_score(score) when is_binary(score) do
    case Decimal.parse(score) do
      {%Decimal{} = decimal, ""} -> {:ok, decimal}
      _ -> {:error, :invalid_decimal}
    end
  end

  defp exact_score(_), do: {:error, :invalid_decimal}

  defp evaluate_and_persist(subject, player, selector, mapping, request_id, facts, lease \\ nil) do
    case Valuation.evaluate_managed_membership(subject, selector, facts) do
      {:ok, managed} ->
        with {:ok, result} <- outcome(managed.score, mapping.scale),
             do: persist(subject, player, managed, mapping, request_id, result, lease)

      {:error, %Valuation.Error{} = error} ->
        with {:ok, configuration_id} <- configuration_id(selector),
             {:ok, status, reason} <- safe_failure(error) do
          persist_no_score(subject, player, %{
            configuration_id: configuration_id,
            mapping: mapping,
            request_id: request_id,
            facts: facts,
            status: status,
            reason: reason,
            lease: lease
          })
        end

      _ ->
        {:error, :calculation_unavailable}
    end
  end

  defp configuration_id({:version, id}) do
    case Ecto.UUID.cast(id) do
      {:ok, normalized} -> {:ok, normalized}
      _ -> {:error, :configuration_unavailable}
    end
  end

  defp configuration_id(_), do: {:error, :configuration_unavailable}

  defp safe_failure(%Valuation.Error{kind: :no_recorded_performances}),
    do: {:ok, "no_quote", "no_recorded_performances"}

  defp safe_failure(%Valuation.Error{kind: :insufficient_data}),
    do: {:ok, "no_quote", "insufficient_data"}

  defp safe_failure(%Valuation.Error{kind: :unsupported_strategy}),
    do: {:ok, "unsupported_strategy", "unsupported_strategy"}

  defp safe_failure(%Valuation.Error{kind: kind})
       when kind in [:unavailable_replay, :inconsistent_replay],
       do: {:ok, "unreproducible", "original_unavailable"}

  defp safe_failure(%Valuation.Error{}), do: {:ok, "validation_failed", "invalid_valuation_input"}

  defp persist(subject, player, managed, mapping, request_id, outcome, lease) do
    version_id = managed.configuration_version_id
    facts = managed.prepared.facts
    ids = Enum.map(facts, & &1.performance_id)

    identity = %{
      "player_id" => player.id,
      "season_id" => subject.season_id,
      "week_start" => DateTime.to_iso8601(subject.week_start),
      "week_end" => DateTime.to_iso8601(subject.week_end),
      "membership" => ids,
      "configuration_version_id" => version_id,
      "mapping_id" => mapping.id
    }

    reject_nested_confirmation!()

    context = %{
      identity: identity,
      subject: subject,
      player: player,
      managed: managed,
      mapping: mapping,
      request_id: request_id,
      outcome: outcome,
      lease: lease,
      version_id: version_id,
      ids: ids
    }

    Repo.transaction(fn -> persist_calculation(context) end)
    |> persist_result(request_id)
  end

  defp persist_calculation(context) do
    Store.lock_player!(context.player.id)
    ensure_confirmation_lease!(context.lease)

    case Repo.one(from c in Calculation, where: c.canonical_identity == ^context.identity) do
      %Calculation{} = existing -> existing
      nil -> insert_calculation(context)
    end
  end

  defp insert_calculation(context) do
    now = Store.database_clock_now!()
    outcome = context.outcome

    calculation = %Calculation{
      id: Ecto.UUID.generate(),
      player_id: context.player.id,
      season_id: context.subject.season_id,
      week_start: context.subject.week_start,
      week_end: context.subject.week_end,
      configuration_version_id: context.version_id,
      mapping_id: context.mapping.id,
      membership: context.ids,
      status: outcome.status,
      reason: outcome.reason,
      score: outcome.score,
      unit_price: outcome.price,
      effective_at: if(outcome.status == "successful", do: now),
      canonical_identity: context.identity,
      evidence: evidence(context.managed, context.mapping, outcome.score),
      inserted_at: now
    }

    Repo.insert!(calculation)
    confirm_successful_calculation(calculation, context, now)
    calculation
  end

  defp confirm_successful_calculation(%{status: "successful"} = calculation, context, now) do
    Store.confirm!(
      calculation,
      context.player,
      context.managed,
      context.mapping,
      context.outcome.price,
      now
    )
  end

  defp confirm_successful_calculation(_calculation, _context, _now), do: :ok

  defp persist_result({:ok, calculation}, request_id),
    do: {:ok, %{request_id: request_id, calculation: calculation}}

  defp persist_result({:error, error}, _request_id), do: {:error, error}

  defp reject_nested_confirmation! do
    if Repo.in_transaction?(), do: raise(ArgumentError, "caller transaction not allowed")
  end

  defp ensure_confirmation_lease!(nil), do: :ok

  defp ensure_confirmation_lease!({request_id, fence}) do
    request =
      Repo.one(
        from r in FootballMarket.Quotes.CalculationRequest,
          where: r.id == ^request_id,
          lock: "FOR UPDATE"
      )

    # `now()` is fixed at transaction start. This confirmation may have waited
    # for the player lock, so check lease expiry against the current DB clock.
    now = Store.database_clock_now!()

    if request && request.state == "running" && request.lease_fence == fence &&
         request.lease_until && DateTime.compare(request.lease_until, now) == :gt do
      request
    else
      Repo.rollback(:stale_fence)
    end
  end

  defp persist_no_score(subject, player, attributes) do
    reject_nested_confirmation!()

    case Valuation.Configurations.get(attributes.configuration_id) do
      {:ok, %{version: version}} ->
        persist_no_score_version(subject, player, attributes, version)

      _ ->
        {:error, :configuration_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp persist_no_score_version(subject, player, attributes, version) do
    attributes = Map.update!(attributes, :facts, &Valuation.Preparation.canonical_order/1)
    membership = Enum.map(attributes.facts, & &1.performance_id)

    identity = %{
      "player_id" => player.id,
      "season_id" => subject.season_id,
      "week_start" => DateTime.to_iso8601(subject.week_start),
      "week_end" => DateTime.to_iso8601(subject.week_end),
      "membership" => membership,
      "configuration_version_id" => version.id,
      "mapping_id" => attributes.mapping.id
    }

    context = %{
      identity: identity,
      subject: subject,
      player: player,
      attributes: attributes,
      version: version,
      membership: membership
    }

    Repo.transaction(fn -> persist_no_score_calculation(context) end)
    |> persist_result(attributes.request_id)
  end

  defp persist_no_score_calculation(context) do
    Store.lock_player!(context.player.id)
    ensure_confirmation_lease!(context.attributes.lease)

    case Repo.one(from c in Calculation, where: c.canonical_identity == ^context.identity) do
      %Calculation{} = existing -> existing
      nil -> insert_no_score_calculation(context)
    end
  end

  defp insert_no_score_calculation(context) do
    now = Store.database_clock_now!()
    attributes = context.attributes
    mapping = attributes.mapping
    version = context.version

    calculation = %Calculation{
      id: Ecto.UUID.generate(),
      player_id: context.player.id,
      season_id: context.subject.season_id,
      week_start: context.subject.week_start,
      week_end: context.subject.week_end,
      configuration_version_id: version.id,
      mapping_id: mapping.id,
      membership: context.membership,
      canonical_identity: context.identity,
      status: attributes.status,
      reason: attributes.reason,
      score: nil,
      unit_price: nil,
      effective_at: now,
      evidence: no_score_evidence(attributes.facts, version, mapping),
      inserted_at: now
    }

    Repo.insert!(calculation)
  end

  defp no_score_evidence(facts, version, mapping) do
    %{
      "schema_version" => 1,
      "configuration_version_id" => version.id,
      "strategy_id" => version.strategy_id,
      "formula_version" => version.formula_version,
      "mapping_id" => mapping.id,
      "mapping_name" => mapping.name,
      "mapping_version" => mapping.version,
      "scale" => Decimal.to_string(mapping.scale),
      "rounding_rule" => mapping.rounding_rule,
      "facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(facts)
    }
  end

  defp evidence(managed, mapping, score) do
    %{
      "schema_version" => 1,
      "configuration_version_id" => managed.configuration_version_id,
      "strategy_id" => managed.strategy_id,
      "formula_version" => managed.formula_version,
      "mapping_id" => mapping.id,
      "mapping_name" => mapping.name,
      "mapping_version" => mapping.version,
      "scale" => Decimal.to_string(mapping.scale),
      "rounding_rule" => mapping.rounding_rule,
      "score" => if(is_nil(score), do: nil, else: Decimal.to_string(score)),
      "facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(managed.prepared.facts)
    }
  end

  defp selector("active"), do: :active

  defp selector("version:" <> id) do
    case Ecto.UUID.cast(id) do
      {:ok, normalized} -> {:version, normalized}
      _ -> :invalid
    end
  end

  defp selector(_), do: :invalid

  defp same_result(calc, score, %{status: "successful", price: price}) do
    if calc.status == "successful" and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score) and
         Decimal.equal?(calc.unit_price, price), do: :ok, else: {:error, :mismatch}
  end

  defp same_result(calc, score, %{status: status, reason: reason}) do
    if calc.status == status and calc.reason == reason and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score),
       do: :ok,
       else: {:error, :mismatch}
  end
end
