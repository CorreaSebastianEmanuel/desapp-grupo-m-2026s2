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

  def provision_presets_for(actor) do
    if FootballMarket.Accounts.administrator?(actor),
      do: Store.provision_presets(),
      else: {:error, :forbidden}
  end

  def save_custom_for(actor, base_id, values) do
    if FootballMarket.Accounts.administrator?(actor) do
      with {:ok, %{version: version}} <- get(base_id),
           {:ok, rules} <- FootballMarket.Valuation.Configurations.Editor.rules(version, values),
           do: create(rules)
    else
      {:error, :forbidden}
    end
  end

  defdelegate create(rules), to: Store
  defdelegate get(id), to: Store
  defdelegate list(), to: Store
  defdelegate active(), to: Store
  defdelegate activate(target, expected), to: Store
  defdelegate history(), to: Store
end
