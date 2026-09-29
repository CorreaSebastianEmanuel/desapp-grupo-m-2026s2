defmodule FootballMarketWeb.UserLoginLive do
  use FootballMarketWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)

    {:ok,
     socket
     |> assign(:page_title, gettext("Log in"))
     |> assign(:form, to_form(%{"email" => email}, as: "user"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="mx-auto max-w-sm">
        <div class="card border border-base-300 bg-base-100 shadow-sm">
          <div class="card-body">
            <.header>
              {gettext("Log in")}
              <:subtitle>
                {gettext("Don't have an account?")}
                <.link navigate={~p"/users/register"} class="link font-semibold link-primary">
                  {gettext("Create one")}
                </.link>
              </:subtitle>
            </.header>

            <%!-- The session cookie can only be written by a regular HTTP request. --%>
            <.form for={@form} id="login-form" action={~p"/users/log-in"} phx-update="ignore">
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
                autocomplete="current-password"
                required
              />
              <.button variant="primary" class="btn btn-primary mt-2 w-full" phx-disable-with="…">
                {gettext("Log in")} <span aria-hidden="true">→</span>
              </.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
