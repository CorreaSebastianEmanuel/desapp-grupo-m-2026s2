defmodule FootballMarketWeb.PageController do
  use FootballMarketWeb, :controller

  def home(conn, _params), do: render(conn, :home)
end

defmodule FootballMarketWeb.PageHTML do
  use FootballMarketWeb, :html
  embed_templates "page_html/*"
end

defmodule FootballMarketWeb.ApiDocsController do
  use FootballMarketWeb, :controller

  def index(conn, _params), do: render(conn, :docs)
end

defmodule FootballMarketWeb.ApiDocsHTML do
  use FootballMarketWeb, :html
  embed_templates "api_docs_html/*"
end

defmodule FootballMarketWeb.SessionHTML do
  use FootballMarketWeb, :html
  embed_templates "session_html/*"
end

defmodule FootballMarketWeb.ErrorHTML do
  @moduledoc false
  use FootballMarketWeb, :html

  def render("403.html", assigns) do
    assigns = Map.new(assigns)

    ~H"""
    <main>
      <h1>Acceso denegado</h1><p role="alert">No se pudo aceptar esta solicitud.</p><a href="/portfolio">Volver al espacio de trabajo</a><a href="/sign-in">Iniciar sesión</a>
    </main>
    """
  end

  def render("404.html", assigns) do
    assigns = Map.new(assigns)

    ~H"""
    <main>
      <h1>No encontrado</h1><p role="alert">Este destino no está disponible.</p><a href="/portfolio">Volver al espacio de trabajo</a><a href="/sign-in">Iniciar sesión</a>
    </main>
    """
  end

  def render("500.html", assigns) do
    assigns = Map.new(assigns)

    ~H"""
    <main>
      <h1>Error interno del servidor</h1>
      <p role="alert">No pudimos completar la solicitud. Probá de nuevo en unos instantes.</p>
      <a href="/portfolio">Volver al espacio de trabajo</a>
    </main>
    """
  end

  def render(template, _assigns), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule FootballMarketWeb.HealthController do
  use FootballMarketWeb, :controller

  alias FootballMarket.Infrastructure.Health

  def live(conn, _params), do: json(conn, %{status: "live"})

  def ready(conn, _params), do: respond_ready(conn, Health.readiness())

  def info(conn, _params), do: json(conn, Health.info())

  def respond_ready(conn, result) do
    body = %{
      status: Atom.to_string(result.status),
      dependencies:
        Map.new(result.dependencies, fn {name, status} -> {name, Atom.to_string(status)} end)
    }

    conn
    |> put_status(if(result.status == :ready, do: :ok, else: :service_unavailable))
    |> json(body)
  end
end
