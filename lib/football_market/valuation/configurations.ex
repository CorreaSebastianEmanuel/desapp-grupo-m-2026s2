defmodule FootballMarket.Valuation.Configurations do
  @moduledoc "Trusted internal immutable configuration management. Saves never activate."
  alias FootballMarket.Valuation.Configurations.Store

  def inspect_for(actor) do
    if FootballMarket.Accounts.administrator?(actor) do
      with {:ok, bases} <- Store.ensure_presets(),
           {:ok, data} <- list(),
           do: {:ok, %{data | versions: bases}}
    else
      {:error, :forbidden}
    end
  end

  def activate_for(actor, target, expected) do
    if FootballMarket.Accounts.administrator?(actor) do
      activate_base(target, expected)
    else
      {:error, :forbidden}
    end
  end

  defp activate_base(target, expected) do
    with {:ok, bases} <- Store.ensure_presets() do
      if Enum.any?(bases, &(&1.id == target)),
        do: activate(target, expected),
        else: {:error, :unsupported_configuration}
    end
  end

  defdelegate create(rules), to: Store
  defdelegate get(id), to: Store
  defdelegate list(), to: Store
  defdelegate active(), to: Store
  defdelegate activate(target, expected), to: Store
  defdelegate history(), to: Store
end
