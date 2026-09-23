defmodule FootballMarket.Accounts.ApiKeyPersistenceTest do
  use FootballMarket.DataCase
  use FootballMarket.AccountsCase

  alias FootballMarket.Accounts.ApiKey

  setup do
    {:ok, user} = Accounts.register_user(registration_attrs())
    %{user: user}
  end

  test "requires an existing owner and a 32-byte digest", %{user: user} do
    digest = :crypto.strong_rand_bytes(32)
    assert {:error, _} = Repo.insert(ApiKey.changeset(%ApiKey{}, %{secret_hash: digest}))

    assert {:error, _} =
             Repo.insert(
               ApiKey.changeset(%ApiKey{}, %{user_id: Ecto.UUID.generate(), secret_hash: digest}),
               mode: :savepoint
             )

    assert {:error, _} =
             Repo.insert(ApiKey.changeset(%ApiKey{}, %{user_id: user.id, secret_hash: <<1>>}),
               mode: :savepoint
             )

    assert Repo.aggregate(ApiKey, :count) == 0
  end

  test "stores creation and revocation metadata and enforces digest uniqueness after revocation",
       %{user: user} do
    digest = :crypto.strong_rand_bytes(32)

    assert {:ok, key} =
             Repo.insert(ApiKey.changeset(%ApiKey{}, %{user_id: user.id, secret_hash: digest}))

    assert {:ok, _} = Ecto.UUID.cast(key.id)
    assert key.inserted_at && key.inserted_at.microsecond
    assert key.revoked_at == nil
    assert Repo.get!(ApiKey, key.id).secret_hash == digest

    key |> Ecto.Changeset.change(revoked_at: DateTime.utc_now()) |> Repo.update!()

    assert {:error, _} =
             Repo.insert(ApiKey.changeset(%ApiKey{}, %{user_id: user.id, secret_hash: digest}),
               mode: :savepoint
             )

    assert Repo.aggregate(ApiKey, :count) == 1
  end

  test "schema inspection redacts verification material", %{user: user} do
    digest = :crypto.strong_rand_bytes(32)

    assert {:ok, key} =
             Repo.insert(ApiKey.changeset(%ApiKey{}, %{user_id: user.id, secret_hash: digest}))

    refute inspect(key) =~ "secret_hash"
    refute inspect(key) =~ Base.encode16(digest)
    refute inspect(key) =~ inspect(digest)
  end

  test "issuance fails safely for absent or malformed owner", %{user: user} do
    for owner <- [Ecto.UUID.generate(), "not-a-uuid", nil, 17] do
      assert {:error, :issuance_failed} = Accounts.issue_api_key(owner)
    end

    assert Repo.aggregate(ApiKey, :count) == 0
    assert Repo.get!(User, user.id)
  end

  test "confirmed database rejection leaves no key or secret", %{user: user} do
    install_insert_trigger("RAISE EXCEPTION 'forced insert rejection';")
    assert {:error, :issuance_failed} = Accounts.issue_api_key(user.id)
    assert Repo.aggregate(ApiKey, :count) == 0
  end

  for state <- [:active, :revoked] do
    test "digest collision with #{state} row fails closed", %{user: user} do
      assert {:ok, issued} = Accounts.issue_api_key(user.id)
      key = Repo.get!(ApiKey, issued.id)

      if unquote(state) == :revoked do
        key |> Ecto.Changeset.change(revoked_at: DateTime.utc_now()) |> Repo.update!()
      end

      digest_hex = Base.encode16(key.secret_hash, case: :lower)
      install_insert_trigger("NEW.secret_hash := decode('#{digest_hex}', 'hex'); RETURN NEW;")
      assert {:error, :issuance_failed} = Accounts.issue_api_key(user.id)
      assert Repo.aggregate(ApiKey, :count) == 1
      assert Repo.get!(ApiKey, issued.id).secret_hash == key.secret_hash
    end
  end

  defp install_insert_trigger(body) do
    suffix = System.unique_integer([:positive])
    function_name = "api_key_test_insert_#{suffix}"
    trigger_name = "api_key_test_trigger_#{suffix}"

    Ecto.Adapters.SQL.query!(Repo, """
    CREATE FUNCTION #{function_name}() RETURNS trigger AS $$
    BEGIN
      #{body}
    END;
    $$ LANGUAGE plpgsql
    """)

    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER #{trigger_name}
    BEFORE INSERT ON api_keys
    FOR EACH ROW EXECUTE FUNCTION #{function_name}()
    """)
  end
end
