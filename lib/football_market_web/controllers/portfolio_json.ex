defmodule FootballMarketWeb.PortfolioJSON do
  @moduledoc false

  def data(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  def data(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def data(%Date{} = value), do: Date.to_iso8601(value)
  def data(value) when is_list(value), do: Enum.map(value, &data/1)

  def data(value) when is_map(value) do
    Map.new(value, fn
      {:unit_price, %Decimal{} = price} ->
        {:unit_price, price |> Decimal.round(2) |> Decimal.to_string(:normal)}

      {key, item} ->
        {key, data(item)}
    end)
  end

  def data(value), do: value
end
