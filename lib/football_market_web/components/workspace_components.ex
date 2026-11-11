defmodule FootballMarketWeb.WorkspaceComponents do
  @moduledoc false
  use FootballMarketWeb, :html
  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :src, :string, default: nil
  attr :class, :string, default: ""

  def avatar(assigns) do
    ~H"""
    <span id={@id} class={["player-avatar", @class]} phx-hook="PlayerMedia" aria-hidden="true">
      <span class="avatar-fallback">{initials(@name)}</span>
      <img
        :if={@src}
        src={@src}
        alt=""
        loading="lazy"
        decoding="async"
        referrerpolicy="no-referrer"
        width="128"
        height="128"
      />
    </span>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :profile, :map, default: nil
  attr :subtitle, :string, default: nil

  def player_identity(assigns) do
    ~H"""
    <span class="player-identity">
      <.avatar id={@id} name={@name} src={@profile && @profile.photo} />
      <span class="identity-copy"><strong>{@name}</strong><small :if={@subtitle || @profile}>{@subtitle ||
        @profile.team}</small></span>
    </span>
    """
  end

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :profile, :map, default: nil

  def club_identity(assigns) do
    ~H"""
    <span class="club-identity"><.avatar
      id={@id}
      name={@name}
      src={@profile && @profile.crest}
      class="club-crest"
    /><span>{@name}</span></span>
    """
  end

  defp initials(name),
    do: name |> String.split() |> Enum.take(2) |> Enum.map_join(&String.first/1)

  def profit_class(value) do
    case Decimal.compare(value, Decimal.new(0)) do
      :gt -> "profit-positive"
      :lt -> "profit-negative"
      :eq -> "profit-neutral"
    end
  end

  attr :quotes, :list, required: true

  def price_chart(assigns) do
    assigns = assign(assigns, :points, quote_points(assigns.quotes))

    ~H"""
    <div :if={@quotes != []} class="price-chart">
      <div class="chart-legend">
        <span><i></i> Créditos por token</span><span>{length(@quotes)} cotizaciones publicadas</span>
      </div>
      <svg
        viewBox="0 0 600 170"
        role="img"
        aria-label="Evolución de las cotizaciones publicadas, en orden cronológico"
      >
        <path d="M12 35H588 M12 85H588 M12 135H588" class="price-grid" />
        <polyline :if={length(@quotes) > 1} points={@points} class="price-line" />
        <circle :if={length(@quotes) == 1} cx="300" cy="85" r="5" class="price-dot" />
      </svg>
      <p :if={length(@quotes) == 1} class="muted">
        Primera cotización publicada. La evolución aparecerá con los próximos cierres.
      </p>
      <p :if={length(@quotes) > 1} class="muted">
        De la primera a la última cotización registrada. Consultá los valores exactos debajo.
      </p>
    </div>
    """
  end

  defp quote_points([]), do: ""

  defp quote_points(quotes) do
    values =
      quotes
      |> Enum.sort_by(& &1.effective_at, DateTime)
      |> Enum.map(&Decimal.to_float(&1.unit_price))

    low = Enum.min(values)
    span = max(Enum.max(values) - low, 1.0)

    values
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {v, i} ->
      "#{12 + i * 576 / max(length(values) - 1, 1)},#{135 - (v - low) / span * 100}"
    end)
  end

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
        <div class="workspace-toolbar">
          <span><span class="status-dot"></span>Tu espacio de inversión</span><div>
            <.icon name="hero-wallet" class="button-icon" /><span :if={!@credit_balance_unavailable}>Disponible
            <strong>{money(@credit_balance)} créditos</strong></span><span :if={
              @credit_balance_unavailable
            }>Saldo no disponible</span>
          </div>
        </div>
        <main id="workspace-main" tabindex="-1">{render_slot(@inner_block)}</main>
        <footer class="workspace-footer">
          Football Market <span>Tokens de jugadores · Cotizaciones según rendimiento</span>
        </footer>
      </div>
    </section>
    """
  end

  attr :profile, :map, default: nil
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
      <header class="player-hero">
        <div class="player-hero-identity">
          <.avatar
            id={"hero-#{@card.player.id}"}
            name={@card.player.display_name}
            src={@profile && @profile.photo}
            class="hero-avatar"
          />
          <div>
            <p class="eyebrow">PERFIL DEL JUGADOR</p><h1>{@card.player.display_name}</h1>
            <p class="player-subtitle">
              <span class="position-pill">{position_name(@card.player.position.code)}</span><span>{@card.player.team.season.league.name}</span>
            </p>
            <.club_identity
              id={"hero-club-#{@card.player.id}"}
              name={@card.player.team.name}
              profile={@profile}
            />
          </div>
        </div>
        <div class="hero-market-value">
          <p class="eyebrow">
            {if performance_quote?(@quote),
              do: "COTIZACIÓN ACTUAL POR TOKEN",
              else: "VALOR INICIAL DE EMISIÓN"}
          </p>
          <p :if={@quote} id="player-quote">
            <strong>{money(@quote.unit_price)}</strong><span>créditos</span><small>Vigente desde {Calendar.strftime(
              @quote.effective_at,
              "%d/%m/%Y %H:%M UTC"
            )}</small>
          </p>
          <p :if={!@quote} id="player-quote-missing">Cotización pendiente</p>
          <span class="season-pill">Temporada {@card.player.team.season.start_year}–{@card.player.team.season.end_year}</span>
        </div>
      </header>
      <div class="player-detail-grid">
        <div class="player-analysis">
          <section class="player-performance surface-panel">
            <div class="section-heading">
              <div>
                <p class="eyebrow">RENDIMIENTO</p><h2>La temporada en números</h2>
              </div><.icon name="hero-chart-bar" class="section-icon" />
            </div>
            <p
              :if={@card.statistics_status}
              id="player-scraping-status"
              class="statistics-notice"
              role="status"
            >
              <span class={"status-dot status-#{@card.statistics_status.refresh.state}"}></span>{scraping_status(
                @card.statistics_status.refresh
              )}
            </p>
            <dl :if={@card.statistics.recorded_match_count > 0} id="player-statistics">
              <div>
                <dt>Partidos registrados</dt><dd>{@card.statistics.recorded_match_count}</dd>
              </div>
              <div
                :for={metric <- [:minutes_played | FootballMarket.Statistics.Input.metrics()]}
                data-metric={metric}
              >
                <dt>{metric_name(metric)}</dt>
                <dd>{Map.get(@card.statistics, metric) || "Desconocido"}</dd>
                <small>{metric_coverage_label(@card.statistics.metric_coverage[metric])}</small>
              </div>
            </dl>
            <p
              :if={@card.statistics.recorded_match_count > 0}
              id="player-statistics-coverage"
              class="coverage-note"
            >
              Partidos registrados para esta temporada; la cobertura puede ser parcial.
            </p>
            <p
              :if={@card.statistics.recorded_match_count == 0}
              id="player-statistics-unavailable"
              class="empty-inline"
            >
              <.icon name="hero-clock" class="section-icon" />Todavía no hay estadísticas cargadas para esta temporada.<span :if={
                !@quote
              }> No se pueden operar tokens por ahora.</span>
            </p>
          </section>
          <section id="quote-history">
            <div class="section-heading">
              <div>
                <p class="eyebrow">EVOLUCIÓN DEL VALOR</p><h2>Historial de cotizaciones</h2>
              </div><span class="status-badge">Créditos / token</span>
            </div>
            <.price_chart quotes={@quote_history} />
            <form phx-submit="quote_date">
              <label for="quote-history-date">Buscar cotización al cierre de una fecha</label>
              <input id="quote-history-date" type="date" name="date" value={@quote_date} required />
              <button type="submit" phx-disable-with="Consultando…">Consultar fecha</button>
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
          <section class="surface-panel player-data-notes">
            <h2>Acerca de estos datos</h2>
            <details :if={@quote} id="quote-provenance">
              <summary>Procedencia de la cotización</summary><.quote_details quote={@quote} />
            </details>
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
              <p :if={performance_quote?(@quote)}>
                Última cotización de rendimiento publicada: {timestamp(@quote.effective_at)}.
              </p>
              <p :if={@quote && !performance_quote?(@quote)}>
                El valor mostrado corresponde a la emisión inicial; todavía no hay una valuación de rendimiento publicada.
              </p>
              <p>
                Las estadísticas se actualizan por separado; las cotizaciones se recalculan en el cierre del mercado.
              </p>
            </details>
          </section>
        </div>
        <aside class="trade-panel surface-panel" aria-label="Operar tokens">
          <div class="section-heading">
            <div>
              <p class="eyebrow">TU PRÓXIMO MOVIMIENTO</p><h2>Comprar o vender</h2>
            </div><.icon name="hero-arrows-right-left" class="section-icon" />
          </div>
          <div :if={@credit_balance && !@credit_balance_unavailable} class="ticket-balance">
            <span>Saldo disponible</span><strong>{money(@credit_balance)} créditos</strong>
          </div>
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
            class="conditional-trade-link"
          ><.icon name="hero-adjustments-horizontal" class="button-icon" /> Crear orden condicional</a>
          <p :if={@initial_recipient} id="initial-issuer-trade-note" class="statistics-notice">
            Esta cuenta emitió los tokens iniciales. Otros usuarios pueden comprarlos de su inventario; esta cuenta no puede operar sus propios tokens.
          </p>
          <p
            :if={@quote && !performance_quote?(@quote)}
            id="player-performance-quote-unavailable"
            class="statistics-notice"
            role="status"
          >
            No hay una cotización de rendimiento disponible. No se pueden comprar tokens hasta que se publique una cotización positiva.
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
            <p
              :if={@credit_balance_unavailable}
              id="player-card-credit-balance-unavailable"
              role="alert"
            >
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
                phx-disable-with="Comprando…"
                class="trade-action-buy"
                disabled={@credit_balance_unavailable || !performance_quote?(@quote)}
              >Comprar tokens</button>
              <button
                type="submit"
                name="side"
                value="sell"
                phx-disable-with="Vendiendo…"
                class="trade-action-sell"
                disabled={Enum.find(@positions, &(&1.player_id == @card.player.id)) == nil}
              >Vender tokens</button>
            </div>
          </form>
          <p :if={@trade_error} id="trade-error" role="alert">{@trade_error}</p>
          <p :if={@notice} id="trade-notice" role="status">
            <.icon name="hero-check-circle" class="feedback-icon" />{@notice}
          </p>
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
          <p class="trade-footnote">
            <.icon name="hero-lock-closed" class="button-icon" />Operaciones al precio vigente. Revisá el importe antes de confirmar.
          </p>
        </aside>
      </div>
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
  attr :profiles, :map, default: %{}

  def ranking_view(assigns) do
    ~H"""
    <section id="ranking">
      <header class="page-heading">
        <div>
          <p class="eyebrow">LOS PROTAGONISTAS DEL MERCADO</p><h1>Ranking de estrategia activa</h1><p class="section-description">
            Rendimiento en la cancha. Valor en tu portafolio.
          </p>
        </div><.link navigate="/players" class="secondary-button">Explorar jugadores
        <.icon name="hero-arrow-up-right" class="button-icon" /></.link>
      </header>
      <p :if={@error} role="alert">{@error}</p>
      <div :if={!@ranking && !@error} id="ranking-unavailable" class="empty-state">
        <.icon name="hero-trophy" class="empty-symbol" /><h2>
          El ranking todavía no está disponible
        </h2><p>Se mostrará cuando haya una estrategia de cotización activa.</p><.link
          class="text-link"
          navigate="/players"
        >Explorar jugadores →</.link>
      </div>
      <div :if={@ranking}>
        <div id="ranking-strategy">
          <span><span class="status-dot"></span>Estrategia activa:
          <strong>{strategy_name(@ranking.configuration.strategy_id)}</strong>
          · Fórmula {@ranking.configuration.formula_version}</span><span>{length(@ranking.entries)} jugadores con cotización</span>
        </div>
        <p :if={@ranking.entries == []} id="ranking-empty">
          No hay cotizaciones válidas para la estrategia activa.
        </p>
        <div
          :if={@ranking.entries != []}
          class="ranking-podium"
          aria-label="Los tres primeros puestos"
        >
          <.link
            :for={{entry, index} <- Enum.with_index(Enum.take(@ranking.entries, 3), 1)}
            navigate={~p"/players?player_id=#{entry.player_id}"}
            class={["podium-card", index == 1 && "podium-leader"]}
          >
            <div class="podium-top">
              <span class="podium-place">0{index}</span><span :if={index == 1} class="leader-label"><.icon
                name="hero-trophy"
                class="button-icon"
              />LÍDER DEL RANKING</span><span :if={index > 1} class="muted">DESTACADO</span>
            </div>
            <.avatar
              id={"podium-#{entry.player_id}"}
              name={entry.player_name}
              src={get_in(@profiles, [entry.player_id, :photo])}
              class="podium-avatar"
            />
            <h2>{entry.player_name}</h2><p>
              {get_in(@profiles, [entry.player_id, :team]) || "Jugador del mercado"}
            </p>
            <div class="podium-price">
              <strong>{money(entry.unit_price)}</strong><span>créditos / token</span><.icon
                name="hero-arrow-up-right"
                class="button-icon"
              />
            </div>
          </.link>
        </div>
        <section
          :if={@ranking.entries != []}
          class="ranking-board"
          aria-label="Clasificación completa"
        >
          <div class="section-heading">
            <h2>La clasificación</h2><span class="muted">Ordenada por valor del token</span>
          </div>
          <div class="ranking-column-labels" aria-hidden="true">
            <span>#</span><span>Jugador</span><span>Club y liga</span><span>Valor por token</span>
          </div>
          <ol id="ranking-entries">
            <li
              :for={{entry, index} <- Enum.with_index(@ranking.entries, 1)}
              id={"ranking-player-#{entry.player_id}"}
            >
              <div class="ranking-row">
                <span class={["rank-number", index <= 3 && "rank-leading"]}>{index}</span>
                <.link
                  navigate={~p"/players?player_id=#{entry.player_id}"}
                  class="ranking-player-link"
                ><.avatar
                  id={"rank-#{entry.player_id}"}
                  name={entry.player_name}
                  src={get_in(@profiles, [entry.player_id, :photo])}
                /><strong>{entry.player_name}</strong></.link>
                <div class="ranking-club">
                  <.club_identity
                    id={"rank-club-#{entry.player_id}"}
                    name={get_in(@profiles, [entry.player_id, :team]) || "Club no disponible"}
                    profile={Map.get(@profiles, entry.player_id)}
                  /><small>{get_in(@profiles, [entry.player_id, :league])}</small>
                </div>
                <div class="ranking-value">
                  <strong>{money(entry.unit_price)}</strong><span>créditos</span>
                </div>
              </div>
              <details class="ranking-reference">
                <summary>Referencia de cotización</summary><p>
                  {money(entry.unit_price)} créditos por token · Efectiva {timestamp(
                    entry.effective_at
                  )} · {strategy_name(@ranking.configuration.strategy_id)} · versión {@ranking.configuration.formula_version}. Fuente: rendimiento deportivo.
                </p>
              </details>
            </li>
          </ol>
        </section>
      </div>
    </section>
    """
  end

  def metric_name(metric) do
    %{
      minutes_played: "Minutos jugados",
      goals: "Goles",
      assists: "Asistencias",
      shots_on_target: "Tiros al arco",
      tackles: "Entradas",
      interceptions: "Intercepciones",
      saves: "Atajadas",
      goals_conceded: "Goles recibidos en cancha",
      yellow_cards: "Tarjetas amarillas",
      red_cards: "Tarjetas rojas"
    }[metric]
  end

  def metric_coverage_label(%{status: "complete", known_match_count: known}),
    do: "#{known} partidos con datos"

  def metric_coverage_label(%{
        status: "partial",
        known_match_count: known,
        unknown_match_count: unknown
      }),
      do: "Cobertura parcial: #{known} con datos, #{unknown} desconocidos"

  def metric_coverage_label(_), do: "Sin datos disponibles"

  def role_name(role),
    do:
      %{
        overall: "General",
        goalkeeper: "Arquero",
        defender: "Defensor",
        midfielder: "Mediocampista",
        forward: "Delantero"
      }[role]

  def strategy_name("balanced"), do: "Equilibrada"
  def strategy_name("position_aware"), do: "Por posición"
  def strategy_name("initial_issuance"), do: "Emisión inicial"
  def strategy_name(value), do: value

  defp performance_quote?(%{
         calculation_id: calculation_id,
         configuration_version_id: configuration_version_id,
         mapping_id: mapping_id,
         performance_sequence: sequence
       }),
       do:
         not is_nil(calculation_id) and not is_nil(configuration_version_id) and
           not is_nil(mapping_id) and is_integer(sequence) and sequence > 0

  defp performance_quote?(_), do: false

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

  def position_name("GK"), do: "Arquero"
  def position_name("DEF"), do: "Defensor"
  def position_name("DF"), do: "Defensor"
  def position_name("MID"), do: "Mediocampista"
  def position_name("MF"), do: "Mediocampista"
  def position_name("FWD"), do: "Delantero"
  def position_name("FW"), do: "Delantero"
  def position_name(value), do: value

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
