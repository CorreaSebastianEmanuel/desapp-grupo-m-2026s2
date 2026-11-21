defmodule FootballMarketWeb.ApiJSON do
  @moduledoc "Shared exact-money serialization helpers for JSON endpoints."

  def money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)

  def trade_data(trade) do
    trade
    |> Map.drop([:transfer, :ledger])
    |> Map.update!(:unit_price, &money/1)
    |> Map.update!(:total, &money/1)
  end
end

defmodule FootballMarketWeb.ErrorJSON do
  @moduledoc false

  def render("400.json", %{conn: %{request_path: "/api/purchases"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/sales"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders/" <> _}}),
    do: %{error: %{code: "invalid_request"}}

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end

defmodule FootballMarketWeb.PlayerJSON do
  def index(%{page: %{players: players, pagination: pagination}}) do
    %{data: Enum.map(players, &player/1), pagination: pagination}
  end

  def show(%{player: record, statistics_status: status, statistics: statistics}),
    do: %{data: player(record), statistics_status: status, statistics: statistics}

  defp player(record) do
    %{
      id: record.id,
      display_name: record.display_name,
      catalog_identity: record.catalog_identity,
      position: %{id: record.position.id, code: record.position.code, name: record.position.name},
      team: %{id: record.team.id, short_code: record.team.code, name: record.team.name},
      season: %{
        id: record.team.season.id,
        start_year: record.team.season.start_year,
        end_year: record.team.season.end_year
      },
      league: %{
        id: record.team.season.league.id,
        code: record.team.season.league.code,
        name: record.team.season.league.name
      }
    }
  end
end

defmodule FootballMarketWeb.QuoteJSON do
  alias FootballMarketWeb.ApiJSON

  def index(%{quotes: quotes}), do: %{data: Enum.map(quotes, &serialize/1)}
  def show(%{quote: record}), do: %{data: serialize(record)}

  defp serialize(record) do
    %{
      id: record.id,
      player_id: record.player_id,
      unit_price: ApiJSON.money(record.unit_price),
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

defmodule FootballMarketWeb.RankingJSON do
  alias FootballMarketWeb.ApiJSON

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
      unit_price: ApiJSON.money(row.unit_price),
      effective_at: DateTime.to_iso8601(row.effective_at)
    }
  end
end

defmodule FootballMarketWeb.PortfolioJSON do
  @moduledoc false
  alias FootballMarketWeb.ApiJSON

  def data(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  def data(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def data(%Date{} = value), do: Date.to_iso8601(value)
  def data(value) when is_list(value), do: Enum.map(value, &data/1)

  def data(value) when is_map(value) do
    Map.new(value, fn
      {:unit_price, %Decimal{} = price} -> {:unit_price, ApiJSON.money(price)}
      {key, item} -> {key, data(item)}
    end)
  end

  def data(value), do: value
end

defmodule FootballMarketWeb.PurchaseJSON do
  @moduledoc false
  defdelegate data(purchase), to: FootballMarketWeb.ApiJSON, as: :trade_data
end

defmodule FootballMarketWeb.SaleJSON do
  @moduledoc false
  defdelegate data(sale), to: FootballMarketWeb.ApiJSON, as: :trade_data
end

defmodule FootballMarketWeb.TransactionJSON do
  @moduledoc false
  alias FootballMarketWeb.ApiJSON

  def data(row) do
    row
    |> Map.update!(:unit_price, &ApiJSON.money/1)
    |> Map.update!(:total, &ApiJSON.money/1)
  end
end

defmodule FootballMarketWeb.ConditionalOrderJSON do
  @moduledoc false
  alias FootballMarketWeb.ApiJSON

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
    |> Map.update!(:maximum_unit_price, &ApiJSON.money/1)
    |> Map.update!(:execution, &execution/1)
  end

  defp execution(nil), do: nil

  defp execution(value),
    do:
      value |> Map.update!(:unit_price, &ApiJSON.money/1) |> Map.update!(:total, &ApiJSON.money/1)
end
