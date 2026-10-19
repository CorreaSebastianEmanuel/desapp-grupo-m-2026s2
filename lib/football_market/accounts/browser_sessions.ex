defmodule FootballMarket.Accounts.BrowserSessions do
  @moduledoc "Revocable browser authority. Raw handles never leave the cookie boundary."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Accounts.{BrowserSession, User}

  def now do
    case Application.get_env(:football_market, :browser_clock) do
      nil -> DateTime.utc_now()
      {module, function, args} -> apply(module, function, args)
    end
  end

  def create_anonymous(time \\ now()), do: safely(fn -> insert(nil, "anonymous", time) end)

  def authenticate(handle, user_id, time \\ now()) do
    safely(fn -> Repo.transaction(fn -> authenticate_locked(handle, user_id, time) end) end)
  end

  defp authenticate_locked(handle, user_id, time) do
    row =
      Repo.one(
        from(s in BrowserSession,
          where: s.token_digest == ^digest(handle),
          lock: "FOR UPDATE"
        ),
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

  def validate(handle, time \\ now()) do
    safely(fn ->
      case digest(handle) do
        nil -> {:error, :invalid}
        hash -> Repo.get_by(BrowserSession, [token_digest: hash], log: false) |> actor(time)
      end
    end)
  end

  # A reference is accepted only from an already authenticated server mount.
  def revalidate(reference, time \\ now()) do
    safely(fn -> Repo.get(BrowserSession, reference, log: false) |> actor(time) end)
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

  defp revoke_locked(handle, time) do
    hash = digest(handle)
    row = if hash, do: Repo.get_by(BrowserSession, [token_digest: hash], log: false)

    if row do
      Repo.update!(Ecto.Changeset.change(row, state: "revoked", revoked_at: time), log: false)
      row.id
    end
  end

  def topic(id), do: "browser_session:" <> id

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

    Repo.insert!(
      %BrowserSession{
        token_digest: digest(handle),
        user_id: user_id,
        state: status,
        started_at: time,
        expires_at: DateTime.add(time, 900, :second)
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
