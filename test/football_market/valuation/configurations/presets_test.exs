defmodule FootballMarket.Valuation.Configurations.PresetsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Accounts, Catalog, Repo}
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.Presets

  setup do
    {:ok, user} =
      Accounts.register_user(%{
        email: "preset-admin@example.test",
        password: "correct-password-123"
      })

    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    actor = %AuthenticatedActor{
      account_id: user.id,
      authentication_method: :browser,
      credential_id: Ecto.UUID.generate()
    }

    %{user: user, actor: actor}
  end

  test "authorized inspection prepares exactly two fixed bases idempotently without activating or pricing",
       f do
    positions_before = Repo.aggregate(Catalog.Position, :count)
    assert {:error, :forbidden} = Configurations.inspect_for(f.actor)
    assert {:error, :forbidden} = Configurations.activate_for(f.actor, Ecto.UUID.generate(), nil)
    assert Repo.aggregate(Catalog.Position, :count) == positions_before
    assert {:ok, %{versions: []}} = Configurations.list()
    Application.put_env(:football_market, :initial_issuance_recipients, [f.user.id])
    before_quotes = Repo.all(FootballMarket.Market.Quote)
    before_jobs = Repo.aggregate(Oban.Job, :count)

    assert {:ok, %{versions: [balanced, positional] = bases, active_version_id: nil}} =
             Configurations.inspect_for(f.actor)

    assert balanced.strategy_id == "balanced"
    assert positional.strategy_id == "position_aware"
    assert balanced.config.weights.goals == 4
    assert Decimal.equal?(balanced.config.weights.yellow_cards, Decimal.new("-0.5"))
    assert balanced.references == %{goals: 2, assists: 2, yellow_cards: 2, red_cards: 1}
    assert positional.references.saves == 10
    assert positional.config.weights.goalkeeper.goals_conceded == -2

    assert Decimal.equal?(
             positional.config.weights.midfielder.shots_on_target,
             Decimal.new("1.5")
           )

    refute Map.has_key?(positional.config.weights.forward, :saves)

    assert {:ok, %{versions: ^bases, active_version_id: nil}} =
             Configurations.inspect_for(f.actor)

    assert {:ok, _} = Configurations.activate_for(f.actor, balanced.id, nil)

    assert {:ok, %{versions: ^bases, active_version_id: active}} =
             Configurations.inspect_for(f.actor)

    assert active == balanced.id
    assert Repo.all(FootballMarket.Market.Quote) == before_quotes
    assert Repo.aggregate(Oban.Job, :count) == before_jobs
  end

  test "historical custom versions are retained but cannot be selected through Administration",
       f do
    Application.put_env(:football_market, :initial_issuance_recipients, [f.user.id])

    assert {:ok, %{versions: [balanced, positional] = bases}} =
             Configurations.inspect_for(f.actor)

    rules =
      Presets.rules("balanced", balanced.position_mapping)
      |> put_in([:config, :weights, :goals], 99)

    assert {:ok, custom} = Configurations.create(rules)
    assert {:ok, _} = Configurations.activate(custom.id, nil)

    assert {:ok, %{versions: ^bases, active_version_id: current}} =
             Configurations.inspect_for(f.actor)

    assert current == custom.id

    assert {:error, :unsupported_configuration} =
             Configurations.activate_for(f.actor, custom.id, custom.id)

    assert {:ok, %{id: active}} = Configurations.active()
    assert active == custom.id
    assert {:ok, %{versions: all}} = Configurations.list()
    assert length(all) == 3

    assert {:ok, %{version: ^custom}} =
             Configurations.get(custom.id)
             |> then(fn {:ok, data} -> {:ok, Map.take(data, [:version])} end)

    assert {:ok, _} = Configurations.activate_for(f.actor, positional.id, custom.id)
    assert {:ok, %{id: active}} = Configurations.active()
    assert active == positional.id
  end

  test "conflicting catalog identities roll back automatic preparation without guessed mappings",
       f do
    Application.put_env(:football_market, :initial_issuance_recipients, [f.user.id])
    assert {:ok, _} = Catalog.create_position(%{code: "OTHER", name: "Goalkeeper"})
    positions_before = Repo.all(Catalog.Position)
    assert {:error, :missing_standard_positions} = Configurations.inspect_for(f.actor)
    assert Repo.all(Catalog.Position) == positions_before
    assert {:ok, %{versions: [], active_version_id: nil}} = Configurations.list()
  end

  test "automatic preparation reuses normalized canonical role identities", f do
    Application.put_env(:football_market, :initial_issuance_recipients, [f.user.id])
    assert {:ok, keeper} = Catalog.create_position(%{code: " gk ", name: "Goalkeeper"})
    assert {:ok, %{versions: bases}} = Configurations.inspect_for(f.actor)
    assert length(bases) == 2
    assert Enum.all?(bases, &({keeper.id, :goalkeeper} in &1.position_mapping))
    assert {:ok, ^keeper} = Catalog.get_position_by_code("GK")
  end
end
