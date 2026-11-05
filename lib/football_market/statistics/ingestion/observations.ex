defmodule FootballMarket.Statistics.Ingestion.Observations do
  @moduledoc "Accepted fact provenance and fixture observations inside the publisher transaction."
  alias FootballMarket.Repo

  alias FootballMarket.Statistics.Ingestion.{
    FactProvenance,
    FactObservation,
    FixtureArtifact,
    Provenance
  }

  def append_replay_observations!(result, check) do
    facts =
      Enum.map(result.facts.matches, &{:match, &1}) ++
        Enum.map(result.facts.performances, &{:performance, &1})

    Enum.each(facts, fn {kind, fact} ->
      identity = Provenance.identity(result, kind, fact)

      provenance =
        Repo.get_by!(FactProvenance,
          provider: result.provenance.provider,
          source_identity: identity
        )

      Repo.insert!(%FactObservation{
        id: Ecto.UUID.generate(),
        provenance_id: provenance.id,
        check_id: check.id
      })
    end)
  end

  def fixture_artifact!(%{provenance: %{fixture_id: nil}}), do: nil

  def fixture_artifact!(result) do
    ref = result.provenance.fixture_id
    path = Path.expand("test/fixtures/statistics_ingestion/documents.exs")
    {inventory, _} = Code.eval_file("test/fixtures/statistics_ingestion/inventory.exs")
    metadata = Map.get(inventory, ref) || Repo.rollback(:unapproved_fixture)
    {:ok, bytes} = File.read(path)
    sha = :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)

    if Map.get(metadata, :non_live) != true or Map.get(metadata, :digest) != sha,
      do: Repo.rollback(:unapproved_fixture)

    row = Repo.get_by(FixtureArtifact, fixture_id: ref, sha256: sha)

    row ||
      Repo.insert!(%FixtureArtifact{
        id: Ecto.UUID.generate(),
        fixture_id: ref,
        artifact_path: "test/fixtures/statistics_ingestion/documents.exs",
        sha256: sha,
        origin: metadata.origin,
        synthetic_created_at: metadata.created_at,
        expected_case: ref,
        rule_ids: metadata.rules,
        non_live: true
      })
  end

  def observe_fact!(result, {fact, id, kind, _state}, check, receipt, artifact, encoded) do
    provenance =
      Repo.get_by(
        FactProvenance,
        if(kind == :match, do: [match_id: id], else: [performance_id: id])
      ) ||
        insert_provenance!(result, fact, id, kind, check, receipt, artifact, encoded)

    Repo.insert!(%FactObservation{
      id: Ecto.UUID.generate(),
      provenance_id: provenance.id,
      check_id: check.id
    })
  end

  defp insert_provenance!(result, fact, id, kind, check, receipt, artifact, encoded) do
    identity = Provenance.identity(result, kind, fact)

    attrs = %{
      id: Ecto.UUID.generate(),
      match_id: if(kind == :match, do: id),
      performance_id: if(kind == :performance, do: id),
      accepted_check_id: check.id,
      run_id: receipt.run_id,
      provider: result.provenance.provider,
      retrieved_at: result.provenance.retrieved_at,
      source_identity: identity,
      source_material: encoded.material,
      fixture_artifact_id: artifact && artifact.id
    }

    Repo.insert!(
      %FactProvenance{}
      |> Ecto.Changeset.cast(attrs, Map.keys(attrs))
      |> Ecto.Changeset.validate_required([
        :accepted_check_id,
        :run_id,
        :provider,
        :retrieved_at,
        :source_identity,
        :source_material
      ])
    )
  end
end
