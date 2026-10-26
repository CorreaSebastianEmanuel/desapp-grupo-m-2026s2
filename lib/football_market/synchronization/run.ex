defmodule FootballMarket.Synchronization.Run do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "synchronization_runs" do
    field :operation, :string, default: "catalog"
    field :correlation_id, :string
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :source_ref, :string
    field :fixture_ref, :string
    field :input, :map
    field :input_digest, :string
    field :policy, :map
    field :original_trigger, :string
    field :state, :string
    field :requested_at, :utc_datetime_usec
    field :started_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
    field :next_retry_at, :utc_datetime_usec
    field :outcome, :map
    field :reason, :string
    field :recovery, :string
    field :delivery_id, :binary_id
    field :job_id, :integer
  end
end
