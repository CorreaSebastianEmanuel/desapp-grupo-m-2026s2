defmodule FootballMarketWeb.WorkspaceComponents do
  @moduledoc false
  use FootballMarketWeb, :html
  attr :actor, :map, required: true
  attr :destination, :string, required: true
  attr :credit_balance, :any, required: true
  attr :credit_balance_unavailable, :boolean, required: true
  attr :administrator, :boolean, default: false
  slot :inner_block, required: true

  def shell(assigns) do
    ~H"""
    <section id="workspace" phx-hook="WorkspaceSession">
      <div id="connection-notice" role="alert" hidden>Se perdió la conexión. Reconectando…</div>
      <div id="private-workspace" data-private-workspace>
        <a class="skip-link" href="#workspace-main">Saltar al contenido</a>
        <header class="workspace-sidebar">
          <a class="brand" href="/"><span class="brand-mark" aria-hidden="true">FM</span>
          Football Market</a>
          <p class="nav-caption">TU MERCADO</p>
          <nav aria-label="Espacio de trabajo">
            <.link
              :for={
                {path, label, icon} <- [
                  {"/players", "Jugadores", "hero-user-group"},
                  {"/ranking", "Ranking", "hero-trophy"},
                  {"/portfolio", "Portafolio", "hero-chart-pie"},
                  {"/transactions", "Operaciones", "hero-arrows-right-left"},
                  {"/conditional-orders", "Órdenes condicionales", "hero-adjustments-horizontal"}
                ]
              }
              navigate={path}
              aria-current={@destination == path && "page"}
            >
              <.icon name={icon} class="nav-icon" /><span>{label}</span>
            </.link>
            <a :if={@administrator} href="/administration">
              <.icon name="hero-cog-6-tooth" class="nav-icon" /><span>Administración</span>
            </a>
          </nav>
          <div class="sidebar-note">
            <span class="sidebar-note-mark" aria-hidden="true">↗</span>
            <strong>Tu visión del juego.</strong><p>Cada posición empieza con un jugador.</p>
          </div>
          <div class="workspace-account">
            <div class="workspace-account-details">
              <span class="account-email">{@actor.email}</span>
              <span
                :if={!@credit_balance_unavailable}
                id="credit-balance"
                class="account-credit-balance"
              >
                Créditos disponibles: {Decimal.round(@credit_balance, 2) |> Decimal.to_string(:normal)}
              </span>
              <span
                :if={@credit_balance_unavailable}
                id="credit-balance-unavailable"
                role="alert"
              >
                Saldo de créditos no disponible
              </span>
            </div>
            <form method="post" action="/sign-out">
              <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
              <button>Cerrar sesión</button>
            </form>
          </div>
        </header>
        <main id="workspace-main" tabindex="-1">{render_slot(@inner_block)}</main>
        <footer class="workspace-footer">
          Football Market <span>Tokens de jugadores · Cotizaciones según rendimiento</span>
        </footer>
      </div>
    </section>
    """
  end

  attr :card, :map, default: nil
  attr :quote, :map, default: nil
  attr :error, :string, default: nil
  attr :request_key, :string, required: true
  attr :credit_balance, :any, default: nil
  attr :credit_balance_unavailable, :boolean, default: false
  attr :initial_recipient, :boolean, default: false
  attr :initial_recipient_unavailable, :boolean, default: false
  attr :trade_quantity, :string, default: ""
  attr :positions, :list, default: []
  attr :portfolio_unavailable, :boolean, default: false
  attr :issuer_inventory, :list, default: []
  attr :issuer_inventory_unavailable, :boolean, default: false
  attr :trade_error, :string, default: nil
  attr :notice, :string, default: nil
  attr :complete, :boolean, default: false
  attr :search_query, :string, default: ""
  attr :quote_history, :list, default: []
  attr :quote_history_unavailable, :boolean, default: false
  attr :quote_date, :string, default: ""
  attr :dated_quote, :any, default: nil
  attr :trade_record, :any, default: nil

  def player_card(assigns) do
    ~H"""
    <p :if={@error} role="alert">{@error}</p>
    <article :if={@card} id="player-card">
      <p class="eyebrow">PERFIL DEL JUGADOR</p>
      <h1>{@card.player.display_name}</h1>
      <p class="player-subtitle">
        {position_name(@card.player.position.code)} · {@card.player.team.name} · {@card.player.team.season.league.name}
      </p>
      <p>Temporada {@card.player.team.season.start_year}–{@card.player.team.season.end_year}</p>
      <p
        :if={@card.statistics_status}
        id="player-scraping-status"
        class="statistics-notice"
        role="status"
      >
        {scraping_status(@card.statistics_status.refresh)}
      </p>
      <p :if={@quote} id="player-quote">
        Valor por token <strong>{money(@quote.unit_price)} créditos</strong>
        <span>· Vigente desde {Calendar.strftime(@quote.effective_at, "%d/%m/%Y %H:%M UTC")}</span>
      </p>
      <details :if={@quote} id="quote-provenance">
        <summary>Procedencia de la cotización</summary>
        <.quote_details quote={@quote} />
      </details>
      <p :if={!@quote && @card.statistics.recorded_match_count > 0} id="player-quote-missing">
        Aún no hay una cotización disponible. Se habilitarán las operaciones cuando se publique.
      </p>
      <p
        :if={@card.statistics.recorded_match_count == 0 && @quote}
        id="player-statistics-unavailable"
        class="statistics-notice"
      >
        Todavía no hay estadísticas cargadas para esta temporada.
      </p>
      <p
        :if={@card.statistics.recorded_match_count == 0 && !@quote}
        id="player-statistics-unavailable"
        class="statistics-notice"
      >
        Todavía no hay estadísticas cargadas ni una cotización disponible. No se pueden operar tokens por ahora.
      </p>
      <p :if={@card.statistics.recorded_match_count > 0} id="player-statistics-coverage">
        Datos registrados para esta temporada; la cobertura puede ser parcial.
      </p>
      <dl :if={@card.statistics.recorded_match_count > 0} id="player-statistics">
        <dt>Partidos registrados</dt><dd>{@card.statistics.recorded_match_count}</dd>
        <dt :if={@card.statistics.minutes_played != nil}>Minutos jugados</dt>
        <dd :if={@card.statistics.minutes_played != nil}>{@card.statistics.minutes_played}</dd>
        <dt :if={@card.statistics.goals != nil}>Goles</dt>
        <dd :if={@card.statistics.goals != nil}>{@card.statistics.goals}</dd>
        <dt :if={@card.statistics.assists != nil}>Asistencias</dt>
        <dd :if={@card.statistics.assists != nil}>{@card.statistics.assists}</dd>
      </dl>
      <details id="player-freshness">
        <summary>Frescura y estado de valuación</summary>
        <p>
          Temporada {@card.player.team.season.start_year}–{@card.player.team.season.end_year} · {coverage_name(
            @card.statistics.coverage
          )}
        </p>
        <p :if={@card.statistics_status}>{scraping_status(@card.statistics_status.refresh)}</p>
        <p :if={@card.statistics_status} id="player-valuation-status">
          {valuation_status(@card.statistics_status.valuation)}
        </p>
        <p :if={@quote}>Última valuación publicada: {timestamp(@quote.effective_at)}.</p>
        <p>
          Las estadísticas se actualizan por separado; las cotizaciones se recalculan en el cierre del mercado.
        </p>
      </details>
      <section id="player-position-summary" aria-label="Tu posición en este jugador">
        <h3>Tu posición</h3>
        <%= cond do %>
          <% @initial_recipient_unavailable ||
               (@initial_recipient && @issuer_inventory_unavailable) ||
               (!@initial_recipient && @portfolio_unavailable) -> %>
            <p id="player-position-unavailable" role="alert">
              Tus tenencias no están disponibles temporalmente.
            </p>
          <% @initial_recipient -> %>
            <%= if item = Enum.find(@issuer_inventory, &(&1.player_id == @card.player.id)) do %>
              <p><strong>{item.quantity} tokens</strong> del inventario inicial</p>
            <% else %>
              <p>Todavía no tenés tokens de este jugador.</p>
            <% end %>
          <% position = Enum.find(@positions, &(&1.player_id == @card.player.id)) -> %>
            <p>
              <strong>{position.quantity} tokens</strong><span :if={@quote}> · Valor estimado {money(
                Decimal.mult(@quote.unit_price, position.quantity)
              )} créditos</span>
            </p>
          <% true -> %>
            <p>Todavía no tenés tokens de este jugador.</p>
        <% end %>
      </section>
      <a
        :if={@quote && !@initial_recipient && !@initial_recipient_unavailable}
        href={~p"/conditional-orders?player_id=#{@card.player.id}"}
      >Crear orden</a>
      <p :if={@initial_recipient} id="initial-issuer-trade-note" class="statistics-notice">
        Esta cuenta emitió los tokens iniciales. Otros usuarios pueden comprarlos de su inventario; esta cuenta no puede operar sus propios tokens.
      </p>
      <p
        :if={@initial_recipient_unavailable}
        id="initial-issuer-check-unavailable"
        role="alert"
      >
        No se pueden operar tokens temporalmente porque no pudimos verificar el tipo de cuenta.
      </p>
      <form
        :if={@quote && !@complete && !@initial_recipient && !@initial_recipient_unavailable}
        id="trade-form"
        phx-submit="trade"
        phx-change="trade_preview"
      >
        <input type="hidden" name="request_key" value={@request_key} />
        <p :if={@credit_balance_unavailable} id="player-card-credit-balance-unavailable" role="alert">
          No se pudo consultar el saldo; la compra no está disponible temporalmente.
        </p>
        <label for="trade-quantity">Cantidad de tokens</label>
        <input
          id="trade-quantity"
          name="quantity"
          type="number"
          min="1"
          step="1"
          placeholder="Ingresá un número entero"
          value={@trade_quantity}
          required
        />
        <p id="trade-estimate" class="trade-estimate">
          Importe estimado:
          <strong>{estimated_total(@trade_quantity, @quote.unit_price)} créditos</strong>
        </p>
        <div id="trade-actions">
          <button
            type="submit"
            name="side"
            value="buy"
            class="trade-action-buy"
            disabled={@credit_balance_unavailable}
          >Comprar tokens</button>
          <button
            type="submit"
            name="side"
            value="sell"
            class="trade-action-sell"
            disabled={Enum.find(@positions, &(&1.player_id == @card.player.id)) == nil}
          >Vender tokens</button>
        </div>
      </form>
      <p :if={@trade_error} id="trade-error" role="alert">{@trade_error}</p>
      <p :if={@notice} id="trade-notice" role="status">{@notice}</p>
      <details :if={@complete && @trade_record} id="trade-confirmation">
        <summary>Detalles de la operación confirmada</summary>
        <dl>
          <dt>Jugador</dt><dd>{@card.player.display_name}</dd>
          <dt>Tipo</dt><dd>
            {if @trade_record.type in ["sale", "sell"], do: "Venta", else: "Compra"}
          </dd>
          <dt>Cantidad</dt><dd>{@trade_record.quantity}</dd>
          <dt>Precio unitario</dt><dd>{money(@trade_record.unit_price)} créditos</dd>
          <dt>Total</dt><dd>{money(@trade_record.total)} créditos</dd>
          <dt>Completada</dt><dd>{timestamp(@trade_record.completed_at)}</dd>
          <dt>Cotización efectiva</dt><dd>{timestamp(@trade_record.quote_effective_at)}</dd>
          <dt>Estrategia</dt><dd>
            {strategy_name(@trade_record.rule_id)} · versión {@trade_record.rule_version}
          </dd>
        </dl>
      </details>
      <button
        :if={@complete}
        id="new-trade"
        class="secondary-button"
        phx-click="new_trade"
      >Nueva operación</button>
      <section id="quote-history">
        <h3>Historial de cotizaciones</h3>
        <form phx-submit="quote_date">
          <label for="quote-history-date">Buscar cotización al cierre de una fecha</label>
          <input id="quote-history-date" type="date" name="date" value={@quote_date} required />
          <button type="submit">Consultar fecha</button>
        </form>
        <p :if={@dated_quote == :invalid} role="alert">
          Ingresá una fecha válida con formato AAAA-MM-DD.
        </p>
        <p :if={@dated_quote == :missing} role="status">No hay cotización para esa fecha.</p>
        <p :if={@dated_quote == :unavailable} role="alert">
          La consulta de cotización no está disponible temporalmente.
        </p>
        <p :if={@dated_quote not in [nil, :missing, :invalid, :unavailable]} role="status">
          Cotización al {@quote_date}: {money(@dated_quote.unit_price)} créditos · vigente desde {timestamp(
            @dated_quote.effective_at
          )}.
        </p>
        <details :if={is_map(@dated_quote)} id="dated-quote-provenance">
          <summary>Procedencia de la cotización consultada</summary>
          <.quote_details quote={@dated_quote} />
        </details>
        <p :if={@quote_history_unavailable} id="quote-history-unavailable" role="alert">
          El historial de cotizaciones no está disponible temporalmente.
        </p>
        <p :if={@quote_history == [] && !@quote_history_unavailable} id="quote-history-empty">
          No hay cotizaciones registradas.
        </p>
        <details :if={@quote_history != []}>
          <summary>Ver {length(@quote_history)} cotizaciones</summary>
          <ol>
            <li :for={item <- @quote_history}>
              <strong>{money(item.unit_price)} créditos</strong>
              · {timestamp(item.effective_at)}
              <details>
                <summary>Procedencia</summary><.quote_details quote={item} />
              </details>
            </li>
          </ol>
        </details>
      </section>
    </article>
    """
  end

  defp scraping_status(%{state: "queued"}), do: "Actualización de estadísticas en cola."

  defp scraping_status(%{state: state}) when state in ["executing", "retry_wait"],
    do: "Actualizando estadísticas del jugador."

  defp scraping_status(%{state: "idle"}), do: "Estadísticas actualizadas para esta temporada."

  defp scraping_status(%{state: "unconfigured"}),
    do: "Actualización automática no configurada para este jugador."

  defp scraping_status(%{state: "unavailable"}),
    do: "No se pudo iniciar la actualización de estadísticas."

  defp scraping_status(%{state: "blocked"}),
    do: "La actualización de estadísticas necesita revisión."

  defp scraping_status(%{state: "cooldown"}), do: "La actualización se reintentará más tarde."
  defp scraping_status(_), do: "Estado de actualización de estadísticas no disponible."

  attr :quote, :map, required: true

  def quote_details(assigns) do
    ~H"""
    <dl>
      <dt>Precio unitario</dt><dd>{money(@quote.unit_price)} créditos</dd>
      <dt>Vigente desde</dt><dd>{timestamp(@quote.effective_at)}</dd>
      <dt>Estrategia</dt><dd>{strategy_name(@quote.rule_id)} · versión {@quote.rule_version}</dd>
      <dt>Fuente</dt><dd>{quote_source(@quote)}</dd>
      <dt>Registrada</dt><dd>{timestamp(@quote.inserted_at)}</dd>
    </dl>
    """
  end

  attr :ranking, :map, default: nil
  attr :error, :string, default: nil

  def ranking_view(assigns) do
    ~H"""
    <section id="ranking">
      <p class="eyebrow">EXPLORÁ EL MERCADO</p>
      <h1>Ranking de estrategia activa</h1>
      <p class="section-description">
        Compará las cotizaciones según la estrategia de valuación vigente.
      </p>
      <p :if={@error} role="alert">{@error}</p>
      <div :if={!@ranking && !@error} id="ranking-unavailable" class="empty-state">
        <h2>El ranking todavía no está disponible</h2>
        <p>Se mostrará cuando haya una estrategia de cotización activa.</p>
        <a class="text-link" href="/players">Explorar jugadores →</a>
      </div>
      <div :if={@ranking}>
        <p id="ranking-strategy">
          Estrategia activa: {strategy_name(@ranking.configuration.strategy_id)} · Fórmula {@ranking.configuration.formula_version}
        </p>
        <p :if={@ranking.entries == []} id="ranking-empty">
          No hay cotizaciones válidas para la estrategia activa.
        </p>
        <ol id="ranking-entries">
          <li :for={entry <- @ranking.entries} id={"ranking-player-#{entry.player_id}"}>
            <a href={~p"/players?player_id=#{entry.player_id}"}>{entry.player_name}</a>
            · {Decimal.to_string(entry.unit_price, :normal)} créditos
            · Efectiva {timestamp(Map.get(entry, :effective_at))} ·
            <details>
              <summary>Referencia de cotización</summary>
              <p>
                {Decimal.to_string(entry.unit_price, :normal)} créditos por token · {timestamp(
                  entry.effective_at
                )} · {strategy_name(@ranking.configuration.strategy_id)} · versión {@ranking.configuration.formula_version}. Fuente: rendimiento deportivo.
              </p>
            </details>
          </li>
        </ol>
      </div>
    </section>
    """
  end

  attr :allocation, :map, default: nil
  attr :allocation_unavailable, :boolean, default: false
  attr :history, :map, default: nil
  attr :history_unavailable, :boolean, default: false

  def portfolio_charts(assigns) do
    ~H"""
    <section id="portfolio-charts" aria-labelledby="portfolio-charts-heading">
      <h2 id="portfolio-charts-heading">Gráficos del portafolio</h2>
      <section id="allocation-chart" aria-labelledby="allocation-heading">
        <h3 id="allocation-heading">Distribución actual</h3>
        <p :if={@allocation_unavailable} role="alert">
          La distribución no está disponible temporalmente. Probá de nuevo en unos instantes.
        </p>
        <div :if={@allocation}>
          <p :if={@allocation.positions == []} id="allocation-empty">
            No hay posiciones para mostrar.
          </p>
          <ol :if={@allocation.positions != []} class="allocation-bars">
            <li :for={position <- @allocation.positions}>
              <span class="allocation-player">{position.player_name}</span>
              <span class="allocation-track" aria-hidden="true">
                <span class="allocation-fill" style={allocation_style(position.weight)}></span>
              </span>
              <span class="allocation-value">
                {if is_nil(position.weight), do: "Sin datos", else: percent(position.weight)}
              </span>
            </li>
          </ol>
          <p :if={@allocation.positions != [] && !@allocation.totals.valuation_complete}>
            La distribución estará disponible cuando todos tus jugadores tengan una cotización actual.
          </p>
          <p :if={@allocation.positions != []} class="chart-as-of">
            Distribución al {timestamp(@allocation.as_of)} · Porcentaje del valor de mercado
          </p>
        </div>
      </section>

      <section id="portfolio-history" aria-labelledby="history-heading">
        <h3 id="history-heading">Historial diario del portafolio</h3>
        <p :if={@history_unavailable} role="alert">
          El historial del portafolio no está disponible temporalmente. Probá de nuevo en unos instantes.
        </p>
        <div :if={@history && !has_historical_activity?(@history.points)} id="history-empty">
          <p>Todavía no hay movimientos. Las compras y ventas realizadas aparecerán acá.</p>
        </div>
        <div :if={@history && has_historical_activity?(@history.points)}>
          <.history_chart
            :for={{metric, label} <- history_metrics()}
            points={@history.points}
            metric={metric}
            label={label}
          />
          <p class="chart-as-of">
            Valores diarios del {@history.from} al {@history.to} (UTC). Cada punto corresponde al cierre del día; el día actual es parcial.
          </p>
        </div>
      </section>
    </section>
    """
  end

  attr :allocation, :map, default: nil
  attr :portfolio_history, :map, default: nil

  def portfolio_tables(assigns) do
    ~H"""
    <div
      :if={@allocation}
      class="table-scroll"
      role="region"
      aria-label="Distribución de posiciones"
      tabindex="0"
    >
      <dl
        id="portfolio-allocation-totals"
        class="portfolio-metrics"
        aria-label="Totales de distribución en créditos"
      >
        <div class="portfolio-metric">
          <dt>Valor de mercado</dt><dd>{exact_money(@allocation.totals.market_value)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Costo base</dt><dd>{exact_money(@allocation.totals.cost_basis)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Compras</dt><dd>{exact_money(@allocation.totals.purchase_expenditure)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Ventas</dt><dd>{exact_money(@allocation.totals.sale_proceeds)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Invertido neto</dt><dd>{exact_money(@allocation.totals.net_invested)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Realizada</dt><dd>{exact_money(@allocation.totals.realized_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>No realizada</dt><dd>{exact_money(@allocation.totals.unrealized_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Resultado total</dt><dd>{exact_money(@allocation.totals.total_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Valuación</dt><dd>
            {if @allocation.totals.valuation_complete, do: "Completa", else: "Incompleta"}
          </dd>
        </div>
      </dl>
      <p
        :if={!@allocation.totals.valuation_complete}
        id="allocation-missing-quotes"
        role="status"
      >
        Cotización pendiente para: {Enum.join(
          @allocation.totals.missing_quote_player_ids,
          ", "
        )}. Los valores faltantes se muestran como huecos.
      </p>
      <table :if={@allocation.positions != []} id="portfolio-allocation-table">
        <caption>Distribución actual del portafolio · {timestamp(@allocation.as_of)}</caption>
        <thead>
          <tr>
            <th>Jugador</th><th>Cantidad</th><th>Costo promedio</th><th>Costo base</th><th>
              Valor de mercado
            </th><th>
              Ganancia/pérdida realizada
            </th><th>No realizada</th><th>Peso</th><th>Cotización</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={item <- @allocation.positions}>
            <th scope="row">
              <a href={~p"/players?player_id=#{item.player_id}"}>{item.player_name}</a>
            </th>
            <td>{item.quantity}</td><td>{exact_money(item.average_unit_cost)}</td><td>
              {exact_money(item.cost_basis)}
            </td><td>
              {exact_money(item.market_value)}
            </td><td>{exact_money(item.realized_profit_loss)}</td><td>
              {exact_money(item.unrealized_profit_loss)}
            </td><td>
              {if item.weight,
                do: exact_money(Decimal.mult(item.weight, Decimal.new(100))) <> "%",
                else: "Sin datos"}
            </td>
            <td>
              <details>
                <summary>Ver cotización</summary><p :if={item.quote}>
                  {exact_money(item.quote.unit_price)} créditos por token · vigente desde {timestamp(
                    item.quote.effective_at
                  )}
                </p><p :if={!item.quote}>Sin cotización disponible</p>
              </details>
            </td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Totales</th><td></td><td></td><td>
              {exact_money(@allocation.totals.cost_basis)}
            </td><td>
              {exact_money(@allocation.totals.market_value)}
            </td><td>{exact_money(@allocation.totals.realized_profit_loss)}</td><td>
              {exact_money(@allocation.totals.unrealized_profit_loss)}
            </td><td></td><td>
              Resultado total: {exact_money(@allocation.totals.total_profit_loss)}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
    <details
      :if={@portfolio_history && @portfolio_history.points != []}
      id="portfolio-history-details"
      class="portfolio-data-details"
    >
      <summary>Ver historial diario completo <span>Valores y detalle de cada día</span></summary>
      <div
        class="table-scroll"
        role="region"
        aria-label="Historial diario del portafolio"
        tabindex="0"
      >
        <table id="portfolio-history-table">
          <caption>
            Historial diario · {@portfolio_history.from} a {@portfolio_history.to} ({@portfolio_history.timezone}) · consultado {timestamp(
              @portfolio_history.as_of
            )}
          </caption>
          <thead>
            <tr>
              <th>Día (UTC)</th><th>Corte</th><th>Valor de mercado</th><th>Costo base</th><th>
                Compras
              </th><th>
                Ventas
              </th><th>Invertido neto</th><th>Realizada</th><th>No realizada</th><th>Total</th><th>
                Valuación
              </th><th>Jugadores sin cotización</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={point <- @portfolio_history.points}>
              <th scope="row">{point.date}</th><td>{daily_cutoff(point)}</td><td>
                {exact_money(point.market_value)}
              </td><td>
                {exact_money(point.cost_basis)}
              </td><td>{exact_money(point.purchase_expenditure)}</td><td>
                {exact_money(point.sale_proceeds)}
              </td><td>{exact_money(point.net_invested)}</td><td>
                {exact_money(point.realized_profit_loss)}
              </td><td>{exact_money(point.unrealized_profit_loss)}</td><td>
                {exact_money(point.total_profit_loss)}
              </td><td>
                {if point.valuation_complete, do: "Completa", else: "Incompleta"}{if point.partial,
                  do: " · parcial",
                  else: ""}
              </td><td>
                {if point.missing_quote_player_ids == [],
                  do: "—",
                  else: Enum.join(point.missing_quote_player_ids, ", ")}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </details>
    """
  end

  attr :points, :list, required: true
  attr :metric, :atom, required: true
  attr :label, :string, required: true

  def history_chart(assigns) do
    assigns = assign(assigns, :path, chart_path(assigns.points, assigns.metric))

    ~H"""
    <section class="history-chart" id={"history-chart-#{@metric}"}>
      <h4>{@label}</h4>
      <svg
        viewBox="0 0 620 200"
        role="img"
        aria-labelledby={"#{@metric}-title #{@metric}-description"}
      >
        <title id={"#{@metric}-title"}>{@label} por día</title>
        <desc id={"#{@metric}-description"}>
          Valores diarios en créditos. Los importes que dependen de una cotización faltante aparecen como espacios.
        </desc>
        <line x1="32" y1="170" x2="608" y2="170" class="chart-axis" />
        <path :if={@path != ""} d={@path} class="chart-line" />
        <text x="32" y="192">{first_chart_date(@points)}</text>
        <text x="608" y="192" text-anchor="end">{last_chart_date(@points)}</text>
      </svg>
      <p class="chart-scale">{chart_scale(@points, @metric)}</p>
      <details>
        <summary>Ver valores diarios de {@label} (UTC)</summary>
        <div class="table-scroll chart-table">
          <table>
            <caption>{@label} · Créditos</caption>
            <thead>
              <tr>
                <th scope="col">Día (UTC)</th><th scope="col">Valor</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={point <- @points}>
                <th scope="row">
                  {point.date}{if Map.get(point, :partial, false),
                    do: " · parcial hasta " <> Calendar.strftime(point.cutoff_at, "%H:%M UTC"),
                    else: ""}
                </th>
                <td>{chart_value(Map.get(point, @metric))}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </details>
    </section>
    """
  end

  defp history_metrics do
    [
      {:market_value, "Valor de mercado del portafolio"},
      {:realized_profit_loss, "Ganancia/pérdida realizada"},
      {:unrealized_profit_loss, "Ganancia/pérdida no realizada"}
    ]
  end

  defp has_historical_activity?(points) do
    Enum.any?(points, fn point ->
      Decimal.positive?(point.purchase_expenditure) or Decimal.positive?(point.sale_proceeds)
    end)
  end

  defp allocation_style(nil), do: "width: 0%"

  defp allocation_style(weight) do
    percentage = weight |> Decimal.mult(Decimal.new(100)) |> Decimal.to_float()
    "width: #{min(max(percentage, 0.0), 100.0)}%"
  end

  defp percent(weight) do
    weight
    |> Decimal.mult(Decimal.new(100))
    |> Decimal.round(1, :half_up)
    |> Decimal.to_string(:normal)
    |> Kernel.<>("%")
  end

  defp chart_path(points, metric) do
    values = Enum.map(points, &Map.get(&1, metric))

    case chart_bounds(values) do
      nil ->
        ""

      {minimum, maximum} ->
        scale = {minimum, maximum, max(length(values) - 1, 1)}

        values
        |> Enum.with_index()
        |> Enum.chunk_by(fn {value, _index} -> is_nil(value) end)
        |> Enum.reject(&missing_chart_segment?/1)
        |> Enum.map_join(" ", &chart_segment_path(&1, scale))
    end
  end

  defp chart_bounds(values) do
    known = Enum.reject(values, &is_nil/1)

    case known do
      [] ->
        nil

      values ->
        floats = Enum.map(values, &Decimal.to_float/1)
        {Enum.min(floats), Enum.max(floats)}
    end
  end

  defp missing_chart_segment?([{nil, _index} | _rest]), do: true
  defp missing_chart_segment?(_segment), do: false

  defp chart_segment_path([{value, index}], scale) do
    command = chart_point_command(value, index, index, scale)
    command <> " L" <> String.replace_prefix(command, "M", "")
  end

  defp chart_segment_path([{_value, first_index} | _rest] = segment, scale) do
    Enum.map_join(segment, " ", fn {value, index} ->
      chart_point_command(value, index, first_index, scale)
    end)
  end

  defp chart_point_command(value, index, first_index, {minimum, maximum, last_index}) do
    x = 32 + 576 * index / last_index
    y = chart_y(value, minimum, maximum)
    command = if index == first_index, do: "M", else: "L"
    "#{command}#{Float.round(x, 2)},#{Float.round(y, 2)}"
  end

  defp chart_y(_value, minimum, maximum) when minimum == maximum, do: 88.0

  defp chart_y(value, minimum, maximum) do
    span = maximum - minimum
    16 + 144 * (maximum - Decimal.to_float(value)) / span
  end

  defp chart_value(nil), do: "Sin datos"
  defp chart_value(value), do: Decimal.to_string(value, :normal)

  defp chart_scale(points, metric) do
    values = points |> Enum.map(&Map.get(&1, metric)) |> Enum.reject(&is_nil/1)

    case values do
      [] ->
        "No hay valores para graficar."

      values ->
        minimum = Enum.min_by(values, &Decimal.to_float/1)
        maximum = Enum.max_by(values, &Decimal.to_float/1)
        "Escala: #{chart_value(minimum)} a #{chart_value(maximum)} créditos."
    end
  end

  defp first_chart_date([point | _]), do: Date.to_iso8601(point.date)
  defp first_chart_date([]), do: ""
  defp last_chart_date([]), do: ""
  defp last_chart_date(points), do: points |> List.last() |> then(&Date.to_iso8601(&1.date))

  def strategy_name("balanced"), do: "Equilibrada"
  def strategy_name("position_aware"), do: "Por posición"
  def strategy_name("initial_issuance"), do: "Emisión inicial"
  def strategy_name(value), do: value

  defp quote_source(%{rule_id: "initial_issuance"}), do: "Emisión inicial del mercado"
  defp quote_source(_), do: "Rendimiento deportivo registrado"
  defp valuation_status(%{state: "pending"}), do: "Valuación pendiente para el próximo cierre."
  defp valuation_status(%{state: "running"}), do: "Valuación en curso."
  defp valuation_status(%{state: "completed"}), do: "Valuación completada."
  defp valuation_status(%{state: "failed"}), do: "La valuación requiere revisión."
  defp valuation_status(%{state: "not_requested"}), do: "No hay una nueva valuación solicitada."
  defp valuation_status(_), do: "Estado de valuación no disponible."
  defp coverage_name("unavailable"), do: "Sin estadísticas registradas"
  defp coverage_name(_), do: "Estadísticas registradas; la cobertura puede ser parcial"

  defp daily_cutoff(%{partial: true, cutoff_at: cutoff}),
    do: "Parcial hasta " <> Calendar.strftime(cutoff, "%H:%M UTC")

  defp daily_cutoff(_), do: "Cierre del día UTC"

  def position_name("GK"), do: "Arquero"
  def position_name("DEF"), do: "Defensor"
  def position_name("DF"), do: "Defensor"
  def position_name("MID"), do: "Mediocampista"
  def position_name("MF"), do: "Mediocampista"
  def position_name("FWD"), do: "Delantero"
  def position_name("FW"), do: "Delantero"
  def position_name(value), do: value

  defp exact_money(nil), do: "Sin datos"
  defp exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  defp timestamp(nil), do: "Sin datos"
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")

  defp estimated_total(quantity, unit_price) do
    case Integer.parse(quantity) do
      {amount, ""} when amount > 0 -> money(Decimal.mult(unit_price, amount))
      _ -> "—"
    end
  end

  attr :heading, :string, required: true

  def unavailable(assigns) do
    ~H"""
    <h1>{@heading}</h1>
    <p>
      Esta sección todavía no está disponible. Se agregarán más funciones en futuras actualizaciones.
    </p>
    """
  end

  attr :kind, :string, required: true

  def recovery(assigns) do
    ~H"""
    <main>
      <h1>{@kind}</h1><p role="alert">Este contenido no está disponible.</p><a href="/portfolio">Volver al espacio de trabajo</a><a href="/sign-in">Iniciar sesión</a>
    </main>
    """
  end
end
