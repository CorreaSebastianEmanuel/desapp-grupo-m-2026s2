defmodule FootballMarket.Providers.Runner do
  @moduledoc "One deadline encompasses callbacks, translation and validation."
  alias FootballMarket.Providers.{Error, Validator}

  def run(request, {adapter, adapter_state}, positions, {runtime, state}) do
    deadline = runtime.now_us(state) + request.timeout_ms * 1000
    context = %{deadline_us: deadline, runtime: {runtime, state}, positions: positions}

    handle =
      runtime.launch(
        fn ->
          with_retry_window(fn record ->
            work(
              request,
              adapter,
              adapter_state,
              Map.put(context, :record_retry_not_before, record)
            )
          end)
        end,
        deadline,
        state
      )

    try do
      case runtime.await(handle, deadline, state) do
        {:ready, {outcome, expiry}, ready} when ready < deadline ->
          refine_retry_delay(outcome, expiry, ready)

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

  defp with_retry_window(work) do
    key = make_ref()

    record = fn
      expiry when is_integer(expiry) ->
        previous = Process.get(key)
        Process.put(key, if(is_integer(previous), do: min(previous, expiry), else: expiry))
        :ok

      _ ->
        :ok
    end

    try do
      outcome = work.(record)
      {outcome, Process.get(key)}
    after
      Process.delete(key)
    end
  end

  defp refine_retry_delay({:error, %Error{category: :rate_limited} = error}, expiry, ready)
       when is_integer(expiry) do
    remaining = div(max(expiry - ready, 0), 1000)
    {:error, %{error | retry_after_ms: if(remaining > 0, do: remaining, else: nil)}}
  end

  defp refine_retry_delay(outcome, _, _), do: outcome

  defp timeout(request, runtime, handle, state) do
    runtime.cancel(handle, state)
    {:error, Error.new(:timeout, request.operation, request.scope)}
  end

  defp work(request, adapter, state, context) do
    try do
      label = adapter.provider_label()

      if FootballMarket.Providers.Provenance.safe_text?(label) do
        case adapter.read(request, Map.put(context, :provider_label, label), state) do
          {:ok, candidate} ->
            Validator.validate(candidate, request, context, label)

          {:error, failure} ->
            error = Error.failure(failure, request)
            {runtime, runtime_state} = context.runtime
            runtime.utc_now(runtime_state)
            {:error, error}

          _ ->
            {:error, Error.new(:invalid_response, request.operation, request.scope)}
        end
      else
        {:error, Error.new(:invalid_response, request.operation, request.scope, :provenance)}
      end
    rescue
      _ -> {:error, Error.new(:unavailable, request.operation, request.scope)}
    catch
      _, _ -> {:error, Error.new(:unavailable, request.operation, request.scope)}
    end
  end
end
