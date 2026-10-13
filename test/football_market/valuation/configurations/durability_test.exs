defmodule FootballMarket.Valuation.Configurations.DurabilityTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Repo, ValuationCase}
  alias FootballMarket.Valuation.Configurations

  @tag timeout: 180_000
  test "fresh BEAM reloads exact typed complete rules with no default activation" do
    c = private_schema()
    f = ValuationCase.fixture()

    ids =
      for strategy <- ["balanced", "position_aware"] do
        r =
          rules(
            f.position.id,
            strategy,
            %{
              goals: Decimal.new("-0.125"),
              assists: Integer.pow(10, 90) + 1,
              tackles: Decimal.new("1.00"),
              interceptions: Decimal.new("-0.00"),
              saves: %Decimal{sign: -1, coef: Integer.pow(10, 100) + 3, exp: -1000}
            },
            %{goals: 2, assists: Decimal.new("1E-1000"), tackles: 1, interceptions: 1, saves: 1}
          )

        assert {:ok, v} = Configurations.create(r)
        {v.id, canonical(Map.take(v, [:config, :references, :requirements, :position_mapping]))}
      end

    Repo.put_dynamic_repo(Repo)
    Supervisor.stop(c.repo)

    fresh(
      c.schema,
      """
      for precision <- [2, 28, 80] do
        Decimal.Context.with(%Decimal.Context{precision: precision}, fn ->
          for {id, expected} <- payload do
            assert {:ok, %{version: v, active_version_id: nil}} = Configurations.get(id)
            assert ValuationConfigurationCase.canonical(Map.take(v, [:config, :references, :requirements, :position_mapping])) == expected
          end
        end)
      end
      assert {:error, %{kind: :no_active_configuration}} = Configurations.active()
      assert {:ok, []} = Configurations.history()
      """,
      ids
    )
  end

  @tag timeout: 180_000
  test "fresh applications recover explicit selection history and inactive originals" do
    c = private_schema()
    f = ValuationCase.fixture()
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "position_aware"))

    {:ok, :ok} =
      Repo.transaction(fn ->
        {:ok, _} = Configurations.activate(a.id, nil)
        {:ok, _} = Configurations.activate(b.id, a.id)
        {:ok, _} = Configurations.activate(a.id, b.id)
        :ok
      end)

    {:ok, history} = Configurations.history()
    assert length(Enum.uniq_by(history, & &1.effective_at)) == 1
    Repo.put_dynamic_repo(Repo)
    Supervisor.stop(c.repo)

    fresh(
      c.schema,
      """
      {a, b, history} = payload
      assert {:ok, %{id: ^a}} = Configurations.active()
      assert {:ok, ^history} = Configurations.history()
      assert {:ok, %{version: %{id: ^b}, active_version_id: ^a}} = Configurations.get(b)
      """,
      {a.id, b.id, history}
    )
  end

  @tag timeout: 180_000
  test "fresh applications replay parent-held original envelopes after selection and late facts for both formulas" do
    c = private_schema()
    f = ValuationCase.fixture()
    record(f, "original", %{goals: 1})

    originals =
      for strategy <- ["balanced", "position_aware"] do
        {:ok, a} = Configurations.create(rules(f.position.id, strategy))
        {:ok, b} = Configurations.create(rules(f.position.id, strategy, %{goals: 4}))
        {:ok, original} = FootballMarket.Valuation.evaluate_managed(subject(f), {:version, a.id})
        {a.id, b.id, original.descriptor}
      end

    {original, selected, _} = hd(originals)
    {_, other, _} = List.last(originals)
    {:ok, _} = Configurations.activate(original, nil)
    {:ok, _} = Configurations.activate(selected, original)
    {:ok, _} = Configurations.activate(other, selected)
    {:ok, _} = Configurations.activate(selected, other)
    record(f, "late", %{goals: 2})
    Repo.put_dynamic_repo(Repo)
    Supervisor.stop(c.repo)
    # Two independent child lifetimes; neither retains Version structs or Repo clients.
    for _ <- 1..2 do
      fresh(
        c.schema,
        """
        {originals, subject, selected} = payload
        assert {:ok, %{id: ^selected}} = Configurations.active()
        for {a, b, envelope} <- originals do
          assert {:ok, r} = Valuation.replay_managed(envelope)
          assert r.score == "1.000000" and r.configuration_version_id == a
          assert r.descriptor == envelope
          assert {:ok, fresh} = Valuation.evaluate_managed(subject, {:version, b})
          assert fresh.score == "4.000000"
        end
        """,
        {originals, subject(f), selected}
      )
    end
  end
end
