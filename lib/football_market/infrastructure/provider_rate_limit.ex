defmodule FootballMarket.Infrastructure.ProviderRateLimit do
  @moduledoc "PostgreSQL-backed provider request pacing shared across workers and restarts."
  alias Ecto.Adapters.SQL
  alias FootballMarket.Repo

  def reserve(key, interval_ms, max_wait_ms)
      when is_binary(key) and is_integer(interval_ms) and interval_ms > 0 and
             is_integer(max_wait_ms) and max_wait_ms >= 0 do
    Repo.transaction(fn ->
      SQL.query!(
        Repo,
        "INSERT INTO provider_rate_limits (credential_key, next_allowed_at, blocked_until, inserted_at, updated_at) " <>
          "VALUES ($1, clock_timestamp(), NULL, clock_timestamp(), clock_timestamp()) ON CONFLICT (credential_key) DO NOTHING",
        [key]
      )

      %{rows: [[next_allowed, blocked_until]]} =
        SQL.query!(
          Repo,
          "SELECT next_allowed_at, blocked_until FROM provider_rate_limits " <>
            "WHERE credential_key = $1 FOR UPDATE",
          [key]
        )

      # Read the clock only after the row lock is held. Do not bank unused
      # intervals while a credential is idle, and keep provider blocks durable.
      %{rows: [[now]]} = SQL.query!(Repo, "SELECT clock_timestamp()", [])
      eligible_at = max_datetime(max_datetime(next_allowed, blocked_until), now)
      wait_ms = max(NaiveDateTime.diff(eligible_at, now, :millisecond), 0)

      if wait_ms <= max_wait_ms do
        SQL.query!(
          Repo,
          "UPDATE provider_rate_limits SET next_allowed_at = $2, updated_at = clock_timestamp() " <>
            "WHERE credential_key = $1",
          [key, NaiveDateTime.add(eligible_at, interval_ms, :millisecond)]
        )

        {:ok, wait_ms}
      else
        {:defer, wait_ms}
      end
    end)
    |> case do
      {:ok, result} -> result
      {:error, _} -> {:error, :unavailable}
    end
  rescue
    _ -> {:error, :unavailable}
  end

  def block(key, duration_ms)
      when is_binary(key) and is_integer(duration_ms) and duration_ms > 0 do
    Repo.transaction(fn ->
      SQL.query!(
        Repo,
        "INSERT INTO provider_rate_limits (credential_key, next_allowed_at, blocked_until, inserted_at, updated_at) " <>
          "VALUES ($1, clock_timestamp(), clock_timestamp() + ($2 * interval '1 millisecond'), clock_timestamp(), clock_timestamp()) " <>
          "ON CONFLICT (credential_key) DO UPDATE SET blocked_until = GREATEST(" <>
          "COALESCE(provider_rate_limits.blocked_until, '-infinity'::timestamptz), " <>
          "EXCLUDED.blocked_until), updated_at = clock_timestamp()",
        [key, duration_ms]
      )

      :ok
    end)
    |> case do
      {:ok, :ok} -> :ok
      _ -> {:error, :unavailable}
    end
  rescue
    _ -> {:error, :unavailable}
  end

  defp max_datetime(left, nil), do: left
  defp max_datetime(nil, right), do: right

  defp max_datetime(left, right),
    do: if(NaiveDateTime.compare(left, right) == :lt, do: right, else: left)
end
