defmodule FootballMarket.ValuationCase do
  alias FootballMarket.{Statistics, StatisticsCase}

  def fixture(code \\ "PL", year \\ 2025), do: StatisticsCase.fixture(code, year)

  def request(f, overrides \\ %{}) do
    Map.merge(
      %{
        player_id: hd(f.players).id,
        season_id: f.season.id,
        week_start: "2026-10-05T00:00:00Z",
        week_end: "2026-10-12T00:00:00Z",
        requirements: %{overall: [:goals]},
        references: %{goals: 4},
        position_mapping: [{f.position.id, :defender}]
      },
      overrides
    )
  end

  def record(f, identity, attrs \\ %{}, kickoff \\ "2026-10-06T12:00:00Z") do
    {:ok, match} =
      Statistics.record_match(
        StatisticsCase.match_attrs(f, %{match_identity: identity, kickoff_at: kickoff})
      )

    {:ok, performance} =
      Statistics.record_performance(StatisticsCase.performance_attrs(f, match, attrs))

    {match, performance}
  end

  def fact(n, attrs \\ %{}) do
    id = fn i ->
      "00000000-0000-0000-0000-#{String.pad_leading(Integer.to_string(i), 12, "0")}"
    end

    struct!(
      FootballMarket.Valuation.Fact,
      Map.merge(
        %{
          performance_id: id.(n),
          match_id: id.(100 + n),
          player_id: id.(900),
          season_id: id.(901),
          team_id: id.(902),
          position_id: id.(903),
          home_team_id: id.(902),
          away_team_id: id.(904),
          match_identity: "match-#{n}",
          kickoff: ~U[2026-10-06 12:00:00.000000Z],
          minutes: 90,
          metrics: Map.new(StatisticsCase.metrics(), &{&1, 0})
        },
        attrs
      )
    )
  end

  def pure_request(overrides \\ %{}) do
    row = fact(1)

    request(
      %{
        players: [%{id: row.player_id}],
        season: %{id: row.season_id},
        position: %{id: row.position_id}
      },
      overrides
    )
  end
end
