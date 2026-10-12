defmodule FootballMarket.Catalog.Ingestion.PublicationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Catalog.Team

  test "complete import atomically publishes independent rows and counts" do
    positions!()
    assert {:ok, outcome} = Ingestion.import_catalog(request(), options())
    assert outcome.status == :accepted_with_changes
    assert outcome.counts == expected_initial_counts()
    assert Repo.aggregate(Player, :count) == 1
    assert Repo.aggregate(Team, :count) == 2
    assert outcome.fixture_id == "independent-catalog"
  end

  test "persistence interruption leaves no orphan hierarchy or acceptance" do
    positions!()
    before = snapshot()
    publication_failpoint(:after_bindings)
    assert {:error, outcome} = Ingestion.import_catalog(request(), options())
    assert outcome.status == :persistence_failure
    assert snapshot() == before
    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
    Process.delete(:catalog_ingestion_failpoint)
  end

  test "durable ingestion has all four FK-backed tables" do
    expected =
      ~w(catalog_ingestion_scopes catalog_source_bindings catalog_ingestion_observations catalog_ingestion_observation_bindings)

    %{rows: rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name = ANY($1) ORDER BY table_name",
        [expected]
      )

    assert Enum.map(rows, &hd/1) == Enum.sort(expected)
  end

  test "team business uniqueness is initially immediate and explicitly deferrable" do
    %{rows: rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT conname, condeferrable, condeferred FROM pg_constraint WHERE conname = ANY($1) ORDER BY conname",
        [~w(teams_season_normalized_code_index teams_season_normalized_name_index)]
      )

    assert rows == [
             ["teams_season_normalized_code_index", true, false],
             ["teams_season_normalized_name_index", true, false]
           ]
  end

  test "every publication failpoint rolls back prior accepted rows bindings membership and pointer" do
    positions!()
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    before = {snapshot(), acceptance_snapshot()}
    c = candidate()

    update = %{
      c
      | facts: %{c.facts | players: [%{hd(c.facts.players) | display_name: "Changed"}]}
    }

    for point <- [:after_catalog, :after_bindings, :after_observation] do
      publication_failpoint(point)

      assert {:error, o} =
               Ingestion.import_catalog(
                 request(),
                 options(update, ~U[2026-10-07 12:00:00.000000Z])
               )

      assert o.status == :persistence_failure
      assert o.acceptance_reference == nil
      assert {snapshot(), acceptance_snapshot()} == before
    end

    Process.delete(:catalog_ingestion_failpoint)
  end

  test "typed targets and membership reject dangling cross-kind and cross-scope records" do
    positions!()
    assert {:ok, _} = Ingestion.import_catalog(request(), options())

    assert {:ok, _} =
             Ingestion.import_catalog(request("PL", 2026), options(candidate("PL", 2026)))

    [scope, foreign] =
      Repo.all(from s in FootballMarket.Catalog.Ingestion.Scope, order_by: s.start_year)

    own =
      Repo.get_by!(FootballMarket.Catalog.Ingestion.SourceBinding,
        scope_id: scope.id,
        kind: "player"
      )

    refute FootballMarket.Catalog.Ingestion.SourceBinding.changeset(own, %{source_id: "retarget"}).valid?

    foreign_player = Repo.get_by!(Player, season_id: foreign.season_id)

    for changes <- [
          %{player_id: foreign_player.id},
          %{player_id: Ecto.UUID.generate()},
          %{kind: "team"},
          %{provider: own.provider, source_id: "different"}
        ] do
      assert_raise Ecto.ConstraintError, fn ->
        Repo.transaction(
          fn ->
            attrs =
              own
              |> Map.from_struct()
              |> Map.drop([:__meta__, :id])
              |> Map.merge(%{provider: "negative-test", source_id: "negative-source"})
              |> Map.merge(changes)

            attrs = Map.put(attrs, :id, Ecto.UUID.generate())
            Repo.insert!(struct(FootballMarket.Catalog.Ingestion.SourceBinding, attrs))
          end,
          mode: :savepoint
        )
      end
    end
  end

  test "membership is complete and cannot join observations and bindings from different scopes" do
    positions!()
    assert {:ok, first} = Ingestion.import_catalog(request(), options())

    assert {:ok, second} =
             Ingestion.import_catalog(request("PL", 2026), options(candidate("PL", 2026)))

    first_o = Repo.get!(FootballMarket.Catalog.Ingestion.Observation, first.acceptance_reference)

    second_o =
      Repo.get!(FootballMarket.Catalog.Ingestion.Observation, second.acceptance_reference)

    member =
      Repo.one!(
        from m in FootballMarket.Catalog.Ingestion.ObservationBinding,
          where: m.observation_id == ^first_o.id,
          limit: 1
      )

    refute FootballMarket.Catalog.Ingestion.ObservationBinding.changeset(member, %{
             scope_id: second_o.scope_id
           }).valid?

    assert Repo.aggregate(
             from(m in FootballMarket.Catalog.Ingestion.ObservationBinding,
               where: m.observation_id == ^first_o.id
             ),
             :count
           ) == 5

    assert_raise Ecto.ConstraintError, fn ->
      Repo.transaction(
        fn ->
          Repo.insert!(%FootballMarket.Catalog.Ingestion.ObservationBinding{
            observation_id: second_o.id,
            scope_id: second_o.scope_id,
            binding_id: member.binding_id
          })
        end,
        mode: :savepoint
      )
    end
  end
end
