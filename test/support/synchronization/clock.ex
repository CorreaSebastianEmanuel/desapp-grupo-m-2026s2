defmodule FootballMarket.Synchronization.TestClock do
  @moduledoc false
  def now, do: Process.get(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
  def set(time), do: Process.put(:synchronization_now, time)
end
