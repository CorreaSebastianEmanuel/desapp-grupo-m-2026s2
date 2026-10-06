defmodule FootballMarket.Providers.CatalogIsolationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Catalog, CatalogCase, Providers, Repo}
  alias FootballMarket.Catalog.{League, Season, Team, Position, Player}
  alias FootballMarket.Providers.FixtureRuntime
  def provider_label, do: "isolation-spy"

  def read(_, _, {category, owner}) do
    send(owner, :provider_work)
    if category == :timeout, do: FixtureRuntime.advance(5_000_000)
    {:error, %{category: category}}
  end

  defp snapshot,
    do:
      Enum.map([League, Season, Team, Position, Player], fn schema ->
        Repo.all(schema) |> Enum.sort_by(& &1.id)
      end)

  defp reads(catalog) do
    [
      Catalog.get_league(catalog.league.id),
      Catalog.get_season(catalog.season.id),
      Catalog.get_team(catalog.team.id),
      Catalog.get_position(catalog.position.id),
      Catalog.list_players(),
      Enum.map(catalog.players, &Catalog.get_player_detail(&1.id))
    ]
  end

  test "F-I01 all eight failures preserve exact five-table state/reads; local reads invoke no provider" do
    catalog = CatalogCase.insert_catalog!(["Same Example", "Same Example"])
    initial_state = snapshot()
    initial_reads = reads(catalog)
    original = Application.get_env(:football_market, Providers)

    on_exit(fn ->
      if is_nil(original),
        do: Application.delete_env(:football_market, Providers),
        else: Application.put_env(:football_market, Providers, original)
    end)

    Application.put_env(:football_market, Providers,
      provider: {__MODULE__, {:unavailable, self()}},
      positions: %{"FW" => "Forward"}
    )

    for category <- FootballMarket.Providers.Error.categories() do
      Process.put(:fixture_elapsed, 0)

      request = %{
        league_code: if(category == :invalid_request, do: "ZZ", else: "PL"),
        start_year: 2025,
        end_year: 2026
      }

      assert {:error, error} =
               Providers.catalog(request,
                 provider: {__MODULE__, {category, self()}},
                 positions: %{"FW" => "Forward"},
                 runtime: {FixtureRuntime, %{}}
               )

      assert error.category == category
      if category != :invalid_request, do: assert_receive(:provider_work)
      refute_receive :provider_work
      assert snapshot() == initial_state
      assert reads(catalog) == initial_reads
      refute_receive :provider_work
    end
  end
end
