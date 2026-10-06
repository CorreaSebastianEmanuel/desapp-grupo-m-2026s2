defmodule FootballMarket.Providers do
  @moduledoc "Provider-neutral read-only catalog and player-performance boundary."
  alias FootballMarket.Providers.{Error, Request, Runner, Runtime}
  def catalog(request, options \\ []), do: execute(:catalog, request, options)
  def performances(request, options \\ []), do: execute(:performances, request, options)

  defp execute(operation, input, options) do
    case Request.normalize(operation, input) do
      {:error, field, scope} ->
        {:error, Error.new(:invalid_request, operation, scope, field)}

      {:error, field} ->
        {:error, Error.new(:invalid_request, operation, nil, field)}

      {:ok, request} ->
        config = Application.get_env(:football_market, __MODULE__, [])
        provider = Keyword.get(options, :provider, Keyword.get(config, :provider))
        positions = Keyword.get(options, :positions, Keyword.get(config, :positions))
        runtime = Keyword.get(options, :runtime, {Runtime, nil})

        cond do
          is_nil(provider) ->
            {:error, Error.new(:unsupported_capability, operation, request.scope)}

          not Request.vocabulary?(positions) ->
            {:error, Error.new(:invalid_request, operation, request.scope, :positions)}

          true ->
            Runner.run(request, provider, positions, runtime)
        end
    end
  end
end
