defmodule FootballMarket.Quotes.Evaluation do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "quote_evaluation_requests" do
    field :quote_id, :binary_id
    field :calculation_id, :binary_id
    field :player_id, :binary_id
    field :idempotency_key, :string
    field :state, :string, default: "pending"
    field :delivery_attempts, :integer, default: 0
    field :lease_fence, :integer, default: 0
    field :lease_started_at, :utc_datetime_usec
    field :lease_until, :utc_datetime_usec
    field :acknowledged_at, :utc_datetime_usec
    field :consumer_receipt, :string
    field :inserted_at, :utc_datetime_usec
  end
end
