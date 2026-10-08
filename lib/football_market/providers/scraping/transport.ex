defmodule FootballMarket.Providers.Scraping.Transport do
  @moduledoc "Synchronous source-document port. Implementations inherit the Runner deadline."
  @callback fetch(String.t(), map(), map()) :: {:ok, map()} | {:error, map()}
end
