defmodule FootballMarket.Catalog.PlayerPaginationTest do
  use FootballMarket.DataCase, async: false

  import FootballMarket.CatalogCase
  alias FootballMarket.Catalog

  test "single filters select matching rows before page bounding" do
    fixture = FootballMarket.CatalogFilterCase.build!()
    target = fixture.target

    for filters <- [
          %{league_id: target.team.season.league.id},
          %{team_id: target.team.id},
          %{position_id: target.position.id}
        ] do
      {:ok, page} = Catalog.list_player_page(%{page_size: 100, cursor: nil, filters: filters})

      assert Enum.map(page.players, & &1.id) ==
               FootballMarket.CatalogFilterCase.expected(fixture.players, filters)
               |> Enum.take(100)
    end
  end

  test "filtered traversal is bounded, replayable, and independent of page size" do
    fixture = FootballMarket.CatalogFilterCase.build!()
    filters = %{team_id: fixture.target.team.id, position_id: fixture.target.position.id}
    expected = FootballMarket.CatalogFilterCase.expected(fixture.players, filters)
    assert length(expected) > 100
    {:ok, first} = Catalog.list_player_page(%{page_size: 50, cursor: nil, filters: filters})
    assert length(first.players) == 50
    cursor = first.pagination.next_cursor

    assert Catalog.list_player_page(%{page_size: 50, cursor: cursor, filters: filters}) ==
             Catalog.list_player_page(%{page_size: 50, cursor: cursor, filters: filters})

    assert {:ok, %{players: [_]}} =
             Catalog.list_player_page(%{page_size: 1, cursor: cursor, filters: filters})

    ids = traverse_filtered(filters, cursor, Enum.map(first.players, & &1.id))
    assert ids == expected
    assert Enum.uniq(ids) == ids

    assert {:error, :invalid_cursor} =
             Catalog.list_player_page(%{page_size: 50, cursor: cursor, filters: %{}})

    last = List.last(expected)
    last_player = Enum.find(fixture.players, &(&1.id == last))

    after_final =
      FootballMarket.Catalog.PlayerCursor.encode(
        %{name: String.downcase(String.trim(last_player.display_name)), id: last},
        filters
      )

    assert {:ok, %{players: [], pagination: %{has_more: false, next_cursor: nil}}} =
             Catalog.list_player_page(%{page_size: 50, cursor: after_final, filters: filters})
  end

  test "an exact filtered final page has no continuation" do
    %{team: team} = insert_catalog!(["Alpha", "Beta"])

    assert {:ok, %{players: [_, _], pagination: %{has_more: false, next_cursor: nil}}} =
             Catalog.list_player_page(%{page_size: 2, cursor: nil, filters: %{team_id: team.id}})
  end

  test "filtered continuation retains non-snapshot mutation behavior" do
    %{team: team, position: position, players: [alpha, middle, omega]} =
      insert_catalog!(["Alpha", "Middle", "Omega"])

    filters = %{team_id: team.id}
    {:ok, first} = Catalog.list_player_page(%{page_size: 2, cursor: nil, filters: filters})
    FootballMarket.Repo.delete!(middle)

    {:ok, before} =
      Catalog.create_player(player_attrs(team, position, %{display_name: "Aardvark"}))

    {:ok, after_anchor} =
      Catalog.create_player(player_attrs(team, position, %{display_name: "Zulu"}))

    {:ok, continuation} =
      Catalog.list_player_page(%{
        page_size: 10,
        cursor: first.pagination.next_cursor,
        filters: filters
      })

    assert Enum.map(continuation.players, & &1.id) == [omega.id, after_anchor.id]
    refute Enum.any?(continuation.players, &(&1.id in [alpha.id, before.id]))
  end

  defp traverse_filtered(filters, cursor, ids) do
    {:ok, page} = Catalog.list_player_page(%{page_size: 50, cursor: cursor, filters: filters})
    ids = ids ++ Enum.map(page.players, & &1.id)

    if page.pagination.next_cursor,
      do: traverse_filtered(filters, page.pagination.next_cursor, ids),
      else: ids
  end

  test "orders normalized names with id tie-breaking and traverses exactly once" do
    %{players: inserted} = insert_catalog!([" beta ", "ALPHA", "alpha", "Gamma"])

    {:ok, first} = Catalog.list_player_page(%{page_size: 2, cursor: nil})

    assert Enum.map(first.players, &String.downcase(String.trim(&1.display_name))) == [
             "alpha",
             "alpha"
           ]

    assert first.pagination == %{
             page_size: 2,
             returned_count: 2,
             has_more: true,
             next_cursor: first.pagination.next_cursor
           }

    {:ok, second} =
      Catalog.list_player_page(%{page_size: 100, cursor: first.pagination.next_cursor})

    assert Enum.map(second.players, &String.downcase(String.trim(&1.display_name))) == [
             "beta",
             "gamma"
           ]

    refute second.pagination.has_more
    assert second.pagination.next_cursor == nil

    assert MapSet.new(first.players ++ second.players, & &1.id) == MapSet.new(inserted, & &1.id)
  end

  test "replay and page-size changes resume after the same anchor" do
    insert_players!(5)
    {:ok, first} = Catalog.list_player_page(%{page_size: 2, cursor: nil})
    cursor = first.pagination.next_cursor

    assert Catalog.list_player_page(%{page_size: 2, cursor: cursor}) ==
             Catalog.list_player_page(%{page_size: 2, cursor: cursor})

    assert {:ok, %{players: [_]}} = Catalog.list_player_page(%{page_size: 1, cursor: cursor})
  end

  test "supports empty catalogs and invalid cursor rejection" do
    assert {:ok,
            %{players: [], pagination: %{returned_count: 0, has_more: false, next_cursor: nil}}} =
             Catalog.list_player_page(%{page_size: 25, cursor: nil})

    assert {:error, :invalid_cursor} = Catalog.list_player_page(%{page_size: 25, cursor: "bad"})
  end

  test "reports exact boundaries and supports a cursor positioned after the final row" do
    insert_players!(2)
    {:ok, exact} = Catalog.list_player_page(%{page_size: 2, cursor: nil})

    assert exact.pagination == %{
             page_size: 2,
             returned_count: 2,
             has_more: false,
             next_cursor: nil
           }

    {:ok, first} = Catalog.list_player_page(%{page_size: 1, cursor: nil})
    {:ok, final} = Catalog.list_player_page(%{page_size: 1, cursor: first.pagination.next_cursor})
    anchor = hd(final.players)

    after_final =
      FootballMarket.Catalog.PlayerCursor.encode(%{
        name: String.downcase(String.trim(anchor.display_name)),
        id: anchor.id
      })

    assert {:ok,
            %{players: [], pagination: %{returned_count: 0, has_more: false, next_cursor: nil}}} =
             Catalog.list_player_page(%{page_size: 25, cursor: after_final})
  end

  test "continuation survives anchor deletion and observes insertions only after its tuple" do
    %{players: [alpha, middle, omega], team: team, position: position} =
      insert_catalog!(["Alpha", "Middle", "Omega"])

    {:ok, first} = Catalog.list_player_page(%{page_size: 2, cursor: nil})
    cursor = first.pagination.next_cursor
    FootballMarket.Repo.delete!(middle)

    {:ok, before} =
      Catalog.create_player(player_attrs(team, position, %{display_name: "Aardvark"}))

    {:ok, after_anchor} =
      Catalog.create_player(player_attrs(team, position, %{display_name: "Zulu"}))

    {:ok, continuation} = Catalog.list_player_page(%{page_size: 10, cursor: cursor})

    assert Enum.map(continuation.players, & &1.id) == [omega.id, after_anchor.id]
    refute Enum.any?(continuation.players, &(&1.id in [alpha.id, before.id]))
  end

  test "preloads the authoritative hierarchy on every page row" do
    %{league: league, season: season, team: team, position: position} = insert_catalog!()
    {:ok, %{players: [player]}} = Catalog.list_player_page(%{page_size: 100, cursor: nil})

    assert player.position.id == position.id
    assert player.team.id == team.id
    assert player.team.season.id == season.id
    assert player.team.season.league.id == league.id
  end
end
