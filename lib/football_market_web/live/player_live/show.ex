defmodule FootballMarketWeb.PlayerLive.Show do
  use FootballMarketWeb, :live_view

  import FootballMarketWeb.PlayerLive.Components

  alias FootballMarket.Catalog

  @impl true
  def mount(%{"player_id" => player_id}, _session, socket) do
    case Catalog.get_player_detail(player_id) do
      {:ok, player} ->
        {:ok, assign(socket, player: player, page_title: player.display_name)}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, gettext("Player not found."))
         |> push_navigate(to: ~p"/players")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} active={:players}>
      <div class="breadcrumbs mb-4 text-sm">
        <ul>
          <li><.link navigate={~p"/players"}>{gettext("Players")}</.link></li>
          <li>{@player.display_name}</li>
        </ul>
      </div>

      <div class="grid gap-6 lg:grid-cols-3">
        <section class="card border border-base-300 bg-base-100 lg:col-span-2">
          <div class="card-body">
            <div class="flex flex-wrap items-center gap-3">
              <h1 id="player-name" class="text-2xl font-bold sm:text-3xl">
                {@player.display_name}
              </h1>
              <.position_badge position={@player.position} />
              <span class="badge badge-neutral font-mono">{@player.team.season.league.code}</span>
            </div>

            <dl class="mt-4 grid gap-4 sm:grid-cols-2">
              <.detail label={gettext("Team")}>{@player.team.name}</.detail>
              <.detail label={gettext("League")}>{@player.team.season.league.name}</.detail>
              <.detail label={gettext("Season")}>{season_label(@player.team.season)}</.detail>
              <.detail label={gettext("Position")}>{@player.position.name}</.detail>
              <.detail label={gettext("Catalog identity")}>
                <code class="text-sm">{@player.catalog_identity}</code>
              </.detail>
            </dl>
          </div>
        </section>

        <aside class="card border border-base-300 bg-base-100">
          <div class="card-body">
            <h2 class="card-title text-base">{gettext("Explore related players")}</h2>
            <ul class="menu w-full p-0">
              <li>
                <.link navigate={~p"/players?#{[team_id: @player.team.id]}"} id="related-team">
                  <.icon name="hero-users" /> {gettext("Same team")}
                </.link>
              </li>
              <li>
                <.link
                  navigate={~p"/players?#{[league_id: @player.team.season.league.id]}"}
                  id="related-league"
                >
                  <.icon name="hero-trophy" /> {gettext("Same league")}
                </.link>
              </li>
              <li>
                <.link
                  navigate={~p"/players?#{[position_id: @player.position.id]}"}
                  id="related-position"
                >
                  <.icon name="hero-arrows-pointing-out" /> {gettext("Same position")}
                </.link>
              </li>
            </ul>
          </div>
        </aside>
      </div>
    </Layouts.app>
    """
  end

  attr :label, :string, required: true
  slot :inner_block, required: true

  defp detail(assigns) do
    ~H"""
    <div class="rounded-box bg-base-200 p-4">
      <dt class="text-xs font-medium uppercase tracking-wide text-base-content/60">{@label}</dt>
      <dd class="mt-1 font-medium">{render_slot(@inner_block)}</dd>
    </div>
    """
  end
end
