defmodule FootballMarket.Valuation.ManagedDescriptor do
  @moduledoc "One strategy-independent binding of a saved UUID and existing reproduction evidence."
  defstruct [:configuration_version_id, :evidence, schema_version: 1]
end

defmodule FootballMarket.Valuation.ManagedResult do
  @moduledoc false
  defstruct [
    :configuration_version_id,
    :strategy_id,
    :formula_version,
    :score,
    :prepared,
    :descriptor
  ]
end
