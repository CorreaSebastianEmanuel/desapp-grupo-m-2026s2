defmodule FootballMarket.Accounts.PasswordCredentialTest do
  use ExUnit.Case, async: true

  alias FootballMarket.Accounts.PasswordCredential

  test "accepts passwords at both length boundaries without changing whitespace" do
    assert :ok = PasswordCredential.validate_password("a" <> String.duplicate("x", 11))
    assert :ok = PasswordCredential.validate_password(String.duplicate("x", 128))
    assert :ok = PasswordCredential.validate_password("  leading and trailing spaces  ")
    assert :ok = PasswordCredential.validate_password("internal  spaces are preserved")
  end

  test "rejects non-binary, short, long, and whitespace-only passwords" do
    for password <- [nil, String.duplicate("x", 11), String.duplicate("x", 129), "            "] do
      assert {:error, _message} = PasswordCredential.validate_password(password)
    end
  end

  test "uses Argon2id verification and redacts credential secrets and ownership from inspection" do
    password = "a secure password"
    hash = PasswordCredential.hash_password(password)

    assert String.starts_with?(hash, "$argon2id$")
    assert PasswordCredential.verify_password(password, hash)
    refute PasswordCredential.verify_password("a distinct secure password", hash)

    credential = %PasswordCredential{user_id: Ecto.UUID.generate(), password_hash: hash}
    inspected = inspect(credential)

    refute inspected =~ credential.user_id
    refute inspected =~ hash
  end
end
