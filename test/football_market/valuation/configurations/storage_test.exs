defmodule FootballMarket.Valuation.Configurations.StorageTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{ValuationCase, Catalog, CatalogCase}
  alias FootballMarket.Valuation.Configurations

  test "empty storage differs from unknown and complete distinct saves never activate" do
    assert {:ok, %{versions: [], active_version_id: nil}} = Configurations.list()
    assert {:error, %{kind: :not_found}} = Configurations.get(Ecto.UUID.generate())
    assert {:error, %{kind: :validation}} = Configurations.get("bad")
    assert {:error, %{kind: :no_active_configuration}} = Configurations.active()
    f = ValuationCase.fixture()
    {:ok, unused} = Catalog.create_position(CatalogCase.position_attrs())

    for strategy <- ["balanced", "position_aware"] do
      r = rules(f.position.id, strategy)
      r = %{r | position_mapping: [{unused.id, :forward} | r.position_mapping]}
      assert {:ok, a} = Configurations.create(r)
      assert {:ok, b} = Configurations.create(r)
      refute a.id == b.id
      assert a.config == r.config
      assert a.references == r.references
      assert a.position_mapping == Enum.sort(r.position_mapping)
      assert a.strategy_id == strategy and a.formula_version == "1"
      assert %DateTime{} = a.created_at
      assert {:ok, %{version: ^a, active_version_id: nil}} = Configurations.get(a.id)
    end

    assert {:ok, %{versions: versions, active_version_id: nil}} = Configurations.list()
    assert length(versions) == 4

    assert versions ==
             Enum.sort_by(versions, &{DateTime.to_unix(&1.created_at, :microsecond), &1.id})

    assert {:ok, []} = Configurations.history()
  end

  test "invalid existing position and malformed rules leave no partial row" do
    f = ValuationCase.fixture()
    assert {:error, %{kind: :validation}} = Configurations.create(rules(Ecto.UUID.generate()))

    assert {:error, %{kind: :validation}} =
             Configurations.create(%{rules(f.position.id) | references: %{}})

    assert {:ok, %{versions: []}} = Configurations.list()
  end

  test "tied creation times use stable UUID ordering and remain distinct" do
    f = ValuationCase.fixture()
    {:ok, original} = Configurations.create(rules(f.position.id))
    tied = ~U[2026-10-13 12:00:00.000000Z]

    copies =
      for _ <- 1..3 do
        Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
          strategy_id: original.strategy_id,
          formula_version: original.formula_version,
          rules: original.rules,
          created_at: tied
        })
      end

    assert {:ok, %{versions: listed, active_version_id: nil}} = Configurations.list()
    tied_ids = listed |> Enum.filter(&(&1.created_at == tied)) |> Enum.map(& &1.id)
    assert tied_ids == Enum.sort(Enum.map(copies, & &1.id))
    assert length(tied_ids) == 3
  end

  test "storage read failure is visible rather than empty/not-found/no-active" do
    f = ValuationCase.fixture()
    {:ok, v} = Configurations.create(rules(f.position.id))

    for fun <- [
          fn -> Configurations.list() end,
          fn -> Configurations.get(v.id) end,
          fn -> Configurations.active() end
        ] do
      error =
        assert_raise Postgrex.Error, fn ->
          Repo.transaction(fn ->
            Repo.query!("SET LOCAL search_path TO pg_catalog")
            fun.()
          end)
        end

      assert error.postgres.code == :undefined_table
    end

    assert {:ok, %{version: ^v}} = Configurations.get(v.id)
  end
end
