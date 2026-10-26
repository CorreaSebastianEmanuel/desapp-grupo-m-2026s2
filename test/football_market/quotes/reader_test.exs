defmodule FootballMarket.Quotes.ReaderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, QuotesCase, ValuationConfigurationCase}

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "issuance is current and history keeps its nullable original metadata", f do
    assert {:ok, quote} = Quotes.latest(f.player.id)
    assert quote.id == f.issuance.initial_quote_id
    assert quote.rule_id == "initial_issuance"
    assert quote.performance_sequence == nil
    assert {:ok, [^quote]} = Quotes.list_history(String.upcase(f.player.id))
    assert {:ok, ^quote} = Quotes.at_date(f.player.id, DateTime.to_date(quote.effective_at))
    assert {:error, :quote_not_found} = Quotes.at_date(f.player.id, ~D[0000-01-01])
  end

  test "dated lookup includes the entire UTC day and carries through gaps and leap days", f do
    first = QuotesCase.dated_quote(f, ~U[2028-02-28 23:59:59.999999Z])
    leap = QuotesCase.dated_quote(f, ~U[2028-02-29 00:00:00.000000Z], "2.50")
    last = QuotesCase.dated_quote(f, ~U[2028-03-02 00:00:00.000000Z], "3.00")

    assert {:ok, ^first} = Quotes.at_date(f.player.id, ~D[2028-02-28])
    assert {:ok, ^leap} = Quotes.at_date(f.player.id, ~D[2028-02-29])
    assert {:ok, ^leap} = Quotes.at_date(f.player.id, ~D[2028-03-01])
    assert {:ok, ^last} = Quotes.at_date(f.player.id, ~D[2028-03-02])
    assert {:ok, ^last} = Quotes.at_date(f.player.id, ~D[9999-12-31])
    assert {:ok, ^last} = Quotes.latest(f.player.id)
  end

  test "same-time and same-price quotes remain distinct in authoritative sequence order", f do
    at = ~U[2028-02-29 12:00:00.000000Z]
    first = QuotesCase.dated_quote(f, at)
    second = QuotesCase.dated_quote(f, at)
    # Sequence remains authoritative even if timestamp order differs.
    third = QuotesCase.dated_quote(f, ~U[2028-02-29 11:00:00.000000Z])

    for _ <- 1..3 do
      assert {:ok, ^third} = Quotes.latest(f.player.id)
      assert {:ok, ^third} = Quotes.at_date(f.player.id, ~D[2028-02-29])
      assert {:ok, history} = Quotes.list_history(f.player.id)

      assert Enum.map(history, & &1.id) == [
               f.issuance.initial_quote_id,
               first.id,
               second.id,
               third.id
             ]
    end
  end

  test "unknown, malformed, unissued and other player reads have explicit outcomes", f do
    for id <- ["bad", Ecto.UUID.generate(), nil] do
      assert {:error, :player_not_found} = Quotes.latest(id)
      assert {:error, :player_not_found} = Quotes.list_history(id)
      assert {:error, :player_not_found} = Quotes.at_date(id, ~D[2028-02-29])
    end

    other = Enum.at(f.base.players, 1)
    assert {:ok, []} = Quotes.list_history(other.id)
    assert {:error, :quote_not_found} = Quotes.latest(other.id)
    assert {:error, :quote_not_found} = Quotes.at_date(other.id, ~D[9999-12-31])
    assert {:error, :invalid_date} = Quotes.at_date(f.player.id, "2028-02-29")
    assert {:error, :invalid_date} = Quotes.at_date(f.player.id, nil)
  end

  test "storage failures are unavailable rather than missing quotes", f do
    previous = Repo.put_dynamic_repo(:task027_unavailable_repo)

    try do
      assert {:error, :temporarily_unavailable} = Quotes.latest(f.player.id)
      assert {:error, :temporarily_unavailable} = Quotes.list_history(f.player.id)
      assert {:error, :temporarily_unavailable} = Quotes.at_date(f.player.id, ~D[2028-02-29])
    after
      Repo.put_dynamic_repo(previous)
    end
  end
end
