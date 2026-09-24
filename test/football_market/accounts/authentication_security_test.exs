defmodule FootballMarket.Accounts.AuthenticationSecurityTest do
  use FootballMarket.DataCase, async: false
  use FootballMarket.AccountsCase

  import ExUnit.CaptureLog
  import FootballMarket.AuthenticationHelpers

  alias FootballMarket.Accounts.{Authentication, PasswordCredential}

  @signing_key_sentinel "signing-key-sentinel-32-bytes-long!!"
  @exception_sentinel "provider-exception-sentinel"

  def raise_clock, do: raise(@exception_sentinel)

  test "all invalid credentials return one generic result without sensitive output" do
    password = "sentinel exact password"

    assert {:ok, user} =
             Accounts.register_user(%{email: "sentinel@example.test", password: password})

    cases = [
      nil,
      %{},
      %{email: nil, password: password},
      %{email: user.email, password: nil},
      %{email: "", password: password},
      %{email: "   ", password: password},
      %{email: "not-an-email", password: password},
      %{email: user.email, password: ""},
      %{email: user.email, password: "   "},
      %{email: "unknown@example.test", password: password},
      %{email: user.email, password: "wrong secure password"}
    ]

    log =
      capture_log(fn ->
        for credentials <- cases do
          assert {:error, :authentication_failed} = Accounts.login(credentials)
        end
      end)

    refute log =~ password
    refute log =~ user.id
  end

  test "configuration failures are safe and fail closed" do
    previous = Application.fetch_env!(:football_market, Authentication)
    Application.put_env(:football_market, Authentication, [])
    on_exit(fn -> Application.put_env(:football_market, Authentication, previous) end)

    assert {:ok, user} = Accounts.register_user(registration_attrs())

    assert {:error, :authentication_failed} =
             Accounts.login(%{email: user.email, password: "a secure password"})

    assert {:error, :invalid_token} = Accounts.validate_access_token("sentinel.token.value")
  end

  test "sensitive sentinels stay out of logs, telemetry, inspection, and safe errors" do
    password = "password-sentinel-exact"
    email = "account-data-sentinel@example.test"
    verified_jti = "11111111-1111-4111-8111-111111111111"
    unverified_account_id = "22222222-2222-4222-8222-222222222222"
    unverified_jti = "33333333-3333-4333-8333-333333333333"
    wrong_key = String.duplicate("unverified-key-sentinel!", 2)
    now = 2_000_000_000

    previous = Application.fetch_env!(:football_market, Authentication)

    configured =
      previous
      |> Keyword.put(:signing_key, Base.encode64(@signing_key_sentinel))
      |> Keyword.put(:clock, {FootballMarket.AuthenticationHelpers, :fixed_time, []})
      |> Keyword.put(
        :jti_provider,
        {FootballMarket.AuthenticationHelpers, :deterministic_jti, []}
      )

    Application.put_env(:football_market, :authentication_test_time, now)
    Application.put_env(:football_market, :authentication_test_jti, verified_jti)
    Application.put_env(:football_market, Authentication, configured)

    on_exit(fn ->
      Application.put_env(:football_market, Authentication, previous)
      Application.delete_env(:football_market, :authentication_test_time)
      Application.delete_env(:football_market, :authentication_test_jti)
    end)

    assert {:ok, user} = Accounts.register_user(%{email: email, password: password})
    credential = Repo.get!(PasswordCredential, user.id)
    password_hash = credential.password_hash
    parent = self()
    handler = "authentication-sentinels-#{System.unique_integer([:positive])}"

    :ok =
      :telemetry.attach_many(
        handler,
        [
          [:football_market, :authentication, :login],
          [:football_market, :authentication, :validation]
        ],
        fn event, measurements, metadata, _ ->
          send(parent, {:sentinel_event, event, measurements, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler) end)

    {results, log} =
      capture_result_and_log(fn ->
        assert {:ok, %{access_token: issued_token}} =
                 success = Accounts.login(%{email: email, password: password})

        assert {:ok, %{account_id: account_id, token_id: ^verified_jti}} =
                 valid = Accounts.validate_access_token(issued_token)

        assert account_id == user.id

        unverified_claims = %{
          "sub" => unverified_account_id,
          "jti" => unverified_jti,
          "iat" => now,
          "exp" => now + 900,
          "iss" => configured[:issuer],
          "aud" => configured[:audience]
        }

        forged_token = signed_token(unverified_claims, "HS256", wrong_key)

        assert {:error, :authentication_failed} =
                 failed_login = Accounts.login(%{email: email, password: password <> "-wrong"})

        assert {:error, :invalid_token} =
                 failed_validation = Accounts.validate_access_token(forged_token)

        {issued_token, forged_token, success, valid, failed_login, failed_validation}
      end)

    {issued_token, forged_token, success, valid, failed_login, failed_validation} = results

    events = receive_events(4)

    outcomes = for {_measurements, metadata} <- events, do: {metadata.operation, metadata.outcome}

    assert Enum.sort(outcomes) ==
             [login: :error, login: :ok, validation: :error, validation: :ok]

    assert Enum.all?(events, fn {measurements, metadata} ->
             Map.keys(measurements) == [:duration] and
               Enum.sort(Map.keys(metadata)) == [:operation, :outcome]
           end)

    assert success == {:ok, %{access_token: issued_token}}
    assert valid == {:ok, %{account_id: user.id, token_id: verified_jti}}

    forbidden = [
      password,
      password_hash,
      email,
      user.id,
      verified_jti,
      @signing_key_sentinel,
      Base.encode64(@signing_key_sentinel),
      issued_token,
      forged_token,
      unverified_account_id,
      unverified_jti
    ]

    for output <- [
          log,
          inspect(events),
          inspect(credential),
          inspect(failed_login),
          inspect(failed_validation),
          inspect(Authentication)
        ],
        sentinel <- forbidden do
      refute output =~ sentinel
    end

    # Successful public projections disclose only the fields promised by their contracts.
    assert inspect(success) =~ issued_token
    refute inspect(success) =~ password
    refute inspect(success) =~ password_hash
    refute inspect(success) =~ email
    refute inspect(success) =~ user.id
    refute inspect(success) =~ verified_jti
    refute inspect(success) =~ @signing_key_sentinel

    assert inspect(valid) =~ user.id
    assert inspect(valid) =~ verified_jti
    refute inspect(valid) =~ password
    refute inspect(valid) =~ password_hash
    refute inspect(valid) =~ email
    refute inspect(valid) =~ issued_token
    refute inspect(valid) =~ @signing_key_sentinel

    refute inspect(credential) =~ "password_hash"
  end

  test "configuration and provider exceptions fail closed without disclosing their values" do
    previous = Application.fetch_env!(:football_market, Authentication)
    invalid_key = "invalid-config-key-sentinel"

    on_exit(fn -> Application.put_env(:football_market, Authentication, previous) end)

    Application.put_env(
      :football_market,
      Authentication,
      Keyword.put(previous, :signing_key, invalid_key)
    )

    {configuration_result, configuration_log} =
      capture_result_and_log(fn -> Authentication.issue(Ecto.UUID.generate()) end)

    assert configuration_result == {:error, :issuance_failed}
    refute inspect(configuration_result) =~ invalid_key
    refute configuration_log =~ invalid_key

    Application.put_env(
      :football_market,
      Authentication,
      previous
      |> Keyword.put(:clock, {__MODULE__, :raise_clock, []})
      |> Keyword.put(:signing_key, Base.encode64(@signing_key_sentinel))
    )

    {exception_result, exception_log} =
      capture_result_and_log(fn -> Authentication.validate("complete-token-sentinel") end)

    assert exception_result == {:error, :invalid_token}
    refute inspect(exception_result) =~ @exception_sentinel
    refute inspect(exception_result) =~ @signing_key_sentinel
    refute exception_log =~ @exception_sentinel
    refute exception_log =~ @signing_key_sentinel
  end

  test "standalone validation performs no repository query" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())

    assert {:ok, %{access_token: token}} =
             Accounts.login(%{email: user.email, password: "a secure password"})

    parent = self()
    handler = "authentication-no-query-#{System.unique_integer([:positive])}"

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :repo, :query],
        fn _, _, _, _ ->
          send(parent, :repository_query)
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler) end)
    assert {:ok, %{account_id: account_id}} = Accounts.validate_access_token(token)
    assert account_id == user.id
    refute_receive :repository_query
  end

  test "telemetry metadata contains only operation and outcome" do
    parent = self()
    handler = "authentication-security-#{System.unique_integer([:positive])}"

    events = [
      [:football_market, :authentication, :login],
      [:football_market, :authentication, :validation]
    ]

    :ok =
      :telemetry.attach_many(
        handler,
        events,
        fn event, measurements, metadata, _ ->
          send(parent, {:event, event, measurements, metadata})
        end,
        nil
      )

    on_exit(fn -> :telemetry.detach(handler) end)

    assert {:error, :authentication_failed} =
             Accounts.login(%{email: "private@example.test", password: "private password"})

    assert {:error, :invalid_token} = Accounts.validate_access_token("private.token.value")

    assert_receive {:event, [:football_market, :authentication, :login], %{duration: duration},
                    %{operation: :login, outcome: :error}}

    assert is_integer(duration)

    assert_receive {:event, [:football_market, :authentication, :validation],
                    %{duration: duration}, %{operation: :validation, outcome: :error}}

    assert is_integer(duration)
  end

  defp capture_result_and_log(function) do
    caller = self()
    reference = make_ref()

    log =
      capture_log([level: :debug], fn ->
        send(caller, {reference, function.()})
      end)

    assert_receive {^reference, result}
    {result, log}
  end

  defp receive_events(count) do
    for _ <- 1..count do
      assert_receive {:sentinel_event, _event, measurements, metadata}
      {measurements, metadata}
    end
  end
end
