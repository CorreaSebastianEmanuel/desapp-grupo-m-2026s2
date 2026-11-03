defmodule FootballMarketWeb.WorkspaceLive do
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents

  alias FootballMarket.Accounts.AuthenticatedActor

  alias FootballMarket.{
    Catalog,
    Market,
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
       card: nil,
       card_error: nil,
       quote: nil,
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
      |> assign(destination: destination, heading: workspace_heading(destination))
      |> reload_credit_balance()
      |> reload_initial_recipient()

    {:noreply,
     case destination do
       "/conditional-orders" ->
         socket |> reload_orders() |> load_selected_player(params["player_id"])

       "/players" ->
         socket = assign(socket, player_search: params["q"] || "")

         if params["player_id"] do
           load_card(socket, params["player_id"])
         else
           socket |> load_card(nil) |> load_player_search(params["q"])
         end

       "/ranking" ->
         load_ranking(socket)

       _ ->
         socket |> reload_portfolio() |> reload_issuer_inventory() |> reload_charts()
     end}
  end

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

  def handle_event("search_players", %{"player_search" => term}, socket) do
    {:noreply, push_patch(socket, to: ~p"/players?q=#{String.trim(term)}")}
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
    if socket.assigns.destination == "/players" and
         Catalog.Scouting.normalize_identity(socket.assigns.player_search) == normalized_name do
      case Catalog.search_players(socket.assigns.player_search) do
        {:ok, players, scouting_status} ->
          {:noreply, assign(socket, player_results: players, scouting_status: scouting_status)}

        _ ->
          {:noreply, socket}
      end
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

  defp trade_result(socket, {:ok, _}) do
    Phoenix.PubSub.broadcast_from(
      FootballMarket.PubSub,
      self(),
      "conditional_orders:" <> socket.assigns.actor.account_id,
      :portfolio_changed
    )

    {:noreply,
     socket
     |> assign(trade_error: nil, trade_notice: "Operación confirmada.", trade_complete: true)
     |> reload_credit_balance()
     |> reload_portfolio()
     |> reload_issuer_inventory()
     |> reload_charts()}
  end

  defp trade_result(socket, {:error, error}),
    do: {:noreply, assign(socket, trade_error: trade_error(error), trade_notice: nil)}

  defp execute_trade("buy", actor, input), do: Market.purchase(actor, input)
  defp execute_trade("sell", actor, input), do: Market.sale(actor, input)

  defp trade_error(%{kind: kind}), do: trade_error(kind)
  defp trade_error(:invalid_request), do: "Ingresá una cantidad entera mayor que cero."
  defp trade_error(:insufficient_funds), do: "No tenés créditos suficientes."
  defp trade_error(:insufficient_inventory), do: "No hay suficientes tokens disponibles."
  defp trade_error(:insufficient_holdings), do: "No tenés tantos tokens para vender."

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

  defp load_card(socket, nil), do: assign(socket, card: nil, quote: nil, card_error: nil)

  defp load_card(socket, id) do
    case Catalog.player_card(id) do
      {:ok, card} ->
        quote =
          case Quotes.latest(id) do
            {:ok, quote} -> quote
            _ -> nil
          end

        socket
        |> assign(card: card, quote: quote, card_error: nil)
        |> reload_portfolio()
        |> reload_issuer_inventory()

      _ ->
        assign(socket, card: nil, card_error: "No se pudo cargar la ficha del jugador.")
    end
  end

  defp load_player_search(socket, nil),
    do:
      assign(socket,
        search_performed: false,
        player_results: [],
        scouting_status: nil,
        player_search_unavailable: false
      )

  defp load_player_search(socket, term) do
    case Catalog.search_players(term) do
      {:ok, players, scouting_status} ->
        assign(socket,
          player_search: term,
          search_performed: true,
          player_results: players,
          scouting_status: scouting_status,
          player_search_unavailable: false
        )

      {:error, _} ->
        assign(socket,
          player_search: term,
          search_performed: true,
          player_results: [],
          player_search_unavailable: true
        )
    end
  end

  defp load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        assign(socket, ranking: ranking, ranking_error: nil)

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
                  type="text"
                  placeholder="2026-11-03T12:00:00Z"
                  required
                  value={@order_form["expires_at"]}
                />
                <p>
                  Usá el formato AAAA-MM-DDTHH:MM:SSZ. La Z indica horario UTC.
                </p>
                <button type="submit" disabled={!@selected_player || !@selected_quote}>Crear orden condicional</button>
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
                    <h3>Compra de {order.player_name}</h3>
                    <dl>
                      <dt>Cantidad</dt><dd>{order.quantity}</dd>
                      <dt>Precio máximo por token</dt><dd>{money(order.maximum_unit_price)}</dd>
                      <dt>Creada</dt><dd>{timestamp(order.created_at)}</dd>
                      <dt>Vence</dt><dd>{timestamp(order.expires_at)}</dd>
                      <dt>Estado</dt><dd>{order_status(order.status)}</dd>
                    </dl>
                    <p :if={order.expiry_reached} class="expiry-reached">
                      Venció el plazo. El estado se actualizará cuando se procese la evaluación.
                    </p>
                    <p :if={order.status == "executed" && order.execution}>
                      Ejecutada a {money(order.execution.unit_price)} por token, total {money(
                        order.execution.total
                      )}.
                    </p>
                    <p :if={order.status == "rejected"}>
                      Rechazada: {readable_reason(order.rejection_reason)}.
                    </p>
                    <button
                      :if={order.status == "pending" && !order.expiry_reached}
                      type="button"
                      phx-click="cancel_order"
                      phx-value-id={order.id}
                    >Cancelar orden</button>
                  </article>
                </li>
              </ul>
            </div>
          </div>
        </section>
      <% else %>
        <%= if @destination == "/players" do %>
          <section id="player-catalog">
            <p :if={@card} class="catalog-back-link">
              <a :if={@player_search != ""} href={~p"/players?q=#{@player_search}"}>← Volver a resultados</a>
              <a :if={@player_search == ""} href="/players">← Buscar otro jugador</a>
            </p>
            <.player_card
              card={@card}
              quote={@quote}
              error={@card_error}
              request_key={@trade_key}
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
                <h1>Jugadores</h1>
                <p class="catalog-intro">
                  Buscá jugadores en el catálogo, compará sus clubes y ligas, y elegí uno para operar.
                </p>
              </div>
            </div>
            <div :if={!@card} class="catalog-search-card">
              <form id="player-catalog-search" phx-submit="search_players">
                <label for="player-search">Nombre del jugador</label>
                <div class="player-search-controls">
                  <input
                    id="player-search"
                    name="player_search"
                    type="search"
                    placeholder="Por ejemplo, Demo BL1 Defender o Demo PL Forward"
                    autocomplete="off"
                    value={@player_search}
                  />
                  <button type="submit">Buscar jugadores</button>
                </div>
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
              <h2>Resultados para “{@player_search}”</h2>
              <span>{@player_results |> length()} jugadores</span>
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
                      <strong>{player.display_name}</strong><span>{position_name(player.position.code)}</span>
                    </th>
                    <td>{player.team.name}</td>
                    <td>{player.team.season.league.name}</td>
                    <td>
                      <a href={~p"/players?player_id=#{player.id}&q=#{@player_search}"}>Ver ficha y operar</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        <% else %>
          <.ranking_view :if={@destination == "/ranking"} ranking={@ranking} error={@ranking_error} />
          <section :if={@destination != "/ranking"} id="portfolio">
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
            </section>
            <p :if={@portfolio_unavailable} id="portfolio-unavailable" role="alert">
              Los datos del portafolio no están disponibles temporalmente. Probá de nuevo en unos instantes.
            </p>
            <div :if={@positions == [] && !@portfolio_unavailable} class="empty-state">
              <span class="empty-symbol" aria-hidden="true">◎</span>
              <h2>Tu portafolio empieza acá</h2>
              <p id="no-positions">
                Todavía no tenés posiciones de operaciones. El inventario inicial se muestra por separado abajo.
              </p>
              <a class="text-link" href="/conditional-orders">Crear una orden condicional →</a>
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
                      <a href={~p"/players?player_id=#{position.player_id}"}>{position.player_name}</a>
                    </th>
                    <td>{position.quantity}</td>
                    <td>{exact_money(position.average_unit_cost)}</td>
                    <td>{exact_money(position.current_quote)}</td>
                    <td>{exact_money(position.current_value)}</td>
                    <td>{exact_money(position.realized_profit_loss)}</td>
                    <td>{exact_money(position.unrealized_profit_loss)}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <section
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
            <.portfolio_charts
              allocation={@allocation}
              allocation_unavailable={@allocation_unavailable}
              history={@portfolio_history}
              history_unavailable={@history_unavailable}
            />
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

    {history, history_unavailable} =
      chart_read(fn -> Market.portfolio_history(domain_actor, %{}) end)

    assign(socket,
      allocation: allocation,
      allocation_unavailable: allocation_unavailable,
      portfolio_history: history,
      history_unavailable: history_unavailable
    )
  end

  defp reload_charts(socket), do: socket

  defp chart_read(read) do
    case read.() do
      {:ok, data} -> {data, false}
      {:error, _} -> {nil, true}
    end
  end

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
       expires_at: params["expires_at"]
     }}
  end

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
