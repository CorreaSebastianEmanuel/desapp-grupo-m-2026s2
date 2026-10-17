defmodule FootballMarket.StatisticsIngestion.RuntimeProbe do
  @moduledoc false

  def start(fun) when is_function(fun, 0) do
    {pid, monitor} = Kernel.spawn_monitor(fun)
    %{pid: pid, monitor: monitor}
  end

  def kill!(%{pid: pid}) when is_pid(pid), do: Process.exit(pid, :kill)

  def await_exit!(%{pid: pid, monitor: monitor}, reason, timeout \\ 5000) do
    receive do
      {:DOWN, ^monitor, :process, ^pid, ^reason} -> :ok
    after
      timeout -> raise "statistics runtime probe did not exit within #{timeout}ms"
    end
  end
end
