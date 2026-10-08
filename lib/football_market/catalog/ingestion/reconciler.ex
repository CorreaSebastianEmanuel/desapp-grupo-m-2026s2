defmodule FootballMarket.Catalog.Ingestion.Reconciler do
  @moduledoc "Conservative complete-candidate reconciliation; no persistence writes."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.{League, Season, Team, Player, Position}
  alias FootballMarket.Catalog.Ingestion.{SourceBinding, Outcome}
  @kinds [:league, :season, :team, :player]
  def normalize(value), do: value |> String.trim() |> String.downcase()
  def conflict(reason), do: Repo.rollback({:reconciliation_conflict, reason})

  def instructions(result, scope, options) do
    mappings = Keyword.get(options, :mappings, [])
    declarations = Keyword.get(options, :new_players, [])
    if not is_list(mappings) or not is_list(declarations), do: conflict(:invalid_instructions)
    incoming = Map.new(result.provenance.bindings, &{{&1.kind, &1.source_id}, &1})
    existing = bindings(scope)
    entries = Enum.map(mappings, &{&1, :mapping}) ++ Enum.map(declarations, &{&1, :new})

    validated =
      Enum.map(entries, fn {entry, type} ->
        fields =
          [:provider, :league_code, :start_year, :end_year, :kind, :source_id] ++
            if(type == :mapping, do: [:target_id], else: [])

        if not is_map(entry) or is_struct(entry) or
             Enum.sort(Map.keys(entry)) != Enum.sort(fields),
           do: conflict(:invalid_instructions)

        if entry.kind not in @kinds or (type == :new and entry.kind != :player) or
             entry.provider != result.provenance.provider or
             Map.take(entry, [:league_code, :start_year, :end_year]) != result.scope,
           do: conflict(:invalid_instructions)

        k = {entry.kind, entry.source_id}
        if not Map.has_key?(incoming, k), do: conflict(:invalid_instructions)
        bound = Map.get(existing, {entry.provider, entry.kind, entry.source_id})

        target =
          if type == :mapping,
            do: instruction_target(entry, scope || legacy_scope(result.scope)),
            else: :new

        if bound && (type == :new or target.id != target_id(bound)),
          do: conflict(:contradictory_binding)

        {k, {type, target}}
      end)

    if length(validated) != length(Enum.uniq_by(validated, &elem(&1, 0))),
      do: conflict(:duplicate_instructions)

    targets = for {{kind, _}, {:mapping, target}} <- validated, do: {kind, target.id}
    if length(targets) != length(Enum.uniq(targets)), do: conflict(:collapsing_bindings)
    Map.new(validated)
  end

  defp legacy_scope(scope) do
    league =
      Repo.one(
        from l in League,
          where: fragment("lower(btrim(?))", l.code) == ^normalize(scope.league_code)
      )

    season =
      if league,
        do:
          Repo.get_by(Season,
            league_id: league.id,
            start_year: scope.start_year,
            end_year: scope.end_year
          )

    if season, do: %{league_id: league.id, season_id: season.id}
  end

  defp instruction_target(entry, scope) do
    if is_nil(scope) or not match?({:ok, _}, Ecto.UUID.cast(entry.target_id)),
      do: conflict(:invalid_target)

    module =
      case entry.kind do
        :league -> League
        :season -> Season
        :team -> Team
        :player -> Player
      end

    target = Repo.get(module, entry.target_id)

    valid =
      target &&
        case entry.kind do
          :league -> target.id == scope.league_id
          :season -> target.id == scope.season_id
          _ -> target.season_id == scope.season_id
        end

    if not valid, do: conflict(:invalid_target)
    target
  end

  def bindings(nil), do: %{}

  def bindings(scope),
    do:
      Repo.all(from b in SourceBinding, where: b.scope_id == ^scope.id)
      |> Map.new(&{{&1.provider, String.to_existing_atom(&1.kind), &1.source_id}, &1})

  def target_id(b), do: Map.fetch!(b, String.to_existing_atom(b.kind <> "_id"))

  def candidate(result, scope, league, season, initial_counts, instructions) do
    existing = bindings(scope)
    provider = result.provenance.provider
    binding_refs = Map.new(result.provenance.bindings, &{{&1.kind, &1.ref}, &1})

    teams =
      Repo.all(
        from t in Team, where: t.season_id == ^season.id, order_by: t.id, lock: "FOR UPDATE"
      )

    players =
      Repo.all(
        from p in Player, where: p.season_id == ^season.id, order_by: p.id, lock: "FOR UPDATE"
      )

    positions = Repo.all(Position) |> Map.new(&{&1.code, &1})
    roles = Map.new(result.facts.positions, &{&1.ref, &1.code})

    replacements =
      Enum.any?(existing, fn {{_, kind, _}, _} -> kind == :player end) and
        not Enum.any?(existing, fn {{p, kind, _}, _} -> p == provider and kind == :player end)

    bound_player_ids =
      existing |> Map.values() |> Enum.filter(&(&1.kind == "player")) |> Enum.map(& &1.player_id)

    counts = initial_counts

    {team_targets, team_ops, counts} =
      Enum.reduce(result.facts.teams, {%{}, [], counts}, fn fact, {targets, ops, counts} ->
        binding = Map.fetch!(binding_refs, {:team, fact.ref})

        target =
          resolve_bound(binding, existing, teams) ||
            fresh_instruction(instructions, binding, teams)

        target = target || adopt_team(teams, fact)
        row = target || %Team{id: Ecto.UUID.generate(), season_id: season.id}
        attrs = %{season_id: season.id, code: fact.code, name: fact.name}
        {operation, state} = operation(row, attrs, Team.changeset(row, attrs))

        {Map.put(targets, fact.ref, row.id), [{row, attrs, operation} | ops],
         increment(counts, "team", state)}
      end)

    final_teams = replace_final(teams, team_ops)
    unique!(final_teams, &normalize(&1.code))
    unique!(final_teams, &normalize(&1.name))

    {player_targets, player_ops, counts} =
      Enum.reduce(result.facts.players, {%{}, [], counts}, fn fact, {targets, ops, counts} ->
        binding = Map.fetch!(binding_refs, {:player, fact.ref})

        target =
          resolve_bound(binding, existing, players) ||
            fresh_instruction(instructions, binding, players)

        declaration = Map.get(instructions, {:player, binding.source_id}) == {:new, :new}

        if is_nil(target) and replacements and not declaration,
          do: conflict(:source_replacement_requires_mapping)

        if is_nil(target) and
             Enum.any?(
               players,
               &(normalize(&1.display_name) == normalize(fact.display_name) and
                   &1.id not in bound_player_ids)
             ),
           do: conflict(:unbound_player_identity)

        row =
          target ||
            %Player{
              id: Ecto.UUID.generate(),
              catalog_identity: Ecto.UUID.generate(),
              season_id: season.id
            }

        code = Map.fetch!(roles, fact.position_ref)
        position = Map.get(positions, code)
        if is_nil(position), do: conflict(:invalid_position)

        attrs = %{
          team_id: Map.fetch!(team_targets, fact.team_ref),
          position_id: position.id,
          display_name: fact.display_name
        }

        cs =
          if row.__meta__.state == :built,
            do:
              Player.create_changeset(
                row,
                Map.put(attrs, :catalog_identity, row.catalog_identity),
                season.id
              ),
            else: Player.update_changeset(row, attrs, season.id)

        {operation, state} = operation(row, attrs, cs)

        {Map.put(targets, fact.ref, row.id), [{row, attrs, operation} | ops],
         increment(counts, "player", state)}
      end)

    targets = %{
      {:league, result.facts.league.ref} => league.id,
      {:season, result.facts.season.ref} => season.id
    }

    targets =
      Enum.reduce(team_targets, targets, fn {ref, id}, acc -> Map.put(acc, {:team, ref}, id) end)

    targets =
      Enum.reduce(player_targets, targets, fn {ref, id}, acc ->
        Map.put(acc, {:player, ref}, id)
      end)

    incoming =
      Enum.map(result.provenance.bindings, fn b ->
        id = Map.fetch!(targets, {b.kind, b.ref})
        bound = Map.get(existing, {b.provider, b.kind, b.source_id})
        if bound && target_id(bound) != id, do: conflict(:contradictory_binding)

        if Enum.any?(existing, fn {{p, k, s}, old} ->
             p == b.provider and k == b.kind and s != b.source_id and target_id(old) == id
           end),
           do: conflict(:collapsing_bindings)

        {b, id, bound}
      end)

    unique!(incoming, fn {b, id, _} -> {b.provider, b.kind, id} end)

    %{
      operations: Enum.reverse(team_ops) ++ Enum.reverse(player_ops),
      bindings: incoming,
      counts: counts
    }
  end

  defp fresh_instruction(instructions, binding, rows) do
    case instruction(instructions, binding) do
      nil -> nil
      target -> Enum.find(rows, &(&1.id == target.id)) || conflict(:invalid_target)
    end
  end

  defp instruction(instructions, b) do
    case Map.get(instructions, {b.kind, b.source_id}) do
      {:mapping, target} -> target
      _ -> nil
    end
  end

  defp resolve_bound(b, existing, rows) do
    case Map.get(existing, {b.provider, b.kind, b.source_id}) do
      nil -> nil
      bound -> Enum.find(rows, &(&1.id == target_id(bound))) || conflict(:invalid_target)
    end
  end

  defp adopt_team(teams, fact) do
    matches =
      Enum.filter(
        teams,
        &(normalize(&1.code) == normalize(fact.code) or normalize(&1.name) == normalize(fact.name))
      )

    case matches do
      [] ->
        nil

      [row] ->
        if normalize(row.code) == normalize(fact.code) and
             normalize(row.name) == normalize(fact.name),
           do: row,
           else: conflict(:team_key_conflict)

      _ ->
        conflict(:team_key_conflict)
    end
  end

  defp operation(row, attrs, cs) do
    if not cs.valid?, do: conflict(:invalid_candidate)

    cond do
      row.__meta__.state == :built ->
        {:insert, "created"}

      Enum.all?(attrs, fn {key, value} -> Map.fetch!(row, key) == value end) ->
        {:unchanged, "unchanged"}

      true ->
        {:update, "updated"}
    end
  end

  defp replace_final(rows, ops) do
    ids = Enum.map(ops, fn {r, _, _} -> r.id end)
    Enum.reject(rows, &(&1.id in ids)) ++ Enum.map(ops, fn {r, attrs, _} -> struct(r, attrs) end)
  end

  defp unique!(rows, fun),
    do:
      if(length(rows) != length(Enum.uniq_by(rows, fun)),
        do: conflict(:business_identity_conflict)
      )

  def increment(counts, kind, state), do: update_in(counts, [kind, state], &(&1 + 1))

  def zero_counts,
    do:
      Map.new(
        ~w(league season team player),
        &{&1, %{"created" => 0, "updated" => 0, "unchanged" => 0}}
      )

  def failure(status, scope, reason), do: Outcome.failure(status, scope, reason)
end
