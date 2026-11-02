defmodule FootballMarket.Providers.FootballDataOrgConfigTest do
  use ExUnit.Case, async: false
  @moduletag :unit

  alias FootballMarket.Providers.FootballDataOrg
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.Input

  setup do
    previous_token = System.get_env("FOOTBALL_DATA_ORG_TOKEN")
    previous_sync = Application.get_env(:football_market, Synchronization)

    on_exit(fn ->
      if is_nil(previous_token),
        do: System.delete_env("FOOTBALL_DATA_ORG_TOKEN"),
        else: System.put_env("FOOTBALL_DATA_ORG_TOKEN", previous_token)

      if is_nil(previous_sync),
        do: Application.delete_env(:football_market, Synchronization),
        else: Application.put_env(:football_market, Synchronization, previous_sync)
    end)

    :ok
  end

  test "runtime config binds the secret and schedules five current-season durable scopes" do
    token = "runtime-config-secret"
    System.put_env("FOOTBALL_DATA_ORG_TOKEN", token)
    config = read_production_config()
    sync = Keyword.fetch!(config, Synchronization)

    assert sync[:enabled]
    assert Map.keys(sync[:sources]) == ["football-data-org"]
    source = Keyword.fetch!(sync, :sources)["football-data-org"]
    assert {FootballDataOrg, %{token: ^token}} = source.provider

    assert Enum.map(Keyword.fetch!(sync, :schedules), fn {name, _} -> name end) |> Enum.sort() ==
             Enum.sort(Enum.map(~w(PL BL1 PD SA FL1), &"football-data-org-#{&1}"))

    Application.put_env(:football_market, Synchronization, sync)
    today = Date.utc_today()
    year = today.year
    start_year = if today.month >= 7, do: year, else: year - 1

    assert {:ok, input} =
             Input.normalize(
               :catalog,
               %{league_code: "PL", start_year: start_year, end_year: start_year + 1},
               source_ref: "football-data-org"
             )

    refute inspect(input.material) =~ token
  end

  test "missing, blank, and malformed runtime secrets leave the provider disabled" do
    for token <- [nil, "   ", "bad\ntoken"] do
      if is_nil(token),
        do: System.delete_env("FOOTBALL_DATA_ORG_TOKEN"),
        else: System.put_env("FOOTBALL_DATA_ORG_TOKEN", token)

      sync = Keyword.fetch!(read_production_config(), Synchronization)
      refute sync[:enabled]
      assert sync[:sources] == %{}
      assert sync[:schedules] == []
    end
  end

  defp read_production_config do
    Config.Reader.read!("config/synchronization.exs", env: :prod)
    |> Keyword.fetch!(:football_market)
  end
end
