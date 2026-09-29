defmodule FootballMarketWeb.HomeLive do
  use FootballMarketWeb, :live_view

  alias FootballMarket.Catalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, nil)
     |> assign(:leagues, Catalog.supported_leagues())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <section class="hero rounded-box bg-base-200 py-12 sm:py-20">
        <div class="hero-content max-w-3xl text-center">
          <div class="space-y-6">
            <span class="badge badge-soft badge-primary">{gettext("Performance-driven market")}</span>
            <h1 class="text-4xl font-bold tracking-tight sm:text-5xl">Football Player Market</h1>
            <p class="text-lg text-base-content/70">
              {gettext(
                "Football performance determines historical player quotes. Each player has a fixed supply of 100 tokens that authenticated users can trade."
              )}
            </p>
            <div class="flex flex-wrap justify-center gap-3">
              <%= if @current_user do %>
                <.button navigate={~p"/players"} variant="primary">
                  <.icon name="hero-user-group" /> {gettext("Browse players")}
                </.button>
                <.button navigate={~p"/account"}>
                  <.icon name="hero-key" /> {gettext("Manage API keys")}
                </.button>
              <% else %>
                <.button navigate={~p"/users/register"} variant="primary">
                  {gettext("Create account")}
                </.button>
                <.button navigate={~p"/users/log-in"}>{gettext("Log in")}</.button>
              <% end %>
            </div>
          </div>
        </div>
      </section>

      <section class="mt-12 space-y-4" aria-labelledby="leagues-heading">
        <h2 id="leagues-heading" class="text-xl font-semibold">{gettext("Supported leagues")}</h2>
        <ul class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          <li :for={{code, name} <- @leagues} class="card border border-base-300 bg-base-100">
            <div class="card-body items-center p-5 text-center">
              <span class="badge badge-neutral font-mono">{code}</span>
              <span class="font-medium">{name}</span>
            </div>
          </li>
        </ul>
      </section>

      <section class="mt-12 grid gap-4 md:grid-cols-3">
        <.feature icon="hero-magnifying-glass" title={gettext("Explore the catalog")}>
          {gettext("Filter players by league, team, and position across every supported season.")}
        </.feature>
        <.feature icon="hero-key" title={gettext("Integrate through the API")}>
          {gettext("Issue personal API keys and use the documented REST API with your own tools.")}
        </.feature>
        <.feature icon="hero-shield-check" title={gettext("Built for integrity")}>
          {gettext("Quotes never use floating point and every financial record is append-only.")}
        </.feature>
      </section>
    </Layouts.app>
    """
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  slot :inner_block, required: true

  defp feature(assigns) do
    ~H"""
    <div class="card border border-base-300 bg-base-100">
      <div class="card-body">
        <.icon name={@icon} class="size-7 text-primary" />
        <h3 class="card-title text-base">{@title}</h3>
        <p class="text-sm text-base-content/70">{render_slot(@inner_block)}</p>
      </div>
    </div>
    """
  end
end
