defmodule FootballMarket.OrderEvaluation.RuntimeProbe do
  @moduledoc false
  defdelegate queued(f, calls, table \\ "players"), to: FootballMarket.Purchases.RuntimeProbe
  defdelegate start(f, owner, label, fun), to: FootballMarket.ConditionalOrders.RuntimeProbe
  defdelegate owned_store!(), to: FootballMarket.Quotes.RuntimeProbe
  defdelegate destroy_store!(store), to: FootballMarket.Quotes.RuntimeProbe
  defdelegate await(assertion, timeout \\ 5_000), to: FootballMarket.Quotes.RuntimeProbe
end
