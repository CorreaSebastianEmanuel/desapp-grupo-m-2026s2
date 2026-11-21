defmodule FootballMarket.Providers do
  @moduledoc """
  Provider-neutral read-only boundary for fetching external football catalogs
  and player match performances.

  Sub-modules under `lib/football_market/providers/`:
    * `contract.ex` & `types.ex` — adapter behaviour, normalized structs, provenance & errors
    * `Request` (`request.ex`) — request normalization and allowed league/position vocabularies
    * `Runtime` (`runtime.ex`) — deadline-enforced cancellable execution & validation runner
    * `Validator` (`validator.ex`), `Catalog` (`catalog.ex`), `Performances` (`performances.ex`)
    * `FootballDataOrg` (`football_data_org.ex`) — optional current-season Football-Data.org adapter
    * `Scraping` (`scraping.ex` + `scraping/`) — assessed FotMob scraping adapter & rate budgets
    * `PlayerIdentity` (`player_identity.ex`) — reviewed player/team alias matching
  """

  alias FootballMarket.Providers.{Error, Request, Runtime}

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
            Runtime.run(request, provider, positions, runtime)
        end
    end
  end
end
