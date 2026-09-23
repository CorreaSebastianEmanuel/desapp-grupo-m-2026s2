defmodule FootballMarket.Accounts.ApiKeySecurityTest do
  use FootballMarket.DataCase
  use FootballMarket.AccountsCase

  import ExUnit.CaptureLog

  alias FootballMarket.Accounts.ApiKey

  setup do
    {:ok, user} = Accounts.register_user(registration_attrs())
    %{user: user}
  end

  test "ordinary projections, inspection, errors, and logs omit credentials", %{user: user} do
    log =
      capture_log([level: :debug], fn ->
        send(self(), {:issue_result, Accounts.issue_api_key(user.id)})
      end)

    assert_receive {:issue_result, {:ok, issued}}
    key = Repo.get!(ApiKey, issued.id)
    digest = key.secret_hash

    assert {:ok, fetched} = Accounts.get_user_by_email(user.email)
    assert Map.keys(fetched) |> Enum.sort() == [:email, :id]
    assert {:error, :issuance_failed} = Accounts.issue_api_key(Ecto.UUID.generate())

    for value <- [fetched, key, {:error, :issuance_failed}, log] do
      output = inspect(value)
      refute output =~ issued.secret
      refute output =~ inspect(digest)
      refute output =~ Base.encode16(digest)
    end

    refute log =~ issued.secret
    refute log =~ Base.encode16(digest)
    refute log =~ "secret_hash"
    refute inspect(key) =~ "secret_hash"
  end

  test "configured metrics and registered routes carry no key credential surface" do
    for metric <- FootballMarketWeb.Telemetry.metrics() do
      assert Map.get(metric, :tags, []) -- [:route, :event] == []
    end

    routes = Phoenix.Router.routes(FootballMarketWeb.Router)

    refute Enum.any?(routes, fn route ->
             String.contains?(route.path, "key") or
               String.contains?(route.path, "credential")
           end)
  end

  test "identification results and application logs disclose no verification material", %{
    user: user
  } do
    assert {:ok, issued} = Accounts.issue_api_key(user.id)
    digest = Repo.get!(ApiKey, issued.id).secret_hash
    unknown = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    log =
      capture_log([level: :debug], fn ->
        send(self(), {:identified, Accounts.identify_api_key(issued.secret)})
        send(self(), {:invalid, Accounts.identify_api_key(unknown)})
        assert :ok = Accounts.revoke_api_key(user.id, issued.id)
        send(self(), {:revoked, Accounts.identify_api_key(issued.secret)})
      end)

    assert_receive {:identified, {:ok, %{account_id: _, key_id: _} = identity}}
    assert_receive {:invalid, {:error, :invalid_key} = invalid}
    assert_receive {:revoked, ^invalid}

    for output <- [inspect(identity), inspect(invalid), log] do
      refute output =~ issued.secret
      refute output =~ Base.encode16(digest)
      refute output =~ inspect(digest)
    end

    refute log =~ "secret_hash"
  end

  test "revocation output and logs reveal neither credentials nor other-owner existence", %{
    user: user
  } do
    {:ok, other} = Accounts.register_user(registration_attrs())
    assert {:ok, issued} = Accounts.issue_api_key(other.id)
    digest = Repo.get!(ApiKey, issued.id).secret_hash

    log =
      capture_log([level: :debug], fn ->
        send(self(), {:other, Accounts.revoke_api_key(user.id, issued.id)})
        send(self(), {:unknown, Accounts.revoke_api_key(user.id, Ecto.UUID.generate())})
        send(self(), {:owned, Accounts.revoke_api_key(other.id, issued.id)})
      end)

    assert_receive {:other, {:error, :not_found}}
    assert_receive {:unknown, {:error, :not_found}}
    assert_receive {:owned, :ok}

    for output <- [log, inspect({:error, :not_found}), inspect(:ok)] do
      refute output =~ issued.secret
      refute output =~ Base.encode16(digest)
      refute output =~ inspect(digest)
    end

    refute log =~ "secret_hash"

    refute Enum.any?(Phoenix.Router.routes(FootballMarketWeb.Router), fn route ->
             String.contains?(route.path, "key")
           end)
  end
end
