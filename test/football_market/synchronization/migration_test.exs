defmodule FootballMarket.Synchronization.MigrationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  test "PostgreSQL owns retained ledgers and one-shot delivery receipts" do
    for table <-
          ~w(oban_jobs synchronization_runs synchronization_attempts synchronization_triggers synchronization_schedules synchronization_occurrences catalog_delivery_receipts) do
      %{rows: [[name]]} =
        Ecto.Adapters.SQL.query!(FootballMarket.Repo, "SELECT to_regclass($1)::text", [table])

      assert name == table, "required durable table missing: #{table}"
    end
  end

  test "prefix migrations isolate constraints from public search_path and retain referenced history" do
    FootballMarket.Synchronization.Case.with_store(fn _repo ->
      alias FootballMarket.Synchronization.{Fixtures, Run, Trigger}
      %{rows: [[schema]]} = Repo.query!("SELECT current_schema()", [])
      assert String.starts_with?(schema, "sync_test_")

      {:ok, first} =
        FootballMarket.Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

      original = Repo.get!(Run, first.run_id)
      duplicate = %{original | id: Ecto.UUID.generate()}

      assert_raise Ecto.ConstraintError, fn ->
        Repo.transaction(fn -> Repo.insert!(duplicate) end)
      end

      Repo.update!(Ecto.Changeset.change(original, state: "failed"))

      {:ok, second} =
        FootballMarket.Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

      assert first.run_id != second.run_id
      assert Repo.aggregate(Run, :count) == 2
      assert Repo.aggregate(Trigger, :count) == 2

      assert_raise Ecto.ConstraintError, fn ->
        Repo.transaction(fn -> Repo.delete!(Repo.get!(Run, first.run_id)) end)
      end

      %{rows: [[foreign_count]]} =
        Repo.query!(
          "SELECT count(*) FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid JOIN pg_namespace n ON n.oid=t.relnamespace JOIN pg_class f ON f.oid=c.confrelid JOIN pg_namespace fn ON fn.oid=f.relnamespace WHERE n.nspname=$1 AND c.contype='f' AND fn.nspname <> $1",
          [schema]
        )

      assert foreign_count == 0
    end)
  end
end
