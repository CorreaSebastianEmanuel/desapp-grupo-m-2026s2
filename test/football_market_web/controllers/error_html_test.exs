defmodule FootballMarketWeb.ErrorHTMLTest do
  use FootballMarketWeb.ConnCase, async: true

  @moduletag :unit

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template, only: [render_to_string: 4]

  test "renders 404.html" do
    assert render_to_string(FootballMarketWeb.ErrorHTML, "404", "html", []) =~ "No encontrado"
    assert render_to_string(FootballMarketWeb.ErrorHTML, "404", "html", []) =~ "Iniciar sesión"
  end

  test "renders 500.html" do
    html = render_to_string(FootballMarketWeb.ErrorHTML, "500", "html", [])
    assert html =~ "Error interno del servidor"
    assert html =~ "No pudimos completar la solicitud"
  end
end
