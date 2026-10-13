defmodule FootballMarket.Valuation.PositionGroups do
  alias FootballMarket.Valuation.Error

  def assign(rows, mapping) do
    mapping = Map.new(mapping)

    Enum.reduce_while(rows, {:ok, []}, fn row, {:ok, acc} ->
      case Map.fetch(mapping, row.position_id) do
        {:ok, group} -> {:cont, {:ok, [%{row | group: group} | acc]}}
        :error -> {:halt, Error.new(:validation, :missing_position_mapping, [row.position_id])}
      end
    end)
    |> case do
      {:ok, rows} -> {:ok, Enum.reverse(rows)}
      error -> error
    end
  end
end
