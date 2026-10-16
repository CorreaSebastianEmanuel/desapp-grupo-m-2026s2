defmodule FootballMarketWeb.BrowserFeedbackTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  import Phoenix.ConnTest
  require Phoenix.LiveViewTest
  import ExUnit.CaptureLog
  @endpoint FootballMarketWeb.Endpoint
  test "shell scope allowance is fixed and fails closed" do
    paths = shell_paths("specs/063-liveview-shell-authentication")
    assert length(paths) == 34
    assert length(paths) == length(Enum.uniq(paths))
    assert Enum.all?(paths, &File.regular?/1)
    assert shell_paths(nil) == []
    assert shell_paths("specs/unknown") == []
    refute "lib/football_market/market/unplanned.ex" in paths
    refute "lib/football_market/providers/unplanned.ex" in paths

    assert File.read!("config/config.exs") =~
             ~s(filter_parameters: ["password", "token", "cursor", "browser_handle", "token_digest", "secret"])
  end

  test "telemetry excludes password and raw browser authority" do
    user = account()
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)
    handler = "browser-secrets-#{Ecto.UUID.generate()}"
    parent = self()

    :ok =
      :telemetry.attach_many(
        handler,
        [[:football_market, :repo, :query], [:football_market, :authentication, :login]],
        fn event, measurements, metadata, target ->
          send(target, {:observed, event, measurements, metadata})
        end,
        parent
      )

    on_exit(fn -> :telemetry.detach(handler) end)
    assert {:ok, _} = BrowserSessions.validate(handle)

    assert {:ok, _} =
             FootballMarket.Accounts.login(%{email: user.email, password: "correct-password-123"})

    events = collect_telemetry([])
    assert events != []
    refute inspect(events) =~ handle
    refute inspect(events) =~ "correct-password-123"
  end

  defp collect_telemetry(acc) do
    receive do
      {:observed, _, _, _} = event -> collect_telemetry([event | acc])
    after
      0 -> acc
    end
  end

  test "subscribe then revalidate closes a revoke during connected mount" do
    alias Phoenix.LiveView.{Lifecycle, Socket}
    user = account()
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)
    handler = "mount-race-#{Ecto.UUID.generate()}"
    Process.put(:revoke_during_mount, true)

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :repo, :query],
        fn _, _, metadata, authority ->
          if Process.get(:revoke_during_mount) &&
               String.contains?(metadata.query, ~s(FROM "browser_sessions")) do
            Process.put(:revoke_during_mount, false)
            :ok = BrowserSessions.revoke(authority)
          end
        end,
        handle
      )

    on_exit(fn -> :telemetry.detach(handler) end)

    socket = %Socket{
      transport_pid: self(),
      endpoint: @endpoint,
      router: FootballMarketWeb.Router,
      view: FootballMarketWeb.WorkspaceLive,
      assigns: %{__changed__: %{}},
      private: %{lifecycle: %Lifecycle{}, connect_info: %{session: %{"browser_handle" => handle}}}
    }

    assert {:halt, ended} =
             FootballMarketWeb.Live.BrowserAuth.on_mount(:workspace, %{}, %{}, socket)

    assert ended.assigns.actor == nil
    assert ended.redirected != nil
  end

  test "mount tokens, HTML and telemetry never carry raw authority or credential material" do
    user = account()
    {:ok, anon} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anon, user.id)
    conn = build_conn() |> Plug.Test.init_test_session(%{browser_handle: handle})

    logs =
      capture_log(fn ->
        html = conn |> get("/portfolio") |> html_response(200)
        [_, token] = Regex.run(~r/data-phx-session="([^"]+)"/, html)
        assert {:ok, payload} = Phoenix.LiveView.Static.verify_token(@endpoint, token)
        refute inspect(payload) =~ handle
        refute inspect(payload) =~ "browser_handle"
        refute html =~ handle
        refute html =~ "correct-password-123"
      end)

    refute logs =~ handle
    refute logs =~ "correct-password-123"
  end

  test "recovery components escape arbitrary text and provide navigable outcomes" do
    html =
      Phoenix.LiveViewTest.render_component(&FootballMarketWeb.WorkspaceComponents.recovery/1,
        kind: "<script>alert(1)</script>"
      )

    assert html =~ "&lt;script&gt;"
    refute html =~ "<script>"
    assert html =~ "role=\"alert\""
    assert html =~ "/portfolio"
    assert html =~ "/sign-in"
  end

  test "trusted lifecycle hooks deny every private callback at the exact deadline" do
    alias Phoenix.LiveView.{Lifecycle, Socket}
    user = account()
    other = account("other@example.com")
    controlled_clock!()
    now = BrowserSessions.now()
    {:ok, anon} = BrowserSessions.create_anonymous(now)
    {:ok, handle} = BrowserSessions.authenticate(anon, user.id, now)
    {:ok, actor} = BrowserSessions.validate(handle, now)

    socket = %Socket{
      endpoint: @endpoint,
      router: FootballMarketWeb.Router,
      view: FootballMarketWeb.WorkspaceLive,
      assigns: %{__changed__: %{}},
      private: %{lifecycle: %Lifecycle{}}
    }

    {:cont, socket} =
      FootballMarketWeb.Live.BrowserAuth.on_mount(
        :workspace,
        %{"account_id" => other.id},
        %{"actor" => actor},
        socket
      )

    assert socket.assigns.actor.account_id == user.id
    # Test-only ownership probe; identity comes from a freshly validated server actor.
    assert {:error, :denied} = owned_resource(socket, other.id)
    assert {:ok, :owned} = owned_resource(socket, user.id)
    refute inspect(socket.assigns) =~ handle
    :persistent_term.put({FootballMarket.BrowserTestClock, :now}, DateTime.add(now, 900, :second))

    for result <- [
          Lifecycle.handle_event("private", %{"account_id" => other.id}, socket),
          Lifecycle.handle_params(%{}, "http://localhost/portfolio", socket),
          Lifecycle.handle_info({:private_result, "sensitive"}, socket),
          Lifecycle.handle_async(:private, {:ok, "sensitive"}, socket)
        ] do
      assert {:halt, ended} = result
      assert ended.assigns.actor == nil
      assert ended.redirected == {:redirect, %{to: "/sign-in?notice=ended", status: 302}}
    end
  end
end
