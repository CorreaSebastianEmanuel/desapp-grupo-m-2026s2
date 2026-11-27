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




defmodule ReviewGuardAdapter do
  @behaviour FootballMarket.Providers.Adapter
  alias FootballMarket.Providers.{Scraping, FixtureRuntime}
  def provider_label, do: Scraping.provider_label()
  def read(request, context, state), do: Scraping.read(request, context, state)
  def publication_guard(_, _, state) do
    fn ->
      case state.review_guard do
        :raise -> raise("FAKE_SENTINEL private guard failure")
        :malformed -> :unexpected
        :before -> FixtureRuntime.advance(4_999_999); :ok
        :equal -> FixtureRuntime.advance(5_000_000); :ok
        :late -> FixtureRuntime.advance(5_000_001); :ok
        :error_at_deadline -> FixtureRuntime.advance(5_000_000); {:error, %{category: :unsupported_capability}}
      end
    end
  end
end
alias FootballMarket.Providers.{ScrapingFixtureData, FixtureRuntime}
alias ScrapingFixtureData, as: Data
for id <- ["catalog-PL-2024", "performance-PL-2024"],
    {kind, expected} <- [raise: :unavailable, malformed: :invalid_response, before: :ok,
                       equal: :timeout, late: :timeout, error_at_deadline: :timeout] do
  c = Data.case!(id)
  Process.put(:fixture_elapsed, 0)
  state = Map.put(Data.state(c), :review_guard, kind)
  result = apply(FootballMarket.Providers, Data.operation(c), [Data.request(c),
    [provider: {ReviewGuardAdapter, state}, positions: Data.positions(), runtime: {FixtureRuntime, %{}}]])
  actual = case result do
    {:ok, _} -> :ok
    {:error, e} -> e.category
  end
  if actual != expected or String.contains?(inspect(result), "FAKE_SENTINEL"),
    do: raise("review guard check failed: #{id} #{kind}")
  IO.puts("REVIEW_GUARD #{id} #{kind} expected=#{expected} actual=#{actual}")
end
IO.puts("REVIEW_GUARD 12 checks passed")
