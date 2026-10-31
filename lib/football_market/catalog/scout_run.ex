defmodule FootballMarket.Catalog.ScoutRun do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_scout_runs" do
    field :normalized_name, :string
    field :display_name, :string
    field :state, :string
    field :config_digest, :string
    field :admitted_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
    field :next_attempt_at, :utc_datetime_usec
    field :scope_inputs, :map, default: %{}
    field :synchronization_run_ids, {:array, :binary_id}, default: []
    field :configured_scope_count, :integer
    field :request_count, :integer, default: 0
    field :error_category, :string
    field :job_id, :integer

    timestamps(type: :utc_datetime_usec)
  end
end
