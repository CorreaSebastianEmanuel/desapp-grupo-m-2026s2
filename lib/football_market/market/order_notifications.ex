defmodule FootballMarket.Market.OrderNotifications do
  @moduledoc "Best-effort post-commit reload hints; stored orders remain authoritative."
  alias FootballMarket.{Repo, Market.ConditionalOrder}

  def changed(id) do
    # No hint may escape a caller-owned outer transaction.
    unless Repo.in_transaction?() do
      case Repo.get(ConditionalOrder, id) do
        nil ->
          :ok

        order ->
          Phoenix.PubSub.broadcast(
            FootballMarket.PubSub,
            "conditional_orders:" <> order.owner_id,
            {:conditional_order_changed, order.id}
          )
      end
    end

    :ok
  rescue
    _ -> :ok
  catch
    :exit, _ -> :ok
  end
end
