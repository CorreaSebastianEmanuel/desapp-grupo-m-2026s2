defmodule FootballMarket.Providers.RateLimit do
  @moduledoc "Credential-scoped durable request reservation boundary."

  def reserve(token, interval_ms, max_wait_ms) do
    backend().reserve(key(token), interval_ms, max_wait_ms)
  end

  def block(token, duration_ms) do
    backend().block(key(token), duration_ms)
  end

  defp backend do
    Application.fetch_env!(:football_market, :provider_rate_limit_backend)
  end

  defp key(token), do: :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
end
