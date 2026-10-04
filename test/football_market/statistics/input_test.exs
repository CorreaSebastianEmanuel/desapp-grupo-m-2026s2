defmodule FootballMarket.Statistics.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.Input
  import FootballMarket.StatisticsCase

  def attrs do
    Map.new([:match_id, :player_id, :team_id, :position_id], &{&1, Ecto.UUID.generate()})
    |> Map.put(:minutes_played, 0)
  end

  test "original identities reject malformed text without narrowing Unicode" do
    for identity <- [
          <<0>> <> "event",
          "ev" <> <<0>> <> "ent",
          "event" <> <<0>>,
          <<255>>,
          <<195, 40>>
        ] do
      assert {:error, %{field: :match_identity, reason: :invalid_identity}} =
               Input.identity(identity)
    end

    for identity <- ["", " ", "\u00A0", "\u2003"] do
      assert {:error, %{field: :match_identity, reason: :required}} = Input.identity(identity)
    end

    for identity <- ["比赛-é⚽", " épreuve ", "a\nb"] do
      assert {:ok, ^identity} = Input.identity(identity)
    end
  end

  test "every count accepts only exact nonnegative integers and optional unknowns" do
    for field <- [:minutes_played | metrics()] do
      for value <- [0, 1, 123, 999_999_999_999_999_999_999_999_999_999] do
        assert {:ok, out} = Input.performance(Map.put(attrs(), field, value))
        assert out[field] == value
      end

      for value <- [-1, 0.5, 1.0, "1", true, false, :unknown] do
        assert {:error, %{field: ^field, reason: :invalid_count}} =
                 Input.performance(Map.put(attrs(), field, value))
      end
    end

    for field <- metrics() do
      assert {:ok, out} = Input.performance(Map.put(attrs(), field, nil))
      assert out[field] == nil
      assert {:ok, _} = Input.performance(Map.delete(attrs(), field))
    end

    assert {:error, %{field: :minutes_played, reason: :required}} =
             Input.performance(Map.delete(attrs(), :minutes_played))

    assert {:error, %{field: :minutes_played}} =
             Input.performance(Map.put(attrs(), :minutes_played, nil))
  end

  test "containers keys identifiers and unsupported attributes are strict" do
    for value <- [nil, [], "attrs", 1], do: assert(match?({:error, _}, Input.performance(value)))
    assert {:ok, _} = Input.performance(Map.new(attrs(), fn {k, v} -> {to_string(k), v} end))
    assert {:error, %{reason: :invalid_shape}} = Input.performance(Map.put(attrs(), "goals", 1))

    for field <- [:score, :id, :season_id, :provider_rating] do
      assert {:error, %{reason: :unsupported_field}} =
               Input.performance(Map.put(attrs(), field, 1))
    end

    for value <- [nil, "", "bad", 7, true],
        do: assert(match?({:error, _}, Input.identifier(value, :player_id)))
  end

  test "instants retain microseconds normalize offsets and reject excess precision" do
    assert {:ok, utc} = Input.instant("2026-01-01T12:00:00.123456Z", :kickoff_at)
    assert {:ok, ^utc} = Input.instant("2026-01-01T09:00:00.123456-03:00", :kickoff_at)
    assert utc.microsecond == {123_456, 6}

    assert {:ok, ^utc} =
             Input.instant(
               %{
                 utc
                 | hour: 9,
                   time_zone: "Offset/MinusThree",
                   zone_abbr: "-03",
                   utc_offset: -10800
               },
               :kickoff_at
             )

    assert {:error, _} = Input.bounds(from: utc, from: utc)

    assert {:error, %{reason: :unsupported_precision}} =
             Input.instant("2026-01-01T12:00:00.1234560Z", :kickoff_at)

    for value <- [
          "2026-01-01",
          "2026-01-01T12:00:00",
          nil,
          1,
          ~N[2026-01-01 00:00:00],
          %{__struct__: DateTime}
        ],
        do: assert(match?({:error, _}, Input.instant(value, :kickoff_at)))

    assert {:error, _} = Input.instant(%{utc | microsecond: {1_234_567, 7}}, :kickoff_at)
  end
end
