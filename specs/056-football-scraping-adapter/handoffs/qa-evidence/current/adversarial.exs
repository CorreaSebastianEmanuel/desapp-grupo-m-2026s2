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



alias FootballMarket.Providers.{ScrapingFixtureData, FixtureRuntime}
alias ScrapingFixtureData, as: Data
check = fn label, result, expected ->
  actual = case result do
    {:error, e} -> e.category
    {:ok, _} -> :ok
  end
  IO.puts("QA_MUTATION #{label} expected=#{expected} actual=#{actual}")
  if actual != expected, do: raise("unexpected outcome: #{label}")
end
for id <- ["catalog-PL-2024", "performance-PL-2024"] do
  c = Data.case!(id)
  a = Data.assessment(c)
  for {label, mutate} <- [
    {"coverage_removed", fn a -> %{a | scopes: %{}} end},
    {"conditions_removed", fn a -> %{a | conditions: :unknown} end},
    {"destination_removed", fn a -> %{a | destinations: []} end},
    {"limits_removed", fn a -> %{a | limits: %{}} end}
  ] do
    reader = fn -> if FixtureRuntime.now_us(nil) >= 1, do: mutate.(a), else: a end
    result = Data.run(c, %{assessment_reader: reader}, {FixtureRuntime, %{validation_us: 2}})
    check.(id <> ":" <> label, result, :unsupported_capability)
  end
end
c = Data.case!("catalog-PL-2024")
p = Data.state(c).portions
for {label, portions} <- [
  {"later_missing", Map.delete(p, "roster:b")},
  {"later_no_terminal", put_in(p, ["roster:b", :observation, :terminal], false)},
  {"later_wrong_witness", put_in(p, ["roster:b", :observation, :witness], "unapproved")}
] do
  check.(label, Data.run(c, %{portions: portions}), :invalid_response)
end
c = Data.case!("performance-PL-2024")
p = Data.state(c).portions
body = Jason.decode!(p["match:m1"].body)
for {label, edited} <- [
  {"missing_playerStats", update_in(body, ["content"], &Map.delete(&1, "playerStats"))},
  {"missing_event_position", update_in(body, ["content", "playerStats", "p1"], &Map.delete(&1, "positionId"))},
  {"detail_wrong_season", put_in(body, ["general", "season"], "2025/2026")},
  {"detail_wrong_kickoff", put_in(body, ["general", "matchTimeUTCDate"], "2024-10-02T12:00:00Z")},
  {"empty_playerStats", put_in(body, ["content", "playerStats"], %{})}
] do
  portions = put_in(p, ["match:m1", :body], Jason.encode!(edited))
  expected = if label == "empty_playerStats", do: :ok, else: :invalid_response
  check.(label, Data.run(c, %{portions: portions}), expected)
end
IO.puts("QA_MUTATIONS 16 assertions passed")
