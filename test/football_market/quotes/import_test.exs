defmodule FootballMarket.Quotes.ImportTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "accepted changed facts pin complete immutable weekly membership before dispatch" do
    scope = Fixtures.scope(2085)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    delivery = Case.delivery_context!(scope)

    assert {:ok, accepted} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: delivery]
             )

    intent = Repo.get!(CalculationIntent, accepted.calculation_intent_id)

    assert [[snapshot_id, schema_version, membership, digest]] =
             Repo.query!(
               "SELECT id, schema_version, cardinality(membership), digest FROM quote_import_scope_snapshots WHERE intent_id=$1",
               [Ecto.UUID.dump!(intent.id)]
             ).rows

    assert schema_version == 1
    assert membership == 1
    assert is_binary(digest) and byte_size(digest) == 64

    assert [[1]] =
             Repo.query!(
               "SELECT count(*) FROM quote_import_snapshot_facts WHERE snapshot_id=$1",
               [snapshot_id]
             ).rows

    replay_delivery = Case.delivery_context!(scope)

    assert {:ok, replayed} =
             Statistics.Ingestion.import_scope(
               scope,
               Case.provider_options(candidate) ++ [delivery_context: replay_delivery]
             )

    assert replayed.status == :replay

    assert Repo.query!("SELECT count(*) FROM quote_import_scope_snapshots WHERE intent_id=$1", [
             Ecto.UUID.dump!(intent.id)
           ]).rows == [[1]]
  end
end
