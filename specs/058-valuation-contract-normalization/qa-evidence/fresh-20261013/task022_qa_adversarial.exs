alias FootballMarket.Valuation
alias FootballMarket.Valuation.{Definition, Descriptor}
alias FootballMarket.ValuationCase, as: Fixtures

base = Fixtures.pure_request()
position = Fixtures.fact(1).position_id
definition = %Definition{
  module: FootballMarket.ValuationScorers.Weighted,
  strategy_id: "illustrative",
  version: "1",
  config: %{weights: %{overall: %{goals: 1}}, policy: :require_all}
}

cases = [
  {"FR-013 malformed requirement list", fn -> Valuation.prepare(%{base | requirements: %{overall: [:goals | :invalid_tail]}}) end},
  {"FR-013 malformed position mapping list", fn -> Valuation.prepare(%{base | position_mapping: [{position, :defender} | :invalid_tail]}) end},
  {"FR-013 malformed nested configuration list", fn -> Valuation.evaluate(base, %{definition | config: Map.put(definition.config, :extra, [1 | :invalid_tail])}) end},
  {"FR-013 malformed replay fact list", fn -> Valuation.replay(%Descriptor{request: base, facts: [Fixtures.fact(1) | :invalid_tail]}, nil) end}
]

failures = Enum.count(cases, fn {label, call} ->
  try do
    case call.() do
      {:error, %{kind: kind}} ->
        IO.puts("PASS #{label}: ordinary error #{kind}")
        false
      _ ->
        IO.puts("FAIL #{label}: returned success or unexpected shape")
        true
    end
  rescue
    error ->
      IO.puts("FAIL #{label}: raised #{inspect(error.__struct__)}")
      for entry <- Enum.take(__STACKTRACE__, 3), do: IO.puts("  " <> Exception.format_stacktrace_entry(entry))
      true
  end
end)

IO.puts("QA_ADVERSARIAL cases=#{length(cases)} failures=#{failures}")
if failures > 0, do: System.halt(1)
