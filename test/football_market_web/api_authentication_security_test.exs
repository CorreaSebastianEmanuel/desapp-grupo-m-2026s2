defmodule FootballMarketWeb.APIAuthenticationSecurityTest do
  use FootballMarket.DataCase, async: false
  use FootballMarket.AccountsCase

  import ExUnit.CaptureLog
  import Plug.Conn
  import Plug.Test

  alias FootballMarketWeb.APIAuthenticationProbe.Validator
  alias FootballMarketWeb.Plugs.AuthenticateAPI

  setup do
    handler = "api-auth-test-#{System.unique_integer([:positive])}"
    parent = self()

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :api, :authentication],
        fn event, measurements, metadata, _ ->
          send(parent, {:telemetry, event, measurements, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler) end)
    :ok
  end

  test "failure response, logs, exception handling, and telemetry disclose no sentinels" do
    sentinel = "private.token.value"
    Process.put({Validator, :jwt}, fn _ -> raise sentinel end)

    log =
      capture_log(fn ->
        conn = conn(:get, "/") |> put_req_header("authorization", "Bearer " <> sentinel)
        result = AuthenticateAPI.call(conn, validator: Validator)
        send(self(), {:result, result})
      end)

    assert_receive {:result, result}
    assert result.status == 401
    refute result.resp_body =~ sentinel
    refute log =~ sentinel
    assert_receive {:telemetry, _, %{duration: duration}, metadata}
    assert is_integer(duration) and duration >= 0

    assert metadata == %{
             route_policy: :protected,
             outcome: :error,
             authentication_method: :jwt
           }

    refute inspect(metadata) =~ sentinel
    refute_receive {:telemetry, _, _, _}
  end

  test "missing and ambiguous decisions use neutral method metadata" do
    for headers <- [[], [{"authorization", "Bearer x"}, {"x-api-key", "y"}]] do
      conn = %{conn(:get, "/") | req_headers: headers}
      AuthenticateAPI.call(conn, validator: Validator)

      assert_receive {:telemetry, _, %{duration: duration},
                      %{route_policy: :protected, outcome: :error, authentication_method: nil}}

      assert duration >= 0
    end
  end

  test "successful actor inspection contains no complete credential" do
    Process.put({Validator, :api_key}, {:ok, %{account_id: "account-id", key_id: "key-id"}})
    secret = String.duplicate("s", 43)

    result =
      conn(:get, "/")
      |> put_req_header("x-api-key", secret)
      |> AuthenticateAPI.call(validator: Validator)

    refute inspect(result.assigns.authenticated_actor) =~ secret
    assert_receive {:telemetry, _, _, %{outcome: :ok, authentication_method: :api_key}}
  end

  test "real API-key lookup keeps the secret and identity out of query logs and telemetry" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())
    assert {:ok, key} = Accounts.issue_api_key(user.id)

    log =
      capture_log(fn ->
        result =
          conn(:get, "/")
          |> put_req_header("x-api-key", key.secret)
          |> AuthenticateAPI.call([])

        assert result.assigns.authenticated_actor.account_id == user.id
      end)

    refute log =~ key.secret
    refute log =~ user.id
    refute log =~ key.id
    assert_receive {:telemetry, _, _, metadata}
    refute inspect(metadata) =~ key.secret
    refute inspect(metadata) =~ user.id
    refute inspect(metadata) =~ key.id
  end
end
