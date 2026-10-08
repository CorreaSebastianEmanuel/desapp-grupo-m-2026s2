defmodule FootballMarket.Catalog.Ingestion.Canonical do
  @moduledoc "Versioned semantic delivery identity, independent of result-local references."
  def encode(result) do
    f = result.facts
    p = result.provenance
    keys = Map.new(p.bindings, &{{&1.kind, &1.ref}, qualified(&1)})
    key = fn kind, ref -> Map.fetch!(keys, {kind, ref}) end
    positions = Map.new(f.positions, &{&1.ref, &1.code})

    material = [
      1,
      "catalog",
      [result.scope.league_code, result.scope.start_year, result.scope.end_year],
      p.provider,
      DateTime.to_iso8601(p.retrieved_at),
      p.fixture_id,
      [key.(:league, f.league.ref), f.league.code, f.league.name],
      [
        key.(:season, f.season.ref),
        key.(:league, f.season.league_ref),
        f.season.start_year,
        f.season.end_year
      ],
      f.teams
      |> Enum.map(&[key.(:team, &1.ref), key.(:season, &1.season_ref), &1.code, &1.name])
      |> Enum.sort(),
      f.positions |> Enum.map(&[&1.code, &1.name]) |> Enum.sort(),
      f.players
      |> Enum.map(
        &[
          key.(:player, &1.ref),
          key.(:season, &1.season_ref),
          &1.display_name,
          key.(:team, &1.team_ref),
          Map.fetch!(positions, &1.position_ref)
        ]
      )
      |> Enum.sort()
    ]

    %{material: %{"v1" => material}, digest: :crypto.hash(:sha256, Jason.encode!(material))}
  end

  defp qualified(b),
    do: [b.provider, Atom.to_string(b.kind), b.league_code, b.start_year, b.end_year, b.source_id]
end
