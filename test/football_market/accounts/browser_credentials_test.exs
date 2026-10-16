defmodule FootballMarket.Accounts.BrowserCredentialsTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  alias FootballMarket.Accounts

  test "normalizes only email, preserves API results and generic browser failures" do
    user = account()

    assert {:ok, %{id: id}} =
             Accounts.verify_browser_credentials(%{
               "email" => " BROWSER@EXAMPLE.COM ",
               "password" => "correct-password-123"
             })

    assert id == user.id

    for attrs <- [
          %{},
          nil,
          %{"email" => "unknown@example.com", "password" => "correct-password-123"},
          %{"email" => user.email, "password" => " correct-password-123 "},
          %{"email" => 42, "password" => []}
        ] do
      assert {:error, :invalid} = Accounts.verify_browser_credentials(attrs)
      assert {:error, :authentication_failed} = Accounts.login(attrs)
    end

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: "correct-password-123"})

    assert {:ok, _} = Accounts.validate_access_token(token)
    controlled_clock!()
    Application.put_env(:football_market, :browser_failure, :all)

    assert {:error, :unavailable} =
             Accounts.verify_browser_credentials(%{
               email: user.email,
               password: "correct-password-123"
             })

    assert {:error, :authentication_failed} =
             Accounts.login(%{email: user.email, password: "correct-password-123"})
  end
end
