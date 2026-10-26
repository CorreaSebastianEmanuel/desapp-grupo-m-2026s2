defmodule FootballMarket.Ranking.SelectionTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.Ranking

  test "only successful performance quotes for the active saved configuration are returned" do
    f = FootballMarket.RankingCase.fixture()

    assert {:ok, %{configuration: config, entries: [entry]}} = Ranking.read()
    assert config.id == f.configuration.id
    assert entry.player_id == f.player.id
    assert entry.quote_id == f.quote.id
    assert entry.position == 1
    assert Decimal.equal?(entry.unit_price, Decimal.new("1.25"))
  end

  test "an active configuration with no successful performance quotes is a valid empty ranking" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    assert {:ok, %{configuration: config, entries: []}} = Ranking.read()
    assert config.id == f.configuration.id
  end

  test "no active configuration is distinct from an empty active ranking" do
    _f = FootballMarket.RankingCase.fixture(active: false, quote: false)
    assert {:error, :no_active_configuration} = Ranking.read()
  end

  test "a later successful quote for an inactive same-name version cannot displace active history" do
    f = FootballMarket.RankingCase.fixture()
    original = f.configuration

    {:ok, inactive} =
      FootballMarket.Valuation.Configurations.create(FootballMarket.RankingCase.rules(f))

    {:ok, %{calculation: calculation}} =
      FootballMarket.Quotes.request(f.subject, {:version, inactive.id}, f.mapping.id)

    inactive_quote =
      FootballMarket.Repo.get_by!(FootballMarket.Market.Quote, calculation_id: calculation.id)

    assert inactive.strategy_id == original.strategy_id
    assert inactive.formula_version == original.formula_version
    assert inactive.id != original.id
    assert {:ok, %{configuration: active, entries: [entry]}} = Ranking.read()
    assert active.id == original.id
    assert entry.quote_id == f.quote.id
    refute entry.quote_id == inactive_quote.id
  end

  test "the latest successful quote for the active version is selected" do
    f = FootballMarket.RankingCase.fixture()
    newer = FootballMarket.RankingCase.add_performance_quote(f)

    assert newer.performance_sequence > f.quote.performance_sequence
    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.quote_id == newer.id
    assert entry.effective_at == newer.effective_at
    assert Decimal.equal?(entry.unit_price, newer.unit_price)
  end

  test "equal effective times choose the greater per-player sequence and pending delivery remains eligible" do
    f = FootballMarket.RankingCase.fixture()
    newer = FootballMarket.RankingCase.add_equal_time_quote(f)

    assert newer.effective_at == f.quote.effective_at
    assert newer.performance_sequence > f.quote.performance_sequence

    evaluation =
      FootballMarket.Repo.get_by!(FootballMarket.Quotes.Evaluation, quote_id: newer.id)

    assert evaluation.state == "pending"
    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.quote_id == newer.id
  end

  test "selection spans retained seasons rather than filtering to the player's current season" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    other_season = FootballMarket.StatisticsCase.unique_fixture().season
    historical = %{f | subject: %{f.subject | season_id: other_season.id}}
    earlier = FootballMarket.QuotesCase.dated_quote(f, ~U[2027-10-01 12:00:00.123456Z], "8.00")

    later =
      FootballMarket.QuotesCase.dated_quote(historical, ~U[2028-10-01 12:00:00.654321Z], "3.00")

    calculation =
      FootballMarket.Repo.get!(FootballMarket.Quotes.Calculation, later.calculation_id)

    assert calculation.season_id == other_season.id
    refute calculation.season_id == f.player.season_id
    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.quote_id == later.id
    refute entry.quote_id == earlier.id
    assert entry.effective_at == later.effective_at
    assert Decimal.equal?(entry.unit_price, later.unit_price)
  end

  test "effective time takes priority over sequence and the individual current quote" do
    f = FootballMarket.RankingCase.fixture(quote: false)

    latest_time =
      FootballMarket.QuotesCase.dated_quote(f, ~U[2028-10-02 12:00:00.000000Z], "3.00")

    latest_sequence =
      FootballMarket.QuotesCase.dated_quote(f, ~U[2028-10-01 12:00:00.000000Z], "9.00")

    assert latest_sequence.performance_sequence > latest_time.performance_sequence
    assert {:ok, ^latest_sequence} = FootballMarket.Quotes.latest(f.player.id)
    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.quote_id == latest_time.id
    assert entry.effective_at == latest_time.effective_at
    assert Decimal.equal?(entry.unit_price, latest_time.unit_price)
  end

  test "a failed calculation under the active configuration never creates a ranking entry" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    fact = FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)
    missing = %{fact | match_id: Ecto.UUID.generate(), performance_id: Ecto.UUID.generate()}

    assert {:ok, %{calculation: calculation}} =
             FootballMarket.Quotes.request_membership(
               f.subject,
               :active,
               f.mapping.id,
               [missing],
               Ecto.UUID.generate()
             )

    assert calculation.status == "unreproducible"
    assert calculation.player_id == f.player.id
    assert calculation.configuration_version_id == f.configuration.id
    assert calculation.unit_price == nil
    refute FootballMarket.Repo.get_by(FootballMarket.Market.Quote, calculation_id: calculation.id)
    assert {:ok, %{configuration: active, entries: []}} = Ranking.read()
    assert active.id == f.configuration.id
  end

  test "initial-only, no-quote and no-history issued players are omitted exactly" do
    f = FootballMarket.RankingCase.fixture()
    no_quote = FootballMarket.RankingCase.add_no_quote_player(f)
    no_history = FootballMarket.RankingCase.add_no_history_player(f)

    assert {:ok, %{entries: [entry]}} = Ranking.read()
    assert entry.player_id == f.player.id
    refute entry.player_id == no_quote.player.id
    refute entry.player_id == no_history.player.id

    initial_quotes =
      FootballMarket.Repo.all(
        from q in FootballMarket.Market.Quote,
          where: q.player_id in ^[no_quote.player.id, no_history.player.id],
          select: q
      )

    assert initial_quotes != []
    assert Enum.all?(initial_quotes, &is_nil(&1.calculation_id))
    assert Enum.all?(initial_quotes, &(&1.rule_id == "initial_issuance"))
  end
end
