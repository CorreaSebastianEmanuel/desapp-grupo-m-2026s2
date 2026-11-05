defmodule FootballMarket.Valuation.CalculationRequest do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "valuation_calculation_requests" do
    field :intent_id, :binary_id
    field :accepted_check_id, :binary_id
    field :changed_performance_ids, {:array, :binary_id}
    field :accepted_at, :utc_datetime_usec
    field :state, :string, default: "requested"
  end
end
