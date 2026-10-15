defmodule FootballMarket.Synchronization.Store do
  @moduledoc "PostgreSQL admission, immutable history and transport bookkeeping."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Synchronization.{Run, Attempt, Trigger, Occurrence, Clock, Policy}
  alias FootballMarket.Catalog.Ingestion.DeliveryReceipt
  alias FootballMarket.Workers.CatalogSync
  @test Mix.env() == :test
  @active ["queued", "executing", "retry_wait"]

  def lock_scope(scope) do
    <<key::signed-64, _::binary>> =
      :crypto.hash(
        :sha256,
        :erlang.term_to_binary({:synchronization_admission, scope}, [:deterministic])
      )

    Repo.query!("SELECT pg_advisory_xact_lock($1)", [key])
  end

  def admit(input, now \\ Clock.now(), occurrence_id \\ nil) do
    Repo.transaction(fn -> admit_locked(input, now, occurrence_id) end) |> unwrap()
  rescue
    _ -> unavailable()
  end

  def admit_locked(input, now, occurrence_id) do
    lock_scope(input.scope)
    scope = input.scope

    active =
      Repo.one(
        from r in Run,
          where:
            r.league_code == ^scope.league_code and r.start_year == ^scope.start_year and
              r.end_year == ^scope.end_year and r.state in @active,
          lock: "FOR UPDATE"
      )

    if active && (active.input_digest != input.digest || active.input != input.material) do
      {:error, %{category: :scope_busy, run_id: active.id, recovery: :wait_for_active_run}}
    else
      {run, disposition} =
        cond do
          is_nil(active) ->
            run =
              Repo.insert!(
                struct!(
                  Run,
                  Map.merge(scope, %{
                    source_ref: input.material["source_ref"],
                    fixture_ref: input.material["fixture_ref"],
                    input: input.material,
                    input_digest: input.digest,
                    policy: input.policy,
                    original_trigger: Atom.to_string(input.trigger),
                    state: "queued",
                    requested_at: now
                  })
                )
              )

            {prepare!(run, now), :created}

          active.input_digest == input.digest and active.input == input.material ->
            {active, :coalesced}

          true ->
            Repo.rollback(%{
              category: :scope_busy,
              run_id: active.id,
              recovery: :wait_for_active_run
            })
        end

      Repo.insert!(%Trigger{
        run_id: run.id,
        kind: Atom.to_string(input.trigger),
        requested_at: now,
        occurrence_id: occurrence_id
      })

      %{run_id: run.id, status: state_atom(run.state), disposition: disposition}
    end
  end

  def prepare!(run, eligible_at) do
    receipt =
      Repo.insert!(
        struct!(
          DeliveryReceipt,
          Map.merge(scope(run), %{run_id: run.id, fence: Ecto.UUID.generate(), state: "prepared"})
        )
      )

    job =
      %{"run_id" => run.id, "delivery_id" => receipt.id}
      |> CatalogSync.new(scheduled_at: eligible_at)
      |> insert_job!()

    run |> Ecto.Changeset.change(delivery_id: receipt.id, job_id: job.id) |> Repo.update!()
  end

  def scope(run), do: Map.take(run, [:league_code, :start_year, :end_year])

  def get_run(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id) do
      case Repo.get(Run, uuid) do
        nil -> {:error, %{category: :not_found}}
        run -> {:ok, inspect_run(run)}
      end
    else
      _ -> {:error, %{category: :invalid_request, field: :run_id}}
    end
  rescue
    _ -> unavailable()
  end

  def list_runs(scope, options) do
    limit = Keyword.get(options, :limit, 20)
    offset = Keyword.get(options, :offset, 0)

    if is_integer(limit) and limit in 1..100 and is_integer(offset) and offset >= 0 and
         Enum.all?(Keyword.keys(options), &(&1 in [:limit, :offset])) do
      runs =
        Repo.all(
          from r in Run,
            where:
              r.league_code == ^scope.league_code and r.start_year == ^scope.start_year and
                r.end_year == ^scope.end_year,
            order_by: [desc: r.requested_at, desc: r.id],
            limit: ^limit,
            offset: ^offset
        )

      {:ok, Enum.map(runs, &inspect_run/1)}
    else
      {:error, %{category: :invalid_request, field: :pagination}}
    end
  rescue
    _ -> unavailable()
  end

  def inspect_run(run) do
    attempts = Repo.all(from a in Attempt, where: a.run_id == ^run.id, order_by: a.number)

    triggers =
      Repo.all(from t in Trigger, where: t.run_id == ^run.id, order_by: [t.requested_at, t.id])

    triggers =
      Enum.map(triggers, fn trigger ->
        occurrence = if trigger.occurrence_id, do: Repo.get(Occurrence, trigger.occurrence_id)
        trigger |> plain() |> Map.put(:due_at, occurrence && occurrence.due_at)
      end)

    remaining =
      if run.next_retry_at,
        do: max(DateTime.diff(run.next_retry_at, Clock.now(), :microsecond), 0),
        else: 0

    run
    |> plain()
    |> Map.merge(%{
      attempts: Enum.map(attempts, &plain/1),
      triggers: triggers,
      remaining_wait_seconds: div(remaining + 999_999, 1_000_000),
      remaining_attempts: max(run.policy["attempt_limit"] - length(attempts), 0)
    })
  end

  defp plain(schema), do: schema |> Map.from_struct() |> Map.drop([:__meta__])

  def claim(run_id, delivery_id, now) do
    Repo.transaction(fn ->
      run = Repo.one(from r in Run, where: r.id == ^run_id, lock: "FOR UPDATE")

      receipt =
        Repo.one(from r in DeliveryReceipt, where: r.id == ^delivery_id, lock: "FOR UPDATE")

      begun = Repo.exists?(from a in Attempt, where: a.delivery_id == ^delivery_id)

      eligible =
        run && (is_nil(run.next_retry_at) || DateTime.compare(now, run.next_retry_at) != :lt)

      if run && receipt && run.delivery_id == delivery_id && run.state in ["queued", "retry_wait"] &&
           receipt.state == "prepared" && eligible && not begun do
        number = Repo.aggregate(from(a in Attempt, where: a.run_id == ^run.id), :count) + 1
        if number > run.policy["attempt_limit"], do: Repo.rollback(:exhausted)

        attempt =
          Repo.insert!(%Attempt{
            run_id: run.id,
            number: number,
            delivery_id: delivery_id,
            started_at: now,
            status: "executing"
          })

        run =
          Repo.update!(
            Ecto.Changeset.change(run,
              state: "executing",
              started_at: run.started_at || now,
              next_retry_at: nil
            )
          )

        {run, attempt, %{receipt_id: receipt.id, fence: receipt.fence}}
      else
        :ignored
      end
    end)
  end

  def complete(run_id, delivery_id, result, now) do
    Repo.transaction(fn ->
      receipt =
        Repo.one!(from r in DeliveryReceipt, where: r.id == ^delivery_id, lock: "FOR UPDATE")

      run = Repo.one!(from r in Run, where: r.id == ^run_id, lock: "FOR UPDATE")
      attempt = Repo.one!(from a in Attempt, where: a.delivery_id == ^delivery_id)

      if run.state == "executing" && attempt.status == "executing" do
        if receipt.state == "confirmed" do
          Repo.update!(
            Ecto.Changeset.change(attempt,
              status: "succeeded",
              outcome: receipt.outcome,
              finished_at: now
            )
          )

          if @test && Process.get(:synchronization_failpoint) == :during_completion,
            do: raise("controlled completion interruption")

          Repo.update!(
            Ecto.Changeset.change(run,
              state: "succeeded",
              outcome: receipt.outcome,
              reason: nil,
              recovery: "none",
              finished_at: now,
              next_retry_at: nil
            )
          )
        else
          outcome = safe_failure(result)
          Repo.update!(Ecto.Changeset.change(receipt, state: "revoked"))
          status = if outcome["status"] == "interrupted", do: "interrupted", else: "failed"

          case Policy.decision(outcome, attempt.number, run.policy, now) do
            {:retry, deadline} ->
              Repo.update!(
                Ecto.Changeset.change(attempt,
                  status: status,
                  outcome: outcome,
                  finished_at: now,
                  next_retry_at: deadline
                )
              )

              run =
                Repo.update!(
                  Ecto.Changeset.change(run,
                    state: "retry_wait",
                    outcome: outcome,
                    reason: outcome["status"],
                    recovery: "wait_for_retry",
                    next_retry_at: deadline
                  )
                )

              prepare!(run, deadline)

            {:failed, reason} ->
              Repo.update!(
                Ecto.Changeset.change(attempt, status: status, outcome: outcome, finished_at: now)
              )

              Repo.update!(
                Ecto.Changeset.change(run,
                  state: "failed",
                  outcome: outcome,
                  reason: reason,
                  recovery: failure_recovery(reason),
                  finished_at: now,
                  next_retry_at: nil
                )
              )
          end
        end
      end
    end)
  rescue
    _ -> unavailable()
  end

  defp failure_recovery("exhausted"), do: "request_new_manual_run"

  defp failure_recovery("exhausted_unconfirmed"),
    do: "inspect_unconfirmed_then_request_manual_run"

  defp failure_recovery(reason) when reason in ["input_drift", "missing_configuration"],
    do: "correct_configuration_then_request_manual_run"

  defp failure_recovery(_), do: "correct_source_or_request"

  def safe_failure({:error, %FootballMarket.Catalog.Ingestion.Outcome{} = outcome}) do
    error = outcome.provider_error

    %{
      "status" => to_string(outcome.status),
      "reason" => if(outcome.reason, do: to_string(outcome.reason)),
      "category" => if(error, do: to_string(error.category)),
      "retryable" => if(error, do: error.retryable, else: false),
      "retry_after_ms" => if(error, do: error.retry_after_ms),
      "recovery" => to_string(outcome.recovery)
    }
  end

  def safe_failure({:error, reason}) when reason in [:input_drift, :missing_configuration],
    do: %{
      "status" => to_string(reason),
      "retryable" => false,
      "recovery" => "correct_configuration"
    }

  def safe_failure({:error, :interrupted}),
    do: %{
      "status" => "interrupted",
      "retryable" => true,
      "recovery" => "retry_or_manual_recovery"
    }

  def safe_failure(_),
    do: %{"status" => "unclassified", "retryable" => false, "recovery" => "inspect_configuration"}

  def insert_job!(changeset) do
    name =
      Application.get_env(:football_market, FootballMarket.Synchronization, [])
      |> Keyword.get(:oban_name, Oban)

    Oban.insert!(name, changeset)
  end

  def unavailable, do: {:error, %{category: :store_unavailable, recovery: :retry_request}}
  defp unwrap({:ok, {:error, reason}}), do: {:error, reason}
  defp unwrap({:ok, result}), do: {:ok, result}
  defp unwrap({:error, reason}), do: {:error, reason}
  defp state_atom("queued"), do: :queued
  defp state_atom("executing"), do: :executing
  defp state_atom("retry_wait"), do: :retry_wait
end
