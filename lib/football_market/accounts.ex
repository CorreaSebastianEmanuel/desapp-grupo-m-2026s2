defmodule FootballMarket.Accounts do
  @moduledoc "Internal account and credential boundary."

  import Ecto.Changeset
  import Ecto.Query

  alias Ecto.Multi
  alias FootballMarket.Accounts.{ApiKey, Authentication, PasswordCredential, User}
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

  @doc "Authenticates credentials and issues one short-lived access token."
  def login(credentials) do
    timed_authentication(:login, fn -> authenticate(credentials) end)
  end

  @doc "Validates a JWT access token without consulting persistence."
  def validate_access_token(token) do
    timed_authentication(:validation, fn -> Authentication.validate(token) end)
  end

  defp authenticate(credentials) when is_map(credentials) do
    email = Map.get(credentials, :email, Map.get(credentials, "email"))
    password = Map.get(credentials, :password, Map.get(credentials, "password"))

    with true <- is_binary(email) and is_binary(password),
         normalized_email <- email |> String.trim() |> String.downcase(),
         {user_id, password_hash} when is_binary(password_hash) <-
           credential_for(normalized_email),
         true <- PasswordCredential.verify_password(password, password_hash),
         {:ok, token} <- Authentication.issue(user_id) do
      {:ok, %{access_token: token}}
    else
      nil ->
        Argon2.no_user_verify()
        {:error, :authentication_failed}

      _ ->
        {:error, :authentication_failed}
    end
  rescue
    _ -> {:error, :authentication_failed}
  end

  defp authenticate(_credentials), do: {:error, :authentication_failed}

  defp credential_for(normalized_email) do
    Repo.one(
      from(user in User,
        join: credential in PasswordCredential,
        on: credential.user_id == user.id,
        where: user.email == ^normalized_email,
        select: {user.id, credential.password_hash}
      ),
      log: false
    )
  end

  defp timed_authentication(operation, function) do
    started = System.monotonic_time()
    result = function.()
    outcome = if match?({:ok, _}, result), do: :ok, else: :error

    :telemetry.execute(
      [:football_market, :authentication, telemetry_event(operation)],
      %{duration: System.monotonic_time() - started},
      %{operation: operation, outcome: outcome}
    )

    result
  end

  defp telemetry_event(:login), do: :login
  defp telemetry_event(:validation), do: :validation

  @doc "Issues a new API key for a trusted account ID, disclosing its secret once."
  def issue_api_key(user_id) do
    with {:ok, owner_id} <- Ecto.UUID.cast(user_id) do
      secret = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
      digest = :crypto.hash(:sha256, secret)

      changeset = ApiKey.changeset(%ApiKey{}, %{user_id: owner_id, secret_hash: digest})

      case insert_api_key(changeset) do
        {:ok, key} -> {:ok, %{id: key.id, secret: secret}}
        {:error, _reason} -> {:error, :issuance_failed}
      end
    else
      :error -> {:error, :issuance_failed}
    end
  end

  defp insert_api_key(changeset) do
    Repo.insert(changeset, mode: :savepoint, log: false)
  rescue
    _error in Postgrex.Error -> {:error, :database_rejection}
  end

  @doc "Identifies an active key from its complete canonical secret."
  def identify_api_key(secret) when is_binary(secret) do
    with true <- byte_size(secret) == 43 and String.valid?(secret),
         true <- String.match?(secret, ~r/\A[A-Za-z0-9_-]{43}\z/),
         {:ok, bytes} <- Base.url_decode64(secret, padding: false),
         true <- byte_size(bytes) == 32,
         true <- Base.url_encode64(bytes, padding: false) == secret do
      digest = :crypto.hash(:sha256, secret)

      case Repo.one(
             from(key in ApiKey,
               where: key.secret_hash == ^digest and is_nil(key.revoked_at),
               select: {key.user_id, key.id}
             ),
             log: false
           ) do
        {user_id, key_id} -> {:ok, %{account_id: user_id, key_id: key_id}}
        nil -> {:error, :invalid_key}
      end
    else
      _ -> {:error, :invalid_key}
    end
  end

  def identify_api_key(_secret), do: {:error, :invalid_key}

  @doc "Irreversibly revokes an owned key by its management ID."
  def revoke_api_key(user_id, key_id) do
    with {:ok, owner_id} <- Ecto.UUID.cast(user_id),
         {:ok, management_id} <- Ecto.UUID.cast(key_id) do
      owned =
        from(key in ApiKey,
          where: key.id == ^management_id and key.user_id == ^owner_id
        )

      active = from(key in owned, where: is_nil(key.revoked_at))

      case Repo.update_all(active, [set: [revoked_at: DateTime.utc_now()]], log: false) do
        {1, _} ->
          :ok

        {0, _} ->
          if Repo.exists?(owned, log: false), do: :ok, else: {:error, :not_found}
      end
    else
      :error -> {:error, :not_found}
    end
  end

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
