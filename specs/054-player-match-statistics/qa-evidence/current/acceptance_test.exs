unless Code.ensure_loaded?(FootballMarket.Repo.Migrations.AlignStatisticsIdentityWhitespace) do
  Code.require_file("priv/repo/migrations/20261004000000_align_statistics_identity_whitespace.exs")
end

defmodule FootballMarket.QA.StatisticsAcceptanceTest do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  defp sql(statement, params \\ []), do: Ecto.Adapters.SQL.query!(Repo, statement, params)

  defp legacy_schema do
    name = "qa_statistics_#{System.unique_integer([:positive])}"
    sql("CREATE SCHEMA #{name}")
    sql("SET LOCAL search_path TO #{name}, public")
    sql("CREATE TABLE matches (id uuid PRIMARY KEY, season_id uuid NOT NULL, match_identity text NOT NULL, kickoff_at timestamp(6) NOT NULL, normalized_identity text GENERATED ALWAYS AS (lower(regexp_replace(match_identity, '^[[:space:]]+|[[:space:]]+$', '', 'g'))) STORED, UNIQUE(season_id, normalized_identity), CHECK(normalized_identity <> ''))")
    sql("CREATE TRIGGER statistics_immutable BEFORE UPDATE OR DELETE ON matches FOR EACH ROW EXECUTE FUNCTION public.statistics_immutable()")
    sql("CREATE TABLE performances (id uuid PRIMARY KEY, match_id uuid REFERENCES matches(id) ON DELETE RESTRICT, goals numeric, assists numeric)")
  end

  defp legacy_match(identity, season) do
    %{rows: [[id]]} = sql("INSERT INTO matches VALUES (gen_random_uuid(), $1, $2, '2026-01-01 12:00:00.123456') RETURNING id", [season, identity])
    id
  end

  defp migrate do
    Ecto.Migration.Runner.run(Repo, Repo.config(), 20261004000000,
      FootballMarket.Repo.Migrations.AlignStatisticsIdentityWhitespace,
      :forward, :up, :up, log: false)
  end

  defp snapshot do
    sql("SELECT id, season_id, match_identity, kickoff_at FROM matches ORDER BY id").rows
  end

  test "corrective migration retains accepted facts and append-only protection" do
    legacy_schema()
    season = Ecto.UUID.bingenerate()
    id = legacy_match("\u00A0Event\u202F", season)
    legacy_match("Other", season)
    sql("INSERT INTO performances VALUES (gen_random_uuid(), $1, 0, NULL)", [id])
    before = snapshot()
    metrics = sql("SELECT * FROM performances").rows
    migrate()
    assert snapshot() == before
    assert sql("SELECT * FROM performances").rows == metrics
    assert sql("SELECT normalized_identity FROM matches WHERE id=$1", [id]).rows == [["event"]]
    for statement <- ["UPDATE matches SET match_identity='changed' WHERE id=$1", "DELETE FROM matches WHERE id=$1"] do
      assert_raise Postgrex.Error, fn ->
        Ecto.Adapters.SQL.query!(Repo, statement, [id], mode: :savepoint)
      end
    end
    assert snapshot() == before
  end

  for kind <- [:duplicate, :blank] do
    test "corrective migration transaction aborts legacy #{kind} without changing facts" do
      legacy_schema()
      season = Ecto.UUID.bingenerate()
      legacy_match("Event", season)
      legacy_match(unquote(if kind == :duplicate, do: "\u00A0event\u00A0", else: "\u00A0"), season)
      before = snapshot()
      Repo.transaction(fn ->
      sql("SAVEPOINT qa_migration")
      error = assert_raise Postgrex.Error, fn -> migrate() end
      assert error.postgres.code == unquote(if kind == :duplicate, do: :unique_violation, else: :check_violation)
      sql("ROLLBACK TO SAVEPOINT qa_migration")
      assert snapshot() == before
      assert sql("SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname=current_schema() AND p.proname='statistics_trim_identity'").rows == [[0]]
      end)
    end
  end

  test "independent full batch roundtrip and failure preserve existing event-time facts" do
    f = fixture()
    huge = 999_999_999_999_999_999_999_999_999_999
    perf = performance_attrs(f, %{id: nil}, Map.new(metrics(), &{&1, huge})) |> Map.delete(:match_id)
    identities = ["\u00A0ÉVÉNT\u202F", "Later"]
    batch = for identity <- identities, do: %{match: match_attrs(f, %{match_identity: identity}), performances: [perf]}
    assert {:ok, rows} = S.record_batch(batch)
    for %{match: m, performances: [p]} <- rows do
      assert {:ok, ^p} = S.get_performance(p.player_id, m.id)
      for key <- metrics(), do: assert(Map.fetch!(p, key) == huge)
    end
    assert {:ok, first} = S.get_match(f.season.id, "\u2003év ént\u2003" |> String.replace(" ", ""))
    assert first.id == hd(rows).match.id
    {:ok, before} = S.list_player_history(hd(f.players).id)
    bad = %{match: match_attrs(f), performances: [Map.put(perf, :minutes_played, true)]}
    assert {:error, %{field: :minutes_played, record: %{match_index: 1}}} = S.record_batch([%{match: match_attrs(f), performances: [perf]}, bad])
    assert S.list_player_history(hd(f.players).id) == {:ok, before}
  end
end
