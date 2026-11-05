defmodule FootballMarket.Statistics.Ingestion.PositionBasis do
  use Ecto.Schema
  @primary_key false
  schema "statistics_position_basis" do
    field :performance_id, :binary_id, primary_key: true
    field :prior_performance_id, :binary_id, primary_key: true
    field :position_id, :binary_id
    field :frequency, :integer
  end
end
