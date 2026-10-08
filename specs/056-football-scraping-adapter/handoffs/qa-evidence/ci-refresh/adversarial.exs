ExUnit.start(autorun: false)
root = File.cwd!()
ebin = Path.join(root, "_build/test/lib/jason/ebin")
true = Code.prepend_path(ebin)
{:module, Jason} = Code.ensure_loaded(Jason)

for file <-
      ~w(types instant error provenance request adapter catalog performances validator runtime runner),
    do: Code.require_file("lib/football_market/providers/#{file}.ex", root)

Code.require_file("lib/football_market/providers.ex", root)

for file <- ~w(fixture_data fixture_runtime fixture_source_a fixture_source_b fact_oracle),
    do: Code.require_file("test/support/providers/#{file}.ex", root)

{:ok, _, _} =
  Kernel.ParallelCompiler.compile(
    Path.wildcard(Path.join(root, "lib/football_market/providers/scraping/*.ex")) ++
      [Path.join(root, "lib/football_market/providers/scraping.ex")],
    return_diagnostics: true
  )

Code.require_file("test/support/providers/scraping_fixture_data.ex", root)



import ExUnit.Assertions
alias FootballMarket.Providers.ScrapingFixtureData, as: Data
alias FootballMarket.Providers.FixtureRuntime
for id <- ["catalog-PL-2024", "performance-PL-2024"] do
 c = Data.case!(id)
 assert {:error, %{category: :unsupported_capability}} = Data.run(c, %{mode: :live, enabled: true})
 refute_receive {:scraping_fetch, _, _}, 0
end
c = Data.case!("performance-PL-2024")
s = Data.state(c)
schedule = Jason.decode!(s.portions["schedule"].body)
match = hd(schedule["fixtures"]["allMatches"])
duplicate = put_in(schedule, ["fixtures", "allMatches"], [match, match])
portions = put_in(s.portions, ["schedule", :body], Jason.encode!(duplicate))
assert {:error, %{category: :invalid_response}} = Data.run(c, %{portions: portions})
for metric <- ["goals", "assists", "ShotsOnTarget", "matchstats.headers.tackles", "interceptions", "saves", "goals_conceded", "yellow_cards", "red_cards"] do
 detail = Jason.decode!(s.portions["match:m1"].body)
 stats = detail["content"]["playerStats"]["p1"]["stats"]
 duplicate = %{ "key" => metric, "stat" => %{ "value" => 0 } }
 detail = put_in(detail, ["content", "playerStats", "p1", "stats"], stats ++ [%{"stats" => [duplicate, duplicate]}])
 portions = put_in(s.portions, ["match:m1", :body], Jason.encode!(detail))
 assert {:error, %{category: :invalid_response}} = Data.run(c, %{portions: portions})
end
for id <- ["catalog-PL-2024", "performance-PL-2024"] do
 c = Data.case!(id)
 assert {:ok, _} = Data.run(c, %{}, {FixtureRuntime, %{validation_us: 4_999_999}})
 assert {:error, %{category: :timeout}} = Data.run(c, %{}, {FixtureRuntime, %{validation_us: 5_000_000}})
end
IO.puts("QA_ADVERSARIAL 16 assertions passed: live-switch denial, repeated match, nine duplicate metric keys, strict final-validation deadline")
