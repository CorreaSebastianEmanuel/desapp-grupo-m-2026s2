defmodule FootballMarket.Statistics.Ingestion.FactObservation do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fact_observations" do
    field :provenance_id, :binary_id
    field :check_id, :binary_id
  end
end
