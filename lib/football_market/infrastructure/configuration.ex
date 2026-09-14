defmodule FootballMarket.Infrastructure.Configuration do
  @moduledoc "Pure parsing and safe diagnostics for local infrastructure."

  @test_prefix "football_market_test"

  def postgres(env \\ System.get_env(), mode \\ :dev) do
    suffix = if mode == :test, do: Map.get(env, "MIX_TEST_PARTITION", ""), else: ""
    default_db = if mode == :test, do: @test_prefix <> suffix, else: "football_market_dev"

    %{
      username: Map.get(env, "POSTGRES_USER", "postgres"),
      password: Map.get(env, "POSTGRES_PASSWORD", "postgres"),
      hostname: Map.get(env, "POSTGRES_HOST", "127.0.0.1"),
      port: port!(Map.get(env, "POSTGRES_PORT", "5432"), "PostgreSQL"),
      database:
        Map.get(env, if(mode == :test, do: "TEST_DATABASE_NAME", else: "POSTGRES_DB"), default_db)
    }
  end

  def redis(env \\ System.get_env()) do
    %{
      host: Map.get(env, "REDIS_HOST", "127.0.0.1"),
      port: port!(Map.get(env, "REDIS_PORT", "6379"), "Redis"),
      password: blank_to_nil(Map.get(env, "REDIS_PASSWORD"))
    }
  end

  def validate_test_database!(
        test_db,
        dev_db,
        partition \\ System.get_env("MIX_TEST_PARTITION") || ""
      ) do
    expected = @test_prefix <> partition

    if test_db != expected or test_db == dev_db do
      raise ArgumentError, "unsafe test database identity (expected #{expected})"
    end

    :ok
  end

  def safe_target(:postgresql, c), do: "postgresql://#{c.hostname}:#{c.port}/#{c.database}"
  def safe_target(:redis, c), do: "redis://#{c.host}:#{c.port}"

  def sanitize(message, secrets) do
    Enum.reduce(secrets, to_string(message), fn
      secret, acc when is_binary(secret) and secret != "" ->
        String.replace(acc, secret, "[REDACTED]")

      _, acc ->
        acc
    end)
    |> String.replace(~r{//[^/@\s:]+:[^/@\s]+@}, "//[REDACTED]@")
  end

  defp port!(value, dependency) do
    case Integer.parse(to_string(value)) do
      {port, ""} when port in 1..65_535 -> port
      _ -> raise ArgumentError, "invalid #{dependency} configuration: port"
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
