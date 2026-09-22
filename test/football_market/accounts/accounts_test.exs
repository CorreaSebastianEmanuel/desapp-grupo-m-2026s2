defmodule FootballMarket.AccountsTest do
  use FootballMarket.DataCase, async: true
  use FootballMarket.AccountsCase

  test "registers one normalized public user with a private verifiable credential" do
    password = "  unchanged password value  "

    assert {:ok, user} =
             Accounts.register_user(%{email: "  PERSON@Example.Test ", password: password})

    assert %{id: id, email: "person@example.test"} = user
    assert Map.keys(user) |> Enum.sort() == [:email, :id]
    assert %{users: 1, credentials: 1} = account_counts()
    assert Accounts.verify_password(id, password)
    refute Accounts.verify_password(id, "a distinct password")
    refute inspect(user) =~ password
  end

  test "returns safe field errors and persists nothing for invalid input" do
    invalid_cases = [
      {%{email: "", password: "a secure password"}, :email},
      {%{email: "person", password: "a secure password"}, :email},
      {%{email: "person@example.test", password: String.duplicate("x", 11)}, :password},
      {%{email: "person@example.test", password: String.duplicate("x", 129)}, :password},
      {%{email: "person@example.test", password: "             "}, :password}
    ]

    for {attrs, field} <- invalid_cases do
      assert {:error, changeset} = Accounts.register_user(attrs)
      assert Keyword.has_key?(changeset.errors, field)
      refute inspect(changeset) =~ attrs.password
      assert %{users: 0, credentials: 0} = account_counts()
    end
  end

  test "rejects normalized-email duplicates while retaining the original credential" do
    password = "a secure password"

    assert {:ok, original} =
             Accounts.register_user(%{email: "person@example.test", password: password})

    for duplicate <- ["person@example.test", "PERSON@EXAMPLE.TEST", "  Person@Example.Test  "] do
      assert {:error, changeset} =
               Accounts.register_user(%{email: duplicate, password: "another secure password"})

      assert Keyword.has_key?(changeset.errors, :email)
    end

    assert %{users: 1, credentials: 1} = account_counts()
    assert Accounts.verify_password(original.id, password)
  end

  test "ordinary lookup returns only the public projection" do
    assert {:ok, registered} =
             Accounts.register_user(registration_attrs(%{email: "lookup@example.test"}))

    assert {:ok, fetched} = Accounts.get_user_by_email(" LOOKUP@EXAMPLE.TEST ")
    assert fetched == registered
  end

  test "rolls back an Accounts registration when its credential write fails" do
    suffix = System.unique_integer([:positive])
    function_name = "fail_password_credential_insert_#{suffix}"
    trigger_name = "force_password_credential_failure_#{suffix}"

    Ecto.Adapters.SQL.query!(Repo, """
    CREATE FUNCTION #{function_name}() RETURNS trigger AS $$
    BEGIN
      RAISE EXCEPTION 'forced credential failure';
    END;
    $$ LANGUAGE plpgsql
    """)

    Ecto.Adapters.SQL.query!(Repo, """
    CREATE TRIGGER #{trigger_name}
    BEFORE INSERT ON password_credentials
    FOR EACH ROW EXECUTE FUNCTION #{function_name}()
    """)

    assert {:error, changeset} = Accounts.register_user(registration_attrs())
    assert Keyword.has_key?(changeset.errors, :password)
    assert %{users: 0, credentials: 0} = account_counts()
  end
end
