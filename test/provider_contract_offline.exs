ExUnit.start(autorun: false)
root = Path.expand("..", __DIR__)

files = [
  "types",
  "instant",
  "error",
  "provenance",
  "request",
  "adapter",
  "catalog",
  "performances",
  "validator",
  "runtime",
  "runner"
]

for file <- files, do: Code.require_file("lib/football_market/providers/#{file}.ex", root)
Code.require_file("lib/football_market/providers.ex", root)

for file <- ["fixture_runtime", "fixture_source_a", "fixture_source_b", "fact_oracle"],
    do: Code.require_file("test/support/providers/#{file}.ex", root)

Code.require_file("test/support/provider_contract_case.ex", root)

suites = %{
  "request" => ["request"],
  "catalog" => ["catalog_contract"],
  "performances" => ["performance_contract"],
  "deadline" => ["deadline"],
  "safety" => ["error_safety"],
  "fixtures" => ["equivalence", "fixture_matrix"]
}

selected =
  case System.argv() do
    ["all"] -> Enum.flat_map(suites, &elem(&1, 1))
    [key] -> Map.get(suites, key, [])
    _ -> []
  end

if selected == [], do: System.halt(2)

for file <- selected,
    do: Code.require_file("test/football_market/providers/#{file}_test.exs", root)

started = Enum.map(Application.started_applications(), &elem(&1, 0))

if Enum.any?([:football_market, :ecto, :postgrex, :redix, :phoenix], &(&1 in started)),
  do: System.halt(3)

result = ExUnit.run()
started_after = Enum.map(Application.started_applications(), &elem(&1, 0))

if Enum.any?([:football_market, :ecto, :postgrex, :redix, :phoenix], &(&1 in started_after)),
  do: System.halt(3)

System.halt(if result.total > 0 and result.failures == 0, do: 0, else: 1)
