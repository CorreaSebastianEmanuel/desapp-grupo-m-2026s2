defmodule FootballMarket.Statistics.Ingestion.CalculationIntent do
  @moduledoc "Durable post-commit request to calculate accepted performance changes."
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_calculation_intents" do
    field :accepted_check_id, :binary_id
    field :changed_performance_ids, {:array, :binary_id}
    field :requested_at, :utc_datetime_usec
    field :state, :string, default: "pending"
    field :attempts, :integer, default: 0
    field :next_attempt_at, :utc_datetime_usec
    field :delivered_at, :utc_datetime_usec
  end
end
