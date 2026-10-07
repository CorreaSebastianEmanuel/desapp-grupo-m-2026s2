defmodule FootballMarket.Providers.ScrapingEquivalenceTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers
  alias Providers.{FixtureSourceA, FixtureRuntime, FactOracle, ScrapingFixtureData}
  alias ScrapingFixtureData, as: Data

  test "existing consumer reads equivalent facts with separate qualified provenance" do
    for id <- ["source-equivalence-catalog", "source-equivalence-performances"] do
      c = Data.case!(id)
      assert {:ok, scraper} = Data.assert_case!(c)
      Process.put(:fixture_elapsed, 0)

      assert {:ok, reference} =
               apply(Providers, Data.operation(c), [
                 Data.request(c),
                 [
                   provider: {FixtureSourceA, {:scraping_reference, c["reference"]}},
                   positions: Data.positions(),
                   runtime: {FixtureRuntime, %{}}
                 ]
               ])

      expected =
        Map.new(reference.facts, fn {k, v} ->
          convert = fn r ->
            Map.from_struct(r)
            |> Map.new(fn {key, value} ->
              {key, if(match?(%DateTime{}, value), do: DateTime.to_iso8601(value), else: value)}
            end)
          end

          {k, if(is_list(v), do: Enum.map(v, convert), else: convert.(v))}
        end)

      correspondence = %{
        league: %{"league" => "league"},
        season: %{"season" => "season"},
        team: %{"team:a" => "team:a", "team:b" => "team:b"},
        position: %{"FW" => "FW", "GK" => "GK"},
        player: %{"player:p1" => "player:p1", "player:p2" => "player:p2"}
      }

      correspondence =
        if Data.operation(c) == :performances do
          Map.merge(correspondence, %{
            player: %{"player:p1" => "player:p1"},
            match: %{"match:m1" => "match:m1"},
            performance: %{"performance:m1:p1" => "performance:m1:p1"}
          })
        else
          correspondence
        end

      FactOracle.assert_facts!(scraper.facts, expected, correspondence)
      assert scraper.provenance.provider != reference.provenance.provider
      assert scraper.provenance.bindings != reference.provenance.bindings
      assert scraper.provenance.fixture_id == reference.provenance.fixture_id
      assert scraper.provenance.retrieved_at == reference.provenance.retrieved_at
    end
  end
end
