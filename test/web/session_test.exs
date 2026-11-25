defmodule FootballMarketWeb.SessionTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  test "renders home, registration, sign-in, and sign-out browser flows" do
    # Public home page
    home = get(build_conn(), "/")
    assert home.status == 200

    # Register a new account via browser form
    reg_page = get(build_conn(), "/register")
    assert reg_page.status == 200

    reg_post =
      reg_page
      |> recycle()
      |> post("/register", %{
        "email" => "browser@example.com",
        "password" => "BrowserPass12345!",
        "password_confirmation" => "BrowserPass12345!"
      })

    assert redirected_to(reg_post, 303) == "/sign-in?notice=created"

    # Sign in with the new credentials
    sign_in_page = get(build_conn(), "/sign-in")
    assert sign_in_page.status == 200

    signed_in =
      sign_in_page
      |> recycle()
      |> post("/sign-in", %{
        "email" => "browser@example.com",
        "password" => "BrowserPass12345!"
      })

    assert redirected_to(signed_in, 303) == "/portfolio"

    # Sign out revokes session and redirects to /sign-in?notice=ended
    signed_out = signed_in |> recycle() |> post("/sign-out")
    assert redirected_to(signed_out, 303) == "/sign-in?notice=ended"

    # Subsequent protected route redirects back to sign-in
    protected = signed_out |> recycle() |> get("/portfolio")
    assert protected.status == 303
    assert redirected_to(protected, 303) =~ "/sign-in"
  end

  test "rejects cross-origin POST mutations with 403" do
    conn =
      build_conn()
      |> put_req_header("origin", "https://evil.example.com")
      |> post("/sign-in", %{"email" => "a@b.com", "password" => "x"})

    assert conn.status == 403
  end

  test "limits normalized sign-in failures across peers while releasing successful attempts" do
    user = create_user!()
    params = %{"email" => String.upcase(user.email) <> " ", "password" => "wrong"}

    for _ <- 1..9 do
      assert post(browser_peer({192, 0, 2, 10}), "/sign-in", params).status == 422
    end

    page = get(browser_peer({192, 0, 2, 11}), "/sign-in")

    assert page
           |> recycle()
           |> post("/sign-in", %{"email" => user.email, "password" => user.password})
           |> redirected_to(303) == "/portfolio"

    assert post(browser_peer({192, 0, 2, 11}), "/sign-in", params).status == 422

    blocked =
      post(browser_peer({192, 0, 2, 12}), "/sign-in", %{
        "email" => user.email,
        "password" => user.password
      })

    assert_browser_quota(blocked)
    refute blocked.resp_body =~ user.email
    refute blocked.resp_body =~ user.password
  end

  test "limits all sign-in attempts per connection peer regardless of forwarded headers" do
    peer = {192, 0, 2, 20}

    user = create_user!()
    page = get(browser_peer(peer), "/sign-in")
    body = URI.encode_query(%{"email" => user.email, "password" => user.password})

    assert page
           |> recycle()
           |> put_req_header("content-type", "application/x-www-form-urlencoded")
           |> post("/sign-in", body)
           |> redirected_to(303) == "/portfolio"

    for suffix <- 1..29 do
      conn = browser_peer(peer, "198.51.100.#{suffix}")
      assert post(conn, "/sign-in", %{"email" => "unknown#{suffix}@example.com"}).status == 422
    end

    assert_browser_quota(post(browser_peer(peer, "198.51.100.31"), "/sign-in", %{}))

    assert_browser_quota(
      post(browser_peer({0, 0, 0, 0, 0, 65_535, 49_152, 532}), "/sign-in", %{})
    )

    assert post(browser_peer({192, 0, 2, 21}), "/sign-in", %{}).status == 422
  end

  test "limits registration at the first untrusted hop and falls back for malformed chains" do
    proxy = {192, 0, 2, 30}
    previous = Application.fetch_env!(:football_market, :trusted_proxies)
    on_exit(fn -> Application.put_env(:football_market, :trusted_proxies, previous) end)
    Application.put_env(:football_market, :trusted_proxies, [proxy, {192, 0, 2, 31}])

    for claimed <- 1..5 do
      conn = browser_peer(proxy, "198.51.100.#{claimed}, 203.0.113.1, 192.0.2.31")
      assert post(conn, "/register", %{}).status == 422
    end

    blocked = browser_peer(proxy, "198.51.100.6, 203.0.113.1, 192.0.2.31")
    assert_browser_quota(post(blocked, "/register", %{}))
    assert post(browser_peer(proxy, "203.0.113.2"), "/register", %{}).status == 422

    for claimed <- 1..5 do
      conn = browser_peer(proxy, "malformed, 203.0.113.#{claimed}")
      assert post(conn, "/register", %{}).status == 422
    end

    assert_browser_quota(post(browser_peer(proxy), "/register", %{}))
    assert get(browser_peer(proxy), "/register").status == 200
  end

  test "uses body credentials and safely handles malformed browser forms" do
    user = create_user!()
    conn = browser_peer({192, 0, 2, 40})
    page = get(conn, "/sign-in")
    credentials = URI.encode_query(%{"email" => user.email, "password" => user.password})

    assert post(recycle(page), "/sign-in?" <> credentials, %{}).status == 422

    registration_query =
      URI.encode_query(%{
        "email" => "query-registration@example.com",
        "password" => user.password,
        "password_confirmation" => user.password
      })

    assert post(conn, "/register?" <> registration_query, %{}).status == 422

    assert {:error, :not_found} =
             FootballMarket.Accounts.get_user_by_email("query-registration@example.com")

    assert post(conn, "/sign-in", %{"email" => "bad" <> <<0>>, "password" => "wrong"}).status ==
             422

    assert post(conn, "/register", %{"email" => %{"nested" => "value"}}).status == 422

    assert post(conn, "/register", %{
             "email" => "bad" <> <<0>> <> "@example.com",
             "password" => user.password,
             "password_confirmation" => user.password
           }).status == 422
  end

  test "identifier reservations are atomic and a late release cannot change a new window" do
    alias FootballMarketWeb.RequestQuota

    key = make_ref()

    results =
      1..16
      |> Task.async_stream(fn _ -> RequestQuota.take(:sign_in_identifier, key) end)
      |> Enum.map(fn {:ok, result} -> result end)

    assert Enum.count(results, &match?({:ok, _}, &1)) == 10
    assert Enum.count(results, &match?({:error, {:limited, _}}, &1)) == 6

    previous = Application.fetch_env!(:football_market, RequestQuota)
    on_exit(fn -> Application.put_env(:football_market, RequestQuota, previous) end)
    changed = Keyword.put(previous, :sign_in_identifier, {1, 500})
    Application.put_env(:football_market, RequestQuota, changed)

    key = make_ref()
    assert {:ok, old} = RequestQuota.take(:sign_in_identifier, key)
    assert {:error, {:limited, 1}} = RequestQuota.take(:sign_in_identifier, key)
    Process.sleep(510)

    Application.put_env(
      :football_market,
      RequestQuota,
      Keyword.put(changed, :sign_in_identifier, {1, 900_000})
    )

    assert {:ok, _} = RequestQuota.take(:sign_in_identifier, key)
    assert :ok = RequestQuota.release(old)
    assert {:error, {:limited, _}} = RequestQuota.take(:sign_in_identifier, key)
  end

  defp browser_peer(address, forwarded \\ nil) do
    conn = Plug.Test.put_peer_data(build_conn(), %{address: address, port: 12_345, ssl_cert: nil})
    if forwarded, do: put_req_header(conn, "x-forwarded-for", forwarded), else: conn
  end

  defp assert_browser_quota(conn) do
    assert response(conn, 429) =~ "Demasiadas solicitudes"
    assert [seconds] = get_resp_header(conn, "retry-after")
    assert {delay, ""} = Integer.parse(seconds)
    assert delay in 1..900
  end
end
