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


alias FootballMarket.Providers.{ScrapingFixtureData, FixtureRuntime, Request, Scraping}
alias ScrapingFixtureData, as: Data
base = ~U[2026-10-07 00:00:00.000000Z]
failures = for id <- ["catalog-PL-2024", "performance-PL-2024"], kind <- [:expiry, :withdrawal, :revision] do
  c = Data.case!(id)
  a = Data.assessment(c)
  overrides = case kind do
    :expiry ->
      %{assessment: %{a | expires_at: DateTime.add(base, 1, :microsecond)},
        assessment_clock: fn -> DateTime.add(base, FixtureRuntime.now_us(nil), :microsecond) end}
    change ->
      %{assessment_reader: fn ->
        if FixtureRuntime.now_us(nil) >= 1 do
          if change == :withdrawal, do: %{a | withdrawn: true}, else: %{a | revision: 2}
        else
          a
        end
      end}
  end
  result = Data.run(c, overrides, {FixtureRuntime, %{validation_us: 2}})
  {:ok, request} = Request.normalize(Data.operation(c), Data.request(c))
  {:error, %{category: :unsupported_capability}} = Scraping.Assessment.admit(request, Data.state(c, overrides), 1)
  passed = match?({:error, %{category: :unsupported_capability}}, result)
  IO.puts("QA_PUBLICATION id=#{id} change=#{kind} expected=unsupported_capability actual=#{elem(result, 0)} elapsed_us=#{FixtureRuntime.now_us(nil)} gate_now=unsupported_capability pass=#{passed}")
  not passed
end
System.halt(if Enum.any?(failures), do: 1, else: 0)
