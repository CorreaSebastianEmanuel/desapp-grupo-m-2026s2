defmodule FootballMarketWeb.ConditionalOrderJSON do
  @moduledoc false
  def data(order) do
    order
    |> Map.take([
      :id,
      :player_id,
      :quantity,
      :maximum_unit_price,
      :created_at,
      :expires_at,
      :status,
      :expiry_reached,
      :completed_at,
      :rejection_reason,
      :execution
    ])
    |> Map.update!(:maximum_unit_price, &money/1)
    |> Map.update!(:execution, &execution/1)
  end

  defp execution(nil), do: nil

  defp execution(value),
    do: value |> Map.update!(:unit_price, &money/1) |> Map.update!(:total, &money/1)

  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
end
