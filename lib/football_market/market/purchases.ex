defmodule FootballMarket.Market.Purchases do
  @moduledoc false
  alias FootballMarket.Market.{PurchaseInput, PurchaseStore}

  def purchase(actor, input) do
    with {:ok, canonical} <- PurchaseInput.validate(actor, input),
         do: PurchaseStore.execute(canonical)
  end

  defdelegate get_for_buyer(buyer, id), to: PurchaseStore
end
