defmodule FootballMarket.Synchronization.RequestTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Fixtures, Run, Trigger}

  setup do
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
  end

  test "durable asynchronous admission coalesces across triggers without provider work" do
    assert {:ok, first} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               trigger: :initial
             )

    assert first.status == :queued
    assert first.disposition == :created

    assert {:ok, second} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               trigger: :manual
             )

    assert first.run_id == second.run_id
    assert second.disposition == :coalesced
    assert Repo.aggregate(Run, :count) == 1
    assert Repo.aggregate(Trigger, :count) == 2
    assert Repo.aggregate(Oban.Job, :count) == 1
    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  test "incompatible inputs conflict without rewriting accepted work" do
    assert {:ok, first} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               fixture_ref: "first"
             )

    before = Repo.get!(Run, first.run_id)

    assert {:error, %{category: :scope_busy, run_id: id}} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               fixture_ref: "different"
             )

    assert id == first.run_id
    assert Repo.get!(Run, id) == before
  end

  test "invalid requests create no work" do
    for options <- [
          [],
          [source_ref: "missing"],
          [source_ref: "fixture", policy: %{attempt_limit: 0}]
        ] do
      assert {:error, %{category: :invalid_request}} =
               Synchronization.request_catalog(Fixtures.scope(), options)
    end

    assert Repo.aggregate(Run, :count) == 0
    assert Repo.aggregate(Oban.Job, :count) == 0
  end

  test "invalid scraper runtime is rejected before initial or manual executable work" do
    alias FootballMarket.Providers.ScrapingFixtureData, as: Data
    data = Data.case!("access-scoped")

    source = %{
      provider: {FootballMarket.Providers.Scraping, Data.state(data)},
      runtime: :invalid_runtime_configuration,
      fixture_path: "test/fixtures/scraping/documents.exs"
    }

    Application.put_env(:football_market, Synchronization, sources: %{"scraping" => source})

    for trigger <- [:initial, :manual] do
      assert {:error, %{category: :invalid_request, field: :source_ref}} =
               Synchronization.request_catalog(Data.request(data),
                 source_ref: "scraping",
                 trigger: trigger
               )
    end

    assert Repo.aggregate(Run, :count) == 0
    assert Repo.aggregate(Trigger, :count) == 0
    assert Repo.aggregate(Oban.Job, :count) == 0
    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  test "full material comparison rejects a colliding digest and source/instruction conflicts" do
    assert {:ok, first} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    before = Repo.get!(Run, first.run_id)

    {:ok, input} =
      FootballMarket.Synchronization.Input.normalize(Fixtures.scope(),
        source_ref: "fixture",
        fixture_ref: "other"
      )

    assert {:error, %{category: :scope_busy}} =
             FootballMarket.Synchronization.Store.admit(%{input | digest: before.input_digest})

    assert Repo.get!(Run, first.run_id) == before

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source(), "other" => Fixtures.source()}
    )

    assert {:error, %{category: :scope_busy}} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "other")

    instruction =
      FootballMarket.IngestionFixtures.mapping(
        :team,
        "another",
        Ecto.UUID.generate(),
        "synthetic-a",
        "PL",
        2090
      )

    assert {:error, %{category: :scope_busy}} =
             Synchronization.request_catalog(Fixtures.scope(),
               source_ref: "fixture",
               mappings: [instruction]
             )

    assert Repo.get!(Run, first.run_id) == before

    assert {:ok, separate} =
             Synchronization.request_catalog(Fixtures.scope(2091), source_ref: "fixture")

    assert separate.run_id != first.run_id
  end

  test "unavailable durable store returns no usable identifier" do
    previous = Repo.get_dynamic_repo()

    try do
      Repo.put_dynamic_repo(:unavailable_synchronization_test_repo)

      assert {:error, %{category: :store_unavailable} = error} =
               Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

      refute Map.has_key?(error, :run_id)

      assert {:error, %{category: :store_unavailable}} =
               Synchronization.get_run(Ecto.UUID.generate())
    after
      Repo.put_dynamic_repo(previous)
    end

    assert Repo.aggregate(Run, :count) == 0
  end
end
