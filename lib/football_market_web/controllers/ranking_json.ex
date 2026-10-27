defmodule FootballMarketWeb.RankingJSON do
  def index(%{result: result}) do
    %{
      configuration: %{
        configuration_version_id: result.configuration.id,
        strategy_id: result.configuration.strategy_id,
        formula_version: result.configuration.formula_version
      },
      data: Enum.map(result.entries, &entry/1)
    }
  end

  defp entry(row) do
    %{
      position: row.position,
      player_id: row.player_id,
      quote_id: row.quote_id,
      unit_price: row.unit_price |> Decimal.round(2) |> Decimal.to_string(:normal),
      effective_at: DateTime.to_iso8601(row.effective_at)
    }
  end
end
