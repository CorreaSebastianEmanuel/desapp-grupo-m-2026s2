defmodule FootballMarketWeb.ConditionalOrdersLiveTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Market.ConditionalOrders
  alias FootballMarket.{Catalog, Market, PurchasesCase}

  @endpoint FootballMarketWeb.Endpoint

  test "creates, lists, and cancels the signed-in user's order" do
    f = fixture()
    view = open_orders(f.buyer)

    assert has_element?(view, "h1", "Conditional orders")
    assert has_element?(view, "#no-orders"), render(view)

    {:ok, catalog, _html} = live(authenticated_conn(f.buyer), "/players")
    refute has_element?(catalog, "#player-search-results")
    catalog |> form("#player-catalog-search", %{"player_search" => "Player"}) |> render_submit()
    assert has_element?(catalog, "#player-search-results", f.player.display_name)

    assert has_element?(
             catalog,
             "a[href='/conditional-orders?player_id=#{f.player.id}']",
             "Create order"
           )

    {:ok, view, _html} =
      live(authenticated_conn(f.buyer), "/conditional-orders?player_id=#{f.player.id}")

    assert has_element?(view, "#selected-player", f.player.display_name)
    assert has_element?(view, "#order-player-id[value='#{f.player.id}']")

    form = %{
      "player_id" => f.player.id,
      "quantity" => "0",
      "maximum_unit_price" => "0.01",
      "expires_at" => future_expiry()
    }

    view |> form("#conditional-order-form", form) |> render_submit()
    assert has_element?(view, "#order-error[role=alert]", "Check the player ID")
    assert has_element?(view, "#order-quantity[value='0']")

    form = %{form | "quantity" => "3"}
    view |> form("#conditional-order-form", form) |> render_submit()
    assert has_element?(view, "#order-notice[role=status]", "Order created.")
    assert [order] = ConditionalOrders.list(C.actor(f.buyer)) |> elem(1)
    assert has_element?(view, "#conditional-order-#{order.id}", f.player.id)
    assert has_element?(view, "#conditional-order-#{order.id}", "pending")
    assert has_element?(view, "#conditional-order-#{order.id} button", "Cancel order")

    view |> element("#conditional-order-#{order.id} button") |> render_click()
    assert has_element?(view, "#conditional-order-#{order.id}", "cancelled")
    refute has_element?(view, "#conditional-order-#{order.id} button")
  end

  test "reload hints and reconnect recover committed owner-scoped states and outcomes" do
    f = fixture()
    other = FootballMarket.BrowserSessionCase.account("other-orders@example.com")
    other_order = C.order!(%{f | buyer: other}, %{maximum_unit_price: "0.01"})
    view = open_orders(f.buyer)

    assert has_element?(view, "#no-orders"), render(view)
    refute render(view) =~ other_order.id

    order = C.order!(f, %{maximum_unit_price: "0.01"})
    :ok = FootballMarket.Market.OrderNotifications.changed(order.id)
    assert has_element?(view, "#conditional-order-#{order.id}", "pending")

    assert {:ok, cancelled} = ConditionalOrders.cancel(C.actor(f.buyer), order.id)
    assert cancelled.status == "cancelled"
    assert has_element?(view, "#conditional-order-#{order.id}", "cancelled")

    executed = C.order!(f, %{maximum_unit_price: "999.99"})
    assert {:ok, result} = ConditionalOrders.evaluate(executed.id)
    assert result.status == "executed"
    assert has_element?(view, "#conditional-order-#{executed.id}", "Executed at")
    assert has_element?(view, "#conditional-order-#{executed.id}", "total")

    PurchasesCase.fund(f.buyer, "0")
    rejected = C.order!(f, %{maximum_unit_price: "999.99"})
    assert {:ok, result} = ConditionalOrders.evaluate(rejected.id)
    assert result.status == "rejected"

    assert has_element?(
             view,
             "#conditional-order-#{rejected.id}",
             "Rejected: insufficient funds."
           )

    conn = authenticated_conn(f.buyer)
    {:ok, reconnected, _html} = live(conn, "/conditional-orders")
    assert has_element?(reconnected, "#conditional-order-#{order.id}", "cancelled")
    assert has_element?(reconnected, "#conditional-order-#{executed.id}", "executed")
    assert has_element?(reconnected, "#conditional-order-#{rejected.id}", "insufficient funds")
  end

  test "shows expiry reached before the persisted transition and the expired outcome after reload" do
    f = fixture()

    order =
      C.order!(f, %{
        maximum_unit_price: "0.01",
        expires_at: DateTime.add(DateTime.utc_now(), 1, :second)
      })

    view = open_orders(f.buyer)

    assert has_element?(view, "#conditional-order-#{order.id}", "pending")
    Process.sleep(1_100)
    :ok = FootballMarket.Market.OrderNotifications.changed(order.id)
    assert has_element?(view, "#conditional-order-#{order.id} .expiry-reached")
    refute has_element?(view, "#conditional-order-#{order.id} button")

    assert {:ok, expired} = ConditionalOrders.evaluate(order.id)
    assert expired.status == "expired"
    assert has_element?(view, "#conditional-order-#{order.id}", "expired")
  end

  defp open_orders(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)
    {:ok, view, _html} = live(authenticated_conn(user, handle), "/conditional-orders")
    view
  end

  defp fixture do
    buyer = account("conditional-ui-buyer@example.com")
    owner = account("conditional-ui-owner@example.com")
    %{team: team} = FootballMarket.CatalogCase.insert_hierarchy!()
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())

    {:ok, player} =
      Catalog.create_player(FootballMarket.CatalogCase.player_attrs(team, position))

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
    %{buyer: buyer, owner: owner, player: player}
  end

  defp authenticated_conn(user, handle \\ nil) do
    handle =
      handle ||
        with {:ok, anonymous} <- FootballMarket.Accounts.BrowserSessions.create_anonymous(),
             {:ok, handle} <-
               FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id) do
          handle
        end

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end

  defp future_expiry do
    DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.to_iso8601()
  end
end
