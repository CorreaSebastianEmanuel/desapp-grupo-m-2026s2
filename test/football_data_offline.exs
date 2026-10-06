ExUnit.start(autorun: false)

suites = %{
  "catalog" => ~w(catalog scope_evidence),
  "configuration" => ~w(configuration),
  "errors" => ~w(errors),
  "retry-expiry" => ~w(retry_expiry),
  "deadline" => ~w(deadline),
  "safety" => ~w(security),
  "fixtures" => ~w(fixtures),
  "transport-runtime" => ~w(transport_runtime)
}

selected =
  case System.argv() do
    ["all"] ->
      suites |> Map.delete("transport-runtime") |> Map.values() |> List.flatten() |> Enum.uniq()

    [key] ->
      Map.get(suites, key, [])

    _ ->
      []
  end

if selected == [], do: System.halt(2)

for name <- selected,
    do: Code.require_file("test/football_market/providers/football_data/#{name}_test.exs")

forbidden = [:football_market, :ecto, :postgrex, :redix, :phoenix]

assert_offline = fn ->
  if Enum.any?(Application.started_applications(), fn {app, _, _} -> app in forbidden end),
    do: System.halt(3)
end

assert_offline.()
result = ExUnit.run()
assert_offline.()
System.halt(if(result.total > 0 and result.failures == 0, do: 0, else: 1))
