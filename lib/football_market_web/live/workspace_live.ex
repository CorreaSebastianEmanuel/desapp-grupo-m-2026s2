defmodule FootballMarketWeb.WorkspaceLive do
  @moduledoc "Workspace lifecycle, navigation and cross-destination refresh coordination."
  use FootballMarketWeb, :live_view
  alias FootballMarket.Catalog

  alias FootballMarketWeb.Workspace.{
    Pages,
    Players,
    Trading,
    Orders,
    Portfolio,
    Transactions,
    Ranking,
    Session
  }

  def mount(_, _, socket) do
    if connected?(socket) and socket.assigns.actor do
      Phoenix.PubSub.subscribe(
        FootballMarket.PubSub,
        "conditional_orders:" <> socket.assigns.actor.account_id
      )

      Phoenix.PubSub.subscribe(FootballMarket.PubSub, "catalog_scouts")
    end

    {:ok,
     assign(socket,
       profiles: %{},
       card: nil,
       card_error: nil,
       quote: nil,
       quote_history: [],
       quote_history_unavailable: false,
       quote_date: "",
       dated_quote: nil,
       trade_record: nil,
       trade_key: Ecto.UUID.generate(),
       trade_error: nil,
       trade_notice: nil,
       trade_intent: nil,
       trade_complete: false,
       trade_quantity: "",
       ranking: nil,
       ranking_error: nil,
       destination: nil,
       heading: nil,
       orders: [],
       positions: [],
       portfolio_unavailable: false,
       credit_balance: Decimal.new("0.00"),
       credit_balance_unavailable: false,
       issuer_inventory: [],
       issuer_inventory_unavailable: false,
       initial_recipient: false,
       initial_recipient_unavailable: false,
       allocation: nil,
       allocation_unavailable: false,
       portfolio_history: nil,
       history_unavailable: false,
       order_form: Orders.empty_form(),
       order_error: nil,
       order_notice: nil,
       player_search: "",
       catalog_filters: %{},
       catalog_page_size: 25,
       catalog_pagination: nil,
       catalog_filter_options: %{leagues: [], teams: [], positions: []},
       transactions: [],
       transaction_pagination: nil,
       transaction_page_size: 25,
       transaction_error: false,
       portfolio_from: "",
       portfolio_to: "",
       portfolio_range_invalid: false,
       search_performed: false,
       player_results: [],
       scouting_status: nil,
       selected_player: nil,
       selected_quote: nil,
       player_search_unavailable: false,
       orders_unavailable: false
     )}
  end

  def handle_params(_, uri, socket) do
    destination = URI.parse(uri).path
    params = URI.parse(uri).query |> then(&if(&1, do: URI.decode_query(&1), else: %{}))

    socket =
      socket
      |> assign(
        destination: destination,
        heading: workspace_heading(destination),
        portfolio_tab:
          if(params["tab"] in ["performance", "details"], do: params["tab"], else: "positions"),
        portfolio_from: params["from"] || "",
        portfolio_to: params["to"] || ""
      )
      |> Session.reload_credit_balance()
      |> Session.reload_initial_recipient()

    {:noreply, socket |> load_destination(destination, params) |> load_profiles()}
  end

  defp load_profiles(socket) do
    a = socket.assigns

    ids =
      case a.destination do
        "/players" -> if a.card, do: [a.card.player.id], else: Enum.map(a.player_results, & &1.id)
        "/ranking" -> if a.ranking, do: Enum.map(a.ranking.entries, & &1.player_id), else: []
        "/transactions" -> Enum.map(a.transactions, & &1.player_id)
        "/conditional-orders" -> Enum.map(a.orders, & &1.player_id)
        _ -> Enum.map(a.positions ++ a.issuer_inventory, & &1.player_id)
      end

    assign(socket, :profiles, Catalog.Profiles.get_many(ids))
  end

  defp load_destination(socket, "/conditional-orders", params),
    do: socket |> Orders.reload_orders() |> Orders.load_selected_player(params["player_id"])

  defp load_destination(socket, "/players", params) do
    socket =
      assign(socket,
        player_search: params["q"] || "",
        catalog_filters: Map.take(params, ["league_id", "team_id", "position_id"]),
        catalog_page_size: Session.page_size(params["page_size"]),
        catalog_state_query: params |> Map.delete("player_id") |> URI.encode_query()
      )

    if params["player_id"],
      do: Players.load_card(socket, params["player_id"], params),
      else: socket |> Players.load_card(nil, params) |> Players.load_player_page(params)
  end

  defp load_destination(socket, "/transactions", params),
    do: Transactions.load_transactions(socket, params)

  defp load_destination(socket, "/ranking", _params), do: Ranking.load_ranking(socket)

  defp load_destination(socket, _destination, _params),
    do:
      socket
      |> Portfolio.reload_portfolio()
      |> Portfolio.reload_issuer_inventory()
      |> Portfolio.reload_charts()

  def handle_info({:conditional_order_changed, _id}, socket) do
    socket =
      socket
      |> Session.reload_credit_balance()
      |> Portfolio.reload_portfolio()
      |> Portfolio.reload_issuer_inventory()
      |> Portfolio.reload_charts()

    {:noreply,
     if(socket.assigns.destination == "/conditional-orders",
       do: Orders.reload_orders(socket),
       else: socket
     )}
  end

  def handle_info({:catalog_scout_changed, normalized_name}, socket) do
    if socket.assigns.destination == "/players" and is_nil(socket.assigns.card) and
         Catalog.Scouting.normalize_identity(socket.assigns.player_search) == normalized_name do
      {:noreply,
       Players.load_player_page(socket, URI.decode_query(socket.assigns.catalog_state_query))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:portfolio_changed, socket),
    do:
      {:noreply,
       socket
       |> Session.reload_credit_balance()
       |> Portfolio.reload_portfolio()
       |> Portfolio.reload_issuer_inventory()
       |> Portfolio.reload_charts()}

  defp workspace_heading("/conditional-orders"), do: "Órdenes condicionales"
  defp workspace_heading("/players"), do: "Jugadores"
  defp workspace_heading("/transactions"), do: "Operaciones"
  defp workspace_heading("/ranking"), do: "Ranking"
  defp workspace_heading(_), do: "Portafolio"

  def handle_event("create_order", params, socket),
    do: Orders.handle_event("create_order", params, socket)

  def handle_event("search_players", params, socket),
    do: Players.handle_event("search_players", params, socket)

  def handle_event("portfolio_range", params, socket),
    do: Portfolio.handle_event("portfolio_range", params, socket)

  def handle_event("quote_date", params, socket),
    do: Players.handle_event("quote_date", params, socket)

  def handle_event("transaction_page_size", params, socket),
    do: Transactions.handle_event("transaction_page_size", params, socket)

  def handle_event("select_player", params, socket),
    do: Orders.handle_event("select_player", params, socket)

  def handle_event("cancel_order", params, socket),
    do: Orders.handle_event("cancel_order", params, socket)

  def handle_event("trade", params, socket), do: Trading.handle_event("trade", params, socket)

  def handle_event("trade_preview", params, socket),
    do: Trading.handle_event("trade_preview", params, socket)

  def handle_event("new_trade", params, socket),
    do: Trading.handle_event("new_trade", params, socket)

  def render(assigns), do: Pages.render(assigns)
end
