defmodule FootballMarketWeb.PlayerLive.Index do
  use FootballMarketWeb, :live_view

  import FootballMarketWeb.PlayerLive.Components

  alias FootballMarket.Catalog

  @page_size 25
  @filter_keys ~w(league_id team_id position_id)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Players"))
     |> assign(:leagues, Catalog.list_leagues())
     |> assign(:positions, Catalog.list_positions())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = parse_filters(params)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:teams, Catalog.list_teams(Map.take(filters, [:league_id])))
     |> assign(:filter_form, to_form(Map.take(params, @filter_keys), as: "filters"))
     |> load_page(nil)}
  end

  @impl true
  def handle_event("filter", %{"filters" => params}, socket) when is_map(params) do
    filters = params |> parse_filters() |> drop_team_outside_league()
    {:noreply, push_patch(socket, to: players_path(filters))}
  end

  def handle_event("clear-filters", _params, socket) do
    {:noreply, push_patch(socket, to: ~p"/players")}
  end

  def handle_event("load-more", _params, socket) do
    case socket.assigns.next_cursor do
      nil -> {:noreply, socket}
      cursor -> {:noreply, load_page(socket, cursor)}
    end
  end

  # The continuation cursor stays in server-side assigns; it is never rendered.
  defp load_page(socket, cursor) do
    reset? = is_nil(cursor)
    request = %{page_size: @page_size, cursor: cursor, filters: socket.assigns.filters}

    case Catalog.list_player_page(request) do
      {:ok, %{players: players, pagination: pagination}} ->
        loaded = if reset?, do: 0, else: socket.assigns.loaded_count

        socket
        |> stream(:players, players, reset: reset?)
        |> assign(:next_cursor, pagination.next_cursor)
        |> assign(:loaded_count, loaded + pagination.returned_count)

      {:error, _reason} ->
        socket
        |> put_flash(:error, gettext("The catalog could not be loaded. Try again."))
        |> stream(:players, [], reset: true)
        |> assign(next_cursor: nil, loaded_count: 0)
    end
  end

  # Unknown or malformed filter values are ignored rather than trusted.
  defp parse_filters(params) do
    for key <- @filter_keys,
        value = params[key],
        is_binary(value),
        {:ok, uuid} <- [Ecto.UUID.cast(value)],
        into: %{},
        do: {String.to_existing_atom(key), uuid}
  end

  defp drop_team_outside_league(%{league_id: league_id, team_id: team_id} = filters) do
    if Enum.any?(Catalog.list_teams(%{league_id: league_id}), &(&1.id == team_id)),
      do: filters,
      else: Map.delete(filters, :team_id)
  end

  defp drop_team_outside_league(filters), do: filters

  defp players_path(filters) when map_size(filters) == 0, do: ~p"/players"

  defp players_path(filters) do
    query = for key <- [:league_id, :team_id, :position_id], filters[key], do: {key, filters[key]}
    ~p"/players?#{query}"
  end

  defp league_options(leagues), do: Enum.map(leagues, &{"#{&1.name} (#{&1.code})", &1.id})
  defp team_options(teams), do: Enum.map(teams, &{team_label(&1), &1.id})
  defp position_options(positions), do: Enum.map(positions, &{&1.name, &1.id})

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} active={:players}>
      <.header>
        {gettext("Players")}
        <:subtitle>{gettext("Browse the catalog by league, team, and position.")}</:subtitle>
      </.header>

      <.form
        for={@filter_form}
        id="player-filters"
        phx-change="filter"
        phx-submit="filter"
        class="mb-6 rounded-box border border-base-300 bg-base-200 p-4"
      >
        <div class="grid items-end gap-x-4 sm:grid-cols-2 lg:grid-cols-[1fr_1fr_1fr_auto]">
          <.input
            field={@filter_form[:league_id]}
            type="select"
            label={gettext("League")}
            prompt={gettext("All leagues")}
            options={league_options(@leagues)}
          />
          <.input
            field={@filter_form[:team_id]}
            type="select"
            label={gettext("Team")}
            prompt={gettext("All teams")}
            options={team_options(@teams)}
          />
          <.input
            field={@filter_form[:position_id]}
            type="select"
            label={gettext("Position")}
            prompt={gettext("All positions")}
            options={position_options(@positions)}
          />
          <button
            type="button"
            id="clear-filters"
            phx-click="clear-filters"
            class="btn mb-2 btn-ghost"
            disabled={@filters == %{}}
          >
            <.icon name="hero-x-mark" /> {gettext("Clear")}
          </button>
        </div>
      </.form>

      <div
        :if={@loaded_count == 0}
        id="players-empty"
        class="rounded-box border border-dashed border-base-300 p-10 text-center text-base-content/70"
      >
        <.icon name="hero-magnifying-glass" class="mx-auto mb-2 size-8" />
        <p>{gettext("No players match these filters.")}</p>
      </div>

      <div class={[
        "overflow-x-auto rounded-box border border-base-300 bg-base-100",
        @loaded_count == 0 && "hidden"
      ]}>
        <.table id="players" rows={@streams.players}>
          <:col :let={{_id, player}} label={gettext("Player")}>
            <.link navigate={~p"/players/#{player}"} class="font-medium link-hover link">
              {player.display_name}
            </.link>
            <div class="text-xs text-base-content/60 md:hidden">{player.team.name}</div>
          </:col>
          <:col :let={{_id, player}} label={gettext("Position")}>
            <.position_badge position={player.position} />
          </:col>
          <:col :let={{_id, player}} label={gettext("Team")} class="hidden md:table-cell">
            {player.team.name}
          </:col>
          <:col :let={{_id, player}} label={gettext("League")} class="hidden sm:table-cell">
            {player.team.season.league.name}
          </:col>
          <:col :let={{_id, player}} label={gettext("Season")} class="hidden lg:table-cell">
            {season_label(player.team.season)}
          </:col>
        </.table>
      </div>

      <div class="mt-4 flex flex-col items-center gap-3 sm:flex-row sm:justify-between">
        <p id="players-count" class="text-sm text-base-content/60">
          {ngettext("Showing 1 player", "Showing %{count} players", @loaded_count)}
        </p>
        <button
          :if={@next_cursor}
          id="load-more"
          phx-click="load-more"
          class="btn btn-soft btn-primary"
          phx-disable-with={gettext("Loading…")}
        >
          {gettext("Load more")}
        </button>
      </div>
    </Layouts.app>
    """
  end
end
