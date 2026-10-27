defmodule FootballMarketWeb.SaleJSON do
  @moduledoc false

  def data(sale) do
    sale
    |> Map.drop([:transfer, :ledger])
    |> Map.update!(:unit_price, &money/1)
    |> Map.update!(:total, &money/1)
  end

  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
end
