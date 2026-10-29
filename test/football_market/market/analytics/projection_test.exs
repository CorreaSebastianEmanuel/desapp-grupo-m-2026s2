defmodule FootballMarket.Market.Analytics.ProjectionTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.{Portfolio, PortfolioLedger}
  alias FootballMarket.Market.Analytics.{Input, Projection}

  test "daily replay includes opening trades, carry-forward quotes and retained closed profit" do
    trades = [trade("purchase", 2, "4", 1), trade("sale", 1, "3", 3), trade("sale", 1, "4", 4)]
    result = history(trades, [price_quote(1, "2", 0), price_quote(2, "3", 2)], 2, 5)
    [a, b, c, d] = result.points
    assert_money(a.market_value, "6")
    assert_money(a.cost_basis, "4")
    assert_money(a.total_profit_loss, "2")
    assert_money(b.market_value, "3")
    assert_money(b.realized_profit_loss, "1")
    assert_money(b.unrealized_profit_loss, "1")
    assert_money(c.market_value, "0")
    assert_money(c.realized_profit_loss, "3")
    assert_money(c.total_profit_loss, "3")
    assert_money(d.purchase_expenditure, "4")
    assert_money(d.sale_proceeds, "7")
    assert_money(d.net_invested, "-3")
    assert_money(d.total_profit_loss, "3")
    assert d.partial
  end

  test "quotes never travel backwards and authoritative sequence wins over later effective time" do
    result =
      history(
        [trade("purchase", 1, "2", 1)],
        [price_quote(3, "4", 2), price_quote(2, "9", 3), price_quote(4, "8", 5)],
        1,
        4
      )

    [a, b, c, d] = result.points
    assert a.market_value == nil
    assert a.missing_quote_player_ids == ["player"]
    assert_money(a.cost_basis, "2")
    assert a.total_profit_loss == nil
    assert_money(b.market_value, "4")
    assert_money(c.market_value, "4")
    assert_money(d.market_value, "4")
  end

  test "partial today uses the actual cutoff and excludes later trades and quotes" do
    snapshot =
      snapshot(
        [trade("purchase", 1, "2", 1), trade("purchase", 1, "4", 6)],
        [price_quote(1, "3", 1), price_quote(2, "8", 6)],
        5,
        5
      )

    result = exact(fn -> Projection.build(snapshot, :history) end)
    assert [point] = result.points
    assert point.partial
    assert point.cutoff_at == snapshot.as_of
    assert_money(point.market_value, "3")
    assert_money(point.purchase_expenditure, "2")
  end

  test "allocation weights use total value and all become unknown when any positive holding lacks a quote" do
    trades = [trade("purchase", 1, "1", 1), %{trade("purchase", 2, "2", 1) | player_id: "other"}]
    quotes = [price_quote(1, "2", 1), %{price_quote(1, "3", 1) | player_id: "other"}]
    snapshot = %{snapshot(trades, quotes, 1, 5) | players: %{"player" => "One", "other" => "Two"}}
    result = exact(fn -> Projection.build(snapshot, :allocation) end)
    assert_money(result.totals.market_value, "8")
    [other, player] = result.positions
    assert_money(other.weight, "0.75")
    assert_money(player.weight, "0.25")

    incomplete =
      exact(fn -> Projection.build(%{snapshot | quotes: [hd(quotes)]}, :allocation) end)

    assert incomplete.totals.market_value == nil
    refute incomplete.totals.valuation_complete
    assert incomplete.totals.missing_quote_player_ids == ["other"]
    assert Enum.all?(incomplete.positions, &is_nil(&1.weight))
    assert Enum.find(incomplete.positions, &(&1.player_id == "player")).market_value != nil
  end

  test "weighted accounting survives repurchase, losses and hostile precision without changing current portfolio" do
    trades = [
      trade("purchase", 3, "0.07", 1),
      trade("sale", 3, "0.03", 2),
      trade("purchase", 2, "6", 3)
    ]

    Decimal.Context.with(%Decimal.Context{precision: 4, rounding: :half_even}, fn ->
      result = history(trades, [price_quote(1, "2", 0)], 3, 4)
      [point | _] = result.points
      assert_money(point.cost_basis, "6")
      assert_money(point.realized_profit_loss, "-0.039999999999999999")
      assert_money(point.unrealized_profit_loss, "-2")
      assert [position] = Portfolio.calculate(trades)
      assert_money(position.average_unit_cost, "3")
      assert_money(position.realized_profit_loss, "-0.039999999999999999")
    end)
  end

  test "large supported decimal values remain exact and empty portfolios are real zeroes" do
    total = "277037036703703703670370370367038.73"
    unit = "92345678901234567890123456789012.91"

    Decimal.Context.with(%Decimal.Context{precision: 4}, fn ->
      result = history([trade("purchase", 3, total, 1)], [price_quote(1, unit, 0)], 1, 1)
      assert_money(hd(result.points).market_value, total)
      assert_money(hd(result.points).total_profit_loss, "0")
    end)

    assert [empty] = history([], [], 1, 1).points
    assert empty.valuation_complete
    assert empty.missing_quote_player_ids == []
    assert_money(empty.market_value, "0")
    assert_money(empty.realized_profit_loss, "0")
  end

  test "UTC ranges include leap days and enforce defaults, limits and strict query shapes" do
    today = ~D[2026-10-29]
    assert {:ok, %{from: ~D[2026-09-30], to: ^today}} = Input.range(%{}, today)

    assert {:ok, %{from: ~D[2026-09-02], to: ~D[2026-10-01]}} =
             Input.range(%{to: ~D[2026-10-01]}, today)

    assert {:ok, %{from: ~D[2026-10-01], to: ^today}} =
             Input.range(%{from: ~D[2026-10-01]}, today)

    assert {:ok, _} = Input.range(%{from: ~D[2024-01-01], to: ~D[2024-12-31]}, today)

    assert {:error, :invalid_date_range} =
             Input.range(%{from: ~D[2024-01-01], to: ~D[2025-01-01]}, today)

    assert {:error, :invalid_date_range} =
             Input.range(%{from: today, to: Date.add(today, 1)}, today)

    assert {:error, :invalid_date_range} =
             Input.range(%{from: today, to: Date.add(today, -1)}, today)

    assert {:ok, %{from: ~D[2024-02-29], to: nil}} = Input.decode("from=2024-02-29")

    for query <- [
          "from=",
          "from=2025-02-29",
          "from=2026-1-01",
          "from=0000-01-01",
          "from=x&from=y",
          "to[]=2026-01-01",
          "from[x]=y",
          "to=2026-01-01&to[]=x"
        ] do
      assert {:error, :invalid_date} = Input.decode(query)
    end

    assert {:ok, %{from: nil, to: nil}} = Input.decode("owner_id=someone-else")
    assert Enum.count(Date.range(~D[2024-02-28], ~D[2024-03-01])) == 3
  end

  test "UTC end-of-day includes the final microsecond and leap-day midnight starts the next point" do
    before = ~U[2024-02-28 23:59:59.999999Z]
    midnight = ~U[2024-02-29 00:00:00.000000Z]

    snapshot = %{
      as_of: ~U[2024-03-01 12:00:00.000000Z],
      range: %{from: ~D[2024-02-28], to: ~D[2024-03-01]},
      transactions: [
        %{trade("purchase", 1, "2", 1) | completed_at: before},
        %{trade("purchase", 1, "3", 2) | completed_at: midnight}
      ],
      quotes: [
        %{price_quote(nil, "2", 1) | effective_at: before, inserted_at: before},
        %{price_quote(1, "3", 2) | effective_at: midnight, inserted_at: midnight}
      ],
      players: %{"player" => "Player"}
    }

    result = exact(fn -> Projection.build(snapshot, :history) end)
    [a, b, c] = result.points
    assert a.date == ~D[2024-02-28]
    assert a.cutoff_at == before
    assert_money(a.market_value, "2")
    assert b.date == ~D[2024-02-29]
    assert_money(b.market_value, "6")
    assert_money(b.purchase_expenditure, "5")
    assert_money(c.market_value, "6")
    assert c.partial
  end

  test "same-sequence quote ties use effective time, inserted time and ID deterministically" do
    base = price_quote(1, "2", 1)
    effective = %{base | id: "effective", effective_at: at(2), unit_price: decimal("3")}
    inserted = %{effective | id: "inserted", inserted_at: at(3), unit_price: decimal("4")}
    winner = %{inserted | id: "zz-winner", unit_price: decimal("5")}

    for quotes <- [[winner, base, inserted, effective], [effective, inserted, base, winner]] do
      result = history([trade("purchase", 1, "1", 1)], quotes, 3, 3)
      assert_money(hd(result.points).market_value, "5")
    end

    nil_sequence = %{base | performance_sequence: nil, unit_price: decimal("1")}

    assert_money(
      hd(history([trade("purchase", 1, "1", 1)], [nil_sequence, base], 2, 2).points).market_value,
      "2"
    )
  end

  defp history(trades, quotes, from, to),
    do: exact(fn -> Projection.build(snapshot(trades, quotes, from, to), :history) end)

  defp snapshot(trades, quotes, from, to),
    do: %{
      as_of: at(5),
      range: %{from: date(from), to: date(to)},
      transactions: trades,
      quotes: quotes,
      players: %{"player" => "Player"}
    }

  defp trade(type, quantity, total, day),
    do: %{
      id: "#{day}-#{type}",
      type: type,
      player_id: "player",
      quantity: quantity,
      total: decimal(total),
      completed_at: at(day)
    }

  defp price_quote(sequence, price, day),
    do: %{
      id: "quote-#{sequence}",
      player_id: "player",
      performance_sequence: sequence,
      unit_price: decimal(price),
      effective_at: at(day),
      inserted_at: at(day)
    }

  defp date(day), do: Date.add(~D[2026-10-01], day)
  defp at(day), do: DateTime.new!(date(day), ~T[12:00:00], "Etc/UTC")
  defp decimal(value), do: value |> Decimal.parse(max_digits: :infinity) |> elem(0)
  defp exact(fun), do: PortfolioLedger.exact(fun)
  defp assert_money(actual, expected), do: assert(Decimal.equal?(actual, decimal(expected)))
end
