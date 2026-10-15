defmodule FootballMarket.Synchronization.Attempt do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "synchronization_attempts" do
    field :run_id, :binary_id
    field :number, :integer
    field :delivery_id, :binary_id
    field :started_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
    field :status, :string
    field :outcome, :map
    field :next_retry_at, :utc_datetime_usec
  end
end
