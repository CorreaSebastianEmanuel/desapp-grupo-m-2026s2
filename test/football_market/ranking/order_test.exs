defmodule FootballMarket.Ranking.OrderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  test "a single entry has a consecutive one-based position and retains exact price and time" do
    f = FootballMarket.RankingCase.fixture()
    assert {:ok, %{entries: [entry]}} = FootballMarket.Ranking.read()
    assert entry.position == 1
    assert entry.quote_id == f.quote.id
    assert DateTime.to_iso8601(entry.effective_at) == DateTime.to_iso8601(f.quote.effective_at)
    assert Decimal.equal?(entry.unit_price, f.quote.unit_price)
  end

  test "repeated reads preserve selected quote identity and order" do
    f = FootballMarket.RankingCase.fixture()
    expected = [{f.player.id, f.quote.id, 1}]

    actual =
      for _ <- 1..3 do
        assert {:ok, %{entries: entries}} = FootballMarket.Ranking.read()
        Enum.map(entries, &{&1.player_id, &1.quote_id, &1.position})
      end

    assert actual == [expected, expected, expected]
  end

  test "numeric prices sort descending and equal prices use canonical player UUID order" do
    f = FootballMarket.RankingCase.fixture()
    high = FootballMarket.RankingCase.add_issued_player(f, Decimal.new("10"))
    low = FootballMarket.RankingCase.add_issued_player(f, Decimal.new("2"))
    tied = FootballMarket.RankingCase.add_issued_player(f, Decimal.new("0.625"))

    assert {:ok, %{entries: entries}} = FootballMarket.Ranking.read()

    assert Enum.map(entries, & &1.unit_price) ==
             Enum.map([high, low, tied, f], & &1.quote.unit_price)

    expected_ties =
      [f, tied]
      |> Enum.sort_by(& &1.player.id)
      |> Enum.map(& &1.player.id)

    assert Enum.map(Enum.drop(entries, 2), & &1.player_id) == expected_ties
    assert Enum.map(entries, & &1.position) == [1, 2, 3, 4]
    assert entries |> Enum.map(& &1.player_id) |> Enum.uniq() |> length() == 4
  end

  test "zero entries have no positions and UTC timestamps preserve microseconds" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    assert {:ok, %{entries: []}} = FootballMarket.Ranking.read()

    quote = FootballMarket.RankingCase.add_performance_quote(f)
    assert {:ok, %{entries: [entry]}} = FootballMarket.Ranking.read()
    assert entry.effective_at == quote.effective_at
    assert entry.effective_at.microsecond == quote.effective_at.microsecond
    assert DateTime.to_iso8601(entry.effective_at) == DateTime.to_iso8601(quote.effective_at)
  end
end
