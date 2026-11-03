defmodule FootballMarketWeb.WorkspaceLive do
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents

  alias FootballMarket.Accounts.AuthenticatedActor

  alias FootballMarket.{
    Catalog,
    Market,
    Market.Analytics.Input,
    Market.ConditionalOrders,
    Market.CreditBalances,
    Market.InitialInventory,
    Market.Portfolio,
    Quotes,
    Ranking
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
       order_form: empty_form(),
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
      |> reload_credit_balance()
      |> reload_initial_recipient()

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

  defp load_destination(socket, "/transactions", params), do: load_transactions(socket, params)
  defp load_destination(socket, "/ranking", _params), do: load_ranking(socket)

  defp load_destination(socket, _destination, _params),
    do: socket |> reload_portfolio() |> reload_issuer_inventory() |> reload_charts()

  def handle_event("create_order", params, socket) do
    with {:ok, quantity} <- quantity(params["quantity"]),
         {:ok, terms} <- order_terms(params, quantity),
         {:ok, _order} <- ConditionalOrders.create(domain_actor(socket.assigns.actor), terms) do
      {:noreply,
       socket
       |> assign(order_form: empty_form(), order_error: nil, order_notice: "Orden creada.")
       |> reload_orders()}
    else
      {:error, error} ->
        {:noreply,
         assign(socket,
           order_form: form_values(params),
           order_error: error_message(error),
           order_notice: nil
         )}
    end
  end

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

  def handle_event("portfolio_range", params, socket) do
    query =
      %{"from" => params["from"], "to" => params["to"], "tab" => socket.assigns.portfolio_tab}
      |> Enum.reject(fn {_key, value} -> value in ["", nil] end)
      |> Map.new()

    {:noreply,
     push_patch(socket,
       to:
         if(map_size(query) == 0,
           do: "/portfolio",
           else: "/portfolio?" <> URI.encode_query(query)
         )
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

  def handle_event("transaction_page_size", %{"page_size" => size}, socket) do
    {:noreply,
     push_patch(socket, to: "/transactions?" <> URI.encode_query(%{"page_size" => size}))}
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
    case ConditionalOrders.cancel(domain_actor(socket.assigns.actor), id) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> assign(order_error: nil, order_notice: "Estado de la orden actualizado.")
         |> reload_orders()}

      {:error, error} ->
        {:noreply, assign(socket, order_error: error_message(error), order_notice: nil)}
    end
  end

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

  def handle_event("trade_preview", %{"quantity" => quantity}, socket) do
    {:noreply, assign(socket, trade_quantity: quantity)}
  end

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
      when not is_nil(intent), do: {:noreply, socket}

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

  def handle_info({:conditional_order_changed, _id}, socket) do
    socket =
      socket
      |> reload_credit_balance()
      |> reload_portfolio()
      |> reload_issuer_inventory()
      |> reload_charts()

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

  def handle_info(:portfolio_changed, socket),
    do:
      {:noreply,
       socket
       |> reload_credit_balance()
       |> reload_portfolio()
       |> reload_issuer_inventory()
       |> reload_charts()}

  defp workspace_heading("/conditional-orders"), do: "Órdenes condicionales"
  defp workspace_heading("/players"), do: "Jugadores"
  defp workspace_heading("/transactions"), do: "Operaciones"
  defp workspace_heading("/ranking"), do: "Ranking"
  defp workspace_heading(_), do: "Portafolio"

  defp submit_trade(socket, player_id, side, amount) do
    intent = {player_id, side, amount}

    if socket.assigns.trade_intent in [nil, intent] do
      socket = assign(socket, trade_intent: intent, trade_quantity: Integer.to_string(amount))
      input = %{player_id: player_id, quantity: amount, request_key: socket.assigns.trade_key}
      trade_result(socket, execute_trade(side, domain_actor(socket.assigns.actor), input))
    else
      {:noreply,
       assign(
         socket,
         trade_error:
           "Esta solicitud ya se usó con otros datos. Iniciá una nueva operación antes de cambiar la acción o la cantidad."
       )}
    end
  end

  defp trade_result(socket, {:ok, record}) do
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
     |> reload_credit_balance()
     |> reload_portfolio()
     |> reload_issuer_inventory()
     |> reload_charts()}
  end

  defp trade_result(socket, {:error, error}) do
    socket =
      if definitive_rejection?(error) do
        assign(socket, trade_intent: nil, trade_key: Ecto.UUID.generate())
      else
        socket
      end

    {:noreply, assign(socket, trade_error: trade_error(error), trade_notice: nil)}
  end

  defp definitive_rejection?(%{kind: kind, reason: reason}) do
    kind in [:insufficient_funds, :insufficient_inventory, :insufficient_holdings] or
      (kind == :invalid_request and reason == :invalid_request)
  end

  defp definitive_rejection?(_), do: false

  defp execute_trade("buy", actor, input), do: Market.purchase(actor, input)
  defp execute_trade("sell", actor, input), do: Market.sale(actor, input)

  defp trade_error(%{reason: :transaction_in_progress}),
    do: "La operación aún no se pudo confirmar. Reintentá con la misma acción y cantidad."

  defp trade_error(%{kind: :temporarily_unavailable}),
    do: "No se pudo confirmar el resultado. Reintentá con la misma acción y cantidad."

  defp trade_error(%{kind: kind}), do: trade_error(kind)
  defp trade_error(:invalid_request), do: "Ingresá una cantidad entera mayor que cero."
  defp trade_error(:insufficient_funds), do: "No tenés créditos suficientes."
  defp trade_error(:insufficient_inventory), do: "No hay suficientes tokens disponibles."
  defp trade_error(:insufficient_holdings), do: "No tenés tantos tokens para vender."

  defp trade_error(:quote_unavailable),
    do: "Todavía no hay una cotización de rendimiento válida para comprar este jugador."

  defp trade_error(:self_purchase),
    do:
      "Esta cuenta aporta el inventario inicial. Para comprar, ingresá con una cuenta inversora."

  defp trade_error(:self_sale),
    do:
      "Esta cuenta recibió el inventario inicial y no puede venderse tokens a sí misma. Usá una cuenta inversora."

  defp trade_error(:request_conflict),
    do:
      "Esta solicitud ya se usó con otros datos. Iniciá una nueva operación antes de cambiar la acción o la cantidad."

  defp trade_error(_),
    do:
      "No se pudo completar la operación. Revisá tus créditos para comprar, tus tokens para vender y que la cantidad sea un número entero. Se necesita una cotización actual."

  defp load_card(socket, nil, _params), do: assign(socket, card: nil, quote: nil, card_error: nil)

  defp load_card(socket, id, params) do
    case Catalog.player_card(id) do
      {:ok, card} ->
        quote = current_quote(id)
        {history, history_unavailable} = quote_history(id)
        date_param = params["date"] || ""
        dated_quote = dated_quote(id, date_param)

        socket
        |> assign(
          card: card,
          quote: quote,
          quote_history: history,
          quote_history_unavailable: history_unavailable,
          quote_date: date_param,
          dated_quote: dated_quote,
          card_error: nil
        )
        |> reload_portfolio()
        |> reload_issuer_inventory()

      _ ->
        assign(socket, card: nil, card_error: "No se pudo cargar la ficha del jugador.")
    end
  end

  defp current_quote(id) do
    case Quotes.latest(id) do
      {:ok, quote} -> quote
      _ -> nil
    end
  end

  defp quote_history(id) do
    case Quotes.list_history(id) do
      {:ok, rows} -> {rows, false}
      _ -> {[], true}
    end
  end

  defp dated_quote(_id, ""), do: nil

  defp dated_quote(id, value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> dated_quote_at(id, date)
      _ -> :invalid
    end
  end

  defp dated_quote_at(id, date) do
    case Quotes.at_date(id, date) do
      {:ok, row} -> row
      {:error, :quote_not_found} -> :missing
      _ -> :unavailable
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
      |> Enum.filter(fn {key, value} ->
        key in ["league_id", "team_id", "position_id"] and value != ""
      end)
      |> Map.new(fn {key, value} -> {String.to_existing_atom(key), value} end)
      |> maybe_name_filter(params["q"])

    opts = %{
      page_size: page_size(params["page_size"]),
      cursor: params["cursor"],
      filters: filters
    }

    valid_filters? =
      filters
      |> Map.delete(:search_name)
      |> Enum.all?(fn {_key, value} -> match?({:ok, _}, Ecto.UUID.cast(value)) end)

    result =
      if valid_filters?, do: Catalog.list_player_page(opts), else: {:error, :invalid_filters}

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

  defp maybe_name_filter(filters, nil), do: filters
  defp maybe_name_filter(filters, ""), do: filters
  defp maybe_name_filter(filters, name), do: Map.put(filters, :search_name, name)

  defp maybe_scout_name_miss(nil, _filters, players, _cursor), do: {players, nil}
  defp maybe_scout_name_miss("", _filters, players, _cursor), do: {players, nil}

  defp maybe_scout_name_miss(_name, _filters, players, _cursor) when players != [],
    do: {players, nil}

  defp maybe_scout_name_miss(name, filters, [], cursor) do
    local_miss? = Catalog.search_local_players(name) == {:ok, []}

    if is_nil(cursor) and local_miss? and Map.keys(filters) == [:search_name] do
      case Catalog.search_players(name) do
        {:ok, players, status} -> {players, status}
        _ -> {[], nil}
      end
    else
      {[], nil}
    end
  end

  defp load_transactions(socket, params) do
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

  defp player_name(id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} -> player.display_name
      _ -> "Jugador"
    end
  end

  defp page_size(value) when is_binary(value) do
    case Integer.parse(value) do
      {size, ""} when size in 1..100 -> size
      _ -> 25
    end
  end

  defp page_size(_), do: 25

  defp load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        entries =
          Enum.map(ranking.entries, &Map.put(&1, :player_name, order_player_name(&1.player_id)))

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

  def render(assigns) do
    ~H"""
    <.shell
      actor={@actor}
      destination={@destination}
      administrator={FootballMarket.Accounts.administrator?(domain_actor(@actor))}
      credit_balance={@credit_balance}
      credit_balance_unavailable={@credit_balance_unavailable}
    >
      <%= if @destination == "/conditional-orders" do %>
        <section id="conditional-orders">
          <p class="eyebrow">ESPACIO DE TRABAJO / ÓRDENES</p>
          <h1>Órdenes condicionales</h1>
          <p>
            Las órdenes no reservan créditos ni tokens. Alcanzar el precio indicado no garantiza una compra.
          </p>

          <div class="orders-layout">
            <div class="order-compose">
              <h2>Nueva orden</h2>
              <p class="muted">Elegí un jugador, un precio máximo y el vencimiento.</p>
              <form id="conditional-order-form" phx-submit="create_order">
                <p :if={!@selected_player}>Primero elegí un jugador del catálogo.</p>
                <a :if={!@selected_player} class="text-link" href="/players">Buscar jugadores →</a>
                <p
                  :if={@selected_player}
                  class="selected-order-player"
                  id="selected-player"
                  role="status"
                >
                  {@selected_player.display_name} · {@selected_player.team.name} · {@selected_player.team.season.league.name}
                  <a href="/players">Cambiar jugador</a>
                </p>
                <p :if={@selected_player && @selected_quote} id="order-current-quote">
                  Cotización actual: <strong>{money(@selected_quote.unit_price)} créditos por token</strong>.
                  La orden se ejecuta solo si el precio llega a tu máximo y hay saldo e inventario.
                </p>
                <p :if={@selected_player && !@selected_quote} id="order-no-quote" role="status">
                  Este jugador no tiene cotización disponible; no se puede crear una orden todavía.
                </p>
                <input
                  id="order-player-id"
                  name="player_id"
                  type="hidden"
                  value={@order_form["player_id"]}
                />
                <label for="order-quantity">Cantidad</label>
                <input
                  id="order-quantity"
                  name="quantity"
                  type="number"
                  min="1"
                  max="100"
                  step="1"
                  required
                  value={@order_form["quantity"]}
                />

                <label for="order-maximum-unit-price">Precio máximo por token (créditos)</label>
                <input
                  id="order-maximum-unit-price"
                  name="maximum_unit_price"
                  type="number"
                  min="0.01"
                  step="0.01"
                  required
                  value={@order_form["maximum_unit_price"]}
                />

                <label for="order-expires-at">Vencimiento (fecha y hora UTC)</label>
                <input
                  id="order-expires-at"
                  name="expires_at"
                  type="datetime-local"
                  step="1"
                  required
                  value={@order_form["expires_at"]}
                />
                <p>
                  Seleccioná fecha y hora en UTC, independientemente de la zona horaria de tu dispositivo.
                </p>
                <button
                  type="submit"
                  phx-disable-with="Creando orden…"
                  disabled={!@selected_player || !@selected_quote}
                >Crear orden condicional</button>
              </form>

              <p :if={@order_error} id="order-error" role="alert">{@order_error}</p>
              <p :if={@order_notice} id="order-notice" role="status">{@order_notice}</p>
              <p :if={@orders_unavailable} id="orders-unavailable" role="alert">
                Las órdenes no están disponibles temporalmente. Probá de nuevo en unos instantes.
              </p>
            </div>
            <div class="orders-history">
              <h2>Tus órdenes</h2>
              <p :if={@orders == [] && !@orders_unavailable} id="no-orders">
                No tenés órdenes condicionales.
              </p>
              <ul id="order-list">
                <li :for={order <- @orders} id={"conditional-order-#{order.id}"}>
                  <article>
                    <div class="order-card-heading">
                      <.link navigate={~p"/players?player_id=#{order.player_id}"}><.player_identity
                        id={"order-face-#{order.id}"}
                        name={order.player_name}
                        profile={Map.get(@profiles, order.player_id)}
                        subtitle="Orden de compra"
                      /></.link><span class={"status-badge status-#{order.status}"}>{order_status(
                        order.status
                      )}</span>
                    </div>
                    <dl>
                      <dt>Cantidad</dt><dd>{order.quantity}</dd>
                      <dt>Precio máximo por token</dt><dd>{money(order.maximum_unit_price)}</dd>
                      <dt>Creada</dt><dd>{timestamp(order.created_at)}</dd>
                      <dt>Vence</dt><dd>{timestamp(order.expires_at)}</dd>
                      <dt>Estado</dt><dd>{order_status(order.status)}</dd>
                      <dt>Completada</dt><dd>
                        {if order.completed_at, do: timestamp(order.completed_at), else: "—"}
                      </dd>
                      <dt>Vencimiento alcanzado</dt><dd>
                        {if order.expiry_reached, do: "Sí", else: "No"}
                      </dd>
                    </dl>
                    <details class="order-reference">
                      <summary>Referencia de la orden</summary><p>
                        Identificador de orden: <code>{order.id}</code>
                      </p><p>Jugador: <code>{order.player_id}</code></p>
                    </details>
                    <p :if={order.expiry_reached} class="expiry-reached">
                      Venció el plazo. El estado se actualizará cuando se procese la evaluación.
                    </p>
                    <details :if={order.status == "executed" && order.execution}>
                      <summary>Detalles de ejecución</summary>
                      <dl>
                        <dt>Precio unitario</dt><dd>{money(order.execution.unit_price)}</dd>
                        <dt>Total</dt><dd>{money(order.execution.total)}</dd>
                        <dt>Completada</dt><dd>{timestamp(order.completed_at)}</dd>
                        <dt>Operación</dt><dd>
                          <code>{Map.get(order.execution, :purchase_id)}</code>
                        </dd>
                        <dt>Cotización utilizada</dt><dd>
                          {money(order.execution.unit_price)} créditos por token
                        </dd>
                        <dt>Completada</dt><dd>
                          {timestamp(Map.get(order.execution, :completed_at))}
                        </dd>
                      </dl>
                    </details>
                    <p :if={order.status == "rejected"}>
                      Rechazada: {readable_reason(order.rejection_reason)}.
                    </p>
                    <button
                      :if={order.status == "pending" && !order.expiry_reached}
                      type="button"
                      phx-click="cancel_order"
                      phx-value-id={order.id}
                      phx-disable-with="Cancelando…"
                    >Cancelar orden</button>
                  </article>
                </li>
              </ul>
            </div>
          </div>
        </section>
      <% else %>
        <section :if={@destination == "/transactions"} id="transactions">
          <p class="eyebrow">TU ACTIVIDAD</p>
          <h1>Historial de operaciones</h1>
          <p class="section-description">Tus compras y ventas, con el detalle de cada movimiento.</p>
          <form id="transaction-page-size" phx-change="transaction_page_size">
            <label for="transaction-size">Operaciones por página</label>
            <select id="transaction-size" name="page_size">
              <option
                :for={size <- 1..100}
                value={size}
                selected={size == @transaction_page_size}
              >
                {size}
              </option>
            </select>
          </form>
          <p :if={@transaction_error} role="alert">El historial no está disponible temporalmente.</p>
          <p :if={@transactions == [] && !@transaction_error} id="transactions-empty">
            Todavía no hay operaciones.
          </p>
          <div
            :if={@transactions != []}
            class="table-scroll"
            role="region"
            aria-label="Historial de operaciones"
            tabindex="0"
          >
            <table>
              <caption>Compras y ventas · Valores en créditos</caption>
              <thead>
                <tr>
                  <th>Tipo</th><th>Jugador</th><th>Cantidad</th><th>Precio unitario</th><th>Total</th><th>
                    Cotización
                  </th><th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={transaction <- @transactions} id={"transaction-#{transaction.id}"}>
                  <td>
                    <span class={"status-badge status-#{transaction.type}"}>{if transaction.type ==
                                                                                  "purchase",
                                                                                do: "Compra",
                                                                                else: "Venta"}</span>
                  </td>
                  <td>
                    <.link navigate={~p"/players?player_id=#{transaction.player_id}"}><.player_identity
                      id={"activity-#{transaction.id}"}
                      name={transaction.player_name}
                      profile={Map.get(@profiles, transaction.player_id)}
                    /></.link>
                  </td>
                  <td>{transaction.quantity}</td><td>{exact_money(transaction.unit_price)}</td><td>
                    {exact_money(transaction.total)}
                  </td>
                  <td>
                    <details>
                      <summary>Ver referencia</summary><p>
                        {exact_money(transaction.unit_price)} créditos por token · operación del {timestamp(
                          transaction.completed_at
                        )}
                      </p>
                    </details>
                  </td>
                  <td>{timestamp(transaction.completed_at)}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <a
            :if={@transaction_pagination && @transaction_pagination.has_more}
            id="transactions-next"
            href={"/transactions?" <> URI.encode_query(%{"page_size" => @transaction_page_size, "cursor" => @transaction_pagination.next_cursor})}
          >Siguiente página</a>
        </section>
        <%= if @destination == "/players" do %>
          <section id="player-catalog">
            <p :if={@card} class="catalog-back-link">
              <a :if={@catalog_state_query != ""} href={"/players?" <> @catalog_state_query}>← Volver a resultados</a>
              <a :if={@player_search == ""} href="/players">← Buscar otro jugador</a>
            </p>
            <.player_card
              card={@card}
              quote={@quote}
              profile={@card && Map.get(@profiles, @card.player.id)}
              error={@card_error}
              request_key={@trade_key}
              search_query={@catalog_state_query}
              quote_history={@quote_history}
              quote_history_unavailable={@quote_history_unavailable}
              quote_date={@quote_date}
              dated_quote={@dated_quote}
              trade_record={@trade_record}
              credit_balance={@credit_balance}
              credit_balance_unavailable={@credit_balance_unavailable}
              initial_recipient={@initial_recipient}
              initial_recipient_unavailable={@initial_recipient_unavailable}
              trade_quantity={@trade_quantity}
              positions={@positions}
              portfolio_unavailable={@portfolio_unavailable}
              issuer_inventory={@issuer_inventory}
              issuer_inventory_unavailable={@issuer_inventory_unavailable}
              trade_error={@trade_error}
              notice={@trade_notice}
              complete={@trade_complete}
            />
            <div :if={!@card} class="catalog-heading">
              <div>
                <p class="eyebrow">DESCUBRÍ TU PRÓXIMA POSICIÓN</p>
                <h1>Jugadores<span class="title-dot" aria-hidden="true">.</span></h1>
                <p class="catalog-intro">
                  Buscá jugadores en el catálogo, compará sus clubes y ligas, y elegí uno para operar.
                </p>
              </div>
            </div>
            <div :if={!@card} class="catalog-search-card">
              <form id="player-catalog-search" phx-submit="search_players" phx-change="search_players">
                <label for="player-search">Nombre del jugador</label>
                <div class="player-search-controls">
                  <input
                    id="player-search"
                    phx-debounce="300"
                    name="player_search"
                    type="search"
                    placeholder="Buscá por nombre o apellido…"
                    autocomplete="off"
                    value={@player_search}
                  />
                  <button type="submit" phx-disable-with="Buscando…"><.icon
                    name="hero-magnifying-glass"
                    class="button-icon"
                  />Buscar jugadores</button>
                </div>
                <p class="search-feedback" role="status">Actualizando resultados…</p>
                <div class="catalog-filters">
                  <label for="catalog-league">Liga</label>
                  <select id="catalog-league" name="league_id"><option value="">
                    Todas las ligas
                  </option><option
                    :for={item <- @catalog_filter_options.leagues}
                    value={item.id}
                    selected={@catalog_filters["league_id"] == item.id}
                  >
                    {item.name}
                  </option></select>
                  <label for="catalog-team">Club</label>
                  <select id="catalog-team" name="team_id"><option value="">Todos los clubes</option><option
                    :for={item <- @catalog_filter_options.teams}
                    value={item.id}
                    selected={@catalog_filters["team_id"] == item.id}
                  >
                    {item.name} · {item.league_name}
                  </option></select>
                  <label for="catalog-position">Posición</label>
                  <select id="catalog-position" name="position_id"><option value="">
                    Todas las posiciones
                  </option><option
                    :for={item <- @catalog_filter_options.positions}
                    value={item.id}
                    selected={@catalog_filters["position_id"] == item.id}
                  >
                    {item.name}
                  </option></select>
                  <label for="catalog-page-size">Resultados por página</label>
                  <select id="catalog-page-size" name="page_size"><option
                    :for={size <- 1..100}
                    value={size}
                    selected={size == @catalog_page_size}
                  >
                    {size}
                  </option></select>
                </div>
                <.link
                  :if={@player_search != "" || map_size(@catalog_filters) > 0}
                  patch="/players"
                  id="catalog-reset"
                  class="text-link filter-reset"
                >
                  Limpiar filtros <span aria-hidden="true">↺</span>
                </.link>
              </form>
              <p :if={!@search_performed} class="catalog-hint">
                Ingresá al menos 2 caracteres y buscá en el catálogo.
              </p>
            </div>
            <p :if={!@card && @player_search_unavailable} role="alert">
              La búsqueda no está disponible temporalmente. Probá de nuevo en unos instantes.
            </p>
            <div
              :if={!@card && @search_performed && @player_results != []}
              class="catalog-results-heading"
            >
              <h2 :if={@player_search == ""}>Todos los jugadores</h2>
              <h2 :if={@player_search != ""}>Resultados para “{@player_search}”</h2>
              <span>{length(@player_results)} {if length(@player_results) == 1,
                do: "jugador",
                else: "jugadores"}</span>
            </div>
            <p
              :if={
                !@card && @search_performed && @player_results == [] && !@player_search_unavailable
              }
              class="catalog-hint"
            >
              No encontramos jugadores. Probá con otro nombre.
            </p>
            <p
              :if={!@card && @scouting_status && @scouting_status.state in [:queued, :scouting]}
              id="catalog-scout-status"
              role="status"
            >
              Estamos buscando en las fuentes configuradas. Volvé a buscar en unos instantes.
            </p>
            <p
              :if={!@card && @scouting_status && @scouting_status.state == :unavailable}
              id="catalog-scout-status"
              role="status"
            >
              La búsqueda ampliada no está disponible porque no hay fuentes configuradas. Podés buscar en el catálogo local.
            </p>
            <p
              :if={
                !@card && @scouting_status &&
                  @scouting_status.state in [:cached_miss, :provider_failure, :rate_limited]
              }
              id="catalog-scout-status"
              role="status"
            >
              La búsqueda de este nombre está pausada. Probá de nuevo después de {DateTime.to_iso8601(
                @scouting_status.next_attempt_at
              )}.
            </p>
            <p
              :if={!@card && @scouting_status && @scouting_status.state == :rejected}
              id="catalog-scout-status"
              role="status"
            >
              Ingresá un nombre de jugador con al menos dos letras.
            </p>
            <div
              :if={!@card && @player_results != []}
              class="player-table-wrap"
              id="player-search-results"
              role="region"
              aria-label="Resultados de búsqueda de jugadores"
              tabindex="0"
            >
              <table class="player-table">
                <thead>
                  <tr>
                    <th scope="col">Jugador</th><th scope="col">Club</th><th scope="col">Liga</th><th scope="col">
                      <span class="sr-only">Acción</span>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={player <- @player_results}>
                    <th scope="row">
                      <.player_identity
                        id={"catalog-#{player.id}"}
                        name={player.display_name}
                        profile={Map.get(@profiles, player.id)}
                        subtitle={position_name(player.position.code)}
                      />
                    </th>
                    <td>
                      <.club_identity
                        id={"catalog-club-#{player.id}"}
                        name={player.team.name}
                        profile={Map.get(@profiles, player.id)}
                      />
                    </td>
                    <td>{player.team.season.league.name}</td>
                    <td>
                      <a href={"/players?player_id=#{player.id}" <> if(@catalog_state_query == "", do: "", else: "&" <> @catalog_state_query)}>Ver ficha y operar</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <a
              :if={@catalog_pagination && @catalog_pagination.has_more}
              id="catalog-next"
              href={"/players?" <> URI.encode_query(Map.merge(Map.take(%{"q" => @player_search}, ["q"]), @catalog_filters) |> Map.put("page_size", @catalog_page_size) |> Map.put("cursor", @catalog_pagination.next_cursor))}
            >Siguiente página</a>
          </section>
        <% else %>
          <.ranking_view
            :if={@destination == "/ranking"}
            ranking={@ranking}
            error={@ranking_error}
            profiles={@profiles}
          />
          <section :if={@destination == "/portfolio"} id="portfolio">
            <p class="eyebrow">ESPACIO DE TRABAJO / PORTAFOLIO</p>
            <h1>Portafolio</h1>
            <p class="section-description">Tus jugadores, posiciones y rendimiento.</p>
            <section
              :if={@positions != []}
              id="portfolio-value-summary"
              aria-label="Valor estimado de tus posiciones"
            >
              <p>Valor estimado de tus posiciones</p>
              <strong>{@positions
              |> Enum.reduce(Decimal.new(0), fn position, total ->
                Decimal.add(total, position.current_value)
              end)
              |> exact_money()} créditos</strong>
              <span>Según la cotización actual; el saldo disponible se muestra arriba.</span>
              <dl :if={@allocation} class="portfolio-highlight-metrics">
                <div>
                  <dt>Ganancia/pérdida realizada</dt><dd class={
                    profit_class(@allocation.totals.realized_profit_loss)
                  }>
                    {money(@allocation.totals.realized_profit_loss)}
                  </dd>
                </div><div>
                  <dt>Ganancia/pérdida no realizada</dt><dd class={
                    profit_class(@allocation.totals.unrealized_profit_loss)
                  }>
                    {money(@allocation.totals.unrealized_profit_loss)}
                  </dd>
                </div>
              </dl>
            </section>
            <nav class="portfolio-tabs" aria-label="Secciones del portafolio">
              <.link
                :for={
                  {tab, label} <- [
                    {"positions", "Mis jugadores"},
                    {"performance", "Rendimiento"},
                    {"details", "Detalle financiero"}
                  ]
                }
                id={"portfolio-tab-#{tab}"}
                patch={"/portfolio?" <> URI.encode_query(%{"tab" => tab, "from" => @portfolio_from, "to" => @portfolio_to})}
                aria-current={if @portfolio_tab == tab, do: "page", else: nil}
              >
                {label}
              </.link>
            </nav>
            <div
              id="portfolio-panel-positions"
              hidden={@portfolio_tab != "positions"}
              aria-labelledby="portfolio-tab-positions"
            >
              <p :if={@portfolio_unavailable} id="portfolio-unavailable" role="alert">
                Los datos del portafolio no están disponibles temporalmente. Probá de nuevo en unos instantes.
              </p>
              <div :if={@positions == [] && !@portfolio_unavailable} class="empty-state">
                <span class="empty-symbol" aria-hidden="true">◎</span>
                <h2>Tu portafolio empieza acá</h2>
                <p id="no-positions">
                  Todavía no tenés posiciones de operaciones. El inventario inicial se muestra por separado abajo.
                </p>
                <.link class="primary-button" navigate="/players">Explorar jugadores
                <span aria-hidden="true">→</span></.link>
              </div>
              <div
                :if={@positions != []}
                class="table-scroll"
                role="region"
                aria-label="Posiciones del portafolio"
                tabindex="0"
              >
                <table id="portfolio-positions">
                  <caption>Posiciones · Valores en créditos</caption>
                  <thead>
                    <tr>
                      <th scope="col">Jugador</th>
                      <th scope="col">Cantidad</th>
                      <th scope="col">Costo promedio (créditos/token)</th>
                      <th scope="col">Cotización (créditos/token)</th>
                      <th scope="col">Valor estimado (créditos)</th>
                      <th scope="col">Ganancia/pérdida realizada</th>
                      <th scope="col">Ganancia/pérdida no realizada</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr :for={position <- @positions} id={"portfolio-position-#{position.player_id}"}>
                      <th scope="row">
                        <.link navigate={~p"/players?player_id=#{position.player_id}"}><.player_identity
                          id={"holding-#{position.player_id}"}
                          name={position.player_name}
                          profile={Map.get(@profiles, position.player_id)}
                        /></.link>
                      </th>
                      <td>{position.quantity}</td>
                      <td>{exact_money(position.average_unit_cost)}</td>
                      <td>{exact_money(position.current_quote)}</td>
                      <td>{exact_money(position.current_value)}</td>
                      <td class={profit_class(position.realized_profit_loss)}>
                        {exact_money(position.realized_profit_loss)}
                      </td>
                      <td class={profit_class(position.unrealized_profit_loss)}>
                        {exact_money(position.unrealized_profit_loss)}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <section
                :if={@initial_recipient || @issuer_inventory != [] || @issuer_inventory_unavailable}
                id="initial-issuer-inventory"
                aria-labelledby="initial-issuer-inventory-heading"
              >
                <h2 id="initial-issuer-inventory-heading">Inventario inicial emitido</h2>
                <p class="section-description">
                  Tokens que aún conservás de la emisión inicial del mercado.
                </p>
                <p :if={@issuer_inventory_unavailable} id="issuer-inventory-unavailable" role="alert">
                  El inventario inicial no está disponible temporalmente. Probá de nuevo en unos instantes.
                </p>
                <p
                  :if={@issuer_inventory == [] && !@issuer_inventory_unavailable}
                  id="no-initial-issuer-inventory"
                  class="empty-state"
                >
                  No te quedan tokens de la emisión inicial.
                </p>
                <div
                  :if={@issuer_inventory != []}
                  class="table-scroll"
                  role="region"
                  aria-label="Inventario inicial emitido"
                  tabindex="0"
                >
                  <table>
                    <caption>Tokens restantes de la emisión inicial</caption>
                    <thead>
                      <tr>
                        <th scope="col">Jugador</th>
                        <th scope="col">Cantidad restante</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        :for={item <- @issuer_inventory}
                        id={"initial-issuer-inventory-#{item.player_id}"}
                      >
                        <th scope="row">
                          <a href={~p"/players?player_id=#{item.player_id}"}>{item.player_name}</a>
                        </th>
                        <td>{item.quantity}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </section>
            </div>
            <div hidden={@portfolio_tab == "positions"}>
              <form id="portfolio-history-range" phx-submit="portfolio_range">
                <label for="portfolio-from">Desde</label><input
                  id="portfolio-from"
                  type="date"
                  name="from"
                  value={@portfolio_from}
                />
                <label for="portfolio-to">Hasta</label><input
                  id="portfolio-to"
                  type="date"
                  name="to"
                  value={@portfolio_to}
                />
                <button type="submit" phx-disable-with="Actualizando…">Actualizar período</button>
              </form>
              <p :if={@portfolio_range_invalid} id="portfolio-range-invalid" role="alert">
                El período debe tener fechas válidas y un rango permitido.
              </p>
            </div>
            <div
              id="portfolio-panel-performance"
              hidden={@portfolio_tab != "performance"}
              aria-labelledby="portfolio-tab-performance"
            >
              <.portfolio_charts
                allocation={@allocation}
                allocation_unavailable={@allocation_unavailable}
                history={@portfolio_history}
                history_unavailable={@history_unavailable}
              />
            </div>
            <div
              id="portfolio-panel-details"
              hidden={@portfolio_tab != "details"}
              aria-labelledby="portfolio-tab-details"
            >
              <h2>Detalle financiero</h2>
              <p class="section-description">
                Costos, resultados y valores diarios del período seleccionado.
              </p>
              <.portfolio_tables allocation={@allocation} portfolio_history={@portfolio_history} />
            </div>
          </section>
        <% end %>
      <% end %>
    </.shell>
    """
  end

  defp reload_orders(socket) do
    case ConditionalOrders.list(domain_actor(socket.assigns.actor)) do
      {:ok, orders} ->
        orders =
          Enum.map(orders, &Map.put(&1, :player_name, order_player_name(&1.player_id)))

        assign(socket, orders: orders, orders_unavailable: false)

      {:error, _} ->
        assign(socket, orders: [], orders_unavailable: true)
    end
  end

  defp order_player_name(player_id) do
    case Catalog.get_player_detail(player_id) do
      {:ok, player} -> player.display_name
      _ -> "Jugador"
    end
  end

  defp reload_portfolio(socket) do
    case Portfolio.list(domain_actor(socket.assigns.actor)) do
      {:ok, positions} -> assign(socket, positions: positions, portfolio_unavailable: false)
      {:error, _} -> assign(socket, positions: [], portfolio_unavailable: true)
    end
  end

  defp reload_credit_balance(socket) do
    case CreditBalances.available(domain_actor(socket.assigns.actor)) do
      {:ok, balance} ->
        assign(socket, credit_balance: balance, credit_balance_unavailable: false)

      {:error, _} ->
        assign(socket, credit_balance: nil, credit_balance_unavailable: true)
    end
  end

  defp reload_initial_recipient(socket) do
    case Market.initial_recipient?(domain_actor(socket.assigns.actor)) do
      {:ok, recipient?} ->
        assign(socket, initial_recipient: recipient?, initial_recipient_unavailable: false)

      {:error, _} ->
        assign(socket, initial_recipient: false, initial_recipient_unavailable: true)
    end
  end

  defp reload_issuer_inventory(socket) do
    case InitialInventory.list(domain_actor(socket.assigns.actor)) do
      {:ok, inventory} ->
        assign(socket, issuer_inventory: inventory, issuer_inventory_unavailable: false)

      {:error, _} ->
        assign(socket, issuer_inventory: [], issuer_inventory_unavailable: true)
    end
  end

  defp reload_charts(%{assigns: %{destination: "/portfolio", actor: actor}} = socket)
       when not is_nil(actor) do
    domain_actor = domain_actor(actor)

    {allocation, allocation_unavailable} =
      chart_read(fn -> Market.portfolio_allocation(domain_actor) end)

    {history, history_unavailable, range_invalid} =
      case portfolio_options(socket.assigns.portfolio_from, socket.assigns.portfolio_to) do
        {:ok, options} ->
          case Market.portfolio_history(domain_actor, options) do
            {:ok, value} ->
              {value, false, false}

            {:error, %{kind: kind}} when kind in [:invalid_date, :invalid_date_range] ->
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

  defp chart_read(read) do
    case read.() do
      {:ok, data} -> {data, false}
      {:error, _} -> {nil, true}
    end
  end

  defp portfolio_options("", ""), do: Input.range(%{}, Date.utc_today())

  defp portfolio_options(from, to) do
    with {:ok, parsed_from} <- optional_date(from),
         {:ok, parsed_to} <- optional_date(to) do
      Input.range(%{from: parsed_from, to: parsed_to}, Date.utc_today())
    end
  end

  defp optional_date(""), do: {:ok, nil}
  defp optional_date(value) when is_binary(value), do: Date.from_iso8601(value)
  defp optional_date(_), do: {:error, :invalid_date}

  defp load_selected_player(socket, nil), do: socket

  defp load_selected_player(socket, id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} ->
        quote =
          case Quotes.latest(id) do
            {:ok, quote} -> quote
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

  defp domain_actor(actor) do
    %AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }
  end

  defp quantity(value) when is_binary(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value),
      do: {:ok, String.to_integer(value)},
      else: {:error, :invalid_request}
  end

  defp quantity(_), do: {:error, :invalid_request}

  defp order_terms(params, quantity) do
    {:ok,
     %{
       player_id: params["player_id"],
       quantity: quantity,
       maximum_unit_price: params["maximum_unit_price"],
       expires_at: utc_expiry(params["expires_at"])
     }}
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

  defp empty_form,
    do: %{"player_id" => "", "quantity" => "", "maximum_unit_price" => "", "expires_at" => ""}

  defp form_values(params), do: Map.new(empty_form(), fn {key, _} -> {key, params[key] || ""} end)

  defp error_message(:invalid_request),
    do: "Revisá el jugador, la cantidad, el precio y que el vencimiento UTC sea futuro."

  defp error_message(:player_not_found), do: "No encontramos ese jugador."

  defp error_message(:not_initialized),
    do: "Ese jugador no está habilitado para órdenes condicionales."

  defp error_message(:self_purchase),
    do: "No podés crear una orden para comprar tus propios tokens emitidos."

  defp error_message(:temporarily_unavailable),
    do: "Las órdenes no están disponibles temporalmente. Probá de nuevo en unos instantes."

  defp error_message(%{kind: kind}), do: error_message(kind)

  defp error_message(_),
    do: "No se pudo completar la orden. Revisá las condiciones e intentá de nuevo."

  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  defp exact_money(nil), do: "Sin datos"
  defp exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")
  defp readable_reason(nil), do: "no disponible"
  defp readable_reason("insufficient_funds"), do: "saldo insuficiente"
  defp readable_reason("insufficient_inventory"), do: "inventario insuficiente"
  defp readable_reason(reason), do: reason |> String.replace("_", " ")

  defp order_status("pending"), do: "Pendiente"
  defp order_status("executed"), do: "Ejecutada"
  defp order_status("rejected"), do: "Rechazada"
  defp order_status("cancelled"), do: "Cancelada"
  defp order_status("expired"), do: "Vencida"
  defp order_status(status), do: status
end
