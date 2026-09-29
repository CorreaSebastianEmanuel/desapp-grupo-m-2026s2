defmodule FootballMarketWeb.AccountLive do
  use FootballMarketWeb, :live_view

  alias FootballMarket.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Account"))
     |> assign(:issued_key, nil)
     |> assign_api_keys()}
  end

  @impl true
  def handle_event("issue-key", _params, socket) do
    case Accounts.issue_api_key(socket.assigns.current_user.id) do
      {:ok, issued_key} ->
        {:noreply,
         socket
         |> assign(:issued_key, issued_key)
         |> assign_api_keys()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, gettext("The API key could not be created."))}
    end
  end

  def handle_event("dismiss-key", _params, socket) do
    {:noreply, assign(socket, :issued_key, nil)}
  end

  def handle_event("revoke-key", %{"id" => key_id}, socket) do
    case Accounts.revoke_api_key(socket.assigns.current_user.id, key_id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("API key revoked."))
         |> assign(:issued_key, dismiss_if_revoked(socket.assigns.issued_key, key_id))
         |> assign_api_keys()}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, gettext("API key not found."))}
    end
  end

  defp assign_api_keys(socket) do
    assign(socket, :api_keys, Accounts.list_api_keys(socket.assigns.current_user.id))
  end

  defp dismiss_if_revoked(%{id: key_id}, key_id), do: nil
  defp dismiss_if_revoked(issued_key, _key_id), do: issued_key

  defp format_timestamp(nil), do: "—"
  defp format_timestamp(timestamp), do: Calendar.strftime(timestamp, "%Y-%m-%d %H:%M UTC")

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} active={:account}>
      <.header>
        {gettext("Account")}
        <:subtitle>{@current_user.email}</:subtitle>
      </.header>

      <section class="card border border-base-300 bg-base-100" aria-labelledby="api-keys-heading">
        <div class="card-body gap-4">
          <div class="flex flex-wrap items-start justify-between gap-4">
            <div>
              <h2 id="api-keys-heading" class="card-title">{gettext("API keys")}</h2>
              <p class="text-sm text-base-content/70">
                {gettext("Send a key in the X-API-Key header to call the REST API.")}
                <a href={~p"/docs"} class="link link-primary">{gettext("Read the API documentation")}</a>.
              </p>
            </div>
            <button
              id="issue-key"
              phx-click="issue-key"
              class="btn btn-primary"
              phx-disable-with={gettext("Creating…")}
            >
              <.icon name="hero-plus" /> {gettext("New API key")}
            </button>
          </div>

          <div :if={@issued_key} id="issued-key" role="alert" class="alert items-start alert-success">
            <.icon name="hero-key" class="size-6 shrink-0" />
            <div class="w-full min-w-0 space-y-2">
              <p class="font-semibold">
                {gettext("Copy this key now. It will not be shown again.")}
              </p>
              <div class="join w-full">
                <input
                  id="issued-key-secret"
                  type="text"
                  readonly
                  value={@issued_key.secret}
                  class="input join-item w-full font-mono text-sm"
                  aria-label={gettext("New API key")}
                />
                <button
                  type="button"
                  class="btn join-item"
                  phx-click={JS.dispatch("phx:copy", to: "#issued-key-secret")}
                >
                  <.icon name="hero-clipboard-document" /> {gettext("Copy")}
                </button>
              </div>
            </div>
            <button
              type="button"
              phx-click="dismiss-key"
              class="btn btn-circle btn-ghost btn-sm"
              aria-label={gettext("Dismiss")}
            >
              <.icon name="hero-x-mark" />
            </button>
          </div>

          <p
            :if={@api_keys == []}
            id="api-keys-empty"
            class="rounded-box border border-dashed border-base-300 p-6 text-center text-sm text-base-content/70"
          >
            {gettext("You have no API keys yet.")}
          </p>

          <div :if={@api_keys != []} class="overflow-x-auto">
            <.table id="api-keys" rows={@api_keys} row_id={&"api-key-#{&1.id}"}>
              <:col :let={key} label={gettext("Key ID")}>
                <code class="text-xs">{key.id}</code>
              </:col>
              <:col :let={key} label={gettext("Created")} class="hidden sm:table-cell">
                {format_timestamp(key.inserted_at)}
              </:col>
              <:col :let={key} label={gettext("Status")}>
                <span :if={is_nil(key.revoked_at)} class="badge badge-soft badge-success">
                  {gettext("Active")}
                </span>
                <span
                  :if={key.revoked_at}
                  class="badge badge-soft badge-error"
                  title={format_timestamp(key.revoked_at)}
                >
                  {gettext("Revoked")}
                </span>
              </:col>
              <:action :let={key}>
                <button
                  :if={is_nil(key.revoked_at)}
                  phx-click="revoke-key"
                  phx-value-id={key.id}
                  data-confirm={gettext("Revoke this key? Clients using it will stop working.")}
                  class="btn btn-ghost btn-xs text-error"
                >
                  {gettext("Revoke")}
                </button>
              </:action>
            </.table>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
