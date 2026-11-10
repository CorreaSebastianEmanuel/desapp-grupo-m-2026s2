defmodule FootballMarketWeb.LocalAdminLiveTest do
  use FootballMarket.BrowserSessionCase

  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import Ecto.Query

  alias FootballMarket.Synchronization.Run

  @endpoint FootballMarketWeb.Endpoint

  setup do
    user = account("local-administrator@example.test")
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)
    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)

    conn =
      build_conn()
      |> Plug.Test.init_test_session(%{browser_handle: handle})
      |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})

    %{conn: conn}
  end

  test "local operations page reports database, queues, jobs, and catalog state", %{conn: conn} do
    old_assessment = Application.fetch_env(:football_market, :scraping_assessment)
    Application.put_env(:football_market, :scraping_assessment, :local_development)

    on_exit(fn ->
      case old_assessment do
        {:ok, value} -> Application.put_env(:football_market, :scraping_assessment, value)
        :error -> Application.delete_env(:football_market, :scraping_assessment)
      end
    end)

    {:ok, view, html} = live(conn, "/__local/ops")

    assert html =~ "SOLO DESARROLLO LOCAL"
    assert has_element?(view, "#database-heading", "PostgreSQL")

    assert has_element?(
             view,
             "#primary-inventory-heading",
             "Cuenta principal de fichas iniciales"
           )

    assert html =~ "local-administrator@example.test"
    assert has_element?(view, "#redis-heading", "Redis")
    assert has_element?(view, "#jobs-heading", "2 · Jobs")
    assert has_element?(view, "#queues-heading", "3 · Colas")
    assert has_element?(view, "#queue-catalog_sync", "catalog_sync")
    assert has_element?(view, "#queue-statistics_import", "statistics_import")
    assert has_element?(view, "#queue-quote_calculation", "quote_calculation")
    refute has_element?(view, "#queue-catalog_scout")
    assert has_element?(view, "#runs-heading", "Últimas 5 ejecuciones")
    assert html =~ "Solicitudes de cotización"
    assert html =~ "Trabajo y alcance"
    assert has_element?(view, "#catalog-heading", "Sincronizar catálogo completo")

    assert has_element?(
             view,
             "#queue-statistics_import",
             "Abrir la ficha de un jugador encola su scraping"
           )

    refute html =~ "Vincular jugador con FotMob"
    assert html =~ "Ejecutar ahora"
    assert html =~ "cinco ligas europeas"

    before_jobs = Repo.aggregate(Oban.Job, :count)
    render_click(view, "run_support_job", %{"job" => "unrecognized"})
    assert Repo.aggregate(Oban.Job, :count) == before_jobs
    assert has_element?(view, "#local-admin-notice", "No se pudo encolar ese job auxiliar.")

    {:ok, retryable} = Oban.insert(Oban, FootballMarket.Workers.ConditionalOrderRecovery.new(%{}))
    Repo.update!(Ecto.Changeset.change(retryable, state: "cancelled"))
    render_click(view, "run_job", %{"id" => Integer.to_string(retryable.id)})
    assert Repo.get!(Oban.Job, retryable.id).state == "available"

    {:ok, primary} = Oban.insert(Oban, FootballMarket.Workers.QuoteRecovery.new(%{}))
    Repo.update!(Ecto.Changeset.change(primary, state: "cancelled"))
    render_click(view, "run_job", %{"id" => Integer.to_string(primary.id)})
    assert Repo.get!(Oban.Job, primary.id).state == "cancelled"
    assert has_element?(view, "#local-admin-notice", "No se pudo ejecutar ese job.")

    render_click(view, "run_support_job", %{"job" => "quote_recovery"})

    assert Repo.exists?(
             from(j in Oban.Job,
               where:
                 j.worker == "FootballMarket.Workers.QuoteRecovery" and
                   j.queue == "quote_calculation"
             )
           )

    render_click(view, "run_support_job", %{"job" => "quote_close"})
    assert has_element?(view, "#local-admin-notice", "Cierre manual de cotizaciones encolado")

    assert Repo.exists?(
             from(j in Oban.Job,
               where:
                 j.worker == "FootballMarket.Workers.QuoteClose" and
                   j.queue == "quote_calculation" and fragment("?->>'mode' = 'manual'", j.args)
             )
           )
  end

  test "statistics queue shows a failed synchronization result beside completed delivery", %{
    conn: conn
  } do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    delivery_id = Ecto.UUID.generate()

    run =
      Repo.insert!(%Run{
        operation: "statistics",
        correlation_id: "admin-failed-statistics-run",
        league_code: "PL",
        start_year: 2026,
        end_year: 2027,
        source_ref: "fotmob-public-html",
        input: %{"timeout_ms" => 1_000},
        input_digest: String.duplicate("a", 64),
        policy: %{"worker_timeout_ms" => 3_000},
        original_trigger: "manual",
        state: "failed",
        requested_at: now,
        started_at: now,
        finished_at: now,
        outcome: %{
          "status" => "provider_failure",
          "category" => "invalid_response",
          "reason" => "invalid_response",
          "retryable" => false
        },
        reason: "non_retryable",
        recovery: "inspect_run",
        delivery_id: delivery_id
      })

    {:ok, job} =
      Oban.insert(
        Oban,
        FootballMarket.Workers.StatisticsImport.new(%{
          "run_id" => run.id,
          "delivery_id" => delivery_id
        })
      )

    Repo.update!(Ecto.Changeset.change(run, job_id: job.id))
    Repo.update!(Ecto.Changeset.change(job, state: "completed", completed_at: now))

    {:ok, view, _html} = live(conn, "/__local/ops")

    assert has_element?(view, "#queue-statistics_import", "Importación fallida")
    assert has_element?(view, "#queue-statistics_import", "Respuesta no válida del proveedor")
    assert has_element?(view, "#queue-statistics_import", "No reintentable")
  end

  test "failed synchronization details identify provider rate limiting", %{conn: conn} do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    delivery_id = Ecto.UUID.generate()

    run =
      Repo.insert!(%Run{
        operation: "catalog",
        correlation_id: "admin-rate-limited-catalog-run",
        league_code: "PD",
        start_year: 2026,
        end_year: 2027,
        source_ref: "football-data-org",
        input: %{},
        input_digest: String.duplicate("b", 64),
        policy: %{},
        original_trigger: "manual",
        state: "failed",
        requested_at: now,
        started_at: now,
        finished_at: now,
        outcome: %{
          "status" => "provider_failure",
          "category" => "rate_limited",
          "retryable" => true
        },
        reason: "exhausted",
        recovery: "provider_guidance",
        delivery_id: delivery_id
      })

    {:ok, job} =
      Oban.insert(
        Oban,
        FootballMarket.Workers.CatalogSync.new(%{
          "run_id" => run.id,
          "delivery_id" => delivery_id
        })
      )

    Repo.update!(Ecto.Changeset.change(run, job_id: job.id))
    Repo.update!(Ecto.Changeset.change(job, state: "completed", completed_at: now))

    {:ok, view, _html} = live(conn, "/__local/ops")

    assert has_element?(view, "#queue-catalog_sync", "Importación fallida")
    assert has_element?(view, "#queue-catalog_sync", "Proveedor limitó las solicitudes")
  end
end
