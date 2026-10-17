defmodule FootballMarket.Statistics.Ingestion.Canonical do
  @moduledoc "Stable semantic source material for replay and conflict detection."

  def encode(result, source_identity \\ nil) do
    bindings = result.provenance.bindings |> Enum.map(&normalize/1)

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

  defp semantic_facts(facts, identity) do
    facts = normalize(facts)

    Map.new(facts, fn {section, value} ->
      rows =
        case section do
          "league" ->
            single(value, "league", identity)

          "season" ->
            single(value, "season", identity)

          "teams" ->
            rows(value, "team", ["season_ref"], identity)

          "positions" ->
            rows(value, nil, [], identity)

          "players" ->
            rows(value, "player", ["season_ref", "team_ref", "position_ref"], identity)

          "matches" ->
            rows(value, "match", ["season_ref", "home_team_ref", "away_team_ref"], identity)

          "performances" ->
            rows(value, nil, ["match_ref", "player_ref", "team_ref", "position_ref"], identity)

          _ ->
            value
        end

      {section, rows}
    end)
  end

  defp rows(value, kind, references, identity) when is_list(value) do
    value
    |> Enum.map(fn row ->
      row =
        if kind,
          do:
            row |> Map.put("source_identity", identity[{kind, row["ref"]}]) |> Map.delete("ref"),
          else: Map.delete(row, "ref")

      Enum.reduce(references, row, fn field, acc ->
        case Map.fetch(acc, field) do
          {:ok, ref} ->
            Map.put(
              acc,
              String.replace_suffix(field, "_ref", "_identity"),
              identity[{reference_kind(field), ref}] || ref
            )
            |> Map.delete(field)

          :error ->
            acc
        end
      end)
    end)
    |> Enum.sort_by(&Jason.encode!/1)
  end

  defp rows(value, _kind, _references, _identity), do: value

  defp single(value, kind, identity) when is_map(value),
    do: value |> Map.put("source_identity", identity[{kind, value["ref"]}]) |> Map.delete("ref")

  defp single(value, _kind, _identity), do: value

  defp semantic_completeness(nil, _identity), do: nil

  defp semantic_completeness(value, identity) do
    value = normalize(value)

    value
    |> Map.update(
      "eligible_match_identities",
      [],
      &(Enum.map(&1, fn ref -> identity[{"match", ref}] || ref end) |> Enum.sort())
    )
    |> Map.update(
      "detail_coverage",
      [],
      &(Enum.map(&1, fn ref -> identity[{"match", ref}] || ref end) |> Enum.sort())
    )
    |> Map.delete("assessment_revision")
    |> Map.delete("assessment_reference")
  end

  defp reference_kind("season_ref"), do: "season"
  defp reference_kind("match_ref"), do: "match"
  defp reference_kind("player_ref"), do: "player"
  defp reference_kind(_), do: "team"

  def normalize(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def normalize(%Date{} = value), do: Date.to_iso8601(value)
  def normalize(nil), do: nil
  def normalize(value) when is_boolean(value), do: value
  def normalize(%_{} = value), do: value |> Map.from_struct() |> normalize()

  def normalize(value) when is_map(value),
    do: value |> Enum.map(fn {k, v} -> {to_string(k), normalize(v)} end) |> Map.new()

  def normalize(value) when is_list(value), do: Enum.map(value, &normalize/1)
  def normalize(value) when is_atom(value), do: Atom.to_string(value)
  def normalize(value), do: value
end
