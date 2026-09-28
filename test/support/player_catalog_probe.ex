defmodule FootballMarket.PlayerCatalogProbe do
  @moduledoc false

  def attach_query_probe(owner) do
    id = {__MODULE__, make_ref()}

    :telemetry.attach(
      id,
      [:football_market, :repo, :query],
      fn _, _, metadata, pid ->
        send(pid, {:catalog_query, metadata})
      end,
      owner
    )

    ExUnit.Callbacks.on_exit(fn -> :telemetry.detach(id) end)
  end

  def forbidden_call(name), do: raise("forbidden external catalog call: #{name}")
end
