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

    assert has_element?(view, "h1", "Órdenes condicionales")
    assert has_element?(view, "#no-orders"), render(view)

    {:ok, catalog, _html} = live(authenticated_conn(f.buyer), "/players")
    catalog |> form("#player-catalog-search", %{"player_search" => "Player"}) |> render_submit()
    assert has_element?(catalog, "#player-search-results", f.player.display_name)

    assert has_element?(
             catalog,
             "a[href^='/players?player_id=#{f.player.id}']",
             "Ver ficha y operar"
           )

    {:ok, view, _html} =
      live(authenticated_conn(f.buyer), "/conditional-orders?player_id=#{f.player.id}")

    assert has_element?(view, ".selected-order-player", f.player.display_name)
    assert has_element?(view, "#order-player-id[value='#{f.player.id}']")

    form = %{
      "player_id" => f.player.id,
      "quantity" => "0",
      "maximum_unit_price" => "0.01",
      "expires_at" => future_expiry()
    }

    view |> form("#conditional-order-form", form) |> render_submit()
    assert has_element?(view, "#order-error[role=alert]", "Revisá el jugador")
    assert has_element?(view, "#order-quantity[value='0']")

    form = %{form | "quantity" => "3"}
    view |> form("#conditional-order-form", form) |> render_submit()
    assert has_element?(view, "#order-notice[role=status]", "Orden creada.")
    assert [order] = ConditionalOrders.list(C.actor(f.buyer)) |> elem(1)
    assert has_element?(view, "#conditional-order-#{order.id}", f.player.display_name)
    assert has_element?(view, "#conditional-order-#{order.id}", "Pendiente")
    assert has_element?(view, "#conditional-order-#{order.id} button", "Cancelar orden")

    view |> element("#conditional-order-#{order.id} button") |> render_click()
    assert has_element?(view, "#conditional-order-#{order.id}", "Cancelada")
    refute has_element?(view, "#conditional-order-#{order.id} button")
  end

  test "UTC picker preserves the selected instant and rejects past or malformed expiry" do
    f = fixture()

    {:ok, view, _} =
      live(authenticated_conn(f.buyer), "/conditional-orders?player_id=#{f.player.id}")

    assert has_element?(view, "#order-expires-at[type=datetime-local][step='1']")
    assert has_element?(view, "label[for=order-expires-at]", "UTC")
    expiry = DateTime.utc_now() |> DateTime.add(3600) |> DateTime.truncate(:second)

    values = %{
      "player_id" => f.player.id,
      "quantity" => "1",
      "maximum_unit_price" => "0.01",
      "expires_at" => "2000-01-01T12:00"
    }

    for invalid <- [values["expires_at"], "invalid"] do
      render_submit(view, "create_order", %{values | "expires_at" => invalid})
      assert has_element?(view, "#order-error")
      assert {:ok, []} = ConditionalOrders.list(C.actor(f.buyer))
    end

    render_submit(view, "create_order", %{
      values
      | "expires_at" => expiry |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()
    })

    assert has_element?(view, "#order-notice", "Orden creada")
    assert {:ok, [order]} = ConditionalOrders.list(C.actor(f.buyer))
    assert DateTime.compare(order.expires_at, expiry) == :eq
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
    assert has_element?(view, "#conditional-order-#{order.id}", "Pendiente")

    assert {:ok, cancelled} = ConditionalOrders.cancel(C.actor(f.buyer), order.id)
    assert cancelled.status == "cancelled"
    assert has_element?(view, "#conditional-order-#{order.id}", "Cancelada")

    PurchasesCase.performance_quote!(f.player)
    executed = C.order!(f, %{maximum_unit_price: "999.99"})
    assert {:ok, result} = ConditionalOrders.evaluate(executed.id)
    assert result.status == "executed"
    assert has_element?(view, "#conditional-order-#{executed.id}", "Detalles de ejecución")
    assert has_element?(view, "#conditional-order-#{executed.id}", result.execution.purchase_id)
    refute has_element?(view, "#conditional-order-#{executed.id}", result.execution.quote_id)
    assert has_element?(view, "#conditional-order-#{executed.id}", "Completada")

    PurchasesCase.fund(f.buyer, "0")
    rejected = C.order!(f, %{maximum_unit_price: "999.99"})
    assert {:ok, result} = ConditionalOrders.evaluate(rejected.id)
    assert result.status == "rejected"

    assert has_element?(
             view,
             "#conditional-order-#{rejected.id}",
             "Rechazada: saldo insuficiente."
           )

    conn = authenticated_conn(f.buyer)
    {:ok, reconnected, _html} = live(conn, "/conditional-orders")
    assert has_element?(reconnected, "#conditional-order-#{order.id}", "Cancelada")
    assert has_element?(reconnected, "#conditional-order-#{executed.id}", "Ejecutada")
    assert has_element?(reconnected, "#conditional-order-#{rejected.id}", "saldo insuficiente")
  end

  test "shows expiry reached before the persisted transition and the expired outcome after reload" do
    f = fixture()

    order =
      C.order!(f, %{
        maximum_unit_price: "0.01",
        expires_at: DateTime.add(DateTime.utc_now(), 1, :second)
      })

    view = open_orders(f.buyer)

    assert has_element?(view, "#conditional-order-#{order.id}", "Pendiente")
    Process.sleep(1_100)
    :ok = FootballMarket.Market.OrderNotifications.changed(order.id)
    assert has_element?(view, "#conditional-order-#{order.id} .expiry-reached")
    refute has_element?(view, "#conditional-order-#{order.id} button")

    assert {:ok, expired} = ConditionalOrders.evaluate(order.id)
    assert expired.status == "expired"
    assert has_element?(view, "#conditional-order-#{order.id}", "Vencida")
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
    DateTime.utc_now()
    |> DateTime.add(3600, :second)
    |> DateTime.to_naive()
    |> NaiveDateTime.to_iso8601()
  end
end
