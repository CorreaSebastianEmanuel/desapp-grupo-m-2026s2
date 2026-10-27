defmodule FootballMarket.Market.OrderEvaluationMember do
  @moduledoc false
  use Ecto.Schema
  @primary_key false
  schema "market_order_evaluation_members" do
    field :pass_generation, :integer, primary_key: true
    field :ordinal, :integer, primary_key: true
    field :captured_created_at, :utc_datetime_usec
    field :order_id, :binary_id
  end
end
