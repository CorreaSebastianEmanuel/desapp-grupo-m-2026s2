defmodule FootballMarket.Valuation.OutcomesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Statistics, StatisticsCase}

  test "empty, unknown, malformed and insufficient outcomes are distinct without fabricated rows" do
    f = fixture()

    {:ok, _} =
      Statistics.record_match(
        StatisticsCase.match_attrs(f, %{kickoff_at: "2026-10-06T12:00:00Z"})
      )

    assert {:error, %{kind: :no_recorded_performances, message: "sin actuaciones registradas"}} =
             Valuation.prepare(request(f))

    assert {:error, %{kind: :not_found}} =
             Valuation.prepare(request(f, %{player_id: Ecto.UUID.generate()}))

    assert {:error, %{kind: :validation}} =
             Valuation.prepare(
               request(f, %{player_id: Ecto.UUID.generate(), references: %{goals: 0}})
             )

    assert {:error, %{kind: :validation, reason: :season_mismatch}} =
             Valuation.prepare(request(f, %{season_id: Ecto.UUID.generate()}))

    record(f, "incomplete", %{minutes_played: 0})

    assert {:error, %{kind: :insufficient_data, message: "datos insuficientes"}} =
             Valuation.prepare(request(f))
  end

  test "public failures distinguish strategy identity, callback exception and invalid result" do
    f = fixture()
    record(f, "complete", %{goals: 0})

    d = %FootballMarket.Valuation.Definition{
      module: FootballMarket.ValuationScorers.Weighted,
      strategy_id: "illustrative",
      version: "unknown",
      config: %{weights: %{overall: %{goals: 1}}, policy: :require_all}
    }

    assert {:error, %{kind: :unsupported_strategy, reason: :unknown_identity_version}} =
             Valuation.evaluate(request(f), d)

    assert {:error, %{kind: :strategy_failure, reason: :callback_exception}} =
             Valuation.evaluate(request(f), %{
               d
               | version: "1",
                 module: FootballMarket.ValuationScorers.Exception
             })

    assert {:error, %{kind: :strategy_failure, reason: :invalid_result}} =
             Valuation.evaluate(request(f), %{
               d
               | version: "1",
                 module: FootballMarket.ValuationScorers.Nonfinite
             })
  end
end
