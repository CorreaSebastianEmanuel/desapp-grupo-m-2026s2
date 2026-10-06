defmodule FootballMarket.Providers.Adapter do
  @moduledoc "Read-only source port. All portions share Context.deadline_us."
  @callback provider_label() :: String.t()
  @callback read(FootballMarket.Providers.Request.t(), map(), term()) ::
              {:ok, map()} | {:error, map()}
end
