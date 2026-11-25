defmodule FootballMarket.AccountsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.BrowserSessions

  test "registers a user, hashes password with Argon2, and enforces unique email" do
    assert {:ok, user} =
             Accounts.register_user(%{
               email: "  Investor@Example.COM ",
               password: "LongSecurePassword123!"
             })

    assert user.email == "investor@example.com"
    assert Accounts.verify_password(user.id, "LongSecurePassword123!")
    refute Accounts.verify_password(user.id, "wrong-password")
    assert {:ok, ^user} = Accounts.get_user_by_email("INVESTOR@example.com")

    assert {:error, cs} =
             Accounts.register_user(%{
               email: "investor@example.com",
               password: "AnotherSecurePassword123!"
             })

    refute cs.valid?

    assert {:error, short_cs} =
             Accounts.register_user(%{email: "short@example.com", password: "short"})

    refute short_cs.valid?
  end

  test "authenticates with password and issues and validates JWT access tokens" do
    user = create_user!()

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: user.password})

    assert {:ok, %{account_id: account_id, token_id: token_id}} =
             Accounts.validate_access_token(token)

    assert account_id == user.id
    assert is_binary(token_id)

    assert {:error, :authentication_failed} =
             Accounts.login(%{email: user.email, password: "wrong-password"})

    assert {:error, :invalid_token} = Accounts.validate_access_token("not.a.jwt")
  end

  test "canonicalizes JWT UUID claims and rejects non-text UUID representations" do
    alias FootballMarket.Accounts.Authentication

    config = Application.fetch_env!(:football_market, Authentication)
    key = Base.decode64!(config[:signing_key])
    signer = Joken.Signer.create("HS256", key)
    now = Authentication.system_time()
    user_id = Ecto.UUID.generate()
    token_id = Ecto.UUID.generate()

    claims = %{
      "sub" => String.upcase(user_id),
      "jti" => String.upcase(token_id),
      "iss" => config[:issuer],
      "aud" => config[:audience],
      "iat" => now,
      "exp" => now + 60
    }

    assert {:ok, token, _} = Joken.generate_and_sign(%{}, claims, signer)

    assert Accounts.validate_access_token(token) ==
             {:ok, %{account_id: user_id, token_id: token_id}}

    for claim <- ["sub", "jti"] do
      invalid_claims = Map.put(claims, claim, "0123456789abcdef")
      assert {:ok, token, _} = Joken.generate_and_sign(%{}, invalid_claims, signer)
      assert Accounts.validate_access_token(token) == {:error, :invalid_token}
    end
  end

  test "issues, identifies, and irreversibly revokes API keys" do
    user = create_user!()
    other = create_user!()

    assert {:ok, %{id: key_id, secret: secret}} = Accounts.issue_api_key(user.id)
    assert {:ok, %{account_id: user_id, key_id: ^key_id}} = Accounts.identify_api_key(secret)
    assert user_id == user.id

    assert {:error, :not_found} = Accounts.revoke_api_key(other.id, key_id)
    assert :ok = Accounts.revoke_api_key(user.id, key_id)
    assert :ok = Accounts.revoke_api_key(user.id, key_id)
    assert {:error, :invalid_key} = Accounts.identify_api_key(secret)
  end

  test "manages revocable browser session lifecycle" do
    user = create_user!()
    {:ok, anon_handle} = BrowserSessions.create_anonymous()
    assert {:error, :invalid} = BrowserSessions.validate(anon_handle)

    assert {:ok, auth_handle} = BrowserSessions.authenticate(anon_handle, user.id)
    assert {:error, :invalid} = BrowserSessions.authenticate(anon_handle, user.id)

    assert {:ok, %{account_id: id, session_id: sid}} = BrowserSessions.validate(auth_handle)
    assert id == user.id
    assert {:ok, %{account_id: ^id}} = BrowserSessions.revalidate(sid)

    assert :ok = BrowserSessions.revoke(auth_handle)
    assert {:error, :invalid} = BrowserSessions.validate(auth_handle)
  end

  test "recognizes only the single configured existing administrator account" do
    admin = create_admin!()
    investor = create_user!()

    assert Accounts.administrator?(actor_for(admin))
    refute Accounts.administrator?(actor_for(investor))
  end
end
