defmodule FootballMarket.Market.ConditionalOrder do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_conditional_buy_orders" do
    field :owner_id, :binary_id
    field :player_id, :binary_id
    field :quantity, :integer
    field :maximum_unit_price, :decimal
    field :created_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :status, :string, default: "pending"
    field :completed_at, :utc_datetime_usec
    field :rejection_reason, :string
    field :purchase_id, :binary_id
  end
end
