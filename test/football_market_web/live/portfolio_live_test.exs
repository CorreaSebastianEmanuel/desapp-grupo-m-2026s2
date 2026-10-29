defmodule FootballMarketWeb.PortfolioLiveTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FootballMarket.{Catalog, Market, PurchasesCase}

  @endpoint FootballMarketWeb.Endpoint

  test "authenticated portfolio displays the user's current positions and exact values" do
    buyer = account("portfolio-ui-buyer@example.com")
    owner = account("portfolio-ui-owner@example.com")
    %{team: team} = FootballMarket.CatalogCase.insert_hierarchy!()
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    {:ok, player} = Catalog.create_player(FootballMarket.CatalogCase.player_attrs(team, position))

    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)
    Application.put_env(:football_market, :initial_issuance_recipients, [owner.id])

    ExUnit.Callbacks.on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    assert {:ok, _} = Market.initialize_player(player.id)
    PurchasesCase.fund(buyer, "100")
    actor = PurchasesCase.actor(buyer)

    assert {:ok, _} =
             Market.purchase(actor, %{
               player_id: player.id,
               quantity: 3,
               request_key: "portfolio-ui"
             })

    {:ok, view, _html} = live(authenticated_conn(buyer), "/portfolio")

    assert has_element?(view, "#portfolio-positions")
    assert has_element?(view, "#portfolio-position-#{player.id}", player.display_name)
    assert has_element?(view, "#portfolio-position-#{player.id}", "3")
    assert has_element?(view, "#portfolio-position-#{player.id}", "1")
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end
