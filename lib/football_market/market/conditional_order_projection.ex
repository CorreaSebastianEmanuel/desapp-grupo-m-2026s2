defmodule FootballMarket.Market.ConditionalOrderProjection do
  @moduledoc false
  def at(order, now),
    do: Map.put(order, :expiry_reached, DateTime.compare(now, order.expires_at) != :lt)
end
