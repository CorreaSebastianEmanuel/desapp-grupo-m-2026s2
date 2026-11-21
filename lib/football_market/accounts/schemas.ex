defmodule FootballMarket.Accounts.AuthenticatedActor do
  @moduledoc "Trusted identity established by the API authentication boundary."

  @enforce_keys [:account_id, :authentication_method, :credential_id]
  defstruct [:account_id, :authentication_method, :credential_id]
end

defmodule FootballMarket.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field(:email, :string)
    has_one(:password_credential, FootballMarket.Accounts.PasswordCredential)
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> normalize_email()
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "has invalid format")
    |> validate_domain()
    |> check_constraint(:email, name: :users_email_not_blank)
    |> unique_constraint(:email, name: :users_normalized_email_index)
  end

  @doc false
  def public_projection(%__MODULE__{id: id, email: email}), do: %{id: id, email: email}

  defp normalize_email(changeset) do
    case get_change(changeset, :email) do
      email when is_binary(email) ->
        put_change(changeset, :email, email |> String.trim() |> String.downcase())

      _ ->
        changeset
    end
  end

  defp validate_domain(changeset) do
    validate_change(changeset, :email, &validate_email_parts/2)
  end

  defp validate_email_parts(:email, email) do
    case String.split(email, "@") do
      [local, domain] ->
        if valid_local?(local) and valid_domain?(domain),
          do: [],
          else: [email: "has invalid format"]

      _ ->
        []
    end
  end

  defp valid_domain?(domain) do
    labels = String.split(domain, ".")

    length(labels) >= 2 and
      Enum.all?(labels, fn label ->
        String.length(label) <= 63 and
          String.length(label) > 0 and
          String.match?(label, ~r/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/)
      end)
  end

  defp valid_local?(local) do
    String.length(local) <= 64 and
      not String.starts_with?(local, ".") and
      not String.ends_with?(local, ".") and
      not String.contains?(local, "..") and
      String.match?(local, ~r/^[a-z0-9.!#$%&'*+\/?=?^_`{|}~-]+$/i)
  end
end

defmodule FootballMarket.Accounts.PasswordCredential do
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Inspect, except: [:user_id, :password_hash]}
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

defmodule FootballMarket.Accounts.ApiKey do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @derive {Inspect, except: [:secret_hash]}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "api_keys" do
    belongs_to(:user, FootballMarket.Accounts.User, type: :binary_id)
    field(:secret_hash, :binary)
    field(:revoked_at, :utc_datetime_usec)
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:user_id, :secret_hash])
    |> validate_required([:user_id, :secret_hash])
    |> foreign_key_constraint(:user_id)
    |> check_constraint(:secret_hash, name: :api_keys_secret_hash_32_bytes)
    |> unique_constraint(:secret_hash, name: :api_keys_secret_hash_index)
  end
end

defmodule FootballMarket.Accounts.BrowserSession do
  use Ecto.Schema
  @derive {Inspect, except: [:token_digest]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "browser_sessions" do
    field :token_digest, :binary, redact: true
    field :user_id, :binary_id
    field :state, :string
    field :started_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end
end
