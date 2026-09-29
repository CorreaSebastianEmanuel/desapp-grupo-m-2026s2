defmodule FootballMarketWeb.AccountLiveTest do
  use FootballMarketWeb.LiveCase, async: false

  @moduletag :integration

  alias FootballMarket.Accounts

  setup :register_and_log_in_user

  test "shows the account email and an empty key list", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/account")

    assert render(view) =~ user.email
    assert has_element?(view, "#api-keys-empty")
  end

  test "issues a key whose secret is shown exactly once", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, ~p"/account")

    view |> element("#issue-key") |> render_click()

    secret = secret_from(view)
    assert {:ok, %{account_id: account_id, key_id: key_id}} = Accounts.identify_api_key(secret)
    assert account_id == user.id
    assert has_element?(view, "#api-key-#{key_id}", "Active")

    {:ok, reloaded, html} = live(conn, ~p"/account")
    refute html =~ secret
    refute has_element?(reloaded, "#issued-key")
    assert has_element?(reloaded, "#api-key-#{key_id}")
  end

  test "the issued secret can be dismissed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/account")

    view |> element("#issue-key") |> render_click()
    assert has_element?(view, "#issued-key")

    render_click(view, "dismiss-key")
    refute has_element?(view, "#issued-key")
  end

  test "revoking a key disables it immediately", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/account")
    view |> element("#issue-key") |> render_click()
    secret = secret_from(view)
    {:ok, %{key_id: key_id}} = Accounts.identify_api_key(secret)

    html = view |> element("#api-key-#{key_id} button", "Revoke") |> render_click()

    assert html =~ "API key revoked."
    assert has_element?(view, "#api-key-#{key_id}", "Revoked")
    refute has_element?(view, "#issued-key")
    assert Accounts.identify_api_key(secret) == {:error, :invalid_key}
  end

  test "keys owned by another account cannot be revoked", %{conn: conn} do
    other = register_user!()
    {:ok, %{id: other_key_id, secret: other_secret}} = Accounts.issue_api_key(other.id)
    {:ok, view, _html} = live(conn, ~p"/account")

    html = render_click(view, "revoke-key", %{"id" => other_key_id})

    assert html =~ "API key not found."
    refute has_element?(view, "#api-key-#{other_key_id}")
    assert {:ok, _identity} = Accounts.identify_api_key(other_secret)
  end

  defp secret_from(view) do
    view
    |> render()
    |> LazyHTML.from_fragment()
    |> LazyHTML.query("#issued-key-secret")
    |> LazyHTML.attribute("value")
    |> hd()
  end
end
