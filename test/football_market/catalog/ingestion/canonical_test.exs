defmodule FootballMarket.Catalog.Ingestion.CanonicalTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Providers
  alias FootballMarket.Catalog.Ingestion.Canonical

  test "independently encoded resolved facts retain opaque IDs and fixture lineage" do
    assert {:ok, result} =
             Providers.catalog(request(), options() ++ [positions: %{"GK" => "Goalkeeper"}])

    key = fn kind, id -> ["synthetic-a", kind, "PL", 2025, 2026, id] end

    expected = [
      1,
      "catalog",
      ["PL", 2025, 2026],
      "synthetic-a",
      "2026-10-06T12:00:00.000000Z",
      "independent-catalog",
      [key.("league", "league-id"), "PL", "Premier League"],
      [key.("season", "season-id"), key.("league", "league-id"), 2025, 2026],
      [
        [key.("team", "team-A"), key.("season", "season-id"), "ALP", "Alpha"],
        [key.("team", "team-B"), key.("season", "season-id"), "BET", "Beta"]
      ],
      [["GK", "Goalkeeper"]],
      [
        [
          key.("player", "player-A"),
          key.("season", "season-id"),
          "Alex",
          key.("team", "team-A"),
          "GK"
        ]
      ]
    ]

    encoded = Canonical.encode(result)
    assert encoded.material == %{"v1" => expected}
    assert encoded.digest == :crypto.hash(:sha256, Jason.encode!(expected))
  end

  test "collection permutations and reference bijections have identical semantic delivery" do
    assert {:ok, result} =
             Providers.catalog(request(), options() ++ [positions: %{"GK" => "Goalkeeper"}])

    facts = result.facts

    renamed = %{
      result
      | facts: %{facts | teams: Enum.reverse(facts.teams)},
        provenance: %{result.provenance | bindings: Enum.reverse(result.provenance.bindings)}
    }

    assert Canonical.encode(result) == Canonical.encode(renamed)
    changed = %{result | provenance: %{result.provenance | fixture_id: "another"}}
    refute Canonical.encode(result) == Canonical.encode(changed)
  end

  test "evidence changesets reject invalid count shape and digest material" do
    alias FootballMarket.Catalog.Ingestion.Observation

    attrs = %{
      scope_id: Ecto.UUID.generate(),
      revision: 1,
      operation: "catalog",
      provider: "synthetic-a",
      retrieved_at: ~U[2026-10-06 12:00:00.000000Z],
      accepted_at: ~U[2026-10-06 12:00:00.000000Z],
      canonical_version: 1,
      delivery_digest: <<1>>,
      canonical_delivery: %{"raw" => "unsafe"},
      counts: %{"player" => %{"created" => -1}}
    }

    refute Observation.changeset(%Observation{}, attrs).valid?
  end

  test "UTC instants normalize while provider scope source case and fixture attribution remain distinct" do
    assert {:ok, result} =
             Providers.catalog(request(), options() ++ [positions: %{"GK" => "Goalkeeper"}])

    assert {:ok, shifted, _} = DateTime.from_iso8601("2026-10-06T14:00:00.000000+02:00")

    assert Canonical.encode(result) ==
             Canonical.encode(%{
               result
               | provenance: %{result.provenance | retrieved_at: shifted}
             })

    for modified <- [
          %{result | provenance: %{result.provenance | fixture_id: nil}},
          %{result | provenance: %{result.provenance | provider: "synthetic-b"}},
          %{result | scope: %{result.scope | start_year: 2026, end_year: 2027}},
          %{
            result
            | provenance: %{
                result.provenance
                | bindings:
                    Enum.map(
                      result.provenance.bindings,
                      &%{&1 | source_id: String.upcase(&1.source_id)}
                    )
              }
          }
        ],
        do: refute(Canonical.encode(result) == Canonical.encode(modified))
  end
end
