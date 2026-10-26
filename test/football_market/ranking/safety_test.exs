defmodule FootballMarket.Ranking.SafetyTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  test "ranking reads leave persisted quote and selection rows unchanged" do
    f = FootballMarket.RankingCase.fixture()
    before = FootballMarket.RankingCase.protected_snapshot()
    handler_id = "ranking-read-only-#{Ecto.UUID.generate()}"
    owner = self()

    :ok =
      :telemetry.attach(
        handler_id,
        [:football_market, :repo, :query],
        fn _event, _measurements, metadata, _config ->
          send(owner, {:ranking_sql, metadata[:query]})
        end,
        nil
      )

    assert {:ok, _} = FootballMarket.Ranking.read()
    queries = collect_queries([])
    :telemetry.detach(handler_id)

    assert FootballMarket.RankingCase.protected_snapshot() == before
    assert Enum.any?(queries, &String.contains?(&1, "READ ONLY"))
    refute Enum.any?(queries, &Regex.match?(~r/^\s*(INSERT|UPDATE|DELETE|TRUNCATE)\b/i, &1))

    supplies =
      FootballMarket.Repo.query!(
        "SELECT player_id, sum(quantity)::integer FROM market_holdings GROUP BY player_id"
      ).rows

    assert Enum.any?(supplies, fn [player_id, total] ->
             player_id == Ecto.UUID.dump!(f.player.id) and total == 100
           end)
  end

  test "a missing selection anchor remains a storage failure rather than an empty success" do
    _f = FootballMarket.RankingCase.fixture(quote: false)

    FootballMarket.Repo.query!(
      "ALTER TABLE valuation_selection_locks RENAME TO valuation_selection_locks_unavailable"
    )

    assert {:error, :storage_unavailable} = FootballMarket.Ranking.read()
  end

  defp collect_queries(acc) do
    receive do
      {:ranking_sql, query} when is_binary(query) -> collect_queries([query | acc])
      {:ranking_sql, _} -> collect_queries(acc)
    after
      0 -> acc
    end
  end
end
