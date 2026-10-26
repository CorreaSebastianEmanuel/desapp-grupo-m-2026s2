defmodule FootballMarket.Statistics.Freshness.ValuationStatusTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, FreshnessCase, Synchronization}
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  setup do
    f = FreshnessCase.fixture()
    first = hd(f.candidate.facts.matches)
    second = %{first | ref: "match-2", kickoff_at: ~U[2026-01-08 12:00:00Z]}
    performance = hd(f.candidate.facts.performances)

    candidate =
      Case.candidate(Fixtures.request(f.scope),
        matches: [first, second],
        performances: [performance, %{performance | ref: "performance-2", match_ref: second.ref}]
      )

    sync = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(sync, :sources, %{"freshness-fixture" => Case.source(candidate)})
    )

    FreshnessCase.perform!(f)
    id = Freshness.for_player(f.player).valuation.calculation_intent_id

    requests =
      Repo.query!(
        "SELECT id, week_start, week_end FROM quote_import_scope_snapshots WHERE intent_id=$1 ORDER BY week_start",
        [Ecto.UUID.dump!(id)]
      ).rows
      |> Enum.map(fn [sid, from, to] ->
        Repo.insert!(%CalculationRequest{
          id: Ecto.UUID.generate(),
          source: "import",
          snapshot_id: Ecto.UUID.load!(sid),
          intent_id: id,
          player_id: f.player.id,
          season_id: f.player.season_id,
          week_start: DateTime.from_naive!(from, "Etc/UTC"),
          week_end: DateTime.from_naive!(to, "Etc/UTC"),
          selector: "active",
          state: "pending",
          inserted_at: DateTime.utc_now()
        })
      end)

    {:ok, Map.merge(f, %{intent: Repo.get!(CalculationIntent, id), requests: requests})}
  end

  test "all weekly requests contribute and partial success cannot claim valuation completed", f do
    assert length(f.requests) == 2
    Repo.update!(Ecto.Changeset.change(f.intent, state: "delivered"))
    [first, second] = f.requests
    Repo.update!(Ecto.Changeset.change(first, state: "no_quote"))
    current = Freshness.for_player(f.player).valuation
    assert current.state == "pending"
    assert current.request_states == %{"no_quote" => 1, "pending" => 1}
    Repo.update!(Ecto.Changeset.change(second, state: "running"))
    assert Freshness.for_player(f.player).valuation.state == "running"
    Repo.update!(Ecto.Changeset.change(second, state: "exhausted"))
    assert Freshness.for_player(f.player).valuation.state == "failed"
    Repo.update!(Ecto.Changeset.change(second, state: "no_quote"))
    assert Freshness.for_player(f.player).valuation.state == "completed"
  end

  test "newer legacy imports without snapshots override older valuation status", f do
    check = Repo.get!(FootballMarket.Statistics.Ingestion.Check, f.intent.accepted_check_id)
    fields = check |> Map.from_struct() |> Map.drop([:__meta__, :id])
    legacy_check = Repo.insert!(struct(FootballMarket.Statistics.Ingestion.Check, fields))

    legacy =
      Repo.insert!(%CalculationIntent{
        accepted_check_id: legacy_check.id,
        changed_performance_ids: f.intent.changed_performance_ids,
        requested_at: DateTime.add(f.intent.requested_at, 1, :second)
      })

    current = Freshness.for_player(f.player).valuation
    assert current.state == "pending"
    assert current.calculation_intent_id == legacy.id
    Repo.update!(Ecto.Changeset.change(legacy, state: "failed"))
    assert Freshness.for_player(f.player).valuation.state == "failed"
  end

  test "dispatch exhaustion and explicit dispatch failure remain failed", f do
    Repo.update!(Ecto.Changeset.change(f.intent, attempts: 3))
    assert Freshness.for_player(f.player).valuation.state == "failed"
    Repo.update!(Ecto.Changeset.change(f.intent, attempts: 0, state: "failed"))
    assert Freshness.for_player(f.player).valuation.state == "failed"
  end
end
