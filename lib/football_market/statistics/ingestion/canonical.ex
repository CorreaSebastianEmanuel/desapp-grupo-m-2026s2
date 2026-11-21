defmodule FootballMarket.Statistics.Ingestion.Canonical do
  @moduledoc """
  Canonicalization, provider identity lookup, and historical substitute position
  derivation for statistics ingestion.
  """

  # --- Provider Identity Lookup ---

  def source_id(result, kind, ref) do
    case Enum.find(result.provenance.bindings, fn b -> b.kind == kind and b.ref == ref end) do
      %{source_id: id} when is_binary(id) -> {:ok, id}
      _ -> {:error, :unbound_identity}
    end
  end

  def fetch_source_id!(result, kind, ref) do
    case source_id(result, kind, ref) do
      {:ok, id} -> id
      {:error, reason} -> raise ArgumentError, Atom.to_string(reason)
    end
  end

  # --- Substitute Position Derivation ---

  @doc "Derives the most frequent prior in-season match position for a substitute appearance."
  def derive_position(subject, committed_history)
      when is_map(subject) and is_list(committed_history) do
    eligible =
      committed_history
      |> Enum.filter(fn prior ->
        prior.player_id == subject.player_id and
          prior.season_id == subject.season_id and
          not is_nil(prior.position_id) and
          DateTime.compare(prior.kickoff_at, subject.kickoff_at) == :lt
      end)
      |> Enum.uniq_by(fn row -> row.match_id end)
      |> Enum.sort_by(fn row -> {row.match_id, row.id} end)

    basis =
      Enum.map(eligible, fn row -> %{performance_id: row.id, position_id: row.position_id} end)

    frequencies = Enum.frequencies_by(eligible, fn row -> row.position_id end)

    case Enum.sort_by(frequencies, fn {position, count} -> {-count, position} end) do
      [] ->
        {:ok, position_result(basis, %{}, nil, :insufficient_history)}

      [{position, count} | rest] ->
        resolve_top_position(basis, frequencies, position, count, rest)
    end
  end

  def derive_position(_, _), do: {:error, :invalid_input}

  defp resolve_top_position(basis, frequencies, position, count, rest) do
    if Enum.any?(rest, fn {_other, other_count} -> other_count == count end),
      do: {:ok, position_result(basis, frequencies, nil, :tie)},
      else: {:ok, position_result(basis, frequencies, position, nil)}
  end

  defp position_result(basis, frequencies, position_id, reason) do
    %{
      basis: basis,
      frequencies: frequencies,
      position_id: position_id,
      reason: reason,
      policy_version: 1
    }
  end

  # --- Semantic Material Encoding ---

  def encode(result, source_identity \\ nil) do
    bindings = Enum.map(result.provenance.bindings, &normalize/1)

    identity =
      Map.new(bindings, fn binding ->
        {{binding["kind"], binding["ref"]}, binding["source_id"]}
      end)

    material = %{
      "version" => 1,
      "scope" => normalize(result.scope),
      "facts" => semantic_facts(result.facts, identity),
      "bindings" =>
        bindings |> Enum.map(&Map.delete(&1, "ref")) |> Enum.sort_by(&Jason.encode!/1),
      "source" => %{
        "provider" => result.provenance.provider,
        "fixture_id" => result.provenance.fixture_id,
        "artifact_digest" => source_identity && source_identity["artifact_digest"],
        "configuration_digest" => source_identity && source_identity["configuration_digest"]
      },
      "completeness" => semantic_completeness(result.completeness, identity)
    }

    encoded = Jason.encode!(material)
    %{material: material, digest: :crypto.hash(:sha256, encoded) |> Base.encode16(case: :lower)}
  end

  def normalize(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def normalize(%Date{} = value), do: Date.to_iso8601(value)
  def normalize(nil), do: nil
  def normalize(value) when is_boolean(value), do: value
  def normalize(%_{} = value), do: value |> Map.from_struct() |> normalize()

  def normalize(value) when is_map(value),
    do: Map.new(value, fn {key, entry} -> {to_string(key), normalize(entry)} end)

  def normalize(value) when is_list(value), do: Enum.map(value, &normalize/1)
  def normalize(value) when is_atom(value), do: Atom.to_string(value)
  def normalize(value), do: value

  # --- Private Helpers ---

  defp semantic_facts(facts, identity) do
    facts = normalize(facts)

    Map.new(facts, fn {section, value} ->
      rows =
        case section do
          "league" ->
            single_fact(value, "league", identity)

          "season" ->
            single_fact(value, "season", identity)

          "teams" ->
            canonical_rows(value, "team", ["season_ref"], identity)

          "positions" ->
            canonical_rows(value, nil, [], identity)

          "players" ->
            canonical_rows(value, "player", ["season_ref", "team_ref", "position_ref"], identity)

          "matches" ->
            canonical_rows(
              value,
              "match",
              ["season_ref", "home_team_ref", "away_team_ref"],
              identity
            )

          "performances" ->
            canonical_rows(
              value,
              nil,
              ["match_ref", "player_ref", "team_ref", "position_ref"],
              identity
            )

          _ ->
            value
        end

      {section, rows}
    end)
  end

  defp canonical_rows(value, kind, references, identity) when is_list(value) do
    value
    |> Enum.map(fn row -> canonical_row(row, kind, references, identity) end)
    |> Enum.sort_by(&Jason.encode!/1)
  end

  defp canonical_rows(value, _kind, _references, _identity), do: value

  defp canonical_row(row, kind, references, identity) do
    row = canonical_source_identity(row, kind, identity)
    Enum.reduce(references, row, fn field, acc -> canonical_reference(field, acc, identity) end)
  end

  defp canonical_source_identity(row, kind, identity) do
    if kind,
      do: row |> Map.put("source_identity", identity[{kind, row["ref"]}]) |> Map.delete("ref"),
      else: Map.delete(row, "ref")
  end

  defp canonical_reference(field, acc, identity) do
    case Map.fetch(acc, field) do
      {:ok, ref} ->
        acc
        |> Map.put(
          String.replace_suffix(field, "_ref", "_identity"),
          identity[{reference_kind(field), ref}] || ref
        )
        |> Map.delete(field)

      :error ->
        acc
    end
  end

  defp single_fact(value, kind, identity) when is_map(value),
    do: value |> Map.put("source_identity", identity[{kind, value["ref"]}]) |> Map.delete("ref")

  defp single_fact(value, _kind, _identity), do: value

  defp semantic_completeness(nil, _identity), do: nil

  defp semantic_completeness(value, identity) do
    value
    |> normalize()
    |> Map.update("eligible_match_identities", [], fn refs ->
      refs |> Enum.map(fn ref -> identity[{"match", ref}] || ref end) |> Enum.sort()
    end)
    |> Map.update("detail_coverage", [], fn refs ->
      refs |> Enum.map(fn ref -> identity[{"match", ref}] || ref end) |> Enum.sort()
    end)
    |> Map.delete("assessment_revision")
    |> Map.delete("assessment_reference")
  end

  defp reference_kind("season_ref"), do: "season"
  defp reference_kind("match_ref"), do: "match"
  defp reference_kind("player_ref"), do: "player"
  defp reference_kind(_), do: "team"
end
