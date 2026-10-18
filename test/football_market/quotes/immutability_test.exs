defmodule FootballMarket.Quotes.ImmutabilityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.QuotesCase
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  defp dt!(value) when is_binary(value) do
    {:ok, dt, _} = DateTime.from_iso8601(value)
    usec6(dt)
  end

  defp dt!(value) when is_struct(value, DateTime), do: usec6(value)

  defp dt!(value), do: value

  defp usec6(dt) do
    dt = DateTime.truncate(dt, :microsecond)
    {micros, _} = dt.microsecond
    %{dt | microsecond: {micros, 6}}
  end

  test "stale calculation lease is fenced before any quote or calculation write", f do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    request =
      Repo.insert!(%CalculationRequest{
        id: Ecto.UUID.generate(),
        source: "explicit",
        player_id: f.player.id,
        season_id: f.subject.season_id,
        week_start: dt!(f.subject.week_start),
        week_end: dt!(f.subject.week_end),
        selector: "version:" <> f.configuration.id,
        mapping_id: f.mapping.id,
        state: "running",
        attempt_count: 1,
        lease_fence: 2,
        lease_until: DateTime.add(now, 300, :second),
        inserted_at: now
      })

    before =
      Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
        Ecto.UUID.dump!(f.player.id)
      ]).rows

    assert {:error, :stale_fence} =
             Quotes.request_membership(
               f.subject,
               {:version, f.configuration.id},
               f.mapping.id,
               [FootballMarket.Valuation.StatisticsReader.snapshot(f.performance, f.match)],
               request.id,
               {request.id, 1}
             )

    assert Repo.query!("SELECT count(*) FROM market_quotes WHERE player_id=$1", [
             Ecto.UUID.dump!(f.player.id)
           ]).rows == before

    assert Repo.query!("SELECT count(*) FROM quote_calculations WHERE player_id=$1", [
             Ecto.UUID.dump!(f.player.id)
           ]).rows == [[0]]
  end

  test "performance quote and evaluation identity are immutable while delivery state is separate",
       f do
    assert {:ok, _} = Configurations.activate(f.configuration.id, nil)
    assert {:ok, %{calculation: calculation}} = Quotes.request(f.subject, :active, f.mapping.id)
    {:ok, [event]} = Quotes.pending_evaluations()

    assert_raise Postgrex.Error, fn ->
      Repo.query!("UPDATE market_quotes SET unit_price=9 WHERE calculation_id=$1", [
        Ecto.UUID.dump!(calculation.id)
      ])
    end

    assert_raise Postgrex.Error, fn ->
      Repo.query!("UPDATE quote_evaluation_requests SET quote_id=gen_random_uuid() WHERE id=$1", [
        Ecto.UUID.dump!(event.id)
      ])
    end

    assert {:ok, _claim} = Quotes.claim_evaluation(event.id)
    assert {:ok, []} = Quotes.pending_evaluations()

    assert Repo.query!("SELECT state FROM quote_evaluation_requests WHERE id=$1", [
             Ecto.UUID.dump!(event.id)
           ]).rows == [["leased"]]
  end
end
