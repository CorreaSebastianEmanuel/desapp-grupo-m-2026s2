defmodule FootballMarket.Providers.Runner do
  @moduledoc "One deadline encompasses callbacks, translation and validation."
  alias FootballMarket.Providers.{Error, Validator}

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

      if FootballMarket.Providers.Provenance.safe_text?(label) do
        guard =
          if function_exported?(adapter, :publication_guard, 3),
            do: adapter.publication_guard(request, context, state),
            else: fn -> :ok end

        case adapter.read(request, Map.put(context, :provider_label, label), state) do
          {:ok, candidate} ->
            case Validator.validate(candidate, request, context, label) do
              {:ok, _} = result ->
                case guard.() do
                  :ok -> result
                  {:error, failure} -> {:error, Error.failure(failure, request)}
                  _ -> {:error, Error.new(:invalid_response, request.operation, request.scope)}
                end

              failure ->
                failure
            end

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
