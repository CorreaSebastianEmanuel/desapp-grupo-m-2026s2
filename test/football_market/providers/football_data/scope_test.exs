defmodule FootballMarket.Providers.FootballData.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  @paths [
    "lib/football_market/providers/football_data.ex"
    | Enum.map(
        ~w(configuration scope translator errors transport mint_transport),
        &"lib/football_market/providers/football_data/#{&1}.ex"
      )
  ]

  test "adapter has exactly the planned files and no persistence, domain, web or detached work" do
    assert Enum.sort(
             Path.wildcard("lib/football_market/providers/football_data/*.ex") ++
               Path.wildcard("lib/football_market/providers/football_data.ex")
           ) == Enum.sort(@paths)

    for path <- @paths do
      source = File.read!(path)

      Macro.prewalk(Code.string_to_quoted!(source), fn
        {:__aliases__, _, [:FootballMarket | rest]} = node ->
          assert hd(rest) == :Providers
          node

        {:__aliases__, _, [module | _]} = node ->
          refute module in [:Repo, :Ecto, :Phoenix, :Postgrex, :Redix, :Task, :File, :Port]
          node

        node ->
          node
      end)

      refute source =~
               ~r/\bspawn(?:_link|_monitor)?\(|\b(retry|backoff|fallback|score|quote|trade|ranking|cache)\s*\(/
    end
  end

  test "original boundary and fixture files retain their committed bytes" do
    protected =
      [
        "lib/football_market/providers.ex",
        "test/provider_contract_offline.exs",
        "test/support/provider_contract_case.ex"
      ] ++
        Enum.map(
          ~w(adapter types request instant error validator catalog performances provenance runtime),
          &"lib/football_market/providers/#{&1}.ex"
        ) ++
        Enum.map(~w(cases expected source_a source_b), &"test/fixtures/providers/#{&1}.exs") ++
        Enum.map(
          ~w(fixture_data fixture_runtime fixture_source_a fixture_source_b fact_oracle),
          &"test/support/providers/#{&1}.ex"
        )

    for path <- protected do
      {original, 0} = System.cmd("git", ["show", "HEAD:#{path}"])
      assert File.read!(path) == original, path
    end
  end

  test "Runner delta permits only private readiness wiring and keeps every other form" do
    path = "lib/football_market/providers/runner.ex"
    {original, 0} = System.cmd("git", ["show", "HEAD:#{path}"])

    forms = fn source ->
      {:defmodule, _, [_, [do: {:__block__, _, nodes}]]} = Code.string_to_quoted!(source)

      Enum.map(nodes, fn node ->
        key =
          case node do
            {kind, _, [{:when, _, [{name, _, args}, _]}, _]} when kind in [:def, :defp] ->
              {kind, name, length(args)}

            {kind, _, [{name, _, args}, _]} when kind in [:def, :defp] ->
              {kind, name, length(args)}

            {kind, _, _} ->
              kind
          end

        {key,
         Macro.prewalk(node, fn
           {a, meta, b} when is_list(meta) -> {a, [], b}
           other -> other
         end)}
      end)
    end

    before = forms.(original)
    after_forms = forms.(File.read!(path))
    allowed = [{:def, :run, 4}, {:defp, :with_retry_window, 1}, {:defp, :refine_retry_delay, 3}]
    strip = fn forms -> Enum.reject(forms, fn {key, _} -> key in allowed end) end
    assert strip.(before) == strip.(after_forms)

    assert Enum.frequencies(for {key, _} <- after_forms, key in allowed, do: key) ==
             %{
               {:def, :run, 4} => 1,
               {:defp, :with_retry_window, 1} => 1,
               {:defp, :refine_retry_delay, 3} => 2
             }

    source = File.read!(path)

    for invariant <- [
          "when ready < deadline",
          "timeout(request, runtime, handle, state)",
          "runtime.close(handle, state)",
          "runtime.cancel(handle, state)"
        ] do
      assert source =~ invariant
    end

    refute source =~ ~r/FootballData|utc_now.*ready|spawn|Task|Repo|Ecto|send\(|receive\s+do/
  end

  test "dependency delta is exactly Mint and its required hpax update; tests remain discoverable" do
    assert {:mint, "~> 1.11"} in Mix.Project.config()[:deps]
    {original, 0} = System.cmd("git", ["show", "HEAD:mix.lock"])
    {before, _} = Code.eval_string(original)
    {after_lock, _} = Code.eval_file("mix.lock")
    assert Map.drop(before, [:hpax, :mint]) == Map.drop(after_lock, [:hpax, :mint])
    assert elem(after_lock[:mint], 2) == "1.11.0"
    assert elem(after_lock[:hpax], 2) == "1.1.0"

    expected =
      ~w(configuration catalog scope_evidence security errors retry_expiry deadline fixtures isolation scope transport_runtime)

    actual = Path.wildcard("test/football_market/providers/football_data/*_test.exs")

    assert Enum.sort(actual) ==
             Enum.sort(
               Enum.map(expected, &"test/football_market/providers/football_data/#{&1}_test.exs")
             )

    for path <- actual do
      source = File.read!(path)
      assert length(Regex.scan(~r/@moduletag :(unit|integration)\b/, source)) == 1
      refute path in Mix.Project.config()[:test_ignore_filters]
    end
  end
end
