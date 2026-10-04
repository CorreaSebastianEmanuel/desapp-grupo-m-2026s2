defmodule FootballMarket.Statistics.HistoryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Catalog
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  test "exact player histories have inclusive UTC bounds and deterministic ties" do
    f = fixture()
    other = fixture("PL", 2026)

    events = [
      {"before", "2026-01-01T12:00:00.123455Z"},
      {"Zulu", "2026-01-01T12:00:00.123456Z"},
      {"alpha", "2026-01-01T09:00:00.123456-03:00"},
      {"after", "2026-01-01T12:00:00.123457Z"}
    ]

    rows =
      for {identity, instant} <- events do
        {:ok, m} =
          S.record_match(match_attrs(f, %{match_identity: identity, kickoff_at: instant}))

        {:ok, p} = S.record_performance(performance_attrs(f, m, %{goals: 0}))

        {:ok, _} =
          S.record_performance(performance_attrs(f, m, %{player_id: List.last(f.players).id}))

        p
      end

    {:ok, om} = S.record_match(match_attrs(other))
    {:ok, _} = S.record_performance(performance_attrs(other, om))
    [before, zulu, alpha, after_row] = rows
    player = hd(f.players)
    assert {:ok, history} = S.list_player_history(player.id)
    assert Enum.map(history, & &1.id) == Enum.map([before, alpha, zulu, after_row], & &1.id)

    assert Enum.all?(
             history,
             &(&1.player_id == player.id and &1.goals == 0 and &1.assists == nil)
           )

    assert Enum.map(history, & &1.match.match_identity) == ["before", "alpha", "Zulu", "after"]
    bound = "2026-01-01T12:00:00.123456Z"

    for {opts, expected} <- [
          {[from: bound], [alpha, zulu, after_row]},
          {[to: bound], [before, alpha, zulu]},
          {[from: bound, to: bound], [alpha, zulu]},
          {[from: nil, to: nil], [before, alpha, zulu, after_row]},
          {[from: "2026-01-01T09:00:00.123456-03:00", to: bound], [alpha, zulu]},
          {[from: "2026-01-02T00:00:00Z"], []},
          {[to: "2025-12-01T00:00:00Z"], []}
        ] do
      assert {:ok, results} = S.list_player_history(player.id, opts)
      assert Enum.map(results, & &1.id) == Enum.map(expected, & &1.id)
    end

    assert {:error, %{reason: :invalid_interval}} =
             S.list_player_history(player.id, from: "2026-02-01T00:00:00Z", to: bound)

    for opts <- [
          [from: "invalid"],
          [to: "2026-01-01T12:00:00.1234567Z"],
          [unsupported: 1],
          "bad",
          [1]
        ],
        do: assert(match?({:error, _}, S.list_player_history(player.id, opts)))

    assert {:ok, ^history} = S.list_player_history(player.id)
  end

  test "historical affiliation survives transfer and accepts later different team and position" do
    f = fixture()
    player = hd(f.players)
    {:ok, old_match} = S.record_match(match_attrs(f))
    {:ok, old} = S.record_performance(performance_attrs(f, old_match))
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    assert {:ok, _} =
             Catalog.update_player(player, %{team_id: f.away.id, position_id: position.id})

    assert {:ok, old_read} = S.get_performance(player.id, old_match.id)
    assert old_read == old
    {:ok, new_match} = S.record_match(match_attrs(f, %{kickoff_at: "2026-01-02T00:00:00Z"}))

    {:ok, new} =
      S.record_performance(
        performance_attrs(f, new_match, %{team_id: f.away.id, position_id: position.id})
      )

    assert {:ok, [h1, h2]} = S.list_player_history(player.id)
    assert h1.team_id == f.home.id and h1.position_id == f.position.id
    assert h2.id == new.id and h2.team_id == f.away.id and h2.position_id == position.id
    # No provider configured or involved: repeated local reads are identical.
    assert S.list_player_history(player.id) == {:ok, [h1, h2]}
  end

  test "empty absent unknown and malformed subjects stay distinct" do
    f = fixture()
    player = hd(f.players)
    {:ok, m} = S.record_match(match_attrs(f))
    assert {:ok, []} = S.list_player_history(player.id)
    assert {:error, :absent_performance} = S.get_performance(player.id, m.id)
    unknown = Ecto.UUID.generate()
    assert {:error, :not_found} = S.list_player_history(unknown)
    assert {:error, :not_found} = S.get_performance(unknown, m.id)
    assert {:error, %{field: :match_id}} = S.get_performance(unknown, "bad")
    assert {:error, :not_found} = S.get_performance(player.id, unknown)
    assert {:error, :not_found} = S.get_match(unknown)
    assert {:error, :not_found} = S.get_match(unknown, "event")

    for id <- [nil, "", "bad", 1] do
      assert {:error, %{reason: :invalid_identifier}} = S.list_player_history(id)
      assert {:error, %{reason: :invalid_identifier}} = S.get_match(id)
      assert {:error, %{reason: :invalid_identifier}} = S.get_performance(id, m.id)
      assert {:error, %{reason: :invalid_identifier}} = S.get_performance(player.id, id)
    end

    assert {:error, _} = S.get_match(f.season.id, "\t ")
  end
end
