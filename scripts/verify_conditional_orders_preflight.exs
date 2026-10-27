defmodule ConditionalOrdersPreflight do
  @moduledoc false

  def run do
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:redix)
    config = Application.fetch_env!(:football_market, FootballMarket.Repo)

    database =
      config
      |> Keyword.take([:username, :password, :hostname, :port, :database])
      |> Keyword.merge(
        connect_timeout: 2_000,
        timeout: 2_000,
        backoff_type: :stop,
        show_sensitive_data_on_connection_error: false
      )

    redis = Application.fetch_env!(:football_market, :redis)

    redis =
      redis
      |> Keyword.take([:host, :port, :password])
      |> Enum.reject(fn {_, value} -> is_nil(value) end)
      |> Keyword.merge(sync_connect: true, timeout: 2_000)

    case Postgrex.start_link(database) do
      {:ok, postgres} -> postgres_ready(postgres, redis)
      _ -> fail()
    end
  end

  defp postgres_ready(postgres, redis) do
    try do
      with {:ok, %{rows: [[1]]}} <- Postgrex.query(postgres, "SELECT 1", [], timeout: 2_000),
           {:ok, client} <- Redix.start_link(redis) do
        redis_ready(client)
      else
        _ -> fail()
      end
    after
      GenServer.stop(postgres)
    end
  end

  defp redis_ready(client) do
    try do
      case Redix.command(client, ["PING"], timeout: 2_000) do
        {:ok, "PONG"} ->
          IO.puts("CONDITIONAL_ORDERS_PREFLIGHT_PASS: PostgreSQL SELECT 1; Redis PONG")

        _ ->
          fail()
      end
    after
      GenServer.stop(client)
    end
  end

  defp fail do
    IO.puts(:stderr, "CONDITIONAL_ORDERS_PREFLIGHT_FAIL: configured services unavailable")
    System.halt(1)
  end
end

ConditionalOrdersPreflight.run()
