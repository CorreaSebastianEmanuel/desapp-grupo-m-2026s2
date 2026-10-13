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

    active_feature =
      case File.read(".specify/feature.json") do
        {:ok, json} -> Jason.decode!(json)["feature_directory"]
        {:error, _} -> nil
      end

    # This feature consumes Providers without modifying provider production.
    # Its independently planned catalog paths must not look like provider leaks.
    ingestion_paths =
      if active_feature == "specs/057-idempotent-catalog-ingestion" do
        [
          "lib/football_market/catalog/ingestion.ex",
          "lib/football_market/catalog/ingestion/canonical.ex",
          "lib/football_market/catalog/ingestion/reconciler.ex",
          "lib/football_market/catalog/ingestion/publisher.ex",
          "lib/football_market/catalog/ingestion/outcome.ex",
          "lib/football_market/catalog/ingestion/scope.ex",
          "lib/football_market/catalog/ingestion/source_binding.ex",
          "lib/football_market/catalog/ingestion/observation.ex",
          "lib/football_market/catalog/ingestion/observation_binding.ex",
          "priv/repo/migrations/20261008000000_create_catalog_ingestion_tables.exs",
          "priv/repo/migrations/20261008000100_make_team_business_keys_deferrable.exs"
        ]
      else
        []
      end

    assert Enum.all?(
             production,
             &(&1 in (@production ++
                        @scraping_production ++ ingestion_paths ++ valuation_paths(active_feature)) or
                 &1 == "mix.exs")
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

  # Exact active TASK-022 inventory; all legacy constraints remain enforced.
  def valuation_paths(active_feature) do
    if active_feature == "specs/060-position-aware-valuation" do
      [
        "lib/football_market/valuation/position_aware.ex",
        "test/support/position_aware_case.ex",
        "test/football_market/valuation/position_aware/config_test.exs",
        "test/football_market/valuation/position_aware/formula_test.exs",
        "test/football_market/valuation/position_aware/mixed_test.exs",
        "test/football_market/valuation/position_aware/outcomes_test.exs",
        "test/football_market/valuation/position_aware/arithmetic_test.exs",
        "test/football_market/valuation/position_aware/replay_test.exs",
        "test/football_market/valuation/position_aware/selection_test.exs",
        "test/football_market/valuation/position_aware/scope_test.exs",
        "test/football_market/valuation/scope_test.exs",
        "test/football_market/statistics/scope_test.exs",
        "test/football_market/providers/scope_test.exs"
      ]
    else
      if active_feature == "specs/059-balanced-valuation-strategy" do
        [
          "lib/football_market/valuation/balanced.ex",
          "lib/football_market/valuation/decimal_math.ex",
          "test/football_market/valuation/balanced/config_test.exs",
          "test/football_market/valuation/balanced/formula_test.exs",
          "test/football_market/valuation/balanced/outcomes_test.exs",
          "test/football_market/valuation/balanced/arithmetic_test.exs",
          "test/football_market/valuation/balanced/replay_test.exs",
          "test/football_market/valuation/balanced/scope_test.exs",
          "test/football_market/valuation/scope_test.exs",
          "test/football_market/statistics/scope_test.exs",
          "test/football_market/providers/scope_test.exs"
        ]
      else
        if active_feature == "specs/058-valuation-contract-normalization" do
          [
            "lib/football_market/valuation.ex",
            "lib/football_market/valuation/types.ex",
            "lib/football_market/valuation/error.ex",
            "lib/football_market/valuation/request.ex",
            "lib/football_market/valuation/week.ex",
            "lib/football_market/valuation/statistics_reader.ex",
            "lib/football_market/valuation/preparation.ex",
            "lib/football_market/valuation/position_groups.ex",
            "lib/football_market/valuation/decimal_math.ex",
            "lib/football_market/valuation/scorer.ex",
            "lib/football_market/valuation/scoring.ex",
            "lib/football_market/valuation/evidence.ex",
            "lib/football_market/valuation/replay.ex",
            "test/support/valuation_case.ex",
            "test/support/valuation_scorers.ex",
            "test/football_market/valuation/contract_test.exs",
            "test/football_market/valuation/week_test.exs",
            "test/football_market/valuation/normalization_test.exs",
            "test/football_market/valuation/history_test.exs",
            "test/football_market/valuation/missing_data_test.exs",
            "test/football_market/valuation/outcomes_test.exs",
            "test/football_market/valuation/position_groups_test.exs",
            "test/football_market/valuation/scoring_test.exs",
            "test/football_market/valuation/replay_test.exs",
            "test/football_market/valuation/canonical_test.exs",
            "test/football_market/valuation/matrix_test.exs",
            "test/football_market/valuation/scope_test.exs",
            "test/football_market/statistics/scope_test.exs",
            "test/football_market/providers/scope_test.exs"
          ]
        else
          []
        end
      end
    end
  end
end
