defmodule FootballMarketWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use FootballMarketWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/football_market_web/controllers/error_html/404.html.heex
  #   * lib/football_market_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "No encontrado".
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
