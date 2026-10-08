defmodule FootballMarket.Catalog.Ingestion.Publisher do
  @moduledoc "Atomic scope-coordinated catalog and acceptance publication."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.{League, Season, Team, Player}

  alias FootballMarket.Catalog.Ingestion.{
    Scope,
    SourceBinding,
    Observation,
    ObservationBinding,
    Canonical,
    Reconciler,
    Outcome
  }

  @test_hooks Mix.env() == :test
  def revision(scope) do
    case scope_row(scope) do
      nil -> 0
      row -> row.revision
    end
  end

  defp scope_row(scope),
    do:
      Repo.get_by(Scope,
        league_code: scope.league_code,
        start_year: scope.start_year,
        end_year: scope.end_year
      )

  def publish(result, captured_revision, options) do
    encoded = Canonical.encode(result)

    transaction =
      Repo.transaction(fn ->
        lock(result.scope)
        current = scope_row(result.scope)
        instructions = Reconciler.instructions(result, current, options)

        replay =
          if current,
            do: Repo.get_by(Observation, scope_id: current.id, delivery_digest: encoded.digest)

        cond do
          replay && replay.canonical_delivery != encoded.material ->
            Reconciler.conflict(:delivery_digest_collision)

          replay ->
            outcome(replay, result.scope, :replay)

          if(current, do: current.revision, else: 0) != captured_revision ->
            Repo.rollback({:concurrent_change, :scope_revision_changed})

          true ->
            order!(current, result)
            accept(result, current, encoded, instructions)
        end
      end)

    case transaction do
      {:ok, outcome} -> {:ok, outcome}
      {:error, {status, reason}} -> failure(status, result, reason)
    end
  rescue
    error in Postgrex.Error ->
      if error.postgres && error.postgres.code == :unique_violation,
        do: failure(:reconciliation_conflict, result, :business_identity_conflict),
        else: failure(:persistence_failure, result, :publication_failed)

    _ ->
      failure(:persistence_failure, result, :publication_failed)
  end

  defp failure(status, result, reason) do
    {:error, outcome} = Outcome.failure(status, result.scope, reason)

    {:error,
     %{outcome | provider: result.provenance.provider, fixture_id: result.provenance.fixture_id}}
  end

  defp lock(scope) do
    bytes =
      :crypto.hash(
        :sha256,
        Jason.encode!([
          "catalog-ingestion-lock-v1",
          scope.league_code,
          scope.start_year,
          scope.end_year
        ])
      )

    <<key::signed-64, _::binary>> = bytes
    Ecto.Adapters.SQL.query!(Repo, "SELECT pg_advisory_xact_lock($1)", [key])
  end

  defp order!(nil, _), do: :ok

  defp order!(scope, result) do
    latest = Repo.get!(Observation, scope.latest_observation_id)

    case DateTime.compare(result.provenance.retrieved_at, latest.retrieved_at) do
      :lt -> Repo.rollback({:stale_observation, :older_retrieval})
      :eq -> Reconciler.conflict(:equal_retrieval_different_delivery)
      :gt -> :ok
    end
  end

  defp accept(result, current, encoded, instructions) do
    {league, league_state} = league!(result.facts.league)
    {season, season_state} = season!(league, result.scope)
    # Stable table order serializes shared canonical creation and legacy row mutations.
    Repo.one!(from l in League, where: l.id == ^league.id, lock: "FOR UPDATE")
    Repo.one!(from s in Season, where: s.id == ^season.id, lock: "FOR UPDATE")

    counts =
      Reconciler.zero_counts()
      |> Reconciler.increment("league", league_state)
      |> Reconciler.increment("season", season_state)

    candidate = Reconciler.candidate(result, current, league, season, counts, instructions)
    acceptance_id = Ecto.UUID.generate()

    scope =
      if current,
        do: current,
        else: %Scope{
          id: Ecto.UUID.generate(),
          league_code: result.scope.league_code,
          start_year: result.scope.start_year,
          end_year: result.scope.end_year,
          league_id: league.id,
          season_id: season.id
        }

    revision = if current, do: current.revision + 1, else: 1

    Ecto.Adapters.SQL.query!(
      Repo,
      "SET CONSTRAINTS catalog_ingestion_latest_observation_fkey DEFERRED",
      []
    )

    scope_cs = Scope.changeset(scope, %{revision: revision, latest_observation_id: acceptance_id})
    scope = if current, do: Repo.update!(scope_cs), else: Repo.insert!(scope_cs)

    Ecto.Adapters.SQL.query!(
      Repo,
      "SET CONSTRAINTS teams_season_normalized_code_index, teams_season_normalized_name_index DEFERRED",
      []
    )

    for {row, attrs, operation} <- candidate.operations do
      if operation != :unchanged do
        cs =
          case row do
            %Team{} ->
              Team.changeset(row, attrs)

            %Player{} ->
              if operation == :insert,
                do:
                  Player.create_changeset(
                    row,
                    Map.put(attrs, :catalog_identity, row.catalog_identity),
                    season.id
                  ),
                else: Player.update_changeset(row, attrs, season.id)
          end

        if operation == :insert, do: Repo.insert!(cs), else: Repo.update!(cs)
      end
    end

    hook(:after_catalog)

    Ecto.Adapters.SQL.query!(
      Repo,
      "SET CONSTRAINTS teams_season_normalized_code_index, teams_season_normalized_name_index IMMEDIATE",
      []
    )

    bindings =
      for {binding, target, existing} <- candidate.bindings do
        existing || begin_binding(scope, binding, target)
      end

    hook(:after_bindings)

    observation =
      %Observation{id: acceptance_id}
      |> Observation.changeset(%{
        scope_id: scope.id,
        revision: revision,
        operation: "catalog",
        provider: result.provenance.provider,
        retrieved_at: result.provenance.retrieved_at,
        accepted_at: DateTime.utc_now(),
        fixture_id: result.provenance.fixture_id,
        canonical_version: 1,
        delivery_digest: encoded.digest,
        canonical_delivery: encoded.material,
        counts: candidate.counts
      })
      |> Repo.insert!()

    for binding <- bindings do
      %ObservationBinding{}
      |> ObservationBinding.changeset(%{
        observation_id: observation.id,
        binding_id: binding.id,
        scope_id: scope.id
      })
      |> Repo.insert!()
    end

    hook(:after_observation)

    Ecto.Adapters.SQL.query!(
      Repo,
      "SET CONSTRAINTS catalog_ingestion_latest_observation_fkey IMMEDIATE",
      []
    )

    changes = Enum.any?(candidate.counts, fn {_, c} -> c["created"] + c["updated"] > 0 end)

    outcome(
      observation,
      result.scope,
      if(changes, do: :accepted_with_changes, else: :accepted_unchanged)
    )
  end

  defp begin_binding(scope, binding, target) do
    target_field = String.to_existing_atom(Atom.to_string(binding.kind) <> "_id")

    attrs = %{
      scope_id: scope.id,
      season_scope_id: scope.season_id,
      league_scope_id: scope.league_id,
      provider: binding.provider,
      kind: Atom.to_string(binding.kind),
      source_id: binding.source_id
    }

    %SourceBinding{}
    |> SourceBinding.changeset(Map.put(attrs, target_field, target))
    |> Repo.insert!()
  end

  defp league!(fact) do
    row =
      Repo.one(
        from l in League,
          where: fragment("lower(btrim(?))", l.code) == ^Reconciler.normalize(fact.code)
      )

    {row, state} =
      if row do
        {row, "unchanged"}
      else
        now = DateTime.utc_now()

        {count, _} =
          Repo.insert_all(
            League,
            [
              %{
                id: Ecto.UUID.generate(),
                code: fact.code,
                name: fact.name,
                inserted_at: now,
                updated_at: now
              }
            ],
            on_conflict: :nothing
          )

        {Repo.one(
           from l in League,
             where: fragment("lower(btrim(?))", l.code) == ^Reconciler.normalize(fact.code)
         ), if(count == 1, do: "created", else: "unchanged")}
      end

    if is_nil(row) or Reconciler.normalize(row.name) != Reconciler.normalize(fact.name),
      do: Reconciler.conflict(:canonical_league_conflict)

    {row, state}
  end

  defp season!(league, scope) do
    keys = [league_id: league.id, start_year: scope.start_year, end_year: scope.end_year]

    case Repo.get_by(Season, keys) do
      nil ->
        now = DateTime.utc_now()

        {count, _} =
          Repo.insert_all(
            Season,
            [
              Map.merge(Map.new(keys), %{
                id: Ecto.UUID.generate(),
                inserted_at: now,
                updated_at: now
              })
            ],
            on_conflict: :nothing
          )

        {Repo.get_by!(Season, keys), if(count == 1, do: "created", else: "unchanged")}

      row ->
        {row, "unchanged"}
    end
  end

  defp outcome(observation, scope, status) do
    first_revisions =
      Repo.all(
        from m in ObservationBinding,
          join: o in Observation,
          on: o.id == m.observation_id,
          where: m.scope_id == ^observation.scope_id,
          group_by: m.binding_id,
          select: min(o.revision)
      )

    new_bindings = Enum.count(first_revisions, &(&1 == observation.revision))

    %Outcome{
      new_bindings_count: new_bindings,
      applied_new_bindings_count: if(status == :replay, do: 0, else: new_bindings),
      status: status,
      scope: scope,
      provider: observation.provider,
      fixture_id: observation.fixture_id,
      acceptance_reference: observation.id,
      counts_historical: status == :replay,
      revision: observation.revision,
      retrieved_at: observation.retrieved_at,
      accepted_at: observation.accepted_at,
      counts: observation.counts,
      applied_counts:
        if(status == :replay, do: Reconciler.zero_counts(), else: observation.counts),
      recovery: :none
    }
  end

  defp hook(point) do
    if @test_hooks do
      case Process.get(:catalog_ingestion_failpoint) do
        ^point -> raise "controlled publication interruption"
        fun when is_function(fun, 1) -> fun.(point)
        _ -> :ok
      end
    end
  end
end
