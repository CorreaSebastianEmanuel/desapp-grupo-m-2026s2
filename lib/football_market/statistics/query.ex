defmodule FootballMarket.Statistics.Query do
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics.Match, Statistics.Performance}

  def trim_identity(value) do
    %{rows: [[trimmed]]} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT statistics_trim_identity($1::text)",
        [value]
      )

    trimmed
  end

  def match_identity(season_id, value) do
    from m in Match,
      where:
        m.season_id == ^season_id and
          m.normalized_identity ==
            fragment(
              "lower(statistics_trim_identity(?::text))",
              ^value
            )
  end

  def pair(player_id, match_id),
    do: from(p in Performance, where: p.player_id == ^player_id and p.match_id == ^match_id)

  def history(player_id, bounds) do
    query =
      from p in Performance,
        join: m in assoc(p, :match),
        where: p.player_id == ^player_id,
        order_by: [asc: m.kickoff_at, asc: m.normalized_identity],
        preload: [match: m]

    query =
      if bounds.from, do: from([p, m] in query, where: m.kickoff_at >= ^bounds.from), else: query

    if bounds.to, do: from([p, m] in query, where: m.kickoff_at <= ^bounds.to), else: query
  end
end
