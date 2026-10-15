defmodule FootballMarket.Synchronization.Schedule do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "synchronization_schedules" do
    field :config_key, :string
    field :generation, :binary_id
    field :enabled, :boolean
    field :enabled_at, :utc_datetime_usec
    field :disabled_at, :utc_datetime_usec
    field :recurrence, :string
    field :definition, :map
  end
end
