defmodule FootballMarket.TestProviderRateLimit do
  @moduledoc false

  def reserve(_key, _interval_ms, _max_wait_ms), do: {:ok, 0}
  def block(_key, _duration_ms), do: :ok
end
