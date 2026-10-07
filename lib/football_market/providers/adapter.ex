defmodule FootballMarket.Providers.Adapter do
  @moduledoc "Read-only source port. All portions share Context.deadline_us."
  @callback provider_label() :: String.t()
  @callback read(FootballMarket.Providers.Request.t(), map(), term()) ::
              {:ok, map()} | {:error, map()}
  @doc "Optional read-only guard captured before source work and checked after final validation."
  @callback publication_guard(FootballMarket.Providers.Request.t(), map(), term()) ::
              (-> :ok | {:error, map()})
  @optional_callbacks publication_guard: 3
end
