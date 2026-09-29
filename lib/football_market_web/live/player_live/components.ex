defmodule FootballMarketWeb.PlayerLive.Components do
  @moduledoc "Presentation helpers shared by the player catalog LiveViews."
  use FootballMarketWeb, :html

  @doc "Formats a season as `2026–27`, or a single year for calendar-year seasons."
  def season_label(%{start_year: year, end_year: year}), do: Integer.to_string(year)

  def season_label(%{start_year: start_year, end_year: end_year}) do
    suffix = end_year |> rem(100) |> Integer.to_string() |> String.pad_leading(2, "0")
    "#{start_year}–#{suffix}"
  end

  @doc "Labels a team with its league and season, since team names repeat across seasons."
  def team_label(team) do
    "#{team.name} · #{team.season.league.code} #{season_label(team.season)}"
  end

  attr :position, :map, required: true

  def position_badge(assigns) do
    ~H"""
    <span class="badge badge-soft badge-secondary font-mono" title={@position.name}>
      {@position.code}
    </span>
    """
  end
end
