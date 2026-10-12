defmodule FootballMarket.Catalog.Ingestion.IdentityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog
  alias FootballMarket.Catalog.Ingestion.SourceBinding
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Catalog.Ingestion

  setup do
    positions!()
    :ok
  end

  test "same-name players remain distinct and a transfer retains both identities" do
    c = candidate()
    second = %{hd(c.facts.players) | ref: "player-b"}

    c = %{
      c
      | facts: %{c.facts | players: [hd(c.facts.players), second]},
        bindings: c.bindings ++ [%{kind: :player, ref: "player-b", source_id: "player-B"}]
    }

    assert {:ok, _} = Ingestion.import_catalog(request(), options(c))
    original = Repo.all(from p in Player, order_by: p.catalog_identity)
    assert length(original) == 2

    update = %{
      c
      | facts: %{
          c.facts
          | players:
              Enum.map(c.facts.players, &%{&1 | team_ref: "team-b", display_name: "Alex Updated"})
        }
    }

    assert {:ok, outcome} =
             Ingestion.import_catalog(request(), options(update, ~U[2026-10-07 12:00:00.000000Z]))

    assert outcome.counts["player"]["updated"] == 2
    after_rows = Repo.all(from p in Player, order_by: p.catalog_identity)

    assert Enum.map(original, &{&1.id, &1.catalog_identity}) ==
             Enum.map(after_rows, &{&1.id, &1.catalog_identity})

    assert Enum.all?(after_rows, &(&1.display_name == "Alex Updated"))
    assert length(Enum.uniq(Enum.map(after_rows, & &1.team_id))) == 1
  end

  test "a name collision with an unbound legacy player blocks the whole delivery" do
    {:ok, l} = Catalog.create_league(%{code: "PL", name: "Premier League"})
    {:ok, s} = Catalog.create_season(%{league_id: l.id, start_year: 2025, end_year: 2026})
    {:ok, t} = Catalog.create_team(%{season_id: s.id, code: "ALP", name: "Alpha"})
    position = Repo.get_by!(FootballMarket.Catalog.Position, code: "GK")

    {:ok, _} =
      Catalog.create_player(%{
        team_id: t.id,
        position_id: position.id,
        catalog_identity: "legacy",
        display_name: "Alex"
      })

    before = snapshot()
    assert {:error, o} = Ingestion.import_catalog(request(), options())
    assert o.status == :reconciliation_conflict
    assert snapshot() == before
  end

  test "bound teams may exchange both keys atomically but retained collisions fail" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    c = candidate()
    [a, b] = c.facts.teams

    swapped = %{
      c
      | facts: %{
          c.facts
          | teams: [%{a | name: b.name, code: b.code}, %{b | name: a.name, code: a.code}]
        }
    }

    assert {:ok, _} =
             Ingestion.import_catalog(
               request(),
               options(swapped, ~U[2026-10-07 12:00:00.000000Z])
             )

    before = snapshot()

    collision = %{
      c
      | facts: %{c.facts | teams: [%{a | code: "ALP", name: "Other"}], players: []},
        bindings: Enum.reject(c.bindings, &(&1.kind == :player or &1.ref == "team-b"))
    }

    assert {:error, o} =
             Ingestion.import_catalog(
               request(),
               options(collision, ~U[2026-10-08 12:00:00.000000Z])
             )

    assert o.status == :reconciliation_conflict
    assert snapshot() == before
  end

  test "replacement requires trusted mapping and appends bindings without changing IDs" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    [original] = Repo.all(Player)

    replacement =
      Keyword.put(options(), :provider, {FootballMarket.IngestionReplacementAdapter, candidate()})

    before = {snapshot(), acceptance_snapshot()}

    assert {:error, conflict} =
             Ingestion.import_catalog(
               request(),
               Keyword.put(
                 replacement,
                 :runtime,
                 {FootballMarket.IngestionFixtureRuntime,
                  %{instant: ~U[2026-10-07 12:00:00.000000Z]}}
               )
             )

    assert conflict.status == :reconciliation_conflict
    assert {snapshot(), acceptance_snapshot()} == before

    mapped =
      replacement
      |> Keyword.put(
        :runtime,
        {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-07 12:00:00.000000Z]}}
      )
      |> Keyword.put(:mappings, [mapping(:player, "player-A", original.id, "synthetic-b")])

    assert {:ok, o} = Ingestion.import_catalog(request(), mapped)
    assert o.status == :accepted_unchanged
    assert Repo.get!(Player, original.id).catalog_identity == original.catalog_identity
    assert Repo.aggregate(SourceBinding, :count) == 10
    assert {:ok, replay} = Ingestion.import_catalog(request(), Keyword.delete(mapped, :mappings))
    assert replay.status == :replay
  end

  test "duplicate extra cross-season and contradictory instructions cannot hide behind replay" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    [player] = Repo.all(Player)

    assert {:ok, _} =
             Ingestion.import_catalog(request("PL", 2026), options(candidate("PL", 2026)))

    foreign = Repo.one!(from p in Player, where: p.id != ^player.id)
    good = mapping(:player, "player-A", player.id)

    for mappings <- [
          [good, good],
          [mapping(:player, "absent", player.id)],
          [mapping(:player, "player-A", foreign.id)],
          [%{good | provider: "wrong"}],
          [%{good | kind: :team}]
        ] do
      before = {snapshot(), acceptance_snapshot()}
      assert {:error, o} = Ingestion.import_catalog(request(), options() ++ [mappings: mappings])
      assert o.status == :reconciliation_conflict
      assert {snapshot(), acceptance_snapshot()} == before
    end
  end

  test "explicit correspondence can adopt an unbound legacy identity before the first observation" do
    {:ok, l} = Catalog.create_league(%{code: "PL", name: "Premier League"})
    {:ok, s} = Catalog.create_season(%{league_id: l.id, start_year: 2025, end_year: 2026})
    {:ok, t} = Catalog.create_team(%{season_id: s.id, code: "ALP", name: "Alpha"})
    position = Repo.get_by!(FootballMarket.Catalog.Position, code: "GK")

    {:ok, original} =
      Catalog.create_player(%{
        team_id: t.id,
        position_id: position.id,
        catalog_identity: "legacy",
        display_name: "Alex"
      })

    assert {:ok, _} =
             Ingestion.import_catalog(
               request(),
               options() ++ [mappings: [mapping(:player, "player-A", original.id)]]
             )

    assert Repo.get!(Player, original.id).catalog_identity == "legacy"
    assert Repo.aggregate(Player, :count) == 1
  end

  test "trusted new declarations permit replacement additions but cannot guess unbound legacy identity" do
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    [old] = Repo.all(Player)
    c = candidate()

    next = %{
      c
      | facts: %{c.facts | players: [%{hd(c.facts.players) | display_name: "New Person"}]}
    }

    declaration = mapping(:player, "player-A", old.id, "synthetic-b") |> Map.delete(:target_id)

    opts =
      options(next, ~U[2026-10-07 12:00:00.000000Z])
      |> Keyword.put(:provider, {FootballMarket.IngestionReplacementAdapter, next})
      |> Keyword.put(:new_players, [declaration])

    assert {:ok, _} = Ingestion.import_catalog(request(), opts)
    assert Repo.aggregate(Player, :count) == 2

    {:ok, legacy} =
      Catalog.create_player(%{
        team_id: old.team_id,
        position_id: old.position_id,
        catalog_identity: "unbound",
        display_name: "Legacy"
      })

    third = %{
      next
      | facts: %{
          next.facts
          | players: [%{hd(next.facts.players) | display_name: "Legacy", ref: "new-ref"}]
        },
        bindings:
          Enum.map(next.bindings, fn b ->
            if b.kind == :player, do: %{b | ref: "new-ref", source_id: "new-player"}, else: b
          end)
    }

    declaration = mapping(:player, "new-player", legacy.id) |> Map.delete(:target_id)
    before = {snapshot(), acceptance_snapshot()}

    assert {:error, o} =
             Ingestion.import_catalog(
               request(),
               options(third, ~U[2026-10-08 12:00:00.000000Z]) ++ [new_players: [declaration]]
             )

    assert o.status == :reconciliation_conflict
    assert {snapshot(), acceptance_snapshot()} == before
  end

  test "bound rename transfer position change and same-name addition are independent of row order" do
    {:ok, _} = Catalog.create_position(%{code: "FW", name: "Forward"})

    for {reverse, year} <- [{false, 2025}, {true, 2026}] do
      c = candidate("PL", year)
      assert {:ok, _} = Ingestion.import_catalog(request("PL", year), options(c))

      old =
        Repo.get_by!(Player,
          display_name: "Alex",
          season_id:
            Repo.get_by!(FootballMarket.Catalog.Ingestion.Scope, start_year: year).season_id
        )

      changed = %{
        hd(c.facts.players)
        | team_ref: "team-b",
          position_ref: "FW",
          display_name: "Renamed"
      }

      new = %{hd(c.facts.players) | ref: "player-b"}
      rows = if reverse, do: [new, changed], else: [changed, new]

      update = %{
        c
        | facts: %{
            c.facts
            | players: rows,
              positions: c.facts.positions ++ [%{ref: "FW", code: "FW", name: "Forward"}]
          },
          bindings: c.bindings ++ [%{kind: :player, ref: "player-b", source_id: "player-B"}]
      }

      assert {:ok, outcome} =
               Ingestion.import_catalog(
                 request("PL", year),
                 options(update, ~U[2026-10-07 12:00:00.000000Z])
               )

      assert outcome.counts["player"] == %{"created" => 1, "updated" => 1, "unchanged" => 0}
      assert {:ok, moved} = Catalog.get_player_detail(old.id)
      assert moved.catalog_identity == old.catalog_identity
      assert moved.team.code == "BET"
      assert moved.position.code == "FW"
      assert moved.display_name == "Renamed"
      new_local = Repo.get_by!(Player, season_id: old.season_id, display_name: "Alex")
      assert new_local.id != old.id
      refute new_local.catalog_identity in ["player-A", "player-B"]
    end
  end
end
