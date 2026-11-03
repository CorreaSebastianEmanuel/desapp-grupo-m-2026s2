defmodule FootballMarketWeb.AdministrationLiveTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FootballMarket.{Accounts, Catalog, ValuationConfigurationCase}
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Valuation.Configurations

  @endpoint FootballMarketWeb.Endpoint

  setup do
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    :ok
  end

  test "designation fails closed and signup or submitted account identity cannot grant administration" do
    user = account()
    other = account("ordinary@example.test")
    actor = actor(user)

    for designation <- [
          [],
          [user.id, other.id],
          [user.id, user.id],
          ["invalid"],
          [Ecto.UUID.generate()],
          nil
        ] do
      Application.put_env(:football_market, :initial_issuance_recipients, designation)
      refute Accounts.administrator?(actor)
      assert {:error, :forbidden} = Configurations.inspect_for(actor)
      assert {:error, :forbidden} = Configurations.activate_for(actor, Ecto.UUID.generate(), nil)

      assert authenticated_conn(user) |> get("/administration") |> html_response(403) =~
               "Acceso restringido"
    end

    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    assert Accounts.administrator?(actor)
    refute Accounts.administrator?(actor(other))
    refute Accounts.administrator?(%{account_id: user.id})

    for path <- ["/administration", "/__local/ops"] do
      assert build_conn() |> get(path) |> redirected_to(303) =~ "/sign-in"

      assert authenticated_conn(other)
             |> get(path <> "?account_id=" <> user.id)
             |> html_response(403) =~ "Acceso restringido"
    end
  end

  test "administrator inspects immutable versions activates with seen selection and handles stale sessions" do
    user = account()
    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    {:ok, first} = Configurations.create(ValuationConfigurationCase.rules(position.id))

    {:ok, second} =
      Configurations.create(
        ValuationConfigurationCase.rules(position.id, "balanced", %{goals: 3})
      )

    {:ok, one, _} = live(authenticated_conn(user), "/administration")
    {:ok, two, _} = live(authenticated_conn(user), "/administration")
    assert has_element?(one, "details", "Ver reglas")
    quotes_before = Repo.all(FootballMarket.Market.Quote)
    jobs_before = Repo.aggregate(Oban.Job, :count)
    render_click(one, "activate", %{"version_id" => first.id})
    assert has_element?(one, "#configuration-#{first.id} .active-configuration", "Activa")
    assert has_element?(one, "#activation-notice", "próximo cierre")
    render_click(two, "activate", %{"version_id" => second.id, "expected" => first.id})
    assert has_element?(two, "#activation-notice", "Otra sesión")
    assert {:ok, %{id: id}} = Configurations.active()
    assert id == first.id
    render_click(two, "activate", %{"version_id" => second.id})
    assert {:ok, %{id: id}} = Configurations.active()
    assert id == second.id

    assert {:ok, %{version: ^first}} =
             Configurations.get(first.id)
             |> then(fn {:ok, data} -> {:ok, Map.take(data, [:version])} end)

    assert Repo.all(FootballMarket.Market.Quote) == quotes_before
    assert Repo.aggregate(Oban.Job, :count) == jobs_before
    assert {:ok, changes} = Configurations.history()
    assert length(changes) == 2
    render_click(two, "activate", %{"version_id" => second.id})
    assert {:ok, ^changes} = Configurations.history()
  end

  test "connected administrator callbacks lose authority after designation changes or logout" do
    user = account()
    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])

    jobs_before = Repo.aggregate(Oban.Job, :count)

    for {path, event, params} <- [
          {"/administration", "activate", %{"version_id" => Ecto.UUID.generate()}},
          {"/__local/ops", "run_support_job", %{"job" => "quote_close"}}
        ] do
      {:ok, view, _} = live(authenticated_conn(user), path)
      Application.put_env(:football_market, :initial_issuance_recipients, [])
      render_click(view, event, params)
      assert_redirect(view, "/portfolio")
      Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    end

    assert Repo.aggregate(Oban.Job, :count) == jobs_before
    conn = authenticated_conn(user)
    {:ok, view, _} = live(conn, "/administration")
    :ok = BrowserSessions.revoke(Plug.Conn.get_session(conn, :browser_handle))
    assert_redirect(view, "/sign-in?notice=ended")
  end

  test "connected mount rechecks designation rather than trusting a signed disconnected render" do
    user = account()
    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])
    conn = authenticated_conn(user) |> get("/administration")
    Application.put_env(:football_market, :initial_issuance_recipients, [])
    assert {:error, {:redirect, %{to: "/portfolio"}}} = live(conn)
  end

  defp actor(user),
    do: %AuthenticatedActor{
      account_id: user.id,
      authentication_method: :browser,
      credential_id: Ecto.UUID.generate()
    }

  defp authenticated_conn(user) do
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end
