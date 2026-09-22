defmodule FootballMarket.Accounts do
  @moduledoc "Internal user registration and password-verification boundary."

  import Ecto.Changeset

  alias Ecto.Multi
  alias FootballMarket.Accounts.{PasswordCredential, User}
  alias FootballMarket.Repo

  @doc "Registers a user and its password credential atomically."
  def register_user(attrs) when is_map(attrs) do
    email = Map.get(attrs, :email, Map.get(attrs, "email"))
    password = Map.get(attrs, :password, Map.get(attrs, "password"))
    user_changeset = User.changeset(%User{}, %{email: email})

    with :ok <- valid_email(user_changeset),
         :ok <- PasswordCredential.validate_password(password) do
      password_hash = PasswordCredential.hash_password(password)

      user_changeset
      |> register_with_credential(password_hash)
      |> registration_result()
    else
      {:error, :email} -> {:error, safe_error_changeset(user_changeset, password)}
      {:error, message} -> {:error, safe_error_changeset(user_changeset, password, message)}
    end
  end

  def register_user(_attrs), do: {:error, safe_error_changeset(User.changeset(%User{}, %{}), nil)}

  @doc "Verifies a candidate password for a user without exposing credential material."
  def verify_password(user_id, password) do
    case Repo.get(PasswordCredential, user_id) do
      nil -> false
      credential -> PasswordCredential.verify_password(password, credential.password_hash)
    end
  end

  @doc "Finds a user by normalized email and returns only its public projection."
  def get_user_by_email(email) when is_binary(email) do
    normalized_email = email |> String.trim() |> String.downcase()

    case Repo.get_by(User, email: normalized_email) do
      nil -> {:error, :not_found}
      user -> {:ok, User.public_projection(user)}
    end
  end

  def get_user_by_email(_email), do: {:error, :not_found}

  defp valid_email(%Ecto.Changeset{valid?: true}), do: :ok
  defp valid_email(_changeset), do: {:error, :email}

  defp register_with_credential(user_changeset, password_hash) do
    Multi.new()
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:credential, fn %{user: user} ->
      PasswordCredential.changeset(%PasswordCredential{}, %{
        user_id: user.id,
        password_hash: password_hash
      })
    end)
    |> Repo.transaction()
  rescue
    _error in Postgrex.Error -> {:error, :credential, :database_failure, %{}}
  end

  defp registration_result({:ok, %{user: user}}), do: {:ok, User.public_projection(user)}

  defp registration_result({:error, :user, changeset, _changes}),
    do: {:error, safe_error_changeset(changeset, nil)}

  defp registration_result({:error, _operation, _reason, _changes}),
    do: {:error, safe_error_changeset(User.changeset(%User{}, %{}), nil, "could not be created")}

  defp safe_error_changeset(user_changeset, password, password_message \\ nil) do
    safe = %User{} |> change() |> put_change(:email, get_change(user_changeset, :email))

    safe =
      case user_changeset.errors do
        [] -> safe
        errors -> %{safe | valid?: false, errors: errors}
      end

    case password_message do
      nil when is_binary(password) -> safe
      nil -> add_error(safe, :password, "is invalid")
      message -> add_error(safe, :password, message)
    end
  end
end
