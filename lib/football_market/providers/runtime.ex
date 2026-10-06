defmodule FootballMarket.Providers.Runtime do
  @moduledoc "Request-scoped cancellable worker with a caller-monitoring coordinator."
  @max_receive_ms 4_294_967_295

  def now_us(_), do: System.monotonic_time(:microsecond)
  def utc_now(_), do: DateTime.utc_now()

  def launch(fun, deadline, state) do
    owner = self()
    target = :erlang.alias()
    {pid, monitor} = spawn_monitor(fn -> coordinate(owner, target, fun, deadline, state) end)
    %{pid: pid, monitor: monitor, target: target}
  end

  def await(handle, deadline, state) do
    receive do
      {:provider_ready, target, outcome, ready} when target == handle.target ->
        {:ready, outcome, ready}

      {:provider_timeout, target} when target == handle.target ->
        :timeout

      {:DOWN, monitor, :process, _, _} when monitor == handle.monitor ->
        :failed
    after
      wait_ms(deadline, state) ->
        if now_us(state) < deadline, do: await(handle, deadline, state), else: :timeout
    end
  end

  def cancel(handle, _), do: send(handle.pid, :cancel)

  def close(handle, _) do
    :erlang.unalias(handle.target)
    Process.demonitor(handle.monitor, [:flush])
    send(handle.pid, :cancel)
    # Remove only this correlation's already-delivered messages.
    drain(handle.target)
    :ok
  end

  defp drain(target) do
    receive do
      {:provider_ready, ^target, _, _} -> drain(target)
      {:provider_timeout, ^target} -> drain(target)
    after
      0 -> :ok
    end
  end

  defp stop(worker) do
    Process.unlink(worker)
    Process.exit(worker, :kill)
  end

  defp coordinate(owner, target, fun, deadline, state) do
    caller_monitor = Process.monitor(owner)
    coordinator = self()

    worker =
      spawn_link(fn ->
        outcome = fun.()
        send(coordinator, {:ready, outcome, now_us(state)})
      end)

    coordinate_wait(owner, target, worker, caller_monitor, deadline, state)
    Process.demonitor(caller_monitor, [:flush])
    :ok
  end

  defp coordinate_wait(owner, target, worker, caller_monitor, deadline, state) do
    receive do
      {:ready, outcome, ready} ->
        send(target, {:provider_ready, target, outcome, ready})
        stop(worker)

      {:DOWN, ^caller_monitor, :process, ^owner, _} ->
        stop(worker)

      :cancel ->
        stop(worker)
    after
      wait_ms(deadline, state) ->
        if now_us(state) < deadline do
          coordinate_wait(owner, target, worker, caller_monitor, deadline, state)
        else
          stop(worker)
          send(target, {:provider_timeout, target})
        end
    end
  end

  # A VM-sized wait is only a slice of the original absolute budget.
  defp wait_ms(deadline, state) do
    remaining = max(0, deadline - now_us(state))
    min(div(remaining + 999, 1000), @max_receive_ms)
  end
end
