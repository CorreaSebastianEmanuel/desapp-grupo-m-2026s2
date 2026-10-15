defmodule FootballMarket.Synchronization.Occurrence do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "synchronization_occurrences" do
    field :schedule_id, :binary_id
    field :generation, :binary_id
    field :due_at, :utc_datetime_usec
    field :state, :string
    field :run_id, :binary_id
    field :superseded_from, :utc_datetime_usec
    field :superseded_until, :utc_datetime_usec
  end
end
