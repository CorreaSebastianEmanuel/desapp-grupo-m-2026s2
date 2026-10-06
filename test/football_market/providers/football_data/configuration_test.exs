defmodule FootballMarket.Providers.FootballData.ConfigurationTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{Configuration, ContractCase, FixtureData}

  test "trusted configuration is redacted and four broad mappings are mandatory" do
    context = %{positions: ContractCase.positions()}
    good = Configuration.new(%{enabled: true, token: "FD_SYNTHETIC_SENTINEL"})
    assert {:ok, checked} = Configuration.validate(good, context)

    assert checked.position_mapping == %{
             "goalkeeper" => "GK",
             "defence" => "DEF",
             "midfield" => "MID",
             "offence" => "FWD"
           }

    refute inspect(good) =~ "FD_SYNTHETIC_SENTINEL"

    for options <- [
          %{enabled: "true"},
          %{base_url: "https://evil.example"},
          %{position_mapping: %{}},
          %{position_mapping: %{"Goalkeeper" => "XX"}},
          %{
            transport:
              {FootballMarket.Providers.FootballData.MintTransport, %{host: "evil.example"}}
          }
        ] do
      assert {:error, %{category: :invalid_request}} =
               Configuration.validate(
                 Configuration.new(
                   Map.merge(%{enabled: true, token: "FD_SYNTHETIC_SENTINEL"}, options)
                 ),
                 context
               )
    end

    assert {:error, %{category: :invalid_request}} =
             Configuration.validate(good, %{positions: %{"GK" => "Wrong"}})
  end

  test "disabled missing and malformed configuration refuse before work" do
    for c <- FixtureData.cases(),
        String.starts_with?(c.id, ["FD-S01", "FD-S02", "FD-S05", "FD-S04-unsafe"]),
        do: ContractCase.run(c)
  end

  test "all runtime environments default disabled; exact opt-in never raises for a missing token" do
    env = %{
      "DATABASE_URL" => "ecto://fixture:fixture@localhost/fixture",
      "SECRET_KEY_BASE" => String.duplicate("s", 64),
      "JWT_ISSUER" => "fixture",
      "JWT_AUDIENCE" => "fixture",
      "JWT_SIGNING_KEY_BASE64" => Base.encode64(String.duplicate("k", 32)),
      "FOOTBALL_DATA_ENABLED" => nil,
      "FOOTBALL_DATA_TOKEN" => nil
    }

    old = Map.new(env, fn {k, _} -> {k, System.get_env(k)} end)
    on_exit(fn -> System.put_env(old) end)
    System.put_env(env)

    for environment <- [:dev, :test, :prod] do
      defaults = Config.Reader.read!("config/config.exs", env: environment, target: :host)
      assert defaults[:football_market][FootballMarket.Providers][:provider] == nil

      for {setting, selected} <- [
            {nil, false},
            {"false", false},
            {"true", true},
            {"TRUE", true},
            {"yes", true}
          ] do
        if is_nil(setting),
          do: System.delete_env("FOOTBALL_DATA_ENABLED"),
          else: System.put_env("FOOTBALL_DATA_ENABLED", setting)

        runtime = Config.Reader.read!("config/runtime.exs", env: environment, target: :host)
        provider = runtime[:football_market][FootballMarket.Providers][:provider]

        if selected do
          assert {FootballMarket.Providers.FootballData, state} = provider

          assert {:error, %{category: category}} =
                   Configuration.validate(state, %{positions: ContractCase.positions()})

          assert category ==
                   if(setting == "true", do: :authentication_failed, else: :invalid_request)
        else
          assert provider == nil
        end
      end
    end
  end

  test "normalized duplicate mappings and wrong canonical names refuse, explicit extensions work" do
    context = %{positions: ContractCase.positions()}
    mapping = Configuration.mapping()

    for broken <- [
          Map.put(mapping, " goalkeeper ", "GK"),
          Map.put(mapping, "", "GK"),
          Map.put(mapping, "Keeper", "XX"),
          Map.put(mapping, "Goalkeeper", nil),
          Map.delete(mapping, "Offence"),
          []
        ] do
      assert {:error, %{category: :invalid_request}} =
               Configuration.validate(
                 Configuration.new(%{
                   enabled: true,
                   token: "FD_SYNTHETIC_SENTINEL",
                   position_mapping: broken
                 }),
                 context
               )
    end

    assert {:ok, value} =
             Configuration.validate(
               Configuration.new(%{
                 enabled: true,
                 token: "FD_SYNTHETIC_SENTINEL",
                 position_mapping: Map.put(mapping, "Centre-Back", "DEF")
               }),
               context
             )

    assert value.position_mapping["centre-back"] == "DEF"

    for token <- ["GK", "Goalkeeper"] do
      assert {:error, %{category: :invalid_request}} =
               Configuration.validate(Configuration.new(%{enabled: true, token: token}), context)
    end
  end

  test "malformed internal invalid-state settings are classified without exceptions" do
    for invalid <- [:bad, "bad", nil] do
      state =
        Configuration.new(%{enabled: true, token: "FD_SYNTHETIC_SENTINEL", invalid: invalid})

      assert {:error, %{category: :invalid_request}} =
               Configuration.validate(state, %{positions: ContractCase.positions()})
    end
  end
end
