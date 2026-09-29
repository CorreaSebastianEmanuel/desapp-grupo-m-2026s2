defmodule FootballMarket.Accounts.AccountReadsTest do
  use FootballMarket.DataCase, async: false
  use FootballMarket.AccountsCase

  @moduletag :integration

  describe "get_user/1" do
    test "returns only the public projection" do
      {:ok, user} = Accounts.register_user(registration_attrs())

      assert Accounts.get_user(user.id) == {:ok, %{id: user.id, email: user.email}}
    end

    test "unknown, malformed, and missing IDs are not found" do
      for id <- [Ecto.UUID.generate(), "not-a-uuid", nil, 123] do
        assert Accounts.get_user(id) == {:error, :not_found}
      end
    end
  end

  describe "list_api_keys/1" do
    test "lists only the owner's keys, newest first, without secret material" do
      {:ok, owner} = Accounts.register_user(registration_attrs())
      {:ok, other} = Accounts.register_user(registration_attrs())
      {:ok, first} = Accounts.issue_api_key(owner.id)
      {:ok, second} = Accounts.issue_api_key(owner.id)
      {:ok, _foreign} = Accounts.issue_api_key(other.id)
      :ok = Accounts.revoke_api_key(owner.id, first.id)

      keys = Accounts.list_api_keys(owner.id)

      assert Enum.map(keys, & &1.id) == [second.id, first.id]
      assert Enum.all?(keys, &(Map.keys(&1) |> Enum.sort() == [:id, :inserted_at, :revoked_at]))
      assert [%{revoked_at: nil}, %{revoked_at: %DateTime{}}] = keys
    end

    test "malformed owner IDs list nothing" do
      assert Accounts.list_api_keys("not-a-uuid") == []
      assert Accounts.list_api_keys(nil) == []
    end
  end
end
