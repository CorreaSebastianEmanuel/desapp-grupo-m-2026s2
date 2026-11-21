defmodule FootballMarket.Providers.Runtime do
  @moduledoc "Request-scoped cancellable worker with a caller-monitoring coordinator."
  @max_receive_ms 4_294_967_295

  def now_us(_), do: System.monotonic_time(:microsecond)
  def utc_now(_), do: DateTime.utc_now()

  def launch(fun, deadline, state) do
    owner = self()
    target = :erlang.alias()
    context = Logger.metadata() |> Keyword.take([:correlation_id, :request_id])

    {pid, monitor} =
      spawn_monitor(fn ->
        Logger.metadata(context)
        coordinate(owner, target, fun, deadline, state)
      end)

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
    context = Logger.metadata() |> Keyword.take([:correlation_id, :request_id])

    worker =
      spawn_link(fn ->
        Logger.metadata(context)
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

  # --- Deadline-Enforced Provider Runner ---

  alias FootballMarket.Providers.{Error, Provenance, Validator}

  @doc "Executes one provider adapter read + translation + validation inside a single deadline."
  def run(request, {adapter, adapter_state}, positions, {runtime, state}) do
    deadline = runtime.now_us(state) + request.timeout_ms * 1000
    context = %{deadline_us: deadline, runtime: {runtime, state}, positions: positions}

    handle =
      runtime.launch(fn -> work(request, adapter, adapter_state, context) end, deadline, state)

    try do
      case runtime.await(handle, deadline, state) do
        {:ready, outcome, ready} when ready < deadline ->
          outcome

        {:ready, _, _} ->
          timeout(request, runtime, handle, state)

        :timeout ->
          timeout(request, runtime, handle, state)

        :failed ->
          if runtime.now_us(state) < deadline,
            do: {:error, Error.new(:unavailable, request.operation, request.scope)},
            else: timeout(request, runtime, handle, state)
      end
    after
      runtime.close(handle, state)
    end
  end

  defp timeout(request, runtime, handle, state) do
    runtime.cancel(handle, state)
    {:error, Error.new(:timeout, request.operation, request.scope)}
  end

  defp work(request, adapter, state, context) do
    try do
      label = adapter.provider_label()
      read_provider(request, adapter, state, context, label)
    rescue
      _ -> {:error, Error.new(:unavailable, request.operation, request.scope)}
    catch
      _, _ -> {:error, Error.new(:unavailable, request.operation, request.scope)}
    end
  end

  defp read_provider(request, adapter, state, context, label) do
    if Provenance.safe_text?(label) do
      guard = publication_guard(adapter, request, context, state)

      case adapter.read(request, Map.put(context, :provider_label, label), state) do
        {:ok, candidate} -> validate_candidate(candidate, request, context, label, guard)
        {:error, failure} -> provider_error(failure, request, context)
        _ -> {:error, Error.new(:invalid_response, request.operation, request.scope)}
      end
    else
      {:error, Error.new(:invalid_response, request.operation, request.scope, :provenance)}
    end
  end

  defp validate_candidate(candidate, request, context, label, guard) do
    case Validator.validate(candidate, request, context, label) do
      {:ok, _} = result -> validate_publication(guard, request, result)
      failure -> failure
    end
  end

  defp validate_publication(guard, request, result) do
    case guard.() do
      :ok -> result
      {:error, failure} -> {:error, Error.failure(failure, request)}
      _ -> {:error, Error.new(:invalid_response, request.operation, request.scope)}
    end
  end

  defp provider_error(failure, request, context) do
    error = Error.failure(failure, request)
    {runtime, runtime_state} = context.runtime
    runtime.utc_now(runtime_state)
    {:error, error}
  end

  defp publication_guard(adapter, request, context, state) do
    if function_exported?(adapter, :publication_guard, 3),
      do: adapter.publication_guard(request, context, state),
      else: fn -> :ok end
  end
end
