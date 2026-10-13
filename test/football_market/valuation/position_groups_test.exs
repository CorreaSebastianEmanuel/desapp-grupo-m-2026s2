defmodule FootballMarket.Valuation.PositionGroupsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog}

  test "mixed historical groups, explicit CB/fullback mapping and current-position independence" do
    f = fixture()
    {:ok, mid} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    {:ok, fb} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    record(f, "defender", %{tackles: 2, minutes_played: 0})
    record(f, "midfielder", %{tackles: 1, position_id: mid.id, minutes_played: 123})
    record(f, "fullback", %{tackles: 0, position_id: fb.id})

    req =
      request(f, %{
        requirements: %{overall: [:tackles], defender: [:tackles], midfielder: [:tackles]},
        references: %{tackles: 4},
        position_mapping: [{f.position.id, :defender}, {mid.id, :midfielder}, {fb.id, :defender}]
      })

    assert {:ok, p} = Valuation.prepare(req)
    assert p.scopes.overall.features.tackles == "0.750000"
    assert p.scopes.defender.features.tackles == "0.500000"
    assert p.scopes.midfielder.features.tackles == "0.250000"
    refute Map.has_key?(p.scopes, :goalkeeper)
    assert Enum.map(p.facts, & &1.group) == [:defender, :defender, :midfielder]
    {:ok, _} = Catalog.update_player(hd(f.players), %{position_id: mid.id})
    assert {:ok, ^p} = Valuation.prepare(req)

    assert {:error, %{reason: :no_applicable_required_scope}} =
             Valuation.prepare(%{
               req
               | requirements: %{goalkeeper: [:saves]},
                 references: %{saves: 4}
             })

    assert {:ok, mixed} =
             Valuation.prepare(%{
               req
               | requirements: %{defender: [:tackles], goalkeeper: [:saves]},
                 references: %{tackles: 4, saves: 4}
             })

    assert mixed.scopes.defender.features.tackles == "0.500000"
    assert mixed.scopes.midfielder.features == %{}
    refute Map.has_key?(mixed.scopes, :goalkeeper)
  end

  test "group-specific missing metrics, all four groups and independent caps" do
    f = fixture()

    positions =
      for group <- [:goalkeeper, :midfielder, :forward],
          into: %{defender: f.position},
          do:
            {group, elem(Catalog.create_position(FootballMarket.CatalogCase.position_attrs()), 1)}

    for {group, position} <- positions do
      attrs = if group == :goalkeeper, do: %{saves: 8}, else: %{tackles: 8}
      record(f, Atom.to_string(group), Map.put(attrs, :position_id, position.id))
    end

    mapping = Enum.map(positions, fn {g, p} -> {p.id, g} end)

    req =
      request(f, %{
        position_mapping: mapping,
        requirements: %{
          goalkeeper: [:saves],
          defender: [:tackles],
          midfielder: [:tackles],
          forward: [:tackles]
        },
        references: %{saves: 4, tackles: 4}
      })

    assert {:ok, p} = Valuation.prepare(req)
    assert map_size(p.scopes) == 5
    assert p.scopes.goalkeeper.features.saves == "1.000000"

    for g <- [:defender, :midfielder, :forward],
        do: assert(p.scopes[g].features.tackles == "1.000000")

    assert {:error, %{details: details}} =
             Valuation.prepare(%{
               req
               | requirements: Map.put(req.requirements, :overall, [:saves])
             })

    assert length(details) == 3
    assert Enum.all?(details, &(&1.metric == :saves and &1.scope == :overall))

    assert {:error, %{kind: :validation}} =
             Valuation.prepare(%{req | position_mapping: mapping ++ [hd(mapping)]})

    assert {:error, %{kind: :validation}} =
             Valuation.prepare(%{req | position_mapping: [{f.position.id, :unknown}]})

    unused = Ecto.UUID.generate()

    assert {:ok, _} =
             Valuation.prepare(%{req | position_mapping: [{unused, :defender} | mapping]})
  end
end
