defmodule FootballMarketWeb.Workspace.Helpers do
  @moduledoc "Shared formatting, session actor, ranking, and transaction helpers for WorkspaceLive."

  import Phoenix.Component, only: [assign: 2]
  import Phoenix.LiveView, only: [push_patch: 2]

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.{Catalog, Market, Ranking}

  def money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  def exact_money(nil), do: "Sin datos"
  def exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  def timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")

  def readable_reason(nil), do: "no disponible"
  def readable_reason("insufficient_funds"), do: "saldo insuficiente"
  def readable_reason("insufficient_inventory"), do: "inventario insuficiente"
  def readable_reason(reason), do: String.replace(reason, "_", " ")

  def order_status("pending"), do: "Pendiente"
  def order_status("executed"), do: "Ejecutada"
  def order_status("rejected"), do: "Rechazada"
  def order_status("cancelled"), do: "Cancelada"
  def order_status("expired"), do: "Vencida"
  def order_status(status), do: status

  def player_name(id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} -> player.display_name
      _ -> "Jugador"
    end
  end

  def page_size(value) when is_binary(value) do
    case Integer.parse(value) do
      {size, ""} when size in 1..100 -> size
      _ -> 25
    end
  end

  def page_size(_), do: 25

  def reload_credit_balance(socket) do
    case Market.credit_balance(domain_actor(socket.assigns.actor)) do
      {:ok, balance} -> assign(socket, credit_balance: balance, credit_balance_unavailable: false)
      {:error, _} -> assign(socket, credit_balance: nil, credit_balance_unavailable: true)
    end
  end

  def reload_initial_recipient(socket) do
    case Market.initial_recipient?(domain_actor(socket.assigns.actor)) do
      {:ok, recipient?} ->
        assign(socket, initial_recipient: recipient?, initial_recipient_unavailable: false)

      {:error, _} ->
        assign(socket, initial_recipient: false, initial_recipient_unavailable: true)
    end
  end

  def domain_actor(actor) do
    %AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }
  end

  def quantity(value) when is_binary(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value),
      do: {:ok, String.to_integer(value)},
      else: {:error, :invalid_request}
  end

  def quantity(_), do: {:error, :invalid_request}

  def load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        entries =
          Enum.map(ranking.entries, fn entry ->
            Map.put(entry, :player_name, player_name(entry.player_id))
          end)

        assign(socket, ranking: %{ranking | entries: entries}, ranking_error: nil)

      {:error, :no_active_configuration} ->
        assign(socket, ranking: nil, ranking_error: nil)

      _ ->
        assign(socket,
          ranking: nil,
          ranking_error: "El ranking no está disponible temporalmente."
        )
    end
  end

  def handle_transaction_page_size(%{"page_size" => size}, socket) do
    {:noreply,
     push_patch(socket, to: "/transactions?" <> URI.encode_query(%{"page_size" => size}))}
  end

  def load_transactions(socket, params) do
    size = page_size(params["page_size"])

    case Market.transaction_history(domain_actor(socket.assigns.actor), %{
           page_size: size,
           cursor: params["cursor"]
         }) do
      {:ok, page} ->
        rows =
          Enum.map(page.data, fn row -> Map.put(row, :player_name, player_name(row.player_id)) end)

        assign(socket,
          transactions: rows,
          transaction_pagination: page.pagination,
          transaction_page_size: size,
          transaction_error: false
        )

      {:error, _} ->
        assign(socket,
          transactions: [],
          transaction_pagination: nil,
          transaction_page_size: size,
          transaction_error: true
        )
    end
  end
end

defmodule FootballMarketWeb.Workspace.Pages do
  @moduledoc "HEEx template wrapper rendering the active workspace tab inside the app shell."
  use FootballMarketWeb, :html

  import FootballMarketWeb.WorkspaceComponents
  import FootballMarketWeb.Workspace.Helpers
  alias FootballMarketWeb.PortfolioComponents

  embed_templates "workspace/pages/*"

  def render(assigns) do
    ~H"""
    <.shell
      actor={@actor}
      destination={@destination}
      administrator={FootballMarket.Accounts.administrator?(domain_actor(@actor))}
      credit_balance={@credit_balance}
      credit_balance_unavailable={@credit_balance_unavailable}
    >
      <.orders :if={@destination == "/conditional-orders"} {assigns} />
      <.transactions :if={@destination == "/transactions"} {assigns} />
      <.players :if={@destination == "/players"} {assigns} />
      <.ranking :if={@destination == "/ranking"} {assigns} />
      <.portfolio :if={@destination == "/portfolio"} {assigns} />
    </.shell>
    """
  end
end

defmodule FootballMarketWeb.WorkspaceLive do
  @moduledoc """
  Main authenticated investor workspace LiveView covering all five user tabs:
  `/portfolio`, `/players`, `/transactions`, `/ranking`, and `/conditional-orders`.
  """

  use FootballMarketWeb, :live_view

  alias FootballMarket.{Catalog, Market, Quotes}
  alias FootballMarket.Market.{Orders, Portfolio}
  alias FootballMarketWeb.Workspace.{Helpers, Pages}

  import Helpers, only: [domain_actor: 1, page_size: 1, player_name: 1, quantity: 1]

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
       statistics_refresh_timer: nil,
       statistics_wait: nil,
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
       order_form: empty_order_form(),
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
      |> Helpers.reload_credit_balance()
      |> Helpers.reload_initial_recipient()

    {:noreply,
     socket
     |> load_destination(destination, params)
     |> load_profiles()
     |> maybe_schedule_statistics_refresh()}
  end

  # --- PubSub & Timer Updates ---

  def handle_info({:conditional_order_changed, _id}, socket) do
    socket = reload_portfolio_state(socket)

    {:noreply,
     if(socket.assigns.destination == "/conditional-orders",
       do: reload_orders(socket),
       else: socket
     )}
  end

  def handle_info({:catalog_scout_changed, normalized_name}, socket) do
    if socket.assigns.destination == "/players" and is_nil(socket.assigns.card) and
         Catalog.Scouting.normalize_identity(socket.assigns.player_search) == normalized_name do
      {:noreply, load_player_page(socket, URI.decode_query(socket.assigns.catalog_state_query))}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        :statistics_card_refresh,
        %{assigns: %{destination: "/players", card: card}} = socket
      )
      when not is_nil(card) do
    params =
      URI.decode_query(socket.assigns.catalog_state_query || "")
      |> Map.put("player_id", card.player.id)
      |> maybe_put("date", socket.assigns.quote_date)

    {:noreply,
     socket
     |> assign(:statistics_refresh_timer, nil)
     |> load_card(card.player.id, params)
     |> load_profiles()
     |> maybe_schedule_statistics_refresh()}
  end

  def handle_info(:statistics_card_refresh, socket), do: {:noreply, socket}
  def handle_info(:portfolio_changed, socket), do: {:noreply, reload_portfolio_state(socket)}

  # --- UI Events: Players & Quotes ---

  def handle_event("search_players", params, socket) do
    query =
      %{
        "q" => String.trim(Map.get(params, "player_search", "")),
        "league_id" => Map.get(params, "league_id", ""),
        "team_id" => Map.get(params, "team_id", ""),
        "position_id" => Map.get(params, "position_id", ""),
        "page_size" => Map.get(params, "page_size", "25")
      }
      |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
      |> Map.new()

    {:noreply,
     push_patch(socket,
       to: "/players?" <> URI.encode_query(query),
       replace: Map.has_key?(params, "_target")
     )}
  end

  def handle_event("quote_date", %{"date" => date}, socket) do
    params =
      %{"player_id" => socket.assigns.card.player.id, "date" => date}
      |> Map.merge(
        Map.take(URI.decode_query(socket.assigns.catalog_state_query || ""), [
          "q",
          "league_id",
          "team_id",
          "position_id",
          "page_size",
          "cursor"
        ])
      )

    {:noreply, push_patch(socket, to: "/players?" <> URI.encode_query(params))}
  end

  # --- UI Events: Portfolio & Transactions ---

  def handle_event("portfolio_range", params, socket) do
    query =
      %{"from" => params["from"], "to" => params["to"], "tab" => socket.assigns.portfolio_tab}
      |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
      |> Map.new()

    path =
      if map_size(query) == 0, do: "/portfolio", else: "/portfolio?" <> URI.encode_query(query)

    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("transaction_page_size", params, socket),
    do: Helpers.handle_transaction_page_size(params, socket)

  # --- UI Events: Buy / Sell Trading ---

  def handle_event("trade", %{"side" => side} = params, socket) when side in ["buy", "sell"] do
    with %{player: player} <- socket.assigns.card,
         true <- params["request_key"] == socket.assigns.trade_key,
         {:ok, amount} <- quantity(params["quantity"]) do
      submit_trade(socket, player.id, side, amount)
    else
      _ ->
        {:noreply,
         assign(socket,
           trade_error: "Ingresá una cantidad entera mayor que cero y elegí un jugador.",
           trade_quantity: Map.get(params, "quantity", "")
         )}
    end
  end

  def handle_event("trade_preview", %{"quantity" => qty}, socket),
    do: {:noreply, assign(socket, trade_quantity: qty)}

  def handle_event("trade", params, socket) do
    {:noreply,
     assign(socket,
       trade_error: "Elegí comprar o vender e ingresá una cantidad entera mayor que cero.",
       trade_quantity: Map.get(params, "quantity", "")
     )}
  end

  def handle_event(
        "new_trade",
        _,
        %{assigns: %{trade_intent: intent, trade_complete: false}} = socket
      )
      when not is_nil(intent),
      do: {:noreply, socket}

  def handle_event("new_trade", _, socket) do
    {:noreply,
     assign(socket,
       trade_key: Ecto.UUID.generate(),
       trade_intent: nil,
       trade_complete: false,
       trade_quantity: "",
       trade_error: nil,
       trade_notice: nil
     )}
  end

  # --- UI Events: Conditional Orders ---

  def handle_event("create_order", params, socket) do
    with {:ok, qty} <- quantity(params["quantity"]),
         {:ok, _order} <-
           Orders.create(domain_actor(socket.assigns.actor), %{
             player_id: params["player_id"],
             quantity: qty,
             maximum_unit_price: params["maximum_unit_price"],
             expires_at: utc_expiry(params["expires_at"])
           }) do
      {:noreply,
       socket
       |> assign(order_form: empty_order_form(), order_error: nil, order_notice: "Orden creada.")
       |> reload_orders()}
    else
      {:error, error} ->
        {:noreply,
         assign(socket,
           order_form: Map.new(empty_order_form(), fn {k, _} -> {k, params[k] || ""} end),
           order_error: order_error_message(error),
           order_notice: nil
         )}
    end
  end

  def handle_event("select_player", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.player_results, &(to_string(&1.id) == id)) do
      nil ->
        {:noreply, socket}

      player ->
        {:noreply,
         assign(socket,
           player_search: player.display_name,
           player_results: [],
           selected_player: player,
           order_form: Map.put(socket.assigns.order_form, "player_id", player.id)
         )}
    end
  end

  def handle_event("cancel_order", %{"id" => id}, socket) do
    case Orders.cancel(domain_actor(socket.assigns.actor), id) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> assign(order_error: nil, order_notice: "Estado de la orden actualizado.")
         |> reload_orders()}

      {:error, error} ->
        {:noreply, assign(socket, order_error: order_error_message(error), order_notice: nil)}
    end
  end

  def render(assigns), do: Pages.render(assigns)

  # --- Tab Loaders ---

  defp load_destination(socket, "/conditional-orders", params),
    do: socket |> reload_orders() |> load_selected_player(params["player_id"])

  defp load_destination(socket, "/players", params) do
    socket =
      assign(socket,
        player_search: params["q"] || "",
        catalog_filters: Map.take(params, ["league_id", "team_id", "position_id"]),
        catalog_page_size: page_size(params["page_size"]),
        catalog_state_query: params |> Map.delete("player_id") |> URI.encode_query()
      )

    if params["player_id"],
      do: load_card(socket, params["player_id"], params),
      else: socket |> load_card(nil, params) |> load_player_page(params)
  end

  defp load_destination(socket, "/transactions", params),
    do: Helpers.load_transactions(socket, params)

  defp load_destination(socket, "/ranking", _params), do: Helpers.load_ranking(socket)

  defp load_destination(socket, _destination, _params),
    do: socket |> reload_portfolio() |> reload_issuer_inventory() |> reload_charts()

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

    assign(socket, :profiles, Catalog.get_profiles(ids))
  end

  # --- Player Catalog & Card Loaders ---

  defp load_card(socket, nil, _params), do: assign(socket, card: nil, quote: nil, card_error: nil)

  defp load_card(socket, id, params) do
    case Catalog.player_card(id) do
      {:ok, card} ->
        quote =
          case Quotes.latest(id) do
            {:ok, q} -> q
            _ -> nil
          end

        {history, history_unavailable} =
          case Quotes.list_history(id) do
            {:ok, rows} -> {rows, false}
            _ -> {[], true}
          end

        date_param = params["date"] || ""

        socket
        |> assign(
          card: card,
          quote: quote,
          quote_history: history,
          quote_history_unavailable: history_unavailable,
          quote_date: date_param,
          dated_quote: dated_quote(id, date_param),
          card_error: nil
        )
        |> reload_portfolio()
        |> reload_issuer_inventory()

      _ ->
        assign(socket, card: nil, card_error: "No se pudo cargar la ficha del jugador.")
    end
  end

  defp dated_quote(_id, ""), do: nil

  defp dated_quote(id, value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        case Quotes.at_date(id, date) do
          {:ok, row} -> row
          {:error, :quote_not_found} -> :missing
          _ -> :unavailable
        end

      _ ->
        :invalid
    end
  end

  defp load_player_page(socket, params) do
    filter_options =
      case Catalog.filter_options() do
        {:ok, options} -> options
        _ -> socket.assigns.catalog_filter_options
      end

    filters =
      params
      |> Enum.filter(fn {k, v} -> k in ["league_id", "team_id", "position_id"] and v != "" end)
      |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
      |> then(fn map ->
        if params["q"] in [nil, ""], do: map, else: Map.put(map, :search_name, params["q"])
      end)

    valid_filters? =
      filters
      |> Map.delete(:search_name)
      |> Enum.all?(fn {_k, v} -> match?({:ok, _}, Ecto.UUID.cast(v)) end)

    result =
      if valid_filters?,
        do:
          Catalog.list_market_player_page(%{
            page_size: page_size(params["page_size"]),
            cursor: params["cursor"],
            filters: filters
          }),
        else: {:error, :invalid_filters}

    case result do
      {:ok, page} ->
        {players, scouting_status} =
          maybe_scout_name_miss(params["q"], filters, page.players, params["cursor"])

        assign(socket,
          catalog_filter_options: filter_options,
          catalog_pagination: page.pagination,
          player_results: players,
          search_performed: true,
          scouting_status: scouting_status,
          player_search_unavailable: false
        )

      {:error, _} ->
        assign(socket,
          catalog_filter_options: filter_options,
          player_results: [],
          catalog_pagination: nil,
          search_performed: true,
          scouting_status: nil,
          player_search_unavailable: true
        )
    end
  end

  defp maybe_scout_name_miss(name, filters, [], nil) when is_binary(name) and name != "" do
    if Map.keys(filters) == [:search_name] and Catalog.search_local_players(name) == {:ok, []} do
      case Catalog.search_players(name) do
        {:ok, players, status} -> {players, status}
        _ -> {[], nil}
      end
    else
      {[], nil}
    end
  end

  defp maybe_scout_name_miss(_name, _filters, players, _cursor), do: {players, nil}

  # --- Portfolio, Trading & Order Helpers ---

  defp reload_portfolio_state(socket) do
    socket
    |> Helpers.reload_credit_balance()
    |> reload_portfolio()
    |> reload_issuer_inventory()
    |> reload_charts()
  end

  defp reload_portfolio(socket) do
    case Portfolio.list(domain_actor(socket.assigns.actor)) do
      {:ok, positions} -> assign(socket, positions: positions, portfolio_unavailable: false)
      {:error, _} -> assign(socket, positions: [], portfolio_unavailable: true)
    end
  end

  defp reload_issuer_inventory(socket) do
    case Portfolio.initial_inventory(domain_actor(socket.assigns.actor)) do
      {:ok, inventory} ->
        assign(socket, issuer_inventory: inventory, issuer_inventory_unavailable: false)

      {:error, _} ->
        assign(socket, issuer_inventory: [], issuer_inventory_unavailable: true)
    end
  end

  defp reload_charts(%{assigns: %{destination: "/portfolio", actor: actor}} = socket)
       when not is_nil(actor) do
    d_actor = domain_actor(actor)

    {allocation, allocation_unavailable} =
      case Market.portfolio_allocation(d_actor) do
        {:ok, data} -> {data, false}
        {:error, _} -> {nil, true}
      end

    {history, history_unavailable, range_invalid} =
      case portfolio_options(socket.assigns.portfolio_from, socket.assigns.portfolio_to) do
        {:ok, options} ->
          case Market.portfolio_history(d_actor, options) do
            {:ok, value} ->
              {value, false, false}

            {:error, %{kind: k}} when k in [:invalid_date, :invalid_date_range] ->
              {nil, false, true}

            {:error, _} ->
              {nil, true, false}
          end

        {:error, _} ->
          {nil, false, true}
      end

    assign(socket,
      allocation: allocation,
      allocation_unavailable: allocation_unavailable,
      portfolio_history: history,
      history_unavailable: history_unavailable,
      portfolio_range_invalid: range_invalid
    )
  end

  defp reload_charts(socket), do: socket

  defp portfolio_options("", ""), do: Portfolio.validate_range(%{}, Date.utc_today())

  defp portfolio_options(from, to) do
    with {:ok, f} <- optional_date(from),
         {:ok, t} <- optional_date(to) do
      Portfolio.validate_range(%{from: f, to: t}, Date.utc_today())
    end
  end

  defp optional_date(""), do: {:ok, nil}
  defp optional_date(v) when is_binary(v), do: Date.from_iso8601(v)
  defp optional_date(_), do: {:error, :invalid_date}

  defp submit_trade(socket, player_id, side, amount) do
    intent = {player_id, side, amount}

    if socket.assigns.trade_intent in [nil, intent] do
      socket = assign(socket, trade_intent: intent, trade_quantity: Integer.to_string(amount))
      input = %{player_id: player_id, quantity: amount, request_key: socket.assigns.trade_key}
      actor = domain_actor(socket.assigns.actor)

      result =
        if side == "buy", do: Market.purchase(actor, input), else: Market.sale(actor, input)

      handle_trade_result(socket, result)
    else
      {:noreply,
       assign(socket,
         trade_error:
           "Esta solicitud ya se usó con otros datos. Iniciá una nueva operación antes de cambiar la acción o la cantidad."
       )}
    end
  end

  defp handle_trade_result(socket, {:ok, record}) do
    Phoenix.PubSub.broadcast_from(
      FootballMarket.PubSub,
      self(),
      "conditional_orders:" <> socket.assigns.actor.account_id,
      :portfolio_changed
    )

    {:noreply,
     socket
     |> assign(
       trade_error: nil,
       trade_notice: "Operación confirmada.",
       trade_complete: true,
       trade_record: Map.put(record, :type, elem(socket.assigns.trade_intent, 1))
     )
     |> reload_portfolio_state()}
  end

  defp handle_trade_result(socket, {:error, error}) do
    socket =
      if definitive_rejection?(error),
        do: assign(socket, trade_intent: nil, trade_key: Ecto.UUID.generate()),
        else: socket

    {:noreply, assign(socket, trade_error: trade_error_message(error), trade_notice: nil)}
  end

  defp definitive_rejection?(%{kind: kind, reason: reason}) do
    kind in [:insufficient_funds, :insufficient_inventory, :insufficient_holdings] or
      (kind == :invalid_request and reason == :invalid_request)
  end

  defp definitive_rejection?(_), do: false

  defp trade_error_message(%{reason: :transaction_in_progress}),
    do: "La operación aún no se pudo confirmar. Reintentá con la misma acción y cantidad."

  defp trade_error_message(%{kind: :temporarily_unavailable}),
    do: "No se pudo confirmar el resultado. Reintentá con la misma acción y cantidad."

  defp trade_error_message(%{kind: kind}), do: trade_error_message(kind)
  defp trade_error_message(:invalid_request), do: "Ingresá una cantidad entera mayor que cero."
  defp trade_error_message(:insufficient_funds), do: "No tenés créditos suficientes."
  defp trade_error_message(:insufficient_inventory), do: "No hay suficientes tokens disponibles."
  defp trade_error_message(:insufficient_holdings), do: "No tenés tantos tokens para vender."

  defp trade_error_message(:quote_unavailable),
    do: "Todavía no hay una cotización de rendimiento válida para comprar este jugador."

  defp trade_error_message(:self_purchase),
    do:
      "Esta cuenta aporta el inventario inicial. Para comprar, ingresá con una cuenta inversora."

  defp trade_error_message(:self_sale),
    do:
      "Esta cuenta recibió el inventario inicial y no puede venderse tokens a sí misma. Usá una cuenta inversora."

  defp trade_error_message(_),
    do:
      "No se pudo completar la operación. Revisá tus créditos para comprar, tus tokens para vender y que la cantidad sea un número entero."

  defp reload_orders(socket) do
    case Orders.list(domain_actor(socket.assigns.actor)) do
      {:ok, orders} ->
        orders = Enum.map(orders, &Map.put(&1, :player_name, player_name(&1.player_id)))
        assign(socket, orders: orders, orders_unavailable: false)

      {:error, _} ->
        assign(socket, orders: [], orders_unavailable: true)
    end
  end

  defp load_selected_player(socket, nil), do: socket

  defp load_selected_player(socket, id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} ->
        quote =
          case Quotes.latest(id) do
            {:ok, q} -> q
            _ -> nil
          end

        assign(socket,
          selected_player: player,
          selected_quote: quote,
          player_search: player.display_name,
          order_form: Map.put(socket.assigns.order_form, "player_id", player.id)
        )

      _ ->
        socket
    end
  end

  defp utc_expiry(value) when is_binary(value) do
    normalized = value <> if(byte_size(value) == 16, do: ":00", else: "")

    if Regex.match?(~r/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d{1,6})?)?\z/, value) do
      case NaiveDateTime.from_iso8601(normalized) do
        {:ok, naive} -> DateTime.from_naive!(naive, "Etc/UTC")
        _ -> value
      end
    else
      value
    end
  end

  defp utc_expiry(value), do: value

  defp empty_order_form,
    do: %{"player_id" => "", "quantity" => "", "maximum_unit_price" => "", "expires_at" => ""}

  defp order_error_message(:invalid_request),
    do: "Revisá el jugador, la cantidad, el precio y que el vencimiento UTC sea futuro."

  defp order_error_message(:player_not_found), do: "No encontramos ese jugador."

  defp order_error_message(:not_initialized),
    do: "Ese jugador no está habilitado para órdenes condicionales."

  defp order_error_message(:self_purchase),
    do: "No podés crear una orden para comprar tus propios tokens emitidos."

  defp order_error_message(:temporarily_unavailable),
    do: "Las órdenes no están disponibles temporalmente. Probá de nuevo en unos instantes."

  defp order_error_message(%{kind: kind}), do: order_error_message(kind)

  defp order_error_message(_),
    do: "No se pudo completar la orden. Revisá las condiciones e intentá de nuevo."

  # --- Statistics Card Refresh Polling ---

  defp maybe_schedule_statistics_refresh(socket) do
    now = System.monotonic_time(:millisecond)
    socket = update_statistics_wait(socket, now)
    wait = socket.assigns.statistics_wait
    active? = active_statistics_refresh?(socket)

    case {active?, socket.assigns.statistics_refresh_timer} do
      {true, nil} ->
        delay = if now < elem(wait, 1), do: min(1_000, elem(wait, 1) - now), else: 5_000

        assign(
          socket,
          :statistics_refresh_timer,
          Process.send_after(self(), :statistics_card_refresh, delay)
        )

      {false, timer} when is_reference(timer) ->
        Process.cancel_timer(timer)
        assign(socket, :statistics_refresh_timer, nil)

      _ ->
        socket
    end
  end

  defp update_statistics_wait(socket, now) do
    card = if socket.assigns.destination == "/players", do: socket.assigns.card
    id = card && card.player.id

    wait =
      case socket.assigns.statistics_wait do
        {^id, deadline} when not is_nil(id) -> {id, deadline}
        _ when not is_nil(id) -> {id, now + 20_000}
        _ -> nil
      end

    socket = assign(socket, :statistics_wait, wait)

    if card,
      do: assign(socket, :card, Map.put(card, :statistics_wait_expired, now >= elem(wait, 1))),
      else: socket
  end

  defp active_statistics_refresh?(socket) do
    connected?(socket) and socket.assigns.destination == "/players" and
      match?(
        %{statistics_status: %{refresh: %{state: st}}}
        when st in ["queued", "executing", "retry_wait", "busy", "cooldown"],
        socket.assigns.card
      )
  end

  defp maybe_put(map, _key, value) when value in [nil, ""], do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp workspace_heading("/conditional-orders"), do: "Órdenes condicionales"
  defp workspace_heading("/players"), do: "Jugadores"
  defp workspace_heading("/transactions"), do: "Operaciones"
  defp workspace_heading("/ranking"), do: "Ranking"
  defp workspace_heading(_), do: "Portafolio"
end
