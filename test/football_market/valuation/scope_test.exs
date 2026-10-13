defmodule FootballMarket.Valuation.ScopeTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Statistics}
  alias FootballMarket.Valuation.Definition

  @production [
    "lib/football_market/valuation.ex"
    | Enum.map(
        ~w(types error request week statistics_reader preparation position_groups decimal_math scorer scoring evidence replay),
        &"lib/football_market/valuation/#{&1}.ex"
      )
  ]

  @legacy_production @production
  @production @production ++ ["lib/football_market/valuation/balanced.ex"]

  test "AST dependencies, production inventory and absence of writes, time and providers" do
    assert Enum.sort(
             Path.wildcard("lib/football_market/valuation/*.ex") ++
               ["lib/football_market/valuation.ex"]
           ) == Enum.sort(@production)

    for path <- @production do
      source = File.read!(path)

      Macro.prewalk(Code.string_to_quoted!(source), fn
        {:__aliases__, _, [:FootballMarket | rest]} = node when rest != [] ->
          assert hd(rest) in [:Valuation, :Statistics, :Catalog], path

          if hd(rest) in [:Statistics, :Catalog],
            do:
              assert(
                Path.basename(path) in [
                  "statistics_reader.ex",
                  "request.ex",
                  "week.ex",
                  "replay.ex",
                  "evidence.ex"
                ]
              )

          node

        {:__aliases__, _, [name | _]} = node ->
          refute name in [
                   :Repo,
                   :Phoenix,
                   :Finch,
                   :Req,
                   :HTTPoison,
                   :Redix,
                   :Postgrex,
                   :File,
                   :System,
                   :Task,
                   :Port
                 ],
                 path

          node

        {{:., _, [_, function]}, _, _} = node ->
          refute function in [
                   :insert,
                   :insert!,
                   :insert_all,
                   :update,
                   :update!,
                   :update_all,
                   :delete,
                   :delete!,
                   :delete_all,
                   :record_match,
                   :record_performance,
                   :broadcast,
                   :send,
                   :utc_now,
                   :uniform,
                   :strong_rand_bytes
                 ],
                 path

          node

        node ->
          node
      end)

      refute Regex.match?(
               ~r/FootballMarketWeb|FootballMarket\.(Providers|Quotes|Trading|Cache)|:rand\.|:crypto\.|\bspawn\(/,
               source
             )
    end

    scorer_source = File.read!("test/support/valuation_scorers.ex")
    refute scorer_source =~ ~r/\b(Repo|Catalog|Statistics|Providers|System|DateTime)\b/
  end

  test "prepare, evaluate, score and replay leave immutable stored facts unchanged" do
    f = fixture()
    {match, row} = record(f, "original", %{goals: 1, minutes_played: 123})
    before = Statistics.get_performance(row.player_id, match.id)

    d = %Definition{
      module: FootballMarket.ValuationScorers.Weighted,
      strategy_id: "illustrative",
      version: "1",
      config: %{weights: %{overall: %{goals: 2}}, policy: :require_all}
    }

    assert {:ok, p} = Valuation.prepare(request(f))
    assert {:ok, result} = Valuation.evaluate(request(f), d)
    assert {:ok, ^result} = Valuation.score(p, d)
    assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
    assert Statistics.get_performance(row.player_id, match.id) == before
    assert Statistics.get_match(match.id) == {:ok, match}
    assert {:ok, history} = Statistics.list_player_history(row.player_id)
    assert length(history) == 1
  end

  test "legacy allowances are exact and active-feature-only" do
    feature = "specs/058-valuation-contract-normalization"

    for path <- [
          "test/football_market/statistics/scope_test.exs",
          "test/football_market/providers/scope_test.exs"
        ] do
      allowance = allowance(path)
      paths = allowance.(feature)
      assert Enum.all?(@legacy_production, &(&1 in paths))
      refute "lib/football_market/valuation/unplanned.ex" in paths
      refute "lib/football_market/catalog.ex" in paths
      refute "test/football_market/valuation/unplanned_test.exs" in paths
      assert allowance.("specs/other") == []
    end
  end

  defp allowance(path) do
    {_, body} =
      Macro.prewalk(Code.string_to_quoted!(File.read!(path)), nil, fn
        {:def, _, [{:valuation_paths, _, [_]}, [do: body]]} = node, _ -> {node, body}
        node, acc -> {node, acc}
      end)

    fn feature -> elem(Code.eval_quoted(body, active_feature: feature), 0) end
  end
end
