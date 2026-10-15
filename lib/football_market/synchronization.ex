defmodule FootballMarket.Synchronization do
  @moduledoc "Trusted local catalog synchronization interface; no public route."
  alias FootballMarket.Synchronization.{Input, Store}
  alias FootballMarket.Providers.Request

  def request_catalog(scope, options \\ []) do
    with true <- Keyword.keyword?(options),
         true <- Keyword.get(options, :trigger, :manual) in [:initial, :manual],
         {:ok, input} <- Input.normalize(scope, options) do
      Store.admit(input)
    else
      {:error, field} -> invalid(field)
      _ -> invalid(:request)
    end
  end

  def configure_schedule(key, definition),
    do: FootballMarket.Synchronization.Scheduler.configure(key, definition)

  def get_run(id), do: Store.get_run(id)

  def list_runs(scope, options \\ []) do
    with {:ok, request} <- Request.normalize(:catalog, scope),
         true <- Keyword.keyword?(options) do
      Store.list_runs(request.scope, options)
    else
      _ -> invalid(:scope)
    end
  end

  defp invalid(field),
    do: {:error, %{category: :invalid_request, field: field, recovery: :correct_request}}
end
