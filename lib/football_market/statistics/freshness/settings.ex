defmodule FootballMarket.Statistics.Freshness.Settings do
  @moduledoc false
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.Synchronization.Input

  def load(player) do
    config = Application.get_env(:football_market, Freshness, [])
    ttl = Keyword.get(config, :ttl_seconds, 86_400)
    cooldown = Keyword.get(config, :cooldown_seconds, 3_600)
    sources = Keyword.get(config, :refresh_options_by_scope, %{})
    season = player.team.season

    scope = %{
      league_code: season.league.code,
      start_year: season.start_year,
      end_year: season.end_year
    }

    key = {scope.league_code, scope.start_year, scope.end_year}

    with true <- is_integer(ttl) and ttl > 0 and is_integer(cooldown) and cooldown > 0,
         true <- is_map(sources) do
      case Map.fetch(sources, key) do
        :error -> {:error, {:unconfigured, ttl}}
        {:ok, options} -> resolve(scope, options, ttl, cooldown)
      end
    else
      _ -> {:error, :invalid_configuration}
    end
  rescue
    _ -> {:error, :invalid_configuration}
  end

  defp resolve(scope, options, ttl, cooldown) do
    case Input.normalize(:statistics, scope, options) do
      {:ok, input} ->
        {provider, _} = input.source.provider
        {:ok, %{input: input, provider: provider.provider_label(), ttl: ttl, cooldown: cooldown}}

      _ ->
        {:error, :invalid_configuration}
    end
  end
end
