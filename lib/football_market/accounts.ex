defmodule FootballMarket.Accounts.AuthenticatedActor do
  @moduledoc "Trusted caller identity attached to authenticated HTTP and LiveView requests."
  @enforce_keys [:account_id, :authentication_method, :credential_id]
  defstruct [:account_id, :authentication_method, :credential_id]
end

defmodule FootballMarket.Accounts.User do
  @moduledoc "User account record (`users` table)."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field(:email, :string)
    has_one(:password_credential, FootballMarket.Accounts.PasswordCredential)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> normalize_email()
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "has invalid format")
    |> validate_change(:email, &validate_email_parts/2)
    |> check_constraint(:email, name: :users_email_not_blank)
    |> unique_constraint(:email, name: :users_normalized_email_index)
  end

  def public_projection(%__MODULE__{id: id, email: email}), do: %{id: id, email: email}

  defp normalize_email(changeset) do
    case get_change(changeset, :email) do
      email when is_binary(email) ->
        put_change(changeset, :email, email |> String.trim() |> String.downcase())

      _ ->
        changeset
    end
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
        String.length(label) in 1..63 and
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
  @moduledoc "Argon2 password hash (`password_credentials` table)."
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:user_id, :password_hash]}
  @primary_key {:user_id, :binary_id, autogenerate: false}

  schema "password_credentials" do
    field(:password_hash, :string)
    belongs_to(:user, FootballMarket.Accounts.User, define_field: false)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:user_id, :password_hash])
    |> validate_required([:user_id, :password_hash])
    |> assoc_constraint(:user)
  end

  def validate_password(password) when is_binary(password) do
    cond do
      String.length(password) < 12 -> {:error, "should be at least 12 characters"}
      String.length(password) > 128 -> {:error, "should be at most 128 characters"}
      String.trim(password) == "" -> {:error, "cannot be only whitespace"}
      true -> :ok
    end
  end

  def validate_password(_password), do: {:error, "is invalid"}
  def hash_password(password), do: Argon2.hash_pwd_salt(password, salt_len: 16, hashlen: 32)

  def verify_password(password, password_hash)
      when is_binary(password) and is_binary(password_hash),
      do: Argon2.verify_pass(password, password_hash)

  def verify_password(_password, _password_hash), do: false
end

defmodule FootballMarket.Accounts.ApiKey do
  @moduledoc "Hashed API key (`api_keys` table)."
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
  @moduledoc "Database-backed browser session (`browser_sessions` table)."
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

defmodule FootballMarket.Accounts do
  @moduledoc """
  User accounts, passwords, JWT tokens, API keys, and browser sessions.

  Everything related to identity and authentication lives in this file:
    * `FootballMarket.Accounts` — registration, login, API keys, administrator checks
    * `FootballMarket.Accounts.Authentication` — HS256 JWT signing and verification
    * `FootballMarket.Accounts.BrowserSessions` — revocable browser session handles
    * Ecto schemas (`User`, `PasswordCredential`, `ApiKey`, `BrowserSession`, `AuthenticatedActor`)
  """

  import Ecto.Changeset
  import Ecto.Query

  alias FootballMarket.Accounts.{
    ApiKey,
    AuthenticatedActor,
    Authentication,
    PasswordCredential,
    User
  }

  alias FootballMarket.Repo

  @doc "Returns true when the actor is the single configured primary/admin account."
  def administrator?(%AuthenticatedActor{account_id: account_id}) do
    with [designated] <- Application.get_env(:football_market, :initial_issuance_recipients, []),
         {:ok, id} <- Ecto.UUID.cast(designated),
         {:ok, actor_id} <- Ecto.UUID.cast(account_id),
         true <- id == actor_id do
      Repo.exists?(from u in User, where: u.id == ^id)
    else
      _ -> false
    end
  rescue
    _ in [DBConnection.ConnectionError, Postgrex.Error] -> false
  end

  def administrator?(_), do: false

  @doc "Registers a user and stores their Argon2 password hash atomically."
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
      {:error, :email} ->
        password_error = if is_binary(password), do: nil, else: "is invalid"
        {:error, safe_error_changeset(user_changeset, password_error)}

      {:error, message} ->
        {:error, safe_error_changeset(user_changeset, message)}
    end
  end

  def register_user(_attrs),
    do: {:error, safe_error_changeset(User.changeset(%User{}, %{}), "is invalid")}

  @doc "Checks a plaintext password against a user's stored Argon2 hash."
  def verify_password(user_id, password) do
    case Repo.get(PasswordCredential, user_id) do
      nil -> false
      credential -> PasswordCredential.verify_password(password, credential.password_hash)
    end
  end

  @doc "Looks up a user by normalized email and returns `%{id, email}`."
  def get_user_by_email(email) when is_binary(email) do
    normalized_email = email |> String.trim() |> String.downcase()

    case Repo.get_by(User, email: normalized_email) do
      nil -> {:error, :not_found}
      user -> {:ok, User.public_projection(user)}
    end
  end

  def get_user_by_email(_email), do: {:error, :not_found}

  @doc "Authenticates email/password credentials and returns a short-lived JWT access token."
  def login(credentials) do
    timed_authentication(:login, fn ->
      with {:ok, user} <- verify_browser_credentials(credentials),
           {:ok, token} <- Authentication.issue(user.id) do
        {:ok, %{access_token: token}}
      else
        _ -> {:error, :authentication_failed}
      end
    end)
  end

  @doc "Validates a JWT access token statelessly."
  def validate_access_token(token) do
    timed_authentication(:validation, fn -> Authentication.validate(token) end)
  end

  @doc "Verifies email/password for browser sign-in without minting a JWT."
  def verify_browser_credentials(credentials) when is_map(credentials) do
    if Application.get_env(:football_market, :browser_failure) == :all, do: raise("unavailable")
    email = Map.get(credentials, :email, Map.get(credentials, "email"))
    password = Map.get(credentials, :password, Map.get(credentials, "password"))

    with true <- is_binary(email) and is_binary(password),
         normalized <- email |> String.trim() |> String.downcase(),
         {id, hash} when is_binary(hash) <- credential_for(normalized),
         true <- PasswordCredential.verify_password(password, hash),
         user when not is_nil(user) <- Repo.get(User, id) do
      {:ok, User.public_projection(user)}
    else
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid}

      _ ->
        {:error, :invalid}
    end
  rescue
    _ -> {:error, :unavailable}
  catch
    :exit, _ -> {:error, :unavailable}
  end

  def verify_browser_credentials(_), do: {:error, :invalid}

  @doc "Issues an API key for a user, returning its secret once and storing only its SHA-256 hash."
  def issue_api_key(user_id) do
    case Ecto.UUID.cast(user_id) do
      {:ok, owner_id} -> create_api_key(owner_id)
      :error -> {:error, :issuance_failed}
    end
  end

  defp create_api_key(owner_id) do
    secret = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
    digest = :crypto.hash(:sha256, secret)
    changeset = ApiKey.changeset(%ApiKey{}, %{user_id: owner_id, secret_hash: digest})

    case insert_api_key(changeset) do
      {:ok, key} -> {:ok, %{id: key.id, secret: secret}}
      {:error, _reason} -> {:error, :issuance_failed}
    end
  end

  @doc "Looks up an active (non-revoked) API key from its secret."
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

  @doc "Irreversibly revokes an API key owned by `user_id`."
  def revoke_api_key(user_id, key_id) do
    with {:ok, owner_id} <- Ecto.UUID.cast(user_id),
         {:ok, management_id} <- Ecto.UUID.cast(key_id) do
      owned = from(key in ApiKey, where: key.id == ^management_id and key.user_id == ^owner_id)
      active = from(key in owned, where: is_nil(key.revoked_at))

      case Repo.update_all(active, [set: [revoked_at: DateTime.utc_now()]], log: false) do
        {1, _} -> :ok
        {0, _} -> existing_key_status(owned)
      end
    else
      :error -> {:error, :not_found}
    end
  end

  defp existing_key_status(owned) do
    if Repo.exists?(owned, log: false), do: :ok, else: {:error, :not_found}
  end

  # --- Private Helpers ---

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

  defp insert_api_key(changeset) do
    Repo.insert(changeset, log: false)
  rescue
    _error in Postgrex.Error -> {:error, :database_rejection}
  end

  defp timed_authentication(operation, function) do
    started = System.monotonic_time()
    result = function.()
    outcome = if match?({:ok, _}, result), do: :ok, else: :error

    :telemetry.execute(
      [:football_market, :authentication, operation],
      %{duration: System.monotonic_time() - started},
      %{operation: operation, outcome: outcome}
    )

    result
  end

  defp valid_email(%Ecto.Changeset{valid?: true}), do: :ok
  defp valid_email(_changeset), do: {:error, :email}

  defp register_with_credential(user_changeset, password_hash) do
    Repo.transaction(fn ->
      with {:ok, user} <- Repo.insert(user_changeset),
           {:ok, _cred} <- insert_password_credential(user.id, password_hash) do
        user
      else
        {:error, %Ecto.Changeset{data: %User{}} = cs} -> Repo.rollback({:user, cs})
        {:error, reason} -> Repo.rollback({:credential, reason})
      end
    end)
  rescue
    _error in Postgrex.Error -> {:error, {:credential, :database_failure}}
  end

  defp insert_password_credential(user_id, password_hash) do
    PasswordCredential.changeset(%PasswordCredential{}, %{
      user_id: user_id,
      password_hash: password_hash
    })
    |> Repo.insert()
  end

  defp registration_result({:ok, user}), do: {:ok, User.public_projection(user)}

  defp registration_result({:error, {:user, changeset}}),
    do: {:error, safe_error_changeset(changeset)}

  defp registration_result({:error, _reason}),
    do: {:error, safe_error_changeset(User.changeset(%User{}, %{}), "could not be created")}

  defp safe_error_changeset(user_changeset, password_message \\ nil) do
    safe = %User{} |> change() |> put_change(:email, get_change(user_changeset, :email))

    safe =
      case user_changeset.errors do
        [] -> safe
        errors -> %{safe | valid?: false, errors: errors}
      end

    if password_message, do: add_error(safe, :password, password_message), else: safe
  end
end

defmodule FootballMarket.Accounts.Authentication do
  @moduledoc "HS256 JWT access-token issuer and validator."

  @lifetime_seconds 900
  @required_claims ~w(sub jti iat exp iss aud)

  def lifetime_seconds, do: @lifetime_seconds
  def system_time, do: System.system_time(:second)
  def generate_jti, do: Ecto.UUID.generate()

  def issue(account_id) do
    with {:ok, subject} <- Ecto.UUID.cast(account_id),
         {:ok, config} <- configuration(),
         {:ok, now} <- invoke_integer(config.clock),
         {:ok, jti} <- invoke_uuid(config.jti_provider) do
      claims = %{
        "sub" => subject,
        "jti" => jti,
        "iat" => now,
        "exp" => now + @lifetime_seconds,
        "iss" => config.issuer,
        "aud" => config.audience
      }

      case Joken.generate_and_sign(%{}, claims, config.signer) do
        {:ok, token, _claims} -> {:ok, token}
        _ -> {:error, :issuance_failed}
      end
    else
      _ -> {:error, :issuance_failed}
    end
  rescue
    _ -> {:error, :issuance_failed}
  end

  def validate(token) when is_binary(token) do
    with {:ok, config} <- configuration(),
         {:ok, now} <- invoke_integer(config.clock),
         {:ok, claims} <- Joken.verify(token, config.signer),
         :ok <- validate_claims(claims, config, now) do
      {:ok, %{account_id: claims["sub"], token_id: claims["jti"]}}
    else
      _ -> {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :invalid_token}
  end

  def validate(_token), do: {:error, :invalid_token}

  defp configuration do
    config = Application.get_env(:football_market, __MODULE__, [])

    with issuer when is_binary(issuer) and issuer != "" <- config[:issuer],
         audience when is_binary(audience) and audience != "" <- config[:audience],
         encoded when is_binary(encoded) <- config[:signing_key],
         {:ok, key} when byte_size(key) >= 32 <- Base.decode64(encoded),
         0 <- config[:clock_skew_seconds],
         {clock_mod, clock_fun, clock_args} = clock <- config[:clock],
         true <- is_atom(clock_mod) and is_atom(clock_fun) and is_list(clock_args),
         {jti_mod, jti_fun, jti_args} = jti_provider <- config[:jti_provider],
         true <- is_atom(jti_mod) and is_atom(jti_fun) and is_list(jti_args) do
      {:ok,
       %{
         issuer: issuer,
         audience: audience,
         signer: Joken.Signer.create("HS256", key),
         clock: clock,
         jti_provider: jti_provider
       }}
    else
      _ -> {:error, :invalid_configuration}
    end
  end

  defp invoke_integer({mod, fun, args}) do
    case apply(mod, fun, args) do
      value when is_integer(value) -> {:ok, value}
      _ -> {:error, :invalid_provider}
    end
  end

  defp invoke_uuid({mod, fun, args}) do
    with value when is_binary(value) <- apply(mod, fun, args),
         {:ok, uuid} <- Ecto.UUID.cast(value) do
      {:ok, uuid}
    else
      _ -> {:error, :invalid_provider}
    end
  end

  defp validate_claims(claims, config, now) when is_map(claims) do
    with true <- Enum.all?(@required_claims, &Map.has_key?(claims, &1)),
         true <- claims["iss"] == config.issuer,
         true <- claims["aud"] == config.audience,
         {:ok, _subject} <- Ecto.UUID.cast(claims["sub"]),
         {:ok, _jti} <- Ecto.UUID.cast(claims["jti"]),
         iat when is_integer(iat) <- claims["iat"],
         exp when is_integer(exp) <- claims["exp"],
         true <- iat <= now and exp > now,
         :ok <- validate_not_before(claims, now) do
      :ok
    else
      _ -> {:error, :invalid_claims}
    end
  end

  defp validate_not_before(%{"nbf" => nbf}, now) when is_integer(nbf) and nbf <= now, do: :ok
  defp validate_not_before(%{"nbf" => _nbf}, _now), do: {:error, :invalid_claims}
  defp validate_not_before(_claims, _now), do: :ok
end

defmodule FootballMarket.Accounts.BrowserSessions do
  @moduledoc "Revocable browser sessions. Raw handles live only in encrypted cookies."

  import Ecto.Query
  alias FootballMarket.Accounts.{BrowserSession, User}
  alias FootballMarket.Repo

  def now do
    case Application.get_env(:football_market, :browser_clock) do
      nil -> DateTime.utc_now()
      {module, function, args} -> apply(module, function, args)
    end
  end

  def create_anonymous(time \\ now()), do: safely(fn -> insert(nil, "anonymous", time) end)

  def authenticate(handle, user_id, time \\ now()) do
    case digest(handle) do
      nil -> {:error, :invalid}
      hash -> authenticate_digest(hash, user_id, time)
    end
  end

  defp authenticate_digest(hash, user_id, time) do
    safely(fn -> Repo.transaction(fn -> authenticate_locked(hash, user_id, time) end) end)
  end

  def validate(handle, time \\ now()) do
    safely(fn ->
      case digest(handle) do
        nil -> {:error, :invalid}
        hash -> Repo.get_by(BrowserSession, [token_digest: hash], log: false) |> actor(time)
      end
    end)
  end

  def revalidate(session_id, time \\ now()) do
    safely(fn -> Repo.get(BrowserSession, session_id, log: false) |> actor(time) end)
  end

  def revoke(handle, time \\ now()) do
    result =
      safely(fn ->
        if Application.get_env(:football_market, :browser_failure) == :revoke,
          do: raise("unavailable")

        Repo.transaction(fn -> revoke_locked(handle, time) end)
      end)

    case result do
      {:ok, id} ->
        if id,
          do: Phoenix.PubSub.broadcast(FootballMarket.PubSub, topic(id), :browser_session_ended)

        :ok

      error ->
        error
    end
  end

  def topic(id), do: "browser_session:" <> id

  defp authenticate_locked(hash, user_id, time) do
    row =
      Repo.one(
        from(s in BrowserSession, where: s.token_digest == ^hash, lock: "FOR UPDATE"),
        log: false
      )

    if row == nil or row.state != "anonymous" or
         DateTime.compare(time, row.expires_at) != :lt or Repo.get(User, user_id) == nil do
      Repo.rollback(:invalid)
    end

    Repo.update!(Ecto.Changeset.change(row, state: "revoked", revoked_at: time), log: false)
    {:ok, fresh} = insert(user_id, "authenticated", time)
    fresh
  end

  defp revoke_locked(handle, time) do
    hash = digest(handle)
    row = if hash, do: Repo.get_by(BrowserSession, [token_digest: hash], log: false)

    if row do
      Repo.update!(Ecto.Changeset.change(row, state: "revoked", revoked_at: time), log: false)
      row.id
    end
  end

  defp actor(%BrowserSession{state: "authenticated"} = row, time) do
    if DateTime.compare(time, row.expires_at) != :lt do
      {:error, :expired}
    else
      case Repo.get(User, row.user_id, log: false) do
        nil ->
          {:error, :invalid}

        user ->
          {:ok,
           %{
             session_id: row.id,
             account_id: user.id,
             email: user.email,
             expires_at: row.expires_at
           }}
      end
    end
  end

  defp actor(_, _), do: {:error, :invalid}

  defp insert(user_id, status, time) do
    handle = Base.url_encode64(:crypto.strong_rand_bytes(32), padding: false)
    ttl = Application.get_env(:football_market, :browser_session_ttl_seconds, 900)

    Repo.insert!(
      %BrowserSession{
        token_digest: digest(handle),
        user_id: user_id,
        state: status,
        started_at: time,
        expires_at: DateTime.add(time, ttl, :second)
      },
      log: false
    )

    {:ok, handle}
  end

  defp digest(handle) when is_binary(handle) and byte_size(handle) == 43 do
    if Regex.match?(~r/\A[A-Za-z0-9_-]{43}\z/, handle), do: :crypto.hash(:sha256, handle)
  end

  defp digest(_), do: nil

  defp safely(fun) do
    if Application.get_env(:football_market, :browser_failure) in [:all, :persistence],
      do: raise("unavailable")

    fun.()
  rescue
    _ -> {:error, :unavailable}
  catch
    :exit, _ -> {:error, :unavailable}
  end
end
