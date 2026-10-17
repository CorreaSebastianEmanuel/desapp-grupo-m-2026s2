ExUnit.start(autorun: false)
Code.require_file("test/test_helper.exs")
ExUnit.configure(autorun: false)
modules = FootballMarket.TestProfileAudit.discovered_modules()
Enum.each(~w(unit integration e2e), fn profile -> FootballMarket.TestProfileAudit.audit!(profile) end)
Enum.each(Enum.uniq(Enum.map(modules, & &1.file)), &Code.require_file/1)
Enum.each(modules, fn m ->
  if Module.concat([m.module]).__ex_unit__().tests == [], do: raise("undiscovered ExUnit module")
end)
entries = for m <- modules, test <- Module.concat([m.module]).__ex_unit__().tests do
  profiles = Enum.filter(~w(unit integration e2e)a, &Map.get(test.tags, &1))
  if profiles != [String.to_atom(m.profile)] or Map.get(test.tags, :skip, false), do: raise("invalid case assignment")
  %{runner: "exunit", file: m.file, case_id: m.module <> ":" <> Atom.to_string(test.name), profile: m.profile}
end
File.write!(System.fetch_env!("PROFILE_DISCOVERY"), Jason.encode!(entries))
if System.get_env("PROFILE_ENFORCE_INVENTORY") == "1" do
  inventory = "config/test_profiles.json" |> File.read!() |> Jason.decode!()
  expected = Enum.filter(inventory["entries"], &(&1["runner"] == "exunit"))
  FootballMarket.TestProfileAudit.assert_membership!(expected, entries)
end

