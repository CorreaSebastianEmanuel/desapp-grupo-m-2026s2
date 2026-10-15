defmodule FootballMarket.Synchronization.Trigger do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "synchronization_triggers" do
    field :run_id, :binary_id
    field :kind, :string
    field :requested_at, :utc_datetime_usec
    field :occurrence_id, :binary_id
  end
end
