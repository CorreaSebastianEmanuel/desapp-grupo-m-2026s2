defmodule FootballMarket.Statistics.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.{Input, Match, Performance}

  test "FR-013 context contract has no web provider cache or financial dependency" do
    files = [
      "lib/football_market/statistics.ex" | Path.wildcard("lib/football_market/statistics/*.ex")
    ]

    assert length(files) == 7

    for path <- files do
      source = File.read!(path)

      refute Regex.match?(
               ~r/FootballMarketWeb|FootballMarket\.(Providers|Valuation|Quotes|Trading|Cache)|\b(Finch|Req|Redix|HTTPoison)\b/,
               source
             ),
             path
    end

    assert File.read!("specs/054-player-match-statistics/contracts/statistics-context.md") =~
             "No HTTP route"

    forbidden = [:score, :weight, :price, :money, :provider_id, :rating, :provenance]

    for module <- [Match, Performance], field <- forbidden do
      refute field in module.__schema__(:fields)
    end

    for field <- forbidden do
      assert {:error, %{reason: :unsupported_field}} = Input.performance(%{field => 1})
      assert {:error, %{reason: :unsupported_field}} = Input.match(%{field => 1})
    end
  end

  test "product edits stay within plan boundary" do
    {out, 0} =
      System.cmd("git", [
        "status",
        "--porcelain",
        "--untracked-files=all",
        "--",
        "lib",
        "priv",
        "test",
        ".github/workflows"
      ])

    allowed = [
      "lib/football_market/statistics.ex",
      "lib/football_market/statistics/",
      "priv/repo/migrations/20261003000000_create_match_statistics.exs",
      "priv/repo/migrations/20261004000000_align_statistics_identity_whitespace.exs",
      "lib/football_market/catalog/team.ex",
      "lib/football_market/catalog/season.ex",
      "lib/football_market/catalog/position.ex",
      "test/support/statistics_case.ex",
      "test/support/catalog_concurrency_case.ex",
      "test/football_market/catalog/constraints_test.exs",
      "test/football_market/statistics/"
    ]

    active_feature =
      case File.read(".specify/feature.json") do
        {:ok, json} -> Jason.decode!(json)["feature_directory"]
        {:error, _} -> nil
      end

    # TASK-016 adds an independent read-only provider boundary. Retain this
    # task's original allowlist and permit only that active plan's exact files.
    provider_paths =
      if active_feature == "specs/016-external-football-provider-contract" do
        [
          "lib/football_market/providers.ex",
          "test/provider_contract_offline.exs",
          "test/support/provider_contract_case.ex"
        ] ++
          Enum.map(
            ~w(adapter types request instant error validator catalog performances provenance runner runtime),
            &"lib/football_market/providers/#{&1}.ex"
          ) ++
          Enum.map(
            ~w(fixture_data fixture_source_a fixture_source_b fixture_runtime fact_oracle),
            &"test/support/providers/#{&1}.ex"
          ) ++
          Enum.map(~w(cases source_a source_b expected), &"test/fixtures/providers/#{&1}.exs") ++
          Enum.map(
            ~w(request catalog_contract performance_contract deadline error_safety equivalence fixture_matrix fixture_preservation catalog_isolation scope),
            &"test/football_market/providers/#{&1}_test.exs"
          )
      else
        []
      end

    scraper_paths =
      if active_feature == "specs/056-football-scraping-adapter" do
        [
          "lib/football_market/providers/scraping.ex",
          "lib/football_market/providers/adapter.ex",
          "lib/football_market/providers/runner.ex",
          "test/scraping_adapter_offline.exs",
          "test/support/providers/scraping_fixture_data.ex",
          "test/support/providers/fixture_source_a.ex",
          "test/scripts/workflow_artifact_probe_test.py",
          "test/ci/coverage_report_contract_test.exs",
          ".github/workflows/quality-baseline.yml",
          "test/football_market/providers/scope_test.exs"
        ] ++
          Enum.map(
            ~w(assessment source translator transport disabled_transport fixture_transport),
            &"lib/football_market/providers/scraping/#{&1}.ex"
          ) ++
          Enum.map(~w(cases documents expected inventory), &"test/fixtures/scraping/#{&1}.exs") ++
          Enum.map(
            ~w(assessment catalog performances safety deadline matrix equivalence isolation),
            &"test/football_market/providers/scraping/#{&1}_test.exs"
          )
      else
        []
      end

    allowed_ci_paths = [
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256"
    ]

    for line <- String.split(out, "\n", trim: true) do
      path = String.slice(line, 3..-1//1)

      assert path in provider_paths or path in scraper_paths or path in allowed_ci_paths or
               Enum.any?(allowed, &String.starts_with?(path, &1)),
             "outside plan: #{path}"
    end
  end
end
