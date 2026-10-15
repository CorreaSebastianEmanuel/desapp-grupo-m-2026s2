defmodule FootballMarket.Synchronization.ScopeTest do
  use ExUnit.Case, async: false
  @moduletag :integration

  test "feature inventory stays exact and unknown features receive no allowance" do
    for path <-
          ~w(test/football_market/providers/scope_test.exs test/football_market/statistics/scope_test.exs test/football_market/market/scope_test.exs) do
      {_, functions} =
        Macro.prewalk(Code.string_to_quoted!(File.read!(path)), [], fn
          {:def, _, [{:synchronization_paths, _, [arg]}, [do: body]]} = node, acc ->
            {fun, _} = Code.eval_quoted({:fn, [], [{:->, [], [[arg], body]}]})
            {node, [fun | acc]}

          node, acc ->
            {node, acc}
        end)

      assert length(functions) == 1, "missing exact synchronization allowance in #{path}"
      [fun] = functions
      assert fun.(nil) == []
      assert fun.("specs/unknown") == []
      paths = fun.("specs/063-scheduled-synchronization-jobs")
      assert "lib/football_market/synchronization/store.ex" in paths
      refute "lib/football_market/synchronization/unplanned.ex" in paths
      refute "config/config.exs" in paths
      refute "lib/football_market/market/store.ex" in paths
      assert length(paths) == length(Enum.uniq(paths))
      assert Enum.all?(paths, &File.regular?/1)
    end
  end

  test "synchronization production has no financial/statistics/cache/web boundary" do
    files = [
      "lib/football_market/synchronization.ex",
      "lib/football_market/workers/catalog_sync.ex"
      | Path.wildcard("lib/football_market/synchronization/*.ex")
    ]

    for file <- files do
      text = File.read!(file)

      refute text =~
               ~r/FootballMarketWeb|FootballMarket\.(Market|Statistics|Valuation|Trading)|Redix|PubSub|String\.to_atom\(|\.performances\(/
    end

    assert File.read!("lib/football_market/workers/catalog_sync.ex") =~ "Ingestion.import_catalog"
    assert Application.fetch_env!(:football_market, Oban)[:plugins] == []
    assert File.read!("config/synchronization.exs") =~ "enabled: false"
    assert File.read!("config/synchronization.exs") =~ "catalog_sync: 1"
  end
end
