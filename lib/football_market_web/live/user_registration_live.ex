defmodule FootballMarketWeb.UserRegistrationLive do
  use FootballMarketWeb, :live_view

  alias FootballMarket.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Create account"))
     |> assign(:form, to_form(%{}, as: "user"))}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) when is_map(params) do
    case Accounts.register_user(Map.take(params, ["email", "password"])) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Account created. Log in to continue."))
         |> put_flash(:email, user.email)
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, changeset} ->
        # The submitted password is never echoed back to the browser.
        form_params = %{"email" => Map.get(params, "email", ""), "password" => ""}

        {:noreply,
         assign(socket, :form, to_form(form_params, as: "user", errors: changeset.errors))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="mx-auto max-w-sm">
        <div class="card border border-base-300 bg-base-100 shadow-sm">
          <div class="card-body">
            <.header>
              {gettext("Create account")}
              <:subtitle>
                {gettext("Already registered?")}
                <.link navigate={~p"/users/log-in"} class="link font-semibold link-primary">
                  {gettext("Log in")}
                </.link>
              </:subtitle>
            </.header>

            <.form for={@form} id="registration-form" phx-submit="save">
              <.input
                field={@form[:email]}
                type="email"
                label={gettext("Email")}
                autocomplete="username"
                required
                phx-mounted={JS.focus()}
              />
              <.input
                field={@form[:password]}
                type="password"
                label={gettext("Password")}
                autocomplete="new-password"
                required
              />
              <p class="-mt-1 mb-3 text-xs text-base-content/60">
                {gettext("Use 12 to 128 characters.")}
              </p>
              <.button
                variant="primary"
                class="btn btn-primary w-full"
                phx-disable-with={gettext("Creating account…")}
              >
                {gettext("Create account")}
              </.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
