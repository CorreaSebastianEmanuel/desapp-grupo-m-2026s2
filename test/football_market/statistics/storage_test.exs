defmodule FootballMarket.Statistics.StorageTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  test "malformed original identity returns field-safe write and scoped read errors" do
    f = fixture()
    {:ok, original} = S.record_match(match_attrs(f, %{match_identity: "比赛-é⚽"}))

    for identity <- [
          <<0>> <> "event",
          "ev" <> <<0>> <> "ent",
          "event" <> <<0>>,
          <<255>>,
          <<195, 40>>
        ] do
      assert {:error, %{kind: :validation, field: :match_identity, reason: :invalid_identity}} =
               S.record_match(match_attrs(f, %{match_identity: identity}))

      assert {:error, %{kind: :validation, field: :match_identity, reason: :invalid_identity}} =
               S.get_match(f.season.id, identity)

      assert {:ok, ^original} = S.get_match(original.id)
    end

    assert {:ok, ^original} = S.get_match(f.season.id, " 比赛-é⚽ ")
  end

  test "all leagues and two seasons retain every independent fact" do
    for code <- ["PL", "BL1", "PD", "SA", "FL1"], year <- [2025, 2026] do
      f = fixture(code, year)
      {:ok, m} = S.record_match(match_attrs(f, %{match_identity: "  Event\t\n"}))
      assert {:ok, ^m} = S.get_match(m.id)
      assert {:ok, ^m} = S.get_match(f.season.id, "\nEVENT\t")
      assert m.match_identity == "Event"
      assert m.kickoff_at == ~U[2026-01-01 12:00:00.123456Z]
      assert m.home_team_id == f.home.id
      assert m.away_team_id == f.away.id

      for {player, minutes} <- Enum.zip(f.players, [0, 123]) do
        values = Map.new(metrics(), &{&1, 7}) |> Map.put(:goals, 0) |> Map.put(:assists, nil)

        {:ok, p} =
          S.record_performance(
            performance_attrs(
              f,
              m,
              Map.merge(values, %{player_id: player.id, minutes_played: minutes})
            )
          )

        assert {:ok, ^p} = S.get_performance(player.id, m.id)
        for {key, value} <- values, do: assert(Map.fetch!(p, key) == value)
        assert p.minutes_played == minutes
        assert p.team_id == f.home.id
        assert p.position_id == f.position.id
      end

      {:ok, empty} = S.record_match(match_attrs(f))
      assert {:error, :absent_performance} = S.get_performance(hd(f.players).id, empty.id)
      {:ok, ninety} = S.record_performance(performance_attrs(f, empty, %{minutes_played: 90}))
      assert ninety.goals == nil
    end
  end

  test "each metric retains zero positive omitted and explicit unknown through independent reads" do
    f = fixture()

    for field <- metrics(), value <- [0, 7, nil, :omitted] do
      {:ok, m} = S.record_match(match_attrs(f))
      overrides = if value == :omitted, do: %{}, else: %{field => value}
      {:ok, p} = S.record_performance(performance_attrs(f, m, overrides))
      assert {:ok, read} = S.get_performance(p.player_id, m.id)
      assert Map.fetch!(read, field) == if(value == :omitted, do: nil, else: value)
      for other <- metrics() -- [field], do: assert(Map.fetch!(read, other) == nil)
    end
  end
end
