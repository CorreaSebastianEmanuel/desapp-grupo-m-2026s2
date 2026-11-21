defmodule FootballMarket.Valuation.CalculationRequest do
  @moduledoc "Persisted idempotent request triggered by accepted statistics calculation intents."
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "valuation_calculation_requests" do
    field :intent_id, :binary_id
    field :accepted_check_id, :binary_id
    field :changed_performance_ids, {:array, :binary_id}
    field :accepted_at, :utc_datetime_usec
    field :state, :string, default: "requested"
  end
end

defmodule FootballMarket.Valuation.Configurations.Version do
  @moduledoc "Immutable stored valuation strategy version with decoded virtual rules."
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "valuation_configuration_versions" do
    field :strategy_id, :string
    field :formula_version, :string
    field :preset_key, :string, virtual: true
    field :rules, :map
    field :created_at, :utc_datetime_usec, read_after_writes: true
    field :config, :map, virtual: true
    field :references, :map, virtual: true
    field :requirements, :map, virtual: true
    field :position_mapping, {:array, :any}, virtual: true
  end
end

defmodule FootballMarket.Valuation.Configurations.SelectionLock do
  @moduledoc "Singleton row lock coordinating active valuation strategy changes."
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}

  schema "valuation_selection_locks" do
  end
end

defmodule FootballMarket.Valuation.Configurations.SelectionChange do
  @moduledoc "Append-only audit record of active valuation configuration changes."
  use Ecto.Schema

  @primary_key {:change_order, :integer, autogenerate: false, read_after_writes: true}

  schema "valuation_selection_changes" do
    field :previous_version_id, :binary_id
    field :new_version_id, :binary_id
    field :effective_at, :utc_datetime_usec, read_after_writes: true
  end
end
