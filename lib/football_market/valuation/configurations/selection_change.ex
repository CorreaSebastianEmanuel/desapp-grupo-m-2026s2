defmodule FootballMarket.Valuation.Configurations.SelectionChange do
  use Ecto.Schema
  @primary_key {:change_order, :integer, autogenerate: false, read_after_writes: true}
  schema "valuation_selection_changes" do
    field :previous_version_id, :binary_id
    field :new_version_id, :binary_id
    field :effective_at, :utc_datetime_usec, read_after_writes: true
  end
end
