defmodule FootballMarket.Valuation.Configurations do
  @moduledoc "Trusted internal immutable configuration management. Saves never activate."
  alias FootballMarket.Valuation.Configurations.Store
  defdelegate create(rules), to: Store
  defdelegate get(id), to: Store
  defdelegate list(), to: Store
  defdelegate active(), to: Store
  defdelegate activate(target, expected), to: Store
  defdelegate history(), to: Store
end
