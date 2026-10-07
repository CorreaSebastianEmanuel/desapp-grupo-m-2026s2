require ExUnit.Assertions
selectors = ~w(assessment catalog performances safety deadline matrix equivalence)

selection =
  case System.argv() do
    ["repeat"] -> selectors
    [s] -> if(s in selectors, do: [s], else: System.halt(2))
    _ -> System.halt(2)
  end

ExUnit.start(autorun: false)
root = Path.expand("..", __DIR__)
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

for file <- selection,
    do: Code.require_file("test/football_market/providers/scraping/#{file}_test.exs", root)

# Repeat compares complete corpus results in fresh states, then runs its assertions.
if System.argv() == ["repeat"] do
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data
  first = Enum.map(Data.cases(), &Data.assert_case!/1)
  second = Enum.map(Data.cases(), &Data.assert_case!/1)
  ExUnit.Assertions.assert(first == second)
end

for app <- [:football_market, :ecto, :postgrex, :redix, :phoenix],
    do: ExUnit.Assertions.refute(Application.spec(app))

result = ExUnit.run()

for app <- [:football_market, :ecto, :postgrex, :redix, :phoenix],
    do: ExUnit.Assertions.refute(Application.spec(app))

System.halt(if result.total > 0 and result.failures == 0, do: 0, else: 1)
