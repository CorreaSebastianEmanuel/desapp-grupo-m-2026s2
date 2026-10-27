defmodule FootballMarket.ConditionalOrders.RuntimeProbe do
  @moduledoc false
  alias FootballMarket.{MarketCase, Repo}
  defdelegate queued(f, calls, table \\ "players"), to: FootballMarket.Purchases.RuntimeProbe
  defdelegate owned_store!(), to: FootballMarket.Purchases.RuntimeProbe
  defdelegate destroy_store!(store), to: FootballMarket.Purchases.RuntimeProbe
  defdelegate await(assertion, timeout \\ 5_000), to: FootballMarket.Purchases.RuntimeProbe

  def start(f, owner, label, fun) do
    Task.async(fn -> MarketCase.in_client(f.schema, fn -> checked(owner, label, fun) end) end)
  end

  defp checked(owner, label, fun) do
    Repo.checkout(fn ->
      send(owner, {label, MarketCase.backend()})
      fun.()
    end)
  end
end
