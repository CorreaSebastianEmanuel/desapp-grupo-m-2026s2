defmodule FootballMarket.QARoundThree do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  test "original malformed instants are validation failures on writes and history bounds" do
    f = fixture()

    for instant <- [<<255>>, <<195, 40>>, "2026-01-01T00:00:00Z" <> <<0>>, true, %{}] do
      assert {:error, %{kind: :validation, field: :kickoff_at}} =
               S.record_match(match_attrs(f, %{kickoff_at: instant}))

      assert {:error, %{kind: :validation, field: :from}} =
               S.list_player_history(hd(f.players).id, from: instant)
    end

    assert Repo.aggregate(FootballMarket.Statistics.Match, :count) == 0
  end

  test "every metric rejects all invalid values through persistence and leaves accepted facts unchanged" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    {:ok, original} = S.record_performance(performance_attrs(f, m, %{goals: 0}))
    second = List.last(f.players)

    for field <- [:minutes_played | metrics()], value <- [-1, 0.5, 1.0, "1", true, false] do
      assert {:error, %{field: ^field, reason: :invalid_count}} =
               S.record_performance(
                 performance_attrs(f, m, %{field => value, :player_id => second.id})
               )

      assert {:error, :absent_performance} = S.get_performance(second.id, m.id)
      assert {:ok, ^original} = S.get_performance(original.player_id, m.id)
    end

    for field <- metrics() do
      {:ok, event} = S.record_match(match_attrs(f))
      huge = Integer.pow(10, 70)
      {:ok, row} = S.record_performance(performance_attrs(f, event, %{field => huge}))
      assert {:ok, read} = S.get_performance(row.player_id, event.id)
      assert Map.fetch!(read, field) == huge
    end
  end

  test "historical changes to every business field are rejected by SQL without changing reads" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    {:ok, p} = S.record_performance(performance_attrs(f, m))
    {:ok, mid} = Ecto.UUID.dump(m.id)
    {:ok, pid} = Ecto.UUID.dump(p.id)

    for assignment <- [
          "match_identity = 'altered'",
          "kickoff_at = kickoff_at + interval '1 microsecond'",
          "home_team_id = away_team_id",
          "season_id = gen_random_uuid()"
        ] do
      assert_raise Postgrex.Error, fn ->
        Ecto.Adapters.SQL.query!(Repo, "UPDATE matches SET #{assignment} WHERE id = $1", [mid],
          mode: :savepoint
        )
      end
    end

    for assignment <- [
          "goals = 1",
          "minutes_played = 0",
          "player_id = gen_random_uuid()",
          "team_id = gen_random_uuid()",
          "position_id = gen_random_uuid()",
          "match_id = gen_random_uuid()"
        ] do
      assert_raise Postgrex.Error, fn ->
        Ecto.Adapters.SQL.query!(
          Repo,
          "UPDATE player_match_performances SET #{assignment} WHERE id = $1",
          [pid], mode: :savepoint)
      end
    end

    assert {:ok, ^m} = S.get_match(m.id)
    assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
  end

  test "corrective generated-key migration rejects legacy collisions and blanks transactionally" do
    sql = fn statement, params ->
      Ecto.Adapters.SQL.query!(Repo, statement, params, mode: :savepoint)
    end

    for {table, identities} <- [
          {"qa_legacy_collision", ["EVENT", "\u00A0event\u00A0"]},
          {"qa_legacy_blank", ["\u00A0"]}
        ] do
      sql.(
        "CREATE TEMP TABLE #{table} (identity text NOT NULL, normalized text GENERATED ALWAYS AS (lower(regexp_replace(identity, '^[[:space:]]+|[[:space:]]+$', '', 'g'))) STORED, UNIQUE(normalized), CHECK(normalized <> ''))",
        []
      )

      for identity <- identities,
          do: sql.("INSERT INTO #{table}(identity) VALUES ($1)", [identity])

      before = sql.("SELECT identity, normalized FROM #{table} ORDER BY identity", []).rows

      assert_raise Postgrex.Error, fn ->
        sql.(
          "ALTER TABLE #{table} ALTER COLUMN normalized SET EXPRESSION AS (lower(statistics_trim_identity(identity)))",
          []
        )
      end

      assert sql.("SELECT identity, normalized FROM #{table} ORDER BY identity", []).rows ==
               before
    end

    sql.(
      "CREATE TEMP TABLE qa_legacy_safe (identity text, normalized text GENERATED ALWAYS AS (lower(regexp_replace(identity, '^[[:space:]]+|[[:space:]]+$', '', 'g'))) STORED, UNIQUE(normalized), CHECK(normalized <> ''))",
      []
    )

    sql.("INSERT INTO qa_legacy_safe(identity) VALUES ($1)", ["\u00A0Fact\u00A0"])

    sql.(
      "CREATE TRIGGER qa_guard BEFORE UPDATE OR DELETE ON qa_legacy_safe FOR EACH ROW EXECUTE FUNCTION statistics_immutable()",
      []
    )

    sql.(
      "ALTER TABLE qa_legacy_safe ALTER COLUMN normalized SET EXPRESSION AS (lower(statistics_trim_identity(identity)))",
      []
    )

    assert [["\u00A0Fact\u00A0", "fact"]] =
             sql.("SELECT identity, normalized FROM qa_legacy_safe", []).rows

    assert_raise Postgrex.Error, fn ->
      sql.("UPDATE qa_legacy_safe SET identity = identity", [])
    end
  end
end
