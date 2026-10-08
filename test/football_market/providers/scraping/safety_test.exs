defmodule FootballMarket.Providers.ScrapingSafetyTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data

  test "malformed payloads and normalized failures never expose source data" do
    for c <- Data.cases(),
        String.starts_with?(c["id"], ["malformed-", "failure-", "later-failure"]) do
      Data.assert_case!(c)
    end
  end

  test "production adapter has no persistence, web, financial or network dependency" do
    files = [
      "lib/football_market/providers/scraping.ex"
      | Path.wildcard("lib/football_market/providers/scraping/*.ex")
    ]

    assert length(files) == 7

    for file <- files do
      source = File.read!(file)

      refute Regex.match?(
               ~r/\b(Repo|Ecto|CatalogCase|Statistics|Trading|Quotes|Finch|HTTPoison|Req|Tesla|httpc|FootballMarketWeb)\b/,
               source
             )

      refute source =~ "String.to_atom"
    end
  end

  test "offline harness refuses unknown and empty selectors" do
    for args <- [[], ["unknown"]] do
      {_, status} =
        System.cmd("elixir", ["test/scraping_adapter_offline.exs" | args], stderr_to_stdout: true)

      assert status == 2
    end
  end

  test "exception text and credential-bearing diagnostics stay private" do
    c = Data.case!("catalog-PL-2024")

    assert {:error, e} =
             Data.run(c, %{
               on_fetch: fn _ -> raise("password=FAKE_SENTINEL https://credentials.invalid") end
             })

    assert e.category == :unavailable
    refute inspect(e) =~ "FAKE_SENTINEL"
    refute inspect(e) =~ "https://"

    portions =
      Map.put(Data.state(c).portions, "roster:b", %{
        failure: %{category: :unavailable, diagnostics: "FAKE_SENTINEL"}
      })

    assert {:error, e} = Data.run(c, %{portions: portions})
    assert e.category == :invalid_response
    refute inspect(e) =~ "FAKE_SENTINEL"
  end
end
