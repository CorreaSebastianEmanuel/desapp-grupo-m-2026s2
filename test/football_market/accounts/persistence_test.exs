defmodule FootballMarket.Accounts.PersistenceTest do
  use FootballMarket.DataCase, async: true
  use FootballMarket.AccountsCase

  test "uses UUID user identity and a one-to-one credential relationship" do
    assert {:ok, user} = Accounts.register_user(registration_attrs())
    assert {:ok, uuid} = Ecto.UUID.cast(user.id)
    assert uuid == user.id
    assert %{users: 1, credentials: 1} = account_counts()
  end

  test "creates the named normalized-email functional index" do
    %{rows: [[definition]]} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT indexdef FROM pg_indexes WHERE indexname = 'users_normalized_email_index'"
      )

    assert definition =~ "lower(btrim(email))"
  end

  test "database conflict rather than a lookup decides normalized-email uniqueness" do
    assert {:ok, _user} =
             Accounts.register_user(registration_attrs(%{email: "race@example.test"}))

    assert {:error, changeset} =
             Accounts.register_user(registration_attrs(%{email: " RACE@EXAMPLE.TEST "}))

    assert Keyword.has_key?(changeset.errors, :email)
    assert %{users: 1, credentials: 1} = account_counts()
  end

  test "rolls back the user when a credential write fails through Accounts" do
    Ecto.Adapters.SQL.query!(Repo, """
    CREATE FUNCTION fail_password_credential_insert() RETURNS trigger AS $$
    BEGIN
      RAISE EXCEPTION 'forced credential failure';
    END;
    $$ LANGUAGE plpgsql
    """)

    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER force_password_credential_failure
    BEFORE INSERT ON password_credentials
    FOR EACH ROW EXECUTE FUNCTION fail_password_credential_insert()
    """)

    assert {:error, changeset} = Accounts.register_user(registration_attrs())
    assert Keyword.has_key?(changeset.errors, :password)
    assert %{users: 0, credentials: 0} = account_counts()
  end
end
