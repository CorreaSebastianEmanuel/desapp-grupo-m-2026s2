defmodule FootballMarket.Statistics.Freshness.Settings do
  @moduledoc false
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.Catalog
  alias FootballMarket.Synchronization.Input

  def load(player) do
    config = Application.get_env(:football_market, Freshness, [])
    ttl = Keyword.get(config, :ttl_seconds, 86_400)
    cooldown = Keyword.get(config, :cooldown_seconds, 3_600)
    timeout_ms = Keyword.get(config, :request_timeout_ms, 20_000)
    sources = Keyword.get(config, :refresh_options_by_scope, %{})
    season = player.team.season

    scope = %{
      league_code: season.league.code,
      start_year: season.start_year,
      end_year: season.end_year
    }

    key = {scope.league_code, scope.start_year, scope.end_year}

    with true <- is_integer(ttl) and ttl > 0 and is_integer(cooldown) and cooldown > 0,
         true <- is_integer(timeout_ms) and timeout_ms in 1..28_999,
         true <- is_map(sources) do
      case Map.fetch(sources, key) do
        :error -> {:error, {:unconfigured, ttl}}
        {:ok, options} -> resolve(player, scope, options, ttl, cooldown, timeout_ms)
      end
    else
      _ -> {:error, :invalid_configuration}
    end
  rescue
    _ -> {:error, :invalid_configuration}
  end

  defp resolve(player, scope, options, ttl, cooldown, timeout_ms) do
    case Input.normalize(:statistics, scope, options) do
      {:ok, input} ->
        {provider, _} = input.source.provider
        label = provider.provider_label()

        if provider == FootballMarket.Providers.Scraping do
          source_id = Catalog.provider_player_id(player.id, label)

          targeted_options =
            Keyword.merge(options,
              player_id: player.id,
              player_source_id: source_id,
              player_name: player.display_name,
              player_team_name: player.team.name,
              player_position_code: player.position && player.position.code
            )

          scraping_scope = Map.put(scope, :timeout_ms, timeout_ms)

          case Input.normalize(:statistics, scraping_scope, targeted_options) do
            {:ok, targeted_input} ->
              {:ok, %{input: targeted_input, provider: label, ttl: ttl, cooldown: cooldown}}

            _ ->
              {:error, :invalid_configuration}
          end
        else
          {:ok, %{input: input, provider: label, ttl: ttl, cooldown: cooldown}}
        end

      _ ->
        {:error, :invalid_configuration}
    end
  end
end
