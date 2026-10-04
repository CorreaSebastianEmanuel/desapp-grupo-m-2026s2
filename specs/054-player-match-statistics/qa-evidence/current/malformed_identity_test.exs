defmodule FootballMarket.QA.MalformedIdentityTest do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.Statistics, as: S
  import FootballMarket.StatisticsCase

  defp result(fun) do
    fun.()
  rescue
    error in Postgrex.Error -> {:raised, Postgrex.Error, error.postgres.code}
  end

  test "NUL match identity returns field-safe validation instead of PostgreSQL exception" do
    f = fixture()
    response = result(fn -> S.record_match(match_attrs(f, %{match_identity: "\0event"})) end)
    assert Repo.aggregate(FootballMarket.Statistics.Match, :count) == 0
    assert {:error, %{kind: :validation, field: :match_identity}} = response
  end

  test "NUL identity scoped lookup returns field-safe validation" do
    f = fixture()
    response = result(fn -> S.get_match(f.season.id, "event\0") end)
    assert {:error, %{kind: :validation, field: :match_identity}} = response
  end

  test "late malformed batch identity rolls back and identifies the failing envelope" do
    f = fixture()
    good = %{match: match_attrs(f), performances: []}
    bad = %{match: match_attrs(f, %{match_identity: "event\0"}), performances: []}
    response = result(fn -> S.record_batch([good, bad]) end)
    assert Repo.aggregate(FootballMarket.Statistics.Match, :count) == 0
    assert {:error, %{kind: :validation, field: :match_identity, record: %{match_index: 1}}} = response
  end
end
