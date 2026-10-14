defmodule FootballMarket.Valuation.Configurations.ImmutabilityTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Repo, ValuationCase}
  alias FootballMarket.Valuation.Configurations

  test "ordinary SQL protects unused versions, metadata, anchor and history" do
    c = private_schema()
    f = ValuationCase.fixture()
    assert {:ok, a} = Configurations.create(rules(f.position.id))
    assert {:ok, b} = Configurations.create(rules(f.position.id))

    assert_raise Ecto.ConstraintError, ~r/valuation_immutable/, fn ->
      Repo.update!(Ecto.Changeset.change(a, strategy_id: "other"))
    end

    assert_raise Ecto.ConstraintError, ~r/valuation_immutable/, fn -> Repo.delete!(b) end

    %{rows: references} =
      Repo.query!(
        "SELECT confdeltype::text, confupdtype::text FROM pg_constraint WHERE conrelid='valuation_selection_changes'::regclass AND contype='f'"
      )

    assert length(references) == 2
    assert Enum.all?(references, fn [d, u] -> d == "r" and u == "r" end)

    for statement <- [
          "UPDATE valuation_configuration_versions SET id=id",
          "UPDATE valuation_configuration_versions SET strategy_id='other'",
          "UPDATE valuation_configuration_versions SET formula_version='2'",
          "UPDATE valuation_configuration_versions SET rules='{}'",
          "UPDATE valuation_configuration_versions SET created_at=now()",
          "DELETE FROM valuation_configuration_versions",
          "TRUNCATE valuation_configuration_versions CASCADE",
          "UPDATE valuation_selection_locks SET id=id",
          "DELETE FROM valuation_selection_locks",
          "TRUNCATE valuation_selection_locks"
        ] do
      assert {:error, %Postgrex.Error{postgres: %{constraint: "valuation_immutable"}}} =
               Repo.query(statement)

      assert {:ok, %{version: ^a}} = Configurations.get(a.id)
    end

    assert {:error, %Postgrex.Error{postgres: %{code: :unique_violation}}} =
             Repo.query(
               "INSERT INTO valuation_configuration_versions SELECT * FROM valuation_configuration_versions WHERE id=$1",
               [Ecto.UUID.dump!(a.id)]
             )

    # Successful history fixture before mutation assertions, no missing-table false positives.
    assert {:ok, _} =
             Repo.query(
               "INSERT INTO valuation_selection_changes(previous_version_id,new_version_id) VALUES(NULL,$1)",
               [Ecto.UUID.dump!(a.id)]
             )

    for sql <- [
          "UPDATE valuation_selection_changes SET effective_at=now()",
          "DELETE FROM valuation_selection_changes",
          "TRUNCATE valuation_selection_changes"
        ] do
      assert {:error, %Postgrex.Error{postgres: %{constraint: "valuation_immutable"}}} =
               Repo.query(sql)
    end

    for {previous, target} <- [{nil, b.id}, {a.id, a.id}] do
      assert {:error, %Postgrex.Error{postgres: %{constraint: "valuation_predecessor"}}} =
               Repo.query(
                 "INSERT INTO valuation_selection_changes(previous_version_id,new_version_id) VALUES($1,$2)",
                 [previous && Ecto.UUID.dump!(previous), Ecto.UUID.dump!(target)]
               )
    end

    assert {:error, %Postgrex.Error{postgres: %{code: :foreign_key_violation}}} =
             Repo.query(
               "INSERT INTO valuation_selection_changes(previous_version_id,new_version_id) VALUES($1,$2)",
               [Ecto.UUID.dump!(a.id), Ecto.UUID.dump!(Ecto.UUID.generate())]
             )

    for isolation <- ["REPEATABLE READ", "SERIALIZABLE"] do
      assert_raise Postgrex.Error, ~r/valuation write isolation/, fn ->
        Repo.transaction(fn ->
          Repo.query!("SET TRANSACTION ISOLATION LEVEL " <> isolation)

          Repo.query!(
            "INSERT INTO valuation_selection_changes(previous_version_id,new_version_id) VALUES($1,$2)",
            [Ecto.UUID.dump!(a.id), Ecto.UUID.dump!(b.id)]
          )
        end)
      end
    end

    assert {:ok, %{active_version_id: id, versions: versions}} = Configurations.list()
    assert id == a.id and length(versions) == 2
    assert {:ok, [_]} = Configurations.history()
    assert c.schema =~ "valuation_test_"
  end
end
