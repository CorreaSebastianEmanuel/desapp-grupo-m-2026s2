defmodule FootballMarket.Synchronization.InputTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Synchronization.{Input, Fixtures}

  setup do
    old = Application.get_env(:football_market, FootballMarket.Synchronization)

    Application.put_env(:football_market, FootballMarket.Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, FootballMarket.Synchronization, old) end)
  end

  test "normalizes scope and pins non-secret effective fixture identity" do
    assert {:ok, input} =
             Input.normalize(%{Fixtures.scope() | league_code: " pl "},
               source_ref: "fixture",
               fixture_ref: "offline"
             )

    assert input.scope == Fixtures.scope()
    assert input.material["source_ref"] == "fixture"
    assert byte_size(input.digest) == 64
    refute Jason.encode!(input.material) =~ "display_name"
  end

  test "rejects missing sources, unknown options, invalid scopes and execution policy" do
    for {scope, options} <- [
          {Fixtures.scope(), []},
          {Fixtures.scope(), [source_ref: "unknown"]},
          {Fixtures.scope(), [source_ref: "fixture", runtime: :unapproved]},
          {%{Fixtures.scope() | league_code: "search"}, [source_ref: "fixture"]},
          {Fixtures.scope(), [source_ref: "fixture", policy: %{attempt_limit: 0}]}
        ] do
      assert {:error, _} = Input.normalize(scope, options)
    end
  end

  test "validates the effective runtime contract without invoking callbacks" do
    for runtime <- [
          :invalid_runtime_configuration,
          nil,
          {},
          {nil, nil},
          {UnknownSynchronizationRuntime, nil},
          {__MODULE__, nil},
          {FootballMarket.Providers.Runtime, nil, :extra}
        ] do
      Application.put_env(:football_market, FootballMarket.Synchronization,
        sources: %{"fixture" => Map.put(Fixtures.source(), :runtime, runtime)}
      )

      assert {:error, :source_ref} = Input.normalize(Fixtures.scope(), source_ref: "fixture")
    end

    for source <- [Map.delete(Fixtures.source(), :runtime), Fixtures.source()] do
      Application.put_env(:football_market, FootballMarket.Synchronization,
        sources: %{"fixture" => source}
      )

      assert {:ok, _} = Input.normalize(Fixtures.scope(), source_ref: "fixture")
    end
  end

  test "instruction collection order is irrelevant while full input changes are distinct" do
    a =
      FootballMarket.IngestionFixtures.mapping(
        :team,
        "t-a",
        Ecto.UUID.generate(),
        "synthetic-a",
        "PL",
        2090
      )

    b = %{a | source_id: "t-b", target_id: Ecto.UUID.generate()}

    assert {:ok, left} =
             Input.normalize(Fixtures.scope(), source_ref: "fixture", mappings: [a, b])

    assert {:ok, right} =
             Input.normalize(Fixtures.scope(), source_ref: "fixture", mappings: [b, a])

    assert left.material == right.material
    assert left.digest == right.digest

    assert {:ok, changed} =
             Input.normalize(Fixtures.scope(), source_ref: "fixture", mappings: [a])

    refute left.material == changed.material
  end

  test "unsafe labels and invalid global execution settings cannot create accepted input" do
    assert {:error, _} = Input.normalize(Fixtures.scope(), source_ref: "password=do-not-persist")

    assert {:error, _} =
             Input.normalize(Fixtures.scope(),
               source_ref: "fixture",
               fixture_ref: "Bearer do-not-persist"
             )

    Application.put_env(:football_market, FootballMarket.Synchronization,
      concurrency: 0,
      sources: %{"fixture" => Fixtures.source()}
    )

    assert {:error, :policy} = Input.normalize(Fixtures.scope(), source_ref: "fixture")
  end

  test "duplicate, collapsing and wrong-provider instructions fail before executable work" do
    a =
      FootballMarket.IngestionFixtures.mapping(
        :team,
        "t-a",
        Ecto.UUID.generate(),
        "synthetic-a",
        "PL",
        2090
      )

    for entries <- [[a, a], [a, %{a | source_id: "t-b"}], [%{a | provider: "other-source"}]] do
      assert {:error, :instructions} =
               Input.normalize(Fixtures.scope(), source_ref: "fixture", mappings: entries)
    end
  end
end
