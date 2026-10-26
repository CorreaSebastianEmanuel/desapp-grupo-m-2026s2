defmodule FootballMarketWeb.QuoteJSON do
  def index(%{quotes: quotes}), do: %{data: Enum.map(quotes, &serialize/1)}
  def show(%{quote: record}), do: %{data: serialize(record)}

  defp serialize(record) do
    %{
      id: record.id,
      player_id: record.player_id,
      unit_price: record.unit_price |> Decimal.round(2) |> Decimal.to_string(:normal),
      effective_at: DateTime.to_iso8601(record.effective_at),
      inserted_at: DateTime.to_iso8601(record.inserted_at),
      rule_id: record.rule_id,
      rule_version: record.rule_version,
      calculation_id: record.calculation_id,
      configuration_version_id: record.configuration_version_id,
      mapping_id: record.mapping_id,
      performance_sequence: record.performance_sequence
    }
  end
end
