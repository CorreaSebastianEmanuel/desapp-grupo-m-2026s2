defmodule FootballMarket.Market.OrderEvaluationPass do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :integer, autogenerate: false}
  schema "market_order_evaluation_passes" do
    field :state, :string, default: "idle"
    field :generation, :integer, default: 0
    field :cursor_ordinal, :integer, default: 0
    field :rescan_requested, :boolean, default: false
    field :upper_created_at, :utc_datetime_usec
    field :upper_order_id, :binary_id
    field :started_at, :utc_datetime_usec
    field :updated_at, :utc_datetime_usec
  end
end
