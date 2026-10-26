defmodule FootballMarket.Statistics.Freshness do
  @moduledoc "Player detail freshness for complete, accepted provider/league-season checks."
  alias FootballMarket.Statistics.Ingestion.ScopeCheck
  alias FootballMarket.Statistics.Freshness.{Settings, Refresh, ValuationStatus}
  alias FootballMarket.Synchronization.Clock

  def for_player(player) do
    base = base(player)

    case Settings.load(player) do
      {:ok, settings} ->
        configured(player, settings, base)

      {:error, {:unconfigured, ttl}} ->
        %{base | ttl_seconds: ttl}

      {:error, :invalid_configuration} ->
        %{
          base
          | freshness: "unavailable",
            refresh: Refresh.status("unavailable", nil, "invalid_configuration")
        }
    end
  rescue
    _ ->
      %{
        base(player)
        | freshness: "unavailable",
          refresh: Refresh.status("unavailable", nil, "temporarily_unavailable")
      }
  end

  defp configured(player, settings, base) do
    now = Clock.now()
    refresh = Refresh.ensure(player, settings, now)
    row = ScopeCheck.find(settings.provider, player.season_id)
    at = row && row.last_checked_at

    state =
      cond do
        is_nil(at) -> "never_checked"
        Refresh.fresh?(row, settings.ttl, now) -> "fresh"
        true -> "stale"
      end

    %{
      base
      | scope: Map.put(base.scope, :provider, settings.provider),
        source_mode: "fixture",
        last_checked_at: at,
        expires_at: at && DateTime.add(at, settings.ttl, :second),
        ttl_seconds: settings.ttl,
        freshness: state,
        refresh: refresh
    }
  end

  defp base(player) do
    season = player.team.season

    %{
      scope: %{
        player_id: player.id,
        season_id: player.season_id,
        league_code: season.league.code,
        start_year: season.start_year,
        end_year: season.end_year,
        provider: nil,
        coverage: "league_season"
      },
      source_mode: "unconfigured",
      last_checked_at: nil,
      expires_at: nil,
      ttl_seconds: 86_400,
      freshness: "never_checked",
      refresh: Refresh.status("unconfigured"),
      valuation: ValuationStatus.for_player(player)
    }
  end
end
