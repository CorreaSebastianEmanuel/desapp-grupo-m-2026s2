defmodule FootballMarketWeb.APIAuthenticationTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  use FootballMarket.AccountsCase

  import Plug.Conn
  import Plug.Test

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Accounts.Authentication
  alias FootballMarketWeb.APIAuthenticationProbe
  alias FootballMarketWeb.APIAuthenticationProbe.{Router, Validator}
  alias FootballMarketWeb.Plugs.AuthenticateAPI

  @opts Router.init([])
  @failure Jason.encode!(%{error: %{code: "unauthenticated"}})

  setup do
    Process.put({Validator, :owner}, self())
    Process.put({APIAuthenticationProbe, :owner}, self())
    :ok
  end

  test "authenticated actor has the exact trusted shape" do
    assert %AuthenticatedActor{} = actor = actor(:jwt)

    assert Map.from_struct(actor) == %{
             account_id: "account",
             authentication_method: :jwt,
             credential_id: "credential"
           }

    assert Map.keys(Map.from_struct(actor)) |> Enum.sort() == [
             :account_id,
             :authentication_method,
             :credential_id
           ]
  end

  test "one valid Bearer token propagates its exact actor once" do
    Process.put({Validator, :jwt}, {:ok, %{account_id: "account", token_id: "token-id"}})

    conn = request("/api/protected", [{"authorization", "bEaReR exact.token"}])
    assert conn.status == 200
    assert_receive {:validator_called, :jwt, "exact.token"}
    assert_receive {:probe_called, :protected, %{authenticated_actor: actor}}

    assert actor == %AuthenticatedActor{
             account_id: "account",
             authentication_method: :jwt,
             credential_id: "token-id"
           }

    refute_receive {:probe_called, :protected, _}
  end

  test "one active API key propagates its exact actor" do
    Process.put({Validator, :api_key}, {:ok, %{account_id: "account", key_id: "key-id"}})
    secret = String.duplicate("a", 43)

    conn = request("/api/protected", [{"x-api-key", secret}])
    assert conn.status == 200
    assert_receive {:validator_called, :api_key, ^secret}
    assert_receive {:probe_called, :protected, %{authenticated_actor: actor}}

    assert actor == %AuthenticatedActor{
             account_id: "account",
             authentication_method: :api_key,
             credential_id: "key-id"
           }
  end

  test "missing, malformed, invalid, repeated, coalesced, and dual credentials fail identically" do
    cases = [
      [],
      [{"authorization", "Basic abc"}],
      [{"authorization", "Bearer"}],
      [{"authorization", "Bearer a b"}],
      [{"authorization", "Bearer invalid"}],
      [{"authorization", "Bearer a,b"}],
      [{"authorization", "Bearer a"}, {"authorization", "Bearer b"}],
      [{"x-api-key", ""}],
      [{"x-api-key", "unknown"}],
      [{"x-api-key", "a,b"}],
      [{"x-api-key", "a"}, {"x-api-key", "b"}],
      [{"authorization", "Bearer token"}, {"x-api-key", "key"}]
    ]

    Enum.each(cases, fn headers ->
      conn = request("/api/protected", headers)

      assert {conn.status, conn.resp_body, get_resp_header(conn, "www-authenticate")} ==
               {401, @failure, [~s(Bearer realm="api")]}

      refute Map.has_key?(conn.assigns, :authenticated_actor)
      refute_receive {:probe_called, :protected, _}
    end)
  end

  test "validator exceptions and revoked-style failures are generic" do
    Process.put({Validator, :jwt}, fn _ -> raise "private.token.value" end)

    assert request("/api/protected", [{"authorization", "Bearer private.token.value"}]).resp_body ==
             @failure

    Process.put({Validator, :api_key}, {:error, :invalid_key})

    assert request("/api/protected", [{"x-api-key", String.duplicate("z", 43)}]).resp_body ==
             @failure

    refute_receive {:probe_called, :protected, _}
  end

  test "real JWT validation accepts issued tokens and rejects expired tokens" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())
    assert {:ok, token} = Authentication.issue(user.id)
    assert {:ok, %{token_id: token_id}} = Accounts.validate_access_token(token)

    result =
      conn(:get, "/")
      |> put_req_header("authorization", "Bearer " <> token)
      |> AuthenticateAPI.call([])

    assert result.assigns.authenticated_actor == %AuthenticatedActor{
             account_id: user.id,
             authentication_method: :jwt,
             credential_id: token_id
           }

    now = System.system_time(:second)

    expired =
      FootballMarket.AuthenticationHelpers.signed_token(%{
        "sub" => user.id,
        "jti" => Ecto.UUID.generate(),
        "iat" => now - 20,
        "exp" => now - 10,
        "iss" => "football-market-test",
        "aud" => "football-market-test-client"
      })

    rejected =
      conn(:get, "/")
      |> put_req_header("authorization", "Bearer " <> expired)
      |> AuthenticateAPI.call([])

    assert rejected.status == 401
    refute Map.has_key?(rejected.assigns, :authenticated_actor)
  end

  test "real API-key revocation is immediate while a second key remains usable" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())
    assert {:ok, first} = Accounts.issue_api_key(user.id)
    assert {:ok, second} = Accounts.issue_api_key(user.id)
    assert :ok = Accounts.revoke_api_key(user.id, first.id)

    rejected =
      conn(:get, "/")
      |> put_req_header("x-api-key", first.secret)
      |> AuthenticateAPI.call([])

    assert rejected.status == 401

    accepted =
      conn(:get, "/")
      |> put_req_header("x-api-key", second.secret)
      |> AuthenticateAPI.call([])

    assert accepted.assigns.authenticated_actor == %AuthenticatedActor{
             account_id: user.id,
             authentication_method: :api_key,
             credential_id: second.id
           }
  end

  test "public policy ignores all authentication headers" do
    headers = [
      {"authorization", "Bearer invalid"},
      {"x-api-key", "invalid"},
      {"x-api-key", "again"}
    ]

    conn = request("/api/public", headers)
    assert conn.status == 200
    assert_receive {:probe_called, :public, assigns}
    refute Map.has_key?(assigns, :authenticated_actor)
    refute_receive {:validator_called, _, _}
  end

  test "direct non-binary credential input fails closed" do
    conn = %{conn(:get, "/") | req_headers: [{"authorization", :not_text}]}
    result = AuthenticateAPI.call(conn, validator: Validator)
    assert result.status == 401
    assert result.halted
  end

  defp request(path, headers) do
    conn = %{conn(:get, path) | req_headers: headers}
    Router.call(conn, @opts)
  end

  defp actor(method),
    do: %AuthenticatedActor{
      account_id: "account",
      authentication_method: method,
      credential_id: "credential"
    }
end
