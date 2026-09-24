defmodule FootballMarket.Accounts.AuthenticationTest do
  use FootballMarket.DataCase, async: false
  use FootballMarket.AccountsCase

  alias FootballMarket.Accounts.Authentication
  import FootballMarket.AuthenticationHelpers

  setup do
    now = 2_000_000_000
    jti = put_fixed_authentication(now)
    %{now: now, jti: jti}
  end

  test "login normalizes email, preserves exact password, and issues required claims", ctx do
    password = "  exact secure password  "

    assert {:ok, user} =
             Accounts.register_user(%{email: "person@example.test", password: password})

    assert {:error, :authentication_failed} =
             Accounts.login(%{email: "person@example.test", password: String.trim(password)})

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{"email" => " PERSON@EXAMPLE.TEST ", "password" => password})

    assert {:ok, claims} = Joken.peek_claims(token)
    assert claims["sub"] == user.id
    assert claims["jti"] == ctx.jti
    assert claims["iat"] == ctx.now
    assert claims["exp"] == ctx.now + 900
    assert claims["iss"] == "football-market-test"
    assert claims["aud"] == "football-market-test-client"
    assert {:ok, _} = Ecto.UUID.cast(claims["sub"])
    assert {:ok, _} = Ecto.UUID.cast(claims["jti"])
  end

  test "successful logins use fresh production token identifiers" do
    config = Application.fetch_env!(:football_market, Authentication)

    production_providers =
      config
      |> Keyword.put(:clock, {__MODULE__, :fixed_time, []})
      |> Keyword.put(:jti_provider, {Authentication, :generate_jti, []})

    Application.put_env(:football_market, Authentication, production_providers)

    Application.put_env(:football_market, :authentication_test_time, 2_000_000_000)
    on_exit(fn -> Application.put_env(:football_market, Authentication, config) end)

    assert {:ok, _user} =
             Accounts.register_user(registration_attrs(%{email: "unique@example.test"}))

    identifiers =
      for _ <- 1..1_000 do
        assert {:ok, %{access_token: token}} =
                 Accounts.login(%{email: "unique@example.test", password: "a secure password"})

        assert {:ok, claims} = Joken.peek_claims(token)
        claims["jti"]
      end

    assert MapSet.size(MapSet.new(identifiers)) == 1_000
  end

  def fixed_time, do: Application.fetch_env!(:football_market, :authentication_test_time)

  test "validates an issued token to only verified identity", %{jti: jti} do
    assert {:ok, user} = Accounts.register_user(registration_attrs())
    account_id = user.id

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: "a secure password"})

    assert {:ok, %{account_id: ^account_id, token_id: ^jti}} =
             Accounts.validate_access_token(token)
  end

  test "rejects malformed and altered tokens generically" do
    assert {:error, :invalid_token} = Accounts.validate_access_token(nil)
    assert {:error, :invalid_token} = Accounts.validate_access_token(123)
    assert {:error, :invalid_token} = Accounts.validate_access_token("")
    assert {:error, :invalid_token} = Accounts.validate_access_token("not.a.jwt")

    assert {:ok, user} = Accounts.register_user(registration_attrs())

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: "a secure password"})

    assert {:error, :invalid_token} = Accounts.validate_access_token(token <> "altered")
  end

  test "rejects unsigned, wrong-key, and non-HS256 tokens", %{now: now} do
    claims = valid_claims(now)

    unsigned =
      [Jason.encode!(%{"alg" => "none", "typ" => "JWT"}), Jason.encode!(claims), ""]
      |> Enum.map(&Base.url_encode64(&1, padding: false))
      |> Enum.join(".")

    assert {:error, :invalid_token} = Authentication.validate(unsigned)

    assert {:error, :invalid_token} =
             Authentication.validate(sign_with(claims, "HS256", String.duplicate("x", 32)))

    assert {:error, :invalid_token} =
             Authentication.validate(sign_with(claims, "HS512", String.duplicate("y", 64)))
  end

  test "enforces exact expiration, future issuance, and optional not-before", %{now: now} do
    account_id = Ecto.UUID.generate()
    assert {:ok, token} = Authentication.issue(account_id)

    Application.put_env(:football_market, :authentication_test_time, now + 899)
    assert {:ok, %{account_id: ^account_id}} = Authentication.validate(token)

    Application.put_env(:football_market, :authentication_test_time, now + 900)
    assert {:error, :invalid_token} = Authentication.validate(token)

    Application.put_env(:football_market, :authentication_test_time, now - 1)
    assert {:error, :invalid_token} = Authentication.validate(token)
  end

  test "rejects wrong issuer, audience, missing claims, bad UUIDs, noninteger dates, and future nbf",
       %{now: now} do
    account_id = Ecto.UUID.generate()

    valid = %{
      "sub" => account_id,
      "jti" => Ecto.UUID.generate(),
      "iat" => now,
      "exp" => now + 900,
      "iss" => "football-market-test",
      "aud" => "football-market-test-client"
    }

    wrong_or_malformed_claims = [
      Map.put(valid, "iss", "other"),
      Map.put(valid, "aud", "other"),
      Map.put(valid, "sub", "bad"),
      Map.put(valid, "jti", "bad"),
      Map.put(valid, "iat", "#{now}"),
      Map.put(valid, "exp", now),
      Map.put(valid, "nbf", now + 1)
    ]

    for claim <- ~w(sub jti iat exp iss aud) do
      assert {:error, :invalid_token} = Authentication.validate(sign(Map.delete(valid, claim)))
    end

    for claims <- wrong_or_malformed_claims do
      assert {:error, :invalid_token} = Authentication.validate(sign(claims))
    end
  end

  defp sign(claims) do
    config = Application.fetch_env!(:football_market, Authentication)
    {:ok, key} = Base.decode64(config[:signing_key])
    {:ok, token, _} = Joken.generate_and_sign(%{}, claims, Joken.Signer.create("HS256", key))
    token
  end

  defp sign_with(claims, algorithm, key) do
    {:ok, token, _} = Joken.generate_and_sign(%{}, claims, Joken.Signer.create(algorithm, key))
    token
  end

  defp valid_claims(now) do
    %{
      "sub" => Ecto.UUID.generate(),
      "jti" => Ecto.UUID.generate(),
      "iat" => now,
      "exp" => now + 900,
      "iss" => "football-market-test",
      "aud" => "football-market-test-client"
    }
  end
end
