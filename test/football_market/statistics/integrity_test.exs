defmodule FootballMarket.Statistics.IntegrityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  def reject_sql(sql, params \\ []) do
    assert_raise Postgrex.Error, fn ->
      Ecto.Adapters.SQL.query!(Repo, sql, params, mode: :savepoint)
    end
  end

  test "late malformed identity rolls back all batch facts and preserves existing facts" do
    f = fixture()
    {:ok, original} = S.record_match(match_attrs(f))
    {:ok, performance} = S.record_performance(performance_attrs(f, original))

    for identity <- [
          <<0>> <> "event",
          "ev" <> <<0>> <> "ent",
          "event" <> <<0>>,
          <<255>>,
          <<195, 40>>
        ] do
      early = match_attrs(f)
      attrs = performance_attrs(f, original) |> Map.delete(:match_id)

      before_counts =
        {Repo.aggregate(FootballMarket.Statistics.Match, :count),
         Repo.aggregate(FootballMarket.Statistics.Performance, :count)}

      assert {:error,
              %{
                field: :match_identity,
                reason: :invalid_identity,
                record: %{match_index: 1, performance_index: nil}
              }} =
               S.record_batch([
                 %{match: early, performances: [attrs]},
                 %{match: match_attrs(f, %{match_identity: identity}), performances: []}
               ])

      assert {:error, :not_found} = S.get_match(f.season.id, early.match_identity)

      assert before_counts ==
               {Repo.aggregate(FootballMarket.Statistics.Match, :count),
                Repo.aggregate(FootballMarket.Statistics.Performance, :count)}

      assert {:ok, ^original} = S.get_match(original.id)
      assert {:ok, ^performance} = S.get_performance(performance.player_id, original.id)
    end
  end

  test "database protects append-only facts and catalog meaning" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    {:ok, p} = S.record_performance(performance_attrs(f, m))

    for {table, id} <- [{"matches", m.id}, {"player_match_performances", p.id}] do
      {:ok, uuid} = Ecto.UUID.dump(id)
      reject_sql("UPDATE #{table} SET id = id WHERE id = $1", [uuid])
      reject_sql("DELETE FROM #{table} WHERE id = $1", [uuid])
    end

    {:ok, season_id} = Ecto.UUID.dump(f.season.id)

    reject_sql(
      "UPDATE seasons SET start_year = start_year + 1, end_year = end_year + 1 WHERE id = $1",
      [season_id]
    )

    for row <- [f.home, f.away, hd(f.players), f.position, f.season] do
      {:ok, uuid} = Ecto.UUID.dump(row.id)
      reject_sql("DELETE FROM #{row.__struct__.__schema__(:source)} WHERE id = $1", [uuid])
    end

    assert {:ok, ^m} = S.get_match(m.id)
    assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
  end

  test "normalized duplicates conflict without replacing facts, including cross-season reuse" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f, %{match_identity: "EVENT"}))

    for identity <- ["EVENT", "event", " event ", "\tEVENT\n"] do
      assert {:error, %{kind: :conflict, field: :match_identity}} =
               S.record_match(match_attrs(f, %{match_identity: identity}))
    end

    {:ok, p} = S.record_performance(performance_attrs(f, m))

    for goals <- [nil, 7] do
      assert {:error, %{kind: :conflict}} =
               S.record_performance(performance_attrs(f, m, %{goals: goals}))
    end

    assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
    other = fixture("PL", 2026)
    assert {:ok, _} = S.record_match(match_attrs(other, %{match_identity: "event"}))
    assert {:ok, ^m} = S.get_match(m.id)
  end

  test "Unicode whitespace matches String.trim for writes, scoped reads and database guards" do
    f = fixture()
    {:ok, original} = S.record_match(match_attrs(f, %{match_identity: "EVENT"}))
    {:ok, performance} = S.record_performance(performance_attrs(f, original))

    whitespace =
      [9, 10, 11, 12, 13, 32, 0x85, 0xA0, 0x1680] ++
        Enum.to_list(0x2000..0x200A) ++ [0x2028, 0x2029, 0x202F, 0x205F, 0x3000]

    for cp <- whitespace do
      space = <<cp::utf8>>
      identity = space <> "event" <> space
      assert String.trim(space) == ""

      assert {:error, %{kind: :conflict, field: :match_identity}} =
               S.record_match(match_attrs(f, %{match_identity: identity}))

      assert {:ok, ^original} = S.get_match(f.season.id, identity)

      assert {:error, %{field: :match_identity, reason: :required}} =
               S.record_match(match_attrs(f, %{match_identity: space}))

      assert {:error, %{field: :match_identity, reason: :required}} =
               S.get_match(f.season.id, space)

      # Bypass the context trim: the database must enforce the same equivalence.
      for invalid <- [identity, space] do
        changeset =
          FootballMarket.Statistics.Match.changeset(
            match_attrs(f, %{match_identity: invalid}),
            f.season
          )
          |> Ecto.Changeset.force_change(:match_identity, invalid)

        assert {:error, _} = Repo.insert(changeset, mode: :savepoint)
      end
    end

    padding = List.to_string(whitespace)

    assert {:ok, padded} =
             S.record_match(match_attrs(f, %{match_identity: padding <> "Second" <> padding}))

    assert padded.match_identity == "Second"
    assert padded.normalized_identity == "second"
    assert {:ok, ^padded} = S.get_match(f.season.id, padding <> "SECOND" <> padding)

    # Internal whitespace and characters String.trim deliberately retains remain identity facts.
    for identity <- ["A\u00A0B", "\u200Bedge\u200B", "\uFEFFedge\uFEFF"] do
      assert {:ok, stored} = S.record_match(match_attrs(f, %{match_identity: identity}))
      assert stored.match_identity == identity
      assert {:ok, ^stored} = S.get_match(f.season.id, identity)
    end

    other = fixture("PL", 2026)

    assert {:ok, reused} =
             S.record_match(match_attrs(other, %{match_identity: "\u00A0event\u00A0"}))

    assert {:ok, ^reused} = S.get_match(other.season.id, "EVENT")
    assert {:ok, ^original} = S.get_match(original.id)
    assert {:ok, ^performance} = S.get_performance(performance.player_id, original.id)
  end

  test "all missing and inconsistent relationships identify their field" do
    f = fixture()
    other = fixture("PL", 2026)
    {:ok, m} = S.record_match(match_attrs(f))

    for field <- [:season_id, :home_team_id, :away_team_id] do
      assert {:error, %{field: ^field, reason: :missing_reference}} =
               S.record_match(match_attrs(f, %{field => Ecto.UUID.generate()}))
    end

    for field <- [:match_id, :player_id, :team_id, :position_id] do
      assert {:error, %{field: ^field, reason: :missing_reference}} =
               S.record_performance(performance_attrs(f, m, %{field => Ecto.UUID.generate()}))
    end

    assert {:error, %{field: :away_team_id, reason: :identical_teams}} =
             S.record_match(match_attrs(f, %{away_team_id: f.home.id}))

    assert {:error, %{field: :home_team_id, reason: :season_mismatch}} =
             S.record_match(match_attrs(f, %{home_team_id: other.home.id}))

    assert {:error, %{field: :away_team_id, reason: :season_mismatch}} =
             S.record_match(match_attrs(f, %{away_team_id: other.away.id}))

    assert {:error, %{field: :player_id, reason: :season_mismatch}} =
             S.record_performance(performance_attrs(f, m, %{player_id: hd(other.players).id}))

    assert {:error, %{field: :team_id, reason: :season_mismatch}} =
             S.record_performance(performance_attrs(f, m, %{team_id: other.home.id}))

    {:ok, third} =
      FootballMarket.Catalog.create_team(FootballMarket.CatalogCase.team_attrs(f.season))

    assert {:error, %{field: :team_id, reason: :nonparticipant}} =
             S.record_performance(performance_attrs(f, m, %{team_id: third.id}))

    assert Repo.aggregate(FootballMarket.Statistics.Performance, :count) == 0

    for {attrs, field} <- [
          {%{minutes_played: nil}, :minutes_played},
          {%{goals: -1}, :goals},
          {%{goals: true}, :goals},
          {%{tackles: 1.2}, :tackles},
          {%{saves: "1"}, :saves}
        ] do
      assert {:error, %{field: ^field}} = S.record_performance(performance_attrs(f, m, attrs))
    end

    assert {:error, %{reason: :unsupported_field}} =
             S.record_performance(performance_attrs(f, m, %{score: 3}))

    assert {:error, %{field: :kickoff_at}} =
             S.record_match(match_attrs(f, %{kickoff_at: "invalid"}))
  end

  test "database composite and participation constraints reject direct invalid inserts" do
    f = fixture()
    other = fixture("PL", 2026)
    {:ok, m} = S.record_match(match_attrs(f))

    cs =
      FootballMarket.Statistics.Match.changeset(
        match_attrs(f, %{home_team_id: other.home.id}),
        f.season
      )

    assert {:error, _} = Repo.insert(cs, mode: :savepoint)

    cs =
      FootballMarket.Statistics.Match.changeset(
        match_attrs(f, %{away_team_id: f.home.id}),
        f.season
      )

    assert {:error, _} = Repo.insert(cs, mode: :savepoint)

    {:ok, third} =
      FootballMarket.Catalog.create_team(FootballMarket.CatalogCase.team_attrs(f.season))

    for attrs <- [
          %{team_id: third.id},
          %{player_id: hd(other.players).id},
          %{team_id: other.home.id}
        ] do
      cs = FootballMarket.Statistics.Performance.changeset(performance_attrs(f, m, attrs), m)
      assert {:error, _} = Repo.insert(cs, mode: :savepoint)
    end

    {:ok, p} = S.record_performance(performance_attrs(f, m))
    {:ok, id} = Ecto.UUID.dump(p.player_id)
    {:ok, season} = Ecto.UUID.dump(other.season.id)
    reject_sql("UPDATE players SET season_id = $2 WHERE id = $1", [id, season])
    {:ok, team} = Ecto.UUID.dump(f.away.id)
    reject_sql("UPDATE teams SET season_id = $2 WHERE id = $1", [team, season])
  end

  test "persisted count checks reject negative fractional and nonfinite numeric facts" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    attrs = performance_attrs(f, m)
    {:ok, match_id} = Ecto.UUID.dump(m.id)
    {:ok, player_id} = Ecto.UUID.dump(attrs.player_id)
    {:ok, team_id} = Ecto.UUID.dump(attrs.team_id)
    {:ok, position_id} = Ecto.UUID.dump(attrs.position_id)
    {:ok, season_id} = Ecto.UUID.dump(f.season.id)

    for field <- [:minutes_played | metrics()],
        value <- ["-1", "1.5", "NaN", "Infinity", "-Infinity"] do
      reject_sql(
        "INSERT INTO player_match_performances (id, match_id, player_id, team_id, position_id, season_id, inserted_at, minutes_played#{if field == :minutes_played, do: "", else: ", #{field}"}) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, now(), #{if field == :minutes_played, do: "'#{value}'::numeric", else: "0, '#{value}'::numeric"})",
        [match_id, player_id, team_id, position_id, season_id]
      )
    end
  end

  test "batch validates shapes and atomically rejects late invalid entries" do
    f = fixture()
    attrs = match_attrs(f)
    perf = performance_attrs(f, %{id: Ecto.UUID.generate()}) |> Map.delete(:match_id)
    valid = %{match: attrs, performances: [perf]}
    assert {:ok, []} = S.record_batch([])

    assert {:error, %{record: %{match_index: 1, performance_index: 0}, field: :goals}} =
             S.record_batch([
               valid,
               %{match: match_attrs(f), performances: [Map.put(perf, :goals, -1)]}
             ])

    assert {:error, :not_found} = S.get_match(f.season.id, attrs.match_identity)

    assert {:error, %{record: %{match_index: 0, performance_index: 1}, kind: :conflict}} =
             S.record_batch([%{valid | performances: [perf, perf]}])

    assert {:error, :not_found} = S.get_match(f.season.id, attrs.match_identity)

    assert {:error, %{reason: :unsupported_field}} =
             S.record_batch([
               %{valid | performances: [Map.put(perf, :match_id, Ecto.UUID.generate())]}
             ])

    for invalid <- [
          nil,
          %{},
          "x",
          [nil],
          [%{match: attrs}],
          [%{match: attrs, performances: nil}],
          [%{match: attrs, performances: [], other: true}]
        ],
        do: assert(match?({:error, _}, S.record_batch(invalid)))

    string_envelope = %{
      "match" => Map.new(attrs, fn {k, v} -> {to_string(k), v} end),
      "performances" => [Map.new(perf, fn {k, v} -> {to_string(k), v} end)]
    }

    assert {:ok, [%{match: m, performances: [p]}]} = S.record_batch([string_envelope])
    assert p.match_id == m.id

    assert {:ok, [%{performances: []}]} =
             S.record_batch([%{match: match_attrs(f), performances: []}])
  end

  test "rejection APIs and catalog deletions preserve accepted facts" do
    f = fixture()
    {:ok, m} = S.record_match(match_attrs(f))
    {:ok, p} = S.record_performance(performance_attrs(f, m))

    for {update, delete, id} <- [
          {:update_match, :delete_match, m.id},
          {:update_performance, :delete_performance, p.id}
        ] do
      assert {:error, :immutable} = apply(S, update, [id, %{}])
      assert {:error, :immutable} = apply(S, delete, [id])
      assert {:error, :not_found} = apply(S, delete, [Ecto.UUID.generate()])
      assert {:error, %{reason: :invalid_identifier}} = apply(S, delete, ["bad"])
    end

    assert {:error, %Ecto.Changeset{}} = FootballMarket.Catalog.delete_team(f.home)
    assert {:error, %Ecto.Changeset{}} = FootballMarket.Catalog.delete_season(f.season)

    {:ok, new_position} =
      FootballMarket.Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    for player <- f.players,
        do:
          assert(
            match?(
              {:ok, _},
              FootballMarket.Catalog.update_player(player, %{position_id: new_position.id})
            )
          )

    assert {:error, %Ecto.Changeset{}} = FootballMarket.Catalog.delete_position(f.position)
    assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
  end
end
