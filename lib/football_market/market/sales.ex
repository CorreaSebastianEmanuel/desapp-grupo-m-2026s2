defmodule FootballMarket.Market.Sales do
  @moduledoc false
  alias FootballMarket.Market.{SaleInput, SaleStore}

  def sale(actor, input) do
    with {:ok, canonical} <- SaleInput.validate(actor, input),
         do: SaleStore.execute(canonical)
  end

  defdelegate get_for_seller(seller, id), to: SaleStore
end
