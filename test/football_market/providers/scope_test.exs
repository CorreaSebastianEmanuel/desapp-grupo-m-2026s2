defmodule FootballMarket.Providers.ScopeTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.Providers.{Request, Result, Player, Performance, Match}

  @production [
    "lib/football_market/providers.ex"
    | Enum.map(
        ~w(adapter types request instant error validator catalog performances provenance runner runtime),
        &"lib/football_market/providers/#{&1}.ex"
      )
  ]
  @scraping_production [
    "lib/football_market/providers/scraping.ex"
    | Enum.map(
        ~w(assessment source translator transport disabled_transport fixture_transport),
        &"lib/football_market/providers/scraping/#{&1}.ex"
      )
  ]
  test "FR-014 AST dependencies stay pure, read-only and within planned production paths" do
    for path <- @production ++ @scraping_production do
      source = File.read!(path)
      ast = Code.string_to_quoted!(source)

      Macro.prewalk(ast, fn
        {:__aliases__, _, [:FootballMarket | rest]} = node ->
          assert List.first(rest) == :Providers,
                 "#{path} leaks a domain/persistence/web dependency"

          node

        {:__aliases__, _, [module | _]} = node ->
          refute module in [
                   :Ecto,
                   :Repo,
                   :Phoenix,
                   :Req,
                   :HTTPoison,
                   :Finch,
                   :Redix,
                   :Postgrex,
                   :File,
                   :Port,
                   :Task
                 ],
                 "#{path} introduces a forbidden dependency"

          node

        {{:., _, [{:__aliases__, _, [:System]}, :cmd]}, _, _} ->
          flunk("external process in #{path}")

        node ->
          node
      end)

      refute source =~ ~r/\b(retry|backoff|fallback|score|quote|trade|ranking|cache)\s*\(/

      if Path.basename(path) != "runtime.ex",
        do: refute(source =~ ~r/\bspawn(?:_link|_monitor)?\(/)
    end

    {diff, 0} = System.cmd("git", ["diff", "HEAD", "--name-only"])
    {untracked, 0} = System.cmd("git", ["ls-files", "--others", "--exclude-standard"])
    changed = String.split(diff <> untracked, "\n", trim: true) |> Enum.uniq()

    production =
      Enum.filter(changed, fn path ->
        String.starts_with?(path, ["lib/", "config/", "priv/repo/migrations/"]) or
          path in ["mix.exs", "mix.lock"]
      end)

    assert Enum.all?(
             production,
             &(&1 in (@production ++ @scraping_production) or &1 == "mix.exs")
           )

    assert Enum.sort(
             Path.wildcard("lib/football_market/providers/**/*.ex") ++
               ["lib/football_market/providers.ex"]
           ) == Enum.sort(@production ++ @scraping_production)
  end

  test "league parity and plain DTO fields preserve catalog and financial boundaries" do
    assert Request.leagues() == Map.new(FootballMarket.Catalog.supported_leagues())

    for module <- [Result, Player, Performance, Match] do
      refute function_exported?(module, :__schema__, 1)
      keys = module.__struct__() |> Map.keys()

      refute Enum.any?(
               [
                 :id,
                 :catalog_identity,
                 :score,
                 :money,
                 :price,
                 :token_supply,
                 :rating,
                 :headers,
                 :url
               ],
               &(&1 in keys)
             )
    end
  end

  test "Mix changes only exact fixture/bootstrap ignore filters; all actual tests remain discoverable" do
    expected = [
      "test/provider_contract_offline.exs",
      "test/scraping_adapter_offline.exs",
      "test/fixtures/scraping/cases.exs",
      "test/fixtures/scraping/documents.exs",
      "test/fixtures/scraping/expected.exs",
      "test/fixtures/scraping/inventory.exs",
      "test/fixtures/providers/cases.exs",
      "test/fixtures/providers/expected.exs",
      "test/fixtures/providers/source_a.exs",
      "test/fixtures/providers/source_b.exs"
    ]

    assert Enum.sort(Mix.Project.config()[:test_ignore_filters] || []) == Enum.sort(expected)
    {original, 0} = System.cmd("git", ["show", "HEAD:mix.exs"])

    strip = fn text ->
      text
      |> Code.string_to_quoted!()
      |> Macro.prewalk(fn
        list when is_list(list) ->
          if Keyword.keyword?(list), do: Keyword.delete(list, :test_ignore_filters), else: list

        node ->
          node
      end)
      |> Macro.to_string()
    end

    assert strip.(File.read!("mix.exs")) == strip.(original)

    assert Enum.all?(
             Path.wildcard("test/football_market/providers/*_test.exs"),
             &(&1 not in expected)
           )
  end
end
