defmodule FootballMarketWeb.AdminLiveTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  test "restricts /administration to administrators and allows switching valuation strategies" do
    admin = create_admin!()
    investor = create_user!()
    _fixture = create_catalog_fixture!()

    # Non-admin investor receives 403
    forbidden = build_conn() |> with_browser_session(investor) |> get("/administration")
    assert forbidden.status == 403

    # Admin inspects and activates a preset strategy
    admin_conn = build_conn() |> with_browser_session(admin)
    {:ok, view, html} = live(admin_conn, "/administration")
    assert html =~ "Estrategias del mercado"
    assert html =~ "General"
    assert html =~ "Por posición"

    [first_version | _] = :sys.get_state(view.pid).socket.assigns.versions
    updated_html = render_click(view, "activate", %{"version_id" => first_version.id})
    assert updated_html =~ "Estrategia activa actualizada"
    assert updated_html =~ "Activa"
  end

  test "renders /__local/ops for administrators and allows triggering support jobs" do
    admin = create_admin!()
    admin_conn = build_conn() |> with_browser_session(admin)

    {:ok, view, html} = live(admin_conn, "/__local/ops")
    assert html =~ "Operaciones"
    assert html =~ "PostgreSQL"
    assert render_click(view, "run_job", %{"id" => %{"nested" => "value"}}) =~ "Operaciones"

    notice_html = render_click(view, "run_support_job", %{"job" => "quote_close"})
    assert notice_html =~ "Job auxiliar encolado"
  end
end
