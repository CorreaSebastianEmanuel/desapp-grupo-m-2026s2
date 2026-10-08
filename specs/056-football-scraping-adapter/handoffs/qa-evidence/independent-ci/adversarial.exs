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


defmodule IndependentScrapingQA do
  use ExUnit.Case, async: false
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data
  defp mutated(id, portion, change) do
    c = Data.case!(id)
    s = Data.state(c)
    body = s.portions[portion].body |> Jason.decode!() |> change.() |> Jason.encode!()
    Data.run(c, %{portions: put_in(s.portions, [portion, :body], body)})
  end
  test "catalog rejects a duplicate across independent roster portions" do
    assert {:error, %{category: :invalid_response}} = mutated("catalog-PL-2024", "roster:b", fn d ->
      put_in(d, ["players", Access.at(0), "id"], "p1")
    end)
  end
  test "retained match detail must match discovered kickoff and participating teams" do
    for {key, value} <- [{"matchTimeUTCDate", "2024-10-01T12:00:01Z"}, {"homeTeam", %{"id" => "b"}}] do
      assert {:error, %{category: :invalid_response}} = mutated("performance-PL-2024", "match:m1", fn d ->
        put_in(d, ["general", key], value)
      end)
    end
  end
  test "team total and own-goal annotations cannot fabricate player counts" do
    c = Data.case!("own-goal")
    assert {:ok, r} = Data.run(c)
    [p] = r.facts.performances
    assert p.counts.goals == 0
    assert p.counts.shots_on_target == 0
    assert p.counts.tackles == nil
    assert p.counts.goals_conceded == nil
    assert {:ok, r} = Data.run(Data.case!("keeper-change"))
    assert length(r.facts.performances) == 2
    assert Enum.all?(r.facts.performances, &is_nil(&1.counts.goals_conceded))
  end
  test "incomplete final detail witness invalidates the entire performance result" do
    c = Data.case!("performance-PL-2024")
    s = Data.state(c)
    for {key, value} <- [{:terminal, false}, {:witness, "unrecognized"}, {:destination, "elsewhere"}] do
      portions = put_in(s.portions, ["match:m1", :observation, key], value)
      expected = if key == :destination, do: :unsupported_capability, else: :invalid_response
      assert {:error, %{category: ^expected}} = Data.run(c, %{portions: portions})
    end
  end
  test "unknown status fails even when supplied kickoff lies outside the bounds" do
    assert {:error, %{category: :invalid_response}} = mutated("bounds-outside", "schedule", fn d ->
      put_in(d, ["fixtures", "allMatches", Access.at(0), "status"], "unknown")
    end)
  end
  test "default live denial persists even with a valid synthetic assessment" do
    c = Data.case!("catalog-PL-2024")
    assert {:error, %{category: :unsupported_capability}} = Data.run(c, %{mode: :live, enabled: true})
    refute_receive {:scraping_fetch, _, _}, 0
  end
  test "invalid input wins over the live source gate" do
    c = Data.case!("catalog-PL-2024") |> Map.put("invalid", true)
    assert {:error, %{category: :invalid_request}} = Data.run(c, %{mode: :live, enabled: true})
    refute_receive {:scraping_fetch, _, _}, 0
  end
  test "malformed final assessment reader fails safely without publishing facts" do
    c = Data.case!("catalog-PL-2024")
    a = Data.assessment(c)
    reader = fn ->
      if FootballMarket.Providers.FixtureRuntime.now_us(nil) > 0, do: raise("FAKE_SENTINEL"), else: a
    end
    assert {:error, e} = Data.run(c, %{assessment_reader: reader}, {FootballMarket.Providers.FixtureRuntime, %{validation_us: 2}})
    assert e.category == :unsupported_capability
    refute inspect(e) =~ "FAKE_SENTINEL"
  end
end
r = ExUnit.run()
System.halt(if r.total == 8 and r.failures == 0, do: 0, else: 1)
