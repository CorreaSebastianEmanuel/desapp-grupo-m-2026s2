defmodule FootballMarket.Quotes do
  @moduledoc "Trusted internal quote calculation and local history boundary."
  import Ecto.Query
  alias FootballMarket.{Repo, Market.Quote, Valuation}
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Quotes.{Calculation, Evaluation, Mappings, Conversion, Store}

  defdelegate save_mapping(name, version, scale), to: Mappings, as: :save
  defdelegate get_mapping(id), to: Mappings, as: :get

  def request(subject_week, selector, mapping_id, request_id \\ Ecto.UUID.generate()) do
    with false <- Repo.in_transaction?(),
         {:ok, subject} <- Valuation.Request.subject_week(subject_week),
         {:ok, request_id} <- Ecto.UUID.cast(request_id),
         {:ok, mapping} <- Mappings.get(mapping_id),
         {:ok, player} <- initialized_player(subject.player_id, subject.season_id),
         {:ok, request, facts} <- admit_explicit(subject, selector, mapping, request_id),
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
      true -> {:error, :caller_transaction_not_allowed}
      error -> error
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp admit_explicit(subject, selector, mapping, request_id) do
    with {:ok, selector_name} <- selector_name(selector) do
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [request_id])

        result =
          case Repo.get(FootballMarket.Quotes.CalculationRequest, request_id) do
            %FootballMarket.Quotes.CalculationRequest{} = existing ->
              if explicit_request_matches?(existing, subject, selector_name, mapping.id),
                do: load_explicit_facts(existing),
                else: {:error, :request_conflict}

            nil ->
              admit_new_explicit(subject, selector, selector_name, mapping, request_id)
          end

        case result do
          {:ok, request, facts} -> {:ok, request, facts}
          {:error, reason} -> Repo.rollback(reason)
        end
      end)
      |> case do
        {:ok, {:ok, request, facts}} -> {:ok, request, facts}
        {:error, reason} -> {:error, reason}
      end
    end
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
    request.source == "explicit" and request.player_id == subject.player_id and
      request.season_id == subject.season_id and request.week_start == subject.week_start and
      request.week_end == subject.week_end and request.selector == selector and
      request.mapping_id == mapping_id
  end

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
             {:ok, rows} <- FootballMarket.Quotes.Membership.snapshots(req.intent_id) do
          process_bound_import_request(req, selector, rows, fence)
        else
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

  defp process_bound_import_request(req, selector, rows, fence) do
    case Enum.find(rows, fn [sid | _] -> Ecto.UUID.load!(sid) == req.snapshot_id end) do
      [_sid, _player, _season, _start, _end, _ids, fact_material, _digest] ->
        result =
          with {:ok, facts} <- FootballMarket.Quotes.Membership.facts(fact_material) do
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
          end

        case result do
          {:ok, %{calculation: calc}} ->
            finish_request(req, calc.status, calc.reason, calc.id, fence)

          {:error, _} ->
            retry_request(req, fence)
        end

      _ ->
        finish_request(req, "unreproducible", "original_unavailable", nil, fence)
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
    case Repo.update(
           Ecto.Changeset.change(req,
             configuration_version_id: version.id,
             state: "running"
           )
         ) do
      {:ok, bound} -> {:ok, bound, {:version, version.id}}
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

      now = Store.database_now!()

      cond do
        is_nil(req) ->
          Repo.rollback(:not_found)

        req.state in [
          "successful",
          "no_quote",
          "validation_failed",
          "unsupported_strategy",
          "unreproducible",
          "exhausted"
        ] ->
          :not_due

        req.state == "running" and not is_nil(req.lease_until) and
            DateTime.compare(req.lease_until, now) == :gt ->
          :not_due

        req.state == "retrying" and not is_nil(req.next_attempt_at) and
            DateTime.compare(req.next_attempt_at, now) == :gt ->
          :not_due

        req.attempt_count >= 3 ->
          if req.state == "running" and is_nil(req.lease_until) == false,
            do: record_attempt!(req, "interrupted", "worker_interrupted", now)

          Repo.update!(
            Ecto.Changeset.change(req,
              state: "exhausted",
              reason: "retry_exhausted",
              lease_until: nil
            )
          )

          :not_due

        true ->
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
    end)
    |> case do
      {:ok, {:claimed, req, fence}} -> {:ok, req, fence}
      {:ok, :not_due} -> :not_due
      {:error, reason} -> {:error, reason}
    end
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

      if current && current.state == "running" && current.lease_fence == fence do
        now = Store.database_now!()
        exhausted = current.attempt_count >= 3
        wait = Enum.at([60, 300], current.attempt_count - 1, 300)

        record_attempt!(
          current,
          if(exhausted, do: "exhausted", else: "retryable"),
          if(exhausted, do: "retry_exhausted", else: "temporarily_unavailable"),
          now
        )

        Repo.update!(
          Ecto.Changeset.change(current,
            state: if(exhausted, do: "exhausted", else: "retrying"),
            reason: if(exhausted, do: "retry_exhausted", else: "temporarily_unavailable"),
            next_attempt_at: if(exhausted, do: nil, else: DateTime.add(now, wait, :second)),
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

  def list_history(player_id) do
    with {:ok, player_id} <- Ecto.UUID.cast(player_id) do
      {:ok,
       Repo.all(
         from q in Quote,
           where: q.player_id == ^player_id,
           order_by: [
             asc: fragment("COALESCE(?, 0)", q.performance_sequence),
             asc: q.inserted_at,
             asc: q.id
           ]
       )}
    else
      _ -> {:error, :invalid_player}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def latest(player_id) do
    with {:ok, player_id} <- Ecto.UUID.cast(player_id),
         %Quote{} = quote <-
           Repo.one(
             from q in Quote,
               where: q.player_id == ^player_id,
               order_by: [
                 desc: fragment("COALESCE(?, 0)", q.performance_sequence),
                 desc: q.effective_at
               ],
               limit: 1
           ) do
      {:ok, quote}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

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
    with {:ok, calculation} <- get_calculation(calculation_id),
         {:ok, facts} <-
           FootballMarket.Quotes.EvidenceCodec.decode_facts(calculation.evidence["facts"]),
         {:ok, mapping} <- Mappings.get(calculation.mapping_id),
         :ok <- evidence_mapping(calculation, mapping),
         subject = %{
           player_id: calculation.player_id,
           season_id: calculation.season_id,
           week_start: calculation.week_start,
           week_end: calculation.week_end
         } do
      case Valuation.evaluate_managed_membership(
             subject,
             {:version, calculation.configuration_version_id},
             facts
           ) do
        {:ok, managed} ->
          with {:ok, result} <- outcome(managed.score, mapping.scale),
               :ok <- same_result(calculation, result.score, result) do
            {:ok, %{calculation: calculation, score: result.score, outcome: result}}
          end

        {:error, %Valuation.Error{} = error} ->
          with {:ok, status, reason} <- safe_failure(error),
               true <-
                 calculation.status == status and calculation.reason == reason and
                   is_nil(calculation.score) do
            {:ok,
             %{
               calculation: calculation,
               score: nil,
               outcome: %{status: status, reason: reason, price: nil}
             }}
          else
            _ -> {:error, :unreproducible}
          end

        _ ->
          {:error, :unreproducible}
      end
    else
      {:error, _} -> {:error, :unreproducible}
    end
  rescue
    _ -> {:error, :unreproducible}
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
             {:ok, status, reason} <- safe_failure(error),
             do:
               persist_no_score(
                 subject,
                 player,
                 configuration_id,
                 mapping,
                 request_id,
                 facts,
                 status,
                 reason,
                 lease
               )

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

    Repo.transaction(fn ->
      Store.lock_player!(player.id)
      ensure_confirmation_lease!(lease)

      case Repo.one(from c in Calculation, where: c.canonical_identity == ^identity) do
        %Calculation{} = existing ->
          existing

        nil ->
          now = Store.database_now!()

          calc = %Calculation{
            id: Ecto.UUID.generate(),
            player_id: player.id,
            season_id: subject.season_id,
            week_start: subject.week_start,
            week_end: subject.week_end,
            configuration_version_id: version_id,
            mapping_id: mapping.id,
            membership: ids,
            status: outcome.status,
            reason: outcome.reason,
            score: outcome.score,
            unit_price: outcome.price,
            effective_at: if(outcome.status == "successful", do: now),
            canonical_identity: identity,
            evidence: evidence(managed, mapping, outcome.score),
            inserted_at: now
          }

          Repo.insert!(calc)

          if outcome.status == "successful",
            do: Store.confirm!(calc, player, managed, mapping, outcome.price, now)

          calc
      end
    end)
    |> case do
      {:ok, calc} -> {:ok, %{request_id: request_id, calculation: calc}}
      {:error, error} -> {:error, error}
    end
  end

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

    now = Store.database_now!()

    if request && request.state == "running" && request.lease_fence == fence &&
         request.lease_until && DateTime.compare(request.lease_until, now) == :gt do
      :ok
    else
      Repo.rollback(:stale_fence)
    end
  end

  defp persist_no_score(
         subject,
         player,
         configuration_id,
         mapping,
         request_id,
         facts,
         status,
         reason,
         lease
       ) do
    reject_nested_confirmation!()

    with {:ok, %{version: version}} <- Valuation.Configurations.get(configuration_id) do
      membership = Enum.map(facts, & &1.performance_id)

      identity = %{
        "player_id" => player.id,
        "season_id" => subject.season_id,
        "week_start" => DateTime.to_iso8601(subject.week_start),
        "week_end" => DateTime.to_iso8601(subject.week_end),
        "membership" => membership,
        "configuration_version_id" => version.id,
        "mapping_id" => mapping.id
      }

      Repo.transaction(fn ->
        Store.lock_player!(player.id)
        ensure_confirmation_lease!(lease)

        case Repo.one(from c in Calculation, where: c.canonical_identity == ^identity) do
          %Calculation{} = existing ->
            existing

          nil ->
            now = Store.database_now!()

            calculation = %Calculation{
              id: Ecto.UUID.generate(),
              player_id: player.id,
              season_id: subject.season_id,
              week_start: subject.week_start,
              week_end: subject.week_end,
              configuration_version_id: version.id,
              mapping_id: mapping.id,
              membership: membership,
              canonical_identity: identity,
              status: status,
              reason: reason,
              score: nil,
              unit_price: nil,
              effective_at: now,
              evidence: %{
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
              },
              inserted_at: now
            }

            Repo.insert!(calculation)
        end
      end)
      |> case do
        {:ok, calculation} -> {:ok, %{request_id: request_id, calculation: calculation}}
        {:error, error} -> {:error, error}
      end
    else
      _ -> {:error, :configuration_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
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
