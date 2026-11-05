defmodule FootballMarket.Statistics.Ingestion.MatchBinding do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_match_bindings" do
    field :provider, :string
    field :kind, :string, default: "match"
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :source_id, :string
    field :match_id, :binary_id
  end
end
