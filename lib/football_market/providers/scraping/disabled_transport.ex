defmodule FootballMarket.Providers.Scraping.DisabledTransport do
  @moduledoc "Deny-only actual transport. No source contact or configuration bypass."
  @behaviour FootballMarket.Providers.Scraping.Transport
  def fetch(_, _, _), do: {:error, %{category: :unsupported_capability}}
end
