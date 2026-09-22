defmodule FootballMarket.Accounts.PasswordCredential do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Inspect, except: [:password_hash]}
  @primary_key {:user_id, :binary_id, autogenerate: false}

  schema "password_credentials" do
    field(:password_hash, :string)
    belongs_to(:user, FootballMarket.Accounts.User, define_field: false)
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:user_id, :password_hash])
    |> validate_required([:user_id, :password_hash])
    |> assoc_constraint(:user)
  end

  @doc false
  def validate_password(password) when is_binary(password) do
    cond do
      String.length(password) < 12 -> {:error, "should be at least 12 characters"}
      String.length(password) > 128 -> {:error, "should be at most 128 characters"}
      String.trim(password) == "" -> {:error, "cannot be only whitespace"}
      true -> :ok
    end
  end

  def validate_password(_password), do: {:error, "is invalid"}

  @doc false
  def hash_password(password), do: Argon2.hash_pwd_salt(password, salt_len: 16, hashlen: 32)

  @doc false
  def verify_password(password, password_hash)
      when is_binary(password) and is_binary(password_hash),
      do: Argon2.verify_pass(password, password_hash)

  def verify_password(_password, _password_hash), do: false
end
