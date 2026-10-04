defmodule FootballMarket.Statistics.QAAdversarialTest do
  use FootballMarket.DataCase, async: false
  import FootballMarket.StatisticsCase
  alias FootballMarket.Statistics, as: S
  @moduletag :integration

  test "Unicode surrounding whitespace cannot establish a second identity" do
    f = fixture()
    {:ok, original} = S.record_match(match_attrs(f, %{match_identity: "event"}))
    for space <- ["\u00A0", "\u2003", "\u202F"] do
      assert {:error, %{kind: :conflict, field: :match_identity}} =
        S.record_match(match_attrs(f, %{match_identity: space <> "EVENT" <> space}))
      assert {:ok, ^original} = S.get_match(f.season.id, space <> "event" <> space)
    end
  end

  test "all count invalid boundaries reject at public writes and leave history empty" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    for field <- [:minutes_played | metrics()], value <- [-1, 1.5, 1.0, "1", true, false] do
      assert {:error, %{field: ^field, kind: :validation}} = S.record_performance(performance_attrs(f, m, %{field => value}))
      assert {:ok, []} = S.list_player_history(hd(f.players).id)
    end
  end

  test "changed historical facts reject direct SQL and preserve original" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    {:ok, p} = S.record_performance(performance_attrs(f, m, %{goals: 0}))
    {:ok, mid} = Ecto.UUID.dump(m.id)
    {:ok, pid} = Ecto.UUID.dump(p.id)
    for {sql, id} <- [
      {"UPDATE matches SET match_identity = 'changed', kickoff_at = kickoff_at + interval '1 day' WHERE id = $1", mid},
      {"UPDATE player_match_performances SET goals = 7 WHERE id = $1", pid}
    ] do
      assert_raise Postgrex.Error, fn -> Ecto.Adapters.SQL.query!(Repo, sql, [id], mode: :savepoint) end
    end
    assert {:ok, ^m} = S.get_match(m.id)
    assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
  end
end
