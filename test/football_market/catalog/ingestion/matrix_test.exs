defmodule FootballMarket.Catalog.Ingestion.MatrixTest do
  use ExUnit.Case, async: false
  import Ecto.Query
  alias Ecto.Adapters.SQL.Sandbox
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.{Player, Team}
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Ingestion.Observation
  alias FootballMarket.Catalog.Ingestion.SourceBinding

  test "two fresh five-league/two-season runs reproduce independently expected catalogs and outcomes" do
    before = Sandbox.unboxed_run(Repo, fn -> {snapshot(), acceptance_snapshot()} end)

    runs =
      for _ <- 1..2 do
        owner = Sandbox.start_owner!(Repo, shared: true)

        evidence =
          try do
            positions!()

            outcomes =
              for {code, _name} <- leagues(), year <- [2025, 2026] do
                c = candidate(code, year)
                r = request(code, year)
                assert {:ok, first} = Ingestion.import_catalog(r, options(c))

                expected =
                  expected_initial_counts()
                  |> put_in(
                    ["league"],
                    if(year == 2025,
                      do: %{"created" => 1, "updated" => 0, "unchanged" => 0},
                      else: %{"created" => 0, "updated" => 0, "unchanged" => 1}
                    )
                  )

                assert first.counts == expected

                for _ <- 1..10 do
                  assert {:ok, replay} = Ingestion.import_catalog(r, options(c))
                  assert replay.status == :replay
                  assert replay.acceptance_reference == first.acceptance_reference
                  assert replay.counts_historical
                end

                assert {:ok, rereferenced} = Ingestion.import_catalog(r, options(rereference(c)))
                assert rereferenced.status == :replay

                assert {:ok, same} =
                         Ingestion.import_catalog(r, options(c, ~U[2026-10-07 12:00:00.000000Z]))

                assert same.status == :accepted_unchanged

                assert same.counts == %{
                         "league" => %{"created" => 0, "updated" => 0, "unchanged" => 1},
                         "season" => %{"created" => 0, "updated" => 0, "unchanged" => 1},
                         "team" => %{"created" => 0, "updated" => 0, "unchanged" => 2},
                         "player" => %{"created" => 0, "updated" => 0, "unchanged" => 1}
                       }

                assert {:error, stale} =
                         Ingestion.import_catalog(r, options(c, ~U[2026-10-05 12:00:00.000000Z]))

                assert stale.status == :stale_observation
                {code, year, first.status, first.counts, same.status, same.counts}
              end

            rows =
              Repo.all(
                from p in Player,
                  join: t in Team,
                  on: t.id == p.team_id,
                  join: s in FootballMarket.Catalog.Season,
                  on: s.id == p.season_id,
                  join: l in FootballMarket.Catalog.League,
                  on: l.id == s.league_id,
                  join: pos in FootballMarket.Catalog.Position,
                  on: pos.id == p.position_id,
                  order_by: [l.code, s.start_year],
                  select: {l.code, s.start_year, p.display_name, t.code, t.name, pos.code}
              )

            expected_rows =
              for {code, _} <- leagues(),
                  year <- [2025, 2026],
                  do: {code, year, "Alex", "ALP", "Alpha", "GK"}

            assert Enum.sort(rows) == Enum.sort(expected_rows)
            assert Repo.aggregate(Observation, :count) == 20
            assert Repo.aggregate(SourceBinding, :count) == 50

            observations =
              Repo.all(
                from o in Observation,
                  order_by: [o.provider, o.retrieved_at, o.canonical_delivery],
                  select:
                    {o.provider, o.retrieved_at, o.fixture_id, o.canonical_delivery, o.counts,
                     o.revision}
              )

            {outcomes, rows, observations}
          after
            Sandbox.stop_owner(owner)
          end

        assert Sandbox.unboxed_run(Repo, fn -> {snapshot(), acceptance_snapshot()} end) == before
        evidence
      end

    assert Enum.at(runs, 0) == Enum.at(runs, 1)
  end
end
