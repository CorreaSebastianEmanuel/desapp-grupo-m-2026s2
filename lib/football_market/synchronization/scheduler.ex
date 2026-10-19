defmodule FootballMarket.Synchronization.Scheduler do
  @moduledoc "Pure UTC recurrence backed by generation and latest-only occurrence ledgers."
  import Ecto.Query
  alias Oban.Cron.Expression
  alias FootballMarket.Repo
  alias FootballMarket.Synchronization.{Clock, Input, Store, Schedule, Occurrence}

  def validate(value) when is_binary(value) do
    with 5 <- length(String.split(value)),
         {:ok, expression} <- Expression.parse(value),
         true <- possible?(expression) do
      {:ok, expression}
    else
      _ -> {:error, :recurrence}
    end
  rescue
    _ -> {:error, :recurrence}
  end

  def validate(_), do: {:error, :recurrence}

  # A Gregorian cycle proves that at least one valid date satisfies day/month/weekday.
  # This rejects impossible combinations before Oban's next/last traversal.
  defp possible?(expression) do
    Enum.any?(2000..2399, &possible_year?(&1, expression))
  end

  def latest_due(recurrence, enabled_at, now) do
    {:ok, expression} = validate(recurrence)
    minute = now |> DateTime.truncate(:second) |> Map.put(:second, 0)

    due =
      if Expression.now?(expression, minute),
        do: minute,
        else: Expression.last_at(expression, DateTime.add(minute, 1, :minute))

    if DateTime.compare(due, enabled_at) != :lt, do: due
  end

  def configure(key, definition) when is_binary(key) and is_map(definition) do
    options =
      Map.take(definition, [:source_ref, :fixture_ref, :mappings, :new_players, :policy])
      |> Map.to_list()
      |> Keyword.put(:trigger, :scheduled)

    recurrence = Map.get(definition, :recurrence, "0 0 * * *")
    enabled = Map.get(definition, :enabled, false)

    with true <- FootballMarket.Providers.Provenance.safe_text?(key),
         true <- is_boolean(enabled),
         true <-
           Enum.all?(
             Map.keys(definition),
             &(&1 in [
                 :scope,
                 :enabled,
                 :recurrence,
                 :source_ref,
                 :fixture_ref,
                 :mappings,
                 :new_players,
                 :policy
               ])
           ),
         {:ok, _} <- validate(recurrence),
         {:ok, input} <- Input.normalize(definition[:scope], options) do
      now = Clock.now()
      normalized = %{"input" => input.material, "policy" => input.policy}

      Repo.transaction(fn ->
        configure_locked(key, normalized, recurrence, enabled, now)
      end)
    else
      _ -> {:error, :invalid_schedule}
    end
  rescue
    _ -> Store.unavailable()
  end

  def configure(_, _), do: {:error, :invalid_schedule}

  def disable_all(now), do: disable_unconfigured([], now)

  def disable_unconfigured(configured_keys, now) do
    {count, _} =
      Repo.update_all(
        from(s in Schedule, where: s.enabled and s.config_key not in ^configured_keys),
        set: [enabled: false, disabled_at: now]
      )

    {:ok, count}
  rescue
    _ -> Store.unavailable()
  end

  def tick(now) do
    ids = Repo.all(from s in Schedule, where: s.enabled, select: s.id)
    results = Enum.map(ids, &dispatch(&1, now))

    if Enum.any?(results, &match?({:error, _}, &1)),
      do: Store.unavailable(),
      else: {:ok, Enum.flat_map(results, fn {:ok, value} -> List.wrap(value) end)}
  rescue
    _ -> Store.unavailable()
  end

  defp dispatch(id, now) do
    Repo.transaction(fn ->
      schedule = Repo.one!(from s in Schedule, where: s.id == ^id, lock: "FOR UPDATE")
      due = if schedule.enabled, do: latest_due(schedule.recurrence, schedule.enabled_at, now)

      if due, do: dispatch_due(id, schedule, due, now)
    end)
  end

  defp possible_year?(year, expression),
    do: Enum.any?(expression.months, &possible_month?(&1, year, expression))

  defp possible_month?(month, year, expression),
    do: Enum.any?(expression.days, &possible_day?(&1, month, year, expression))

  defp possible_day?(day, month, year, expression) do
    case Date.new(year, month, day) do
      {:ok, date} -> MapSet.member?(expression.weekdays, rem(Date.day_of_week(date), 7))
      _ -> false
    end
  end

  defp configure_locked(key, normalized, recurrence, enabled, now) do
    Store.lock_scope({:schedule, key})
    row = Repo.one(from s in Schedule, where: s.config_key == ^key, lock: "FOR UPDATE")

    same =
      row && Map.take(row.definition, ["input", "policy"]) == normalized &&
        row.recurrence == recurrence

    restart = is_nil(row) || not same || (enabled && not row.enabled)
    history = if row, do: Map.get(row.definition, "previous_generations", %{}), else: %{}

    history = schedule_history(history, restart, row)

    normalized = Map.put(normalized, "previous_generations", history)

    attrs = schedule_attrs(key, row, normalized, recurrence, enabled, now, restart)

    if row,
      do: Repo.update!(Ecto.Changeset.change(row, attrs)),
      else: Repo.insert!(struct!(Schedule, attrs))
  end

  defp schedule_history(history, restart, row) do
    if restart && row do
      Map.put(history, row.generation, %{
        "input" => row.definition["input"],
        "policy" => row.definition["policy"],
        "recurrence" => row.recurrence,
        "enabled_at" => row.enabled_at && DateTime.to_iso8601(row.enabled_at),
        "disabled_at" => row.disabled_at && DateTime.to_iso8601(row.disabled_at)
      })
    else
      history
    end
  end

  defp schedule_attrs(key, row, normalized, recurrence, enabled, now, restart) do
    %{
      config_key: key,
      generation: if(restart || is_nil(row), do: Ecto.UUID.generate(), else: row.generation),
      enabled: enabled,
      enabled_at: enabled_at(row, restart, enabled, now),
      disabled_at: disabled_at(row, enabled, now),
      recurrence: recurrence,
      definition: normalized
    }
  end

  defp enabled_at(row, restart, enabled, now),
    do: if(restart, do: if(enabled, do: now, else: nil), else: row && row.enabled_at)

  defp disabled_at(row, enabled, now),
    do:
      if(enabled,
        do: nil,
        else: if(row && not row.enabled, do: row.disabled_at || now, else: now)
      )

  defp pending_occurrence!(existing, pending, id, schedule, due) do
    cond do
      existing ->
        existing

      pending ->
        Repo.update!(
          Ecto.Changeset.change(pending,
            due_at: due,
            superseded_from: pending.superseded_from || pending.due_at,
            superseded_until: pending.due_at
          )
        )

      true ->
        Repo.insert!(%Occurrence{
          schedule_id: id,
          generation: schedule.generation,
          due_at: due,
          state: "pending"
        })
    end
  end

  defp dispatch_due(id, schedule, due, now) do
    due = %{due | microsecond: {elem(due.microsecond, 0), 6}}

    existing =
      Repo.get_by(Occurrence, schedule_id: id, generation: schedule.generation, due_at: due)

    if is_nil(existing) || existing.state == "pending" do
      pending =
        Repo.one(
          from o in Occurrence,
            where:
              o.schedule_id == ^id and o.generation == ^schedule.generation and
                o.state == "pending",
            lock: "FOR UPDATE"
        )

      occurrence =
        pending_occurrence!(existing, pending, id, schedule, due)

      material = schedule.definition["input"]

      # A persisted definition may outlive source configuration changes.
      # Reject invalid/drifted effective inputs before admitting executable work.
      case Input.execution(material) do
        {:ok, _} -> :ok
        {:error, _} -> Repo.rollback(:invalid_schedule)
      end

      scope = Map.new(material["scope"], fn {k, v} -> {String.to_existing_atom(k), v} end)

      input = %{
        operation: :catalog,
        scope: scope,
        material: material,
        digest: Input.digest(material),
        policy: schedule.definition["policy"],
        trigger: :scheduled
      }

      case Store.admit_locked(input, now, occurrence.id) do
        {:error, %{category: :scope_busy}} ->
          nil

        result ->
          Repo.update!(Ecto.Changeset.change(occurrence, state: "handled", run_id: result.run_id))

          result
      end
    end
  end
end
