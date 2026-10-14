defmodule FootballMarket.Valuation.Configurations.ReplayTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Valuation, ValuationCase, Catalog, CatalogCase}
  alias FootballMarket.Valuation.{ManagedDescriptor, Descriptor}
  alias FootballMarket.Valuation.Configurations

  test "original UUID/rules/membership survive activation, late facts and mutable affiliations" do
    f = ValuationCase.fixture()
    record(f, "original", %{goals: 1})
    {:ok, a} = Configurations.create(rules(f.position.id))
    {:ok, b} = Configurations.create(rules(f.position.id, "balanced", %{goals: 4}))
    {:ok, _} = Configurations.activate(a.id, nil)
    assert {:ok, old} = Valuation.evaluate_managed(subject(f), :active)
    {:ok, _} = Configurations.activate(b.id, a.id)
    record(f, "late", %{goals: 2})
    {:ok, p} = Catalog.create_position(CatalogCase.position_attrs())
    {:ok, _} = Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: p.id})
    assert {:ok, %{score: "4.000000"}} = Valuation.evaluate_managed(subject(f), :active)
    assert {:ok, ^old} = Valuation.replay_managed(old.descriptor)

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay_managed(%{old.descriptor | configuration_version_id: b.id})

    assert {:ok, ^b} = Configurations.active()
    assert {:ok, [_, _]} = Configurations.history()
  end

  test "full binding includes absent-group settings and unused mappings even at equal score" do
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1})
    {:ok, unused} = Catalog.create_position(CatalogCase.position_attrs())
    r = rules(f.position.id, "position_aware")
    r = %{r | position_mapping: [{unused.id, :forward} | r.position_mapping]}
    {:ok, a} = Configurations.create(r)
    {:ok, old} = Valuation.evaluate_managed(subject(f), {:version, a.id})

    for changed <- [
          %{r | config: %{weights: Map.put(r.config.weights, :goalkeeper, %{goals: 999})}},
          %{r | position_mapping: [{unused.id, :midfielder}, {f.position.id, :defender}]}
        ] do
      {:ok, b} = Configurations.create(changed)
      {:ok, other} = Valuation.evaluate_managed(subject(f), {:version, b.id})
      assert other.score == old.score

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay_managed(%{old.descriptor | configuration_version_id: b.id})
    end
  end

  test "missing/unsupported originals, mismatched rules and malformed/tampered evidence yield no scores" do
    f = ValuationCase.fixture()
    record(f, "one", %{goals: 1})
    {:ok, v} = Configurations.create(rules(f.position.id))
    {:ok, result} = Valuation.evaluate_managed(subject(f), {:version, v.id})
    envelope = result.descriptor
    e = envelope.evidence

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay_managed(%{
               envelope
               | configuration_version_id: Ecto.UUID.generate()
             })

    u =
      Repo.insert!(%FootballMarket.Valuation.Configurations.Version{
        strategy_id: "retired",
        formula_version: "1",
        rules: v.rules
      })

    assert {:error, %{kind: :unsupported_strategy}} =
             Valuation.replay_managed(%{envelope | configuration_version_id: u.id})

    [fact] = e.facts

    assert {:error, %{kind: :unavailable_replay}} =
             Valuation.replay_managed(%{
               envelope
               | evidence: %{e | facts: [%{fact | match_id: Ecto.UUID.generate()}]}
             })

    for bad <- [
          %{e | strategy: %{e.strategy | strategy_id: "position_aware"}},
          %{e | strategy: %{e.strategy | version: "2"}},
          %{e | strategy: %{e.strategy | config: canonical(%{weights: %{goals: 4}})}},
          %{e | strategy: %{e.strategy | requirements: %{overall: [:assists]}}},
          %{e | request: %{e.request | references: %{goals: 4}}},
          %{e | request: %{e.request | requirements: %{overall: [:assists]}}},
          %{e | request: %{e.request | position_mapping: [{f.position.id, :forward}]}},
          %{e | facts: [%{fact | metrics: %{fact.metrics | goals: 2}}]},
          %{e | facts: [fact | :bad]},
          %{
            e
            | scopes: %{e.scopes | overall: %{e.scopes.overall | features: %{goals: "9.000000"}}}
          },
          %{e | score: "99.000000"},
          %{e | request: nil},
          Map.put(e, :unexpected, true)
        ] do
      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay_managed(%{envelope | evidence: bad})
    end

    for bad <- [
          nil,
          %{},
          %ManagedDescriptor{},
          %{envelope | schema_version: 2},
          %{envelope | configuration_version_id: "bad"},
          %{envelope | evidence: %Descriptor{}},
          Map.put(envelope, :unexpected, true)
        ] do
      assert {:error, _} = Valuation.replay_managed(bad)
    end
  end
end
