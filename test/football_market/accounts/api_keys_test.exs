defmodule FootballMarket.Accounts.ApiKeysTest do
  use FootballMarket.DataCase
  use FootballMarket.AccountsCase

  alias FootballMarket.Accounts.ApiKey

  setup do
    {:ok, user} = Accounts.register_user(registration_attrs())
    %{user: user}
  end

  test "issues two independent active keys and exposes only one-time result fields", %{user: user} do
    assert {:ok, first} = Accounts.issue_api_key(user.id)
    assert {:ok, second} = Accounts.issue_api_key(user.id)
    assert Map.keys(first) |> Enum.sort() == [:id, :secret]
    assert Map.keys(second) |> Enum.sort() == [:id, :secret]
    assert first.id != second.id
    assert first.secret != second.secret
    assert {:ok, _} = Ecto.UUID.cast(first.id)
    assert {:ok, _} = Ecto.UUID.cast(second.id)

    for issued <- [first, second] do
      assert Regex.match?(~r/\A[A-Za-z0-9_-]{43}\z/, issued.secret)
      assert {:ok, bytes} = Base.url_decode64(issued.secret, padding: false)
      assert byte_size(bytes) == 32
      assert Base.url_encode64(bytes, padding: false) == issued.secret
      key = Repo.get!(ApiKey, issued.id)
      assert key.user_id == user.id
      assert key.revoked_at == nil
      assert key.secret_hash == :crypto.hash(:sha256, issued.secret)
      refute key.secret_hash == issued.secret
    end

    assert Repo.aggregate(ApiKey, :count) == 2
    assert {:ok, projection} = Accounts.get_user_by_email(user.email)
    assert projection == user

    assert Map.keys(User.public_projection(Repo.get!(User, user.id))) |> Enum.sort() == [
             :email,
             :id
           ]
  end

  test "identifies each complete active secret with only account and key identity", %{user: user} do
    assert {:ok, first} = Accounts.issue_api_key(user.id)
    assert {:ok, second} = Accounts.issue_api_key(user.id)

    for issued <- [first, second] do
      assert {:ok, result} = Accounts.identify_api_key(issued.secret)
      assert result == %{account_id: user.id, key_id: issued.id}
      assert Map.keys(result) |> Enum.sort() == [:account_id, :key_id]
    end
  end

  test "rejects identifier-only, changed, malformed, unknown, and revoked secrets equally", %{
    user: user
  } do
    assert {:ok, issued} = Accounts.issue_api_key(user.id)
    replacement = if String.first(issued.secret) == "A", do: "B", else: "A"
    changed = replacement <> String.slice(issued.secret, 1..-1//1)
    unknown = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)

    for candidate <- [
          issued.id,
          changed,
          unknown,
          "",
          "abc",
          "!" <> String.slice(issued.secret, 1..-1//1),
          issued.secret <> "=",
          String.upcase(issued.secret) <> "x",
          nil,
          7,
          %{}
        ] do
      assert {:error, :invalid_key} = Accounts.identify_api_key(candidate)
    end

    key = Repo.get!(ApiKey, issued.id)
    key |> Ecto.Changeset.change(revoked_at: DateTime.utc_now()) |> Repo.update!()
    assert {:error, :invalid_key} = Accounts.identify_api_key(issued.secret)
    assert {:error, :invalid_key} = Accounts.identify_api_key(unknown)
  end

  test "owner revocation affects one key and remains irreversible", %{user: user} do
    assert {:ok, first} = Accounts.issue_api_key(user.id)
    assert {:ok, second} = Accounts.issue_api_key(user.id)
    assert :ok = Accounts.revoke_api_key(user.id, first.id)
    assert {:error, :invalid_key} = Accounts.identify_api_key(first.secret)

    assert {:ok, %{account_id: owner_id, key_id: second_id}} =
             Accounts.identify_api_key(second.secret)

    assert owner_id == user.id
    assert second_id == second.id
    revoked_at = Repo.get!(ApiKey, first.id).revoked_at
    assert revoked_at
    assert :ok = Accounts.revoke_api_key(user.id, first.id)
    assert Repo.get!(ApiKey, first.id).revoked_at == revoked_at
    assert {:error, :invalid_key} = Accounts.identify_api_key(first.secret)
  end

  test "unknown, malformed, and other-owner revocation all fail without a change", %{user: user} do
    {:ok, other} = Accounts.register_user(registration_attrs())
    assert {:ok, issued} = Accounts.issue_api_key(other.id)

    for {owner, key_id} <- [
          {user.id, issued.id},
          {user.id, Ecto.UUID.generate()},
          {user.id, "not-a-uuid"},
          {"not-a-uuid", issued.id},
          {nil, issued.id}
        ] do
      assert {:error, :not_found} = Accounts.revoke_api_key(owner, key_id)
    end

    assert Repo.get!(ApiKey, issued.id).revoked_at == nil
    assert {:ok, %{account_id: owner_id}} = Accounts.identify_api_key(issued.secret)
    assert owner_id == other.id
  end
end
