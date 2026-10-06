defmodule FootballMarket.Providers.FactOracle do
  @moduledoc "Test-only bijective entity oracle, independent of production validation."
  import ExUnit.Assertions

  @kinds %{
    teams: :team,
    positions: :position,
    players: :player,
    matches: :match,
    performances: :performance
  }
  @edges %{
    league_ref: :league,
    season_ref: :season,
    team_ref: :team,
    position_ref: :position,
    home_team_ref: :team,
    away_team_ref: :team,
    player_ref: :player,
    match_ref: :match
  }
  def assert_facts!(actual, expected, correspondence) do
    assert Map.keys(actual) |> Enum.sort() == Map.keys(expected) |> Enum.sort()

    for {field, value} <- actual do
      kind = Map.get(@kinds, field, field)
      actual_rows = if is_list(value), do: value, else: [value]
      expected_rows = if is_list(expected[field]), do: expected[field], else: [expected[field]]
      mapping = Map.fetch!(correspondence, kind)
      assert Enum.sort(Map.keys(mapping)) == Enum.sort(Enum.map(actual_rows, & &1.ref))
      assert Enum.sort(Map.values(mapping)) == Enum.sort(Enum.map(expected_rows, & &1.ref))
      assert length(Enum.uniq(Map.values(mapping))) == map_size(mapping)

      normalized =
        Enum.map(actual_rows, fn row ->
          row = if is_struct(row), do: Map.from_struct(row), else: row

          Map.new(row, fn {key, v} ->
            cond do
              key == :ref -> {key, Map.fetch!(mapping, v)}
              Map.has_key?(@edges, key) -> {key, Map.fetch!(correspondence[@edges[key]], v)}
              match?(%DateTime{}, v) -> {key, DateTime.to_iso8601(v)}
              true -> {key, v}
            end
          end)
        end)

      assert Enum.sort(normalized) == Enum.sort(expected_rows)
    end

    :ok
  end
end
