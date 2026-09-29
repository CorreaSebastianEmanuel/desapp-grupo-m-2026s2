defmodule FootballMarketWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FootballMarketWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders the application shell: responsive navigation, page content, and flash messages.

  ## Examples

      <Layouts.app flash={@flash} current_user={@current_user} active={:players}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, :map, default: nil, doc: "the signed-in user's public projection"

  attr :active, :atom,
    default: nil,
    values: [nil, :players, :account],
    doc: "the navigation entry to highlight"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="flex min-h-screen flex-col">
      <header class="navbar sticky top-0 z-40 border-b border-base-300 bg-base-100/95 px-4 backdrop-blur sm:px-6 lg:px-8">
        <div class="navbar-start gap-1">
          <div :if={@current_user} class="dropdown lg:hidden">
            <div
              tabindex="0"
              role="button"
              class="btn btn-square btn-ghost"
              aria-label={gettext("Open navigation")}
            >
              <.icon name="hero-bars-3" class="size-5" />
            </div>
            <ul
              tabindex="0"
              class="menu dropdown-content menu-sm z-50 mt-3 w-52 rounded-box bg-base-100 p-2 shadow"
            >
              <.nav_links active={@active} />
            </ul>
          </div>
          <.link navigate={~p"/"} class="btn gap-2 px-2 text-base font-semibold btn-ghost">
            <.icon name="hero-trophy" class="size-6 text-primary" />
            <span class="hidden sm:inline">Football Player Market</span>
            <span class="sm:hidden">FPM</span>
          </.link>
        </div>

        <nav :if={@current_user} class="navbar-center hidden lg:flex" aria-label="Main">
          <ul class="menu menu-horizontal gap-1 px-1">
            <.nav_links active={@active} />
          </ul>
        </nav>

        <div class="navbar-end gap-2">
          <.theme_toggle />
          <div :if={@current_user} class="dropdown dropdown-end">
            <div
              tabindex="0"
              role="button"
              class="btn btn-circle btn-soft btn-primary"
              aria-label={gettext("Account menu")}
            >
              <.icon name="hero-user" class="size-5" />
            </div>
            <ul
              tabindex="0"
              class="menu dropdown-content z-50 mt-3 w-64 rounded-box bg-base-100 p-2 shadow"
            >
              <li class="menu-title truncate" id="current-user-email">{@current_user.email}</li>
              <li>
                <.link navigate={~p"/account"}>
                  <.icon name="hero-key" /> {gettext("Account & API keys")}
                </.link>
              </li>
              <li>
                <.link href={~p"/users/log-out"} method="delete" id="log-out-link">
                  <.icon name="hero-arrow-right-start-on-rectangle" /> {gettext("Log out")}
                </.link>
              </li>
            </ul>
          </div>
          <div :if={is_nil(@current_user)} class="flex gap-2">
            <.link navigate={~p"/users/log-in"} class="btn btn-ghost btn-sm">
              {gettext("Log in")}
            </.link>
            <.link navigate={~p"/users/register"} class="btn hidden btn-sm btn-primary sm:inline-flex">
              {gettext("Create account")}
            </.link>
          </div>
        </div>
      </header>

      <main class="flex-1 px-4 py-8 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-6xl">
          {render_slot(@inner_block)}
        </div>
      </main>

      <footer class="footer footer-center border-t border-base-300 p-6 text-sm text-base-content/60">
        <p>
          Football Player Market · UNQ Desarrollo de Aplicaciones — Alquimistas ·
          <a href={~p"/docs"} class="link link-hover">{gettext("API documentation")}</a>
        </p>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :active, :atom, default: nil

  defp nav_links(assigns) do
    ~H"""
    <li>
      <.link navigate={~p"/players"} class={@active == :players && "menu-active"}>
        <.icon name="hero-user-group" /> {gettext("Players")}
      </.link>
    </li>
    <li>
      <.link navigate={~p"/account"} class={@active == :account && "menu-active"}>
        <.icon name="hero-key" /> {gettext("Account")}
      </.link>
    </li>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
