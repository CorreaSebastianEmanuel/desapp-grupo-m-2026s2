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
end
