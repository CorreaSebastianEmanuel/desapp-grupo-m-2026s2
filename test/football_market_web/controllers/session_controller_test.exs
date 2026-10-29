defmodule FootballMarketWeb.SessionControllerTest do
  use FootballMarket.BrowserSessionCase
  alias FootballMarket.Accounts
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  @endpoint FootballMarketWeb.Endpoint
  defp anonymous do
    get(build_conn(), "/sign-in")
  end

  defp submit(conn, attrs \\ %{}) do
    conn
    |> recycle()
    |> post(
      "/sign-in",
      Map.merge(%{"email" => "browser@example.com", "password" => "correct-password-123"}, attrs)
    )
  end

  test "expired and missing sign-in authority issues a recoverable form without authenticating" do
    controlled_clock!()
    account()
    opened = anonymous()
    expired_handle = get_session(opened, :browser_handle)

    :persistent_term.put(
      {FootballMarket.BrowserTestClock, :now},
      DateTime.add(BrowserSessions.now(), 901, :second)
    )

    for conn <- [opened, build_conn() |> init_test_session(%{})] do
      retry = submit(conn, %{"return_to" => "/conditional-orders"})
      html = html_response(retry, 422)
      assert html =~ "Your sign-in form expired. Please try again."
      refute html =~ "correct-password-123"
      fresh_handle = get_session(retry, :browser_handle)
      refute fresh_handle == expired_handle
      assert {:error, :invalid} = BrowserSessions.validate(fresh_handle)

      signed = submit(retry, %{"return_to" => "/conditional-orders"})
      assert redirected_to(signed, 303) == "/conditional-orders"
      assert {:ok, _} = BrowserSessions.validate(get_session(signed, :browser_handle))
      assert {:error, :invalid} = BrowserSessions.validate(fresh_handle)
    end

    assert {:error, :invalid} =
             BrowserSessions.authenticate(expired_handle, account("another@example.com").id)
  end

  test "expired transport still offers session-ended recovery without private content" do
    controlled_clock!()
    user = account()
    signed = anonymous() |> submit()
    handle = get_session(signed, :browser_handle)

    :persistent_term.put(
      {FootballMarket.BrowserTestClock, :now},
      DateTime.add(BrowserSessions.now(), 901, :second)
    )

    assert {:error, :expired} = BrowserSessions.validate(handle)

    for path <- ["/portfolio", "/conditional-orders"] do
      # A new connection models a browser that already removed expired transport.
      denied = get(build_conn(), path)
      location = redirected_to(denied, 303)
      assert location =~ "notice=ended"
      assert location =~ URI.encode_www_form(path)
      assert get_resp_header(denied, "cache-control") == ["no-store"]
      refute response(denied, 303) =~ user.email

      recovery = denied |> recycle() |> get(location) |> html_response(200)
      assert recovery =~ "Your session ended. Please sign in again."
      refute recovery =~ user.email
      refute recovery =~ handle
    end

    refute anonymous() |> html_response(200) =~ "Your session ended"
  end

  test "real wall clock cookie retention does not truncate the remaining lifetime" do
    user = account()
    now = DateTime.utc_now()
    {:ok, anonymous} = BrowserSessions.create_anonymous(now)
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id, now)
    # Place the deadline between integral seconds while retaining the real clock.
    {:ok, actor} = BrowserSessions.validate(handle)
    deadline = DateTime.add(DateTime.utc_now(), 60_800_000, :microsecond)
    session = Repo.get!(FootballMarket.Accounts.BrowserSession, actor.session_id)

    session
    |> Ecto.Changeset.change(
      expires_at: deadline,
      started_at: DateTime.add(deadline, -900, :second)
    )
    |> Repo.update!()

    before_send = DateTime.utc_now()
    conn = build_conn() |> Plug.Test.init_test_session(%{browser_handle: handle})
    conn = FootballMarketWeb.Plugs.BrowserCookie.call(conn, [])
    conn = conn |> put_resp_cookie("_football_market_key", "encrypted") |> send_resp(200, "ok")
    age = conn.resp_cookies["_football_market_key"].max_age
    assert age == 61
    assert DateTime.compare(DateTime.add(before_send, age, :second), deadline) != :lt
    assert {:error, :expired} = BrowserSessions.validate(handle, deadline)
  end

  test "rotates encrypted cookie, ignores stale credentials and keeps APIs separate" do
    user = account()
    old = anonymous()
    old_handle = get_session(old, :browser_handle)
    signed = submit(old)
    assert redirected_to(signed, 303) == "/portfolio"
    handle = get_session(signed, :browser_handle)
    refute handle == old_handle
    assert {:error, :invalid} = BrowserSessions.validate(old_handle)
    assert {:ok, %{account_id: id}} = BrowserSessions.validate(handle)
    assert id == user.id
    assert Enum.join(get_resp_header(signed, "set-cookie")) =~ "HttpOnly"
    refute Enum.join(get_resp_header(signed, "set-cookie")) =~ handle
    stale = submit(signed, %{"email" => "another@example.com", "password" => "wrong"})
    assert redirected_to(stale, 303) == "/portfolio"
    assert get_session(stale, :browser_handle) == handle
    assert stale |> recycle() |> get("/api/players") |> response(401)
    html = signed |> recycle() |> get("/portfolio") |> html_response(200)
    assert html =~ user.email
    refute html =~ handle
    assert signed |> recycle() |> get("/sign-in") |> redirected_to(303) == "/portfolio"
  end

  test "invalid forms clear passwords and return paths are exact" do
    account()
    invalid = anonymous() |> submit(%{"password" => "incorrect-secret"})
    html = html_response(invalid, 422)
    assert html =~ "Unable to sign in"
    refute html =~ "incorrect-secret"
    assert html =~ "aria-describedby=\"sign-in-message\""

    good =
      anonymous()
      |> submit(%{"return_to" => "/conditional-orders", "account_id" => Ecto.UUID.generate()})

    assert redirected_to(good, 303) == "/conditional-orders"
    assert get(build_conn(), "/portfolio") |> redirected_to(303) =~ "/sign-in"
  end

  test "public registration creates an account and returns the user to sign-in" do
    page = get(build_conn(), "/register")
    html = html_response(page, 200)
    assert html =~ "Create your account"
    assert html =~ "name=\"password_confirmation\""
    assert html =~ "name=\"_csrf_token\""

    created =
      page
      |> recycle()
      |> post("/register", %{
        "email" => " New.User@Example.Test ",
        "password" => "correct-password-123",
        "password_confirmation" => "correct-password-123"
      })

    assert redirected_to(created, 303) == "/sign-in?notice=created"
    assert get_session(created, :browser_handle) == nil

    assert {:ok, user} =
             Accounts.verify_browser_credentials(%{
               "email" => "new.user@example.test",
               "password" => "correct-password-123"
             })

    assert user.email == "new.user@example.test"

    assert get(build_conn(), "/sign-in?notice=created") |> html_response(200) =~
             "Account created. Sign in to continue."
  end

  test "registration rejects mismatched or invalid credentials without returning secrets" do
    mismatch =
      get(build_conn(), "/register")
      |> recycle()
      |> post("/register", %{
        "email" => "mismatch@example.test",
        "password" => "correct-password-123",
        "password_confirmation" => "different-password-456"
      })

    mismatch_html = html_response(mismatch, 422)
    assert mismatch_html =~ "Passwords do not match"
    refute mismatch_html =~ "correct-password-123"
    assert {:error, :not_found} = Accounts.get_user_by_email("mismatch@example.test")

    invalid =
      get(build_conn(), "/register")
      |> recycle()
      |> post("/register", %{
        "email" => "bad@example.test",
        "password" => "short",
        "password_confirmation" => "short"
      })

    invalid_html = html_response(invalid, 422)
    assert invalid_html =~ "We couldn&#39;t create the account"
    refute invalid_html =~ "short"
    assert {:error, :not_found} = Accounts.get_user_by_email("bad@example.test")
  end

  test "duplicate email registration returns a generic error and keeps the account intact" do
    existing = account()

    response =
      get(build_conn(), "/register")
      |> recycle()
      |> post("/register", %{
        "email" => existing.email,
        "password" => "different-password-456",
        "password_confirmation" => "different-password-456"
      })

    html = html_response(response, 422)
    assert html =~ "We couldn&#39;t create the account"
    refute html =~ "already taken"

    assert {:ok, authenticated} =
             Accounts.verify_browser_credentials(%{
               "email" => existing.email,
               "password" => "correct-password-123"
             })

    assert authenticated.id == existing.id
  end

  test "revocation commits before cookie deletion and failure retains retry authority" do
    account()
    controlled_clock!()
    signed = anonymous() |> submit()
    handle = get_session(signed, :browser_handle)
    Application.put_env(:football_market, :browser_failure, :revoke)
    failed = signed |> recycle() |> post("/sign-out")
    assert html_response(failed, 503) =~ "Retry sign out"
    assert get_session(failed, :browser_handle) == handle
    assert {:ok, _} = BrowserSessions.validate(handle)
    Application.delete_env(:football_market, :browser_failure)
    out = failed |> recycle() |> post("/sign-out")
    assert redirected_to(out, 303) =~ "/sign-in"
    assert {:error, :invalid} = BrowserSessions.validate(handle)
    replay = build_conn() |> init_test_session(%{browser_handle: handle}) |> get("/portfolio")
    assert redirected_to(replay, 303) =~ "/sign-in"
  end
end
