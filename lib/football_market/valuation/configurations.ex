defmodule FootballMarket.Valuation.Configurations do
  @moduledoc "Trusted internal immutable configuration management. Saves never activate."
  alias FootballMarket.Valuation.Configurations.Store

  def inspect_for(actor) do
    if FootballMarket.Accounts.administrator?(actor), do: list(), else: {:error, :forbidden}
  end

  def activate_for(actor, target, expected) do
    if FootballMarket.Accounts.administrator?(actor),
      do: activate(target, expected),
      else: {:error, :forbidden}
  end

  defdelegate create(rules), to: Store
  defdelegate get(id), to: Store
  defdelegate list(), to: Store
  defdelegate active(), to: Store
  defdelegate activate(target, expected), to: Store
  defdelegate history(), to: Store
end
