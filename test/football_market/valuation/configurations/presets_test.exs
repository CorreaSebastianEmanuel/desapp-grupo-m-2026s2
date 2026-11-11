defmodule FootballMarket.Valuation.Configurations.PresetsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Accounts, Catalog, Repo}
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.{Editor, Presets}

  test "explicit preset setup is idempotent and custom edits retain immutable versions and selection" do
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

    assert {:error, :forbidden} = Configurations.provision_presets_for(actor)
    assert {:error, :forbidden} = Configurations.save_custom_for(actor, Ecto.UUID.generate(), %{})
    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])

    for {code, role} <- Presets.roles() do
      case Repo.get_by(Catalog.Position, code: code) do
        nil -> {:ok, _} = Catalog.create_position(%{code: code, name: Atom.to_string(role)})
        _ -> :ok
      end
    end

    before_quotes = Repo.all(FootballMarket.Market.Quote)
    before_jobs = Repo.aggregate(Oban.Job, :count)
    assert {:ok, [balanced, positional]} = Configurations.provision_presets_for(actor)
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
    assert {:error, %{kind: :no_active_configuration}} = Configurations.active()
    assert {:ok, _} = Configurations.activate(balanced.id, nil)
    assert {:ok, [^balanced, ^positional]} = Configurations.provision_presets_for(actor)
    params = Editor.values(balanced) |> put_in(["weights", "overall", "goals"], "6.25")
    assert {:ok, custom} = Configurations.save_custom_for(actor, balanced.id, params)
    refute custom.id == balanced.id
    assert custom.preset_key == nil
    assert Decimal.equal?(custom.config.weights.goals, Decimal.new("6.25"))

    assert {:ok, %{version: ^balanced}} =
             Configurations.get(balanced.id)
             |> then(fn {:ok, data} -> {:ok, Map.take(data, [:version])} end)

    assert {:ok, %{id: active}} = Configurations.active()
    assert active == balanced.id
    assert Repo.all(FootballMarket.Market.Quote) == before_quotes
    assert Repo.aggregate(Oban.Job, :count) == before_jobs

    assert {:error, _} =
             Configurations.save_custom_for(
               actor,
               balanced.id,
               put_in(params, ["references", "goals"], "0")
             )

    assert {:error, _} =
             Configurations.save_custom_for(
               actor,
               balanced.id,
               put_in(params, ["weights", "overall", "goals"], "NaN")
             )

    assert {:error, _} =
             Configurations.save_custom_for(
               actor,
               balanced.id,
               Map.put(params, "strategy_id", "other")
             )

    assert {:ok, equal} =
             Configurations.save_custom_for(actor, balanced.id, Editor.values(balanced))

    assert Presets.equivalent_key(equal) == Presets.equivalent_key(balanced)
    refute equal.id == balanced.id
  end
end
