defmodule FootballMarket.Market.ScopeTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.MarketCase

  test "exact planned inventory exists and active allowance fails closed" do
    paths = MarketCase.inventory()
    feature = active_feature()

    allowances =
      for path <- [
            "test/football_market/statistics/scope_test.exs",
            "test/football_market/providers/scope_test.exs"
          ],
          do: allowance(path)

    changed =
      product_change_lines(["lib", "config", "priv", "test", ".github/workflows"])

    quality_paths = ["config/credo_inventory.json"]

    for line <- changed, not is_nil(feature) do
      path = String.slice(line, 3..-1//1)

      assert path in (paths ++
                        synchronization_paths(feature) ++
                        FootballMarket.BrowserSessionCase.shell_paths(feature) ++
                        FootballMarket.WorkflowScope.paths(feature) ++ quality_paths) or
               FootballMarket.WorkflowScope.allows_path?(feature, path),
             "outside initial issuance plan: #{line}"
    end

    assert length(paths) == 25
    assert length(paths) == length(Enum.uniq(paths))
    assert Enum.all?(paths, &File.regular?/1)

    assert Enum.sort(Path.wildcard("lib/football_market/market/*.ex")) ==
             Enum.sort(
               Enum.filter(paths, &String.starts_with?(&1, "lib/football_market/market/"))
             )

    assert Enum.sort(Path.wildcard("test/football_market/market/*_test.exs")) ==
             Enum.sort(
               Enum.filter(paths, &String.starts_with?(&1, "test/football_market/market/"))
             )

    for path <- paths do
      assert MarketCase.allowed("specs/062-initial-player-token-issuance", path)
      refute MarketCase.allowed("specs/unknown", path)
      for fun <- allowances, do: assert(path in fun.("specs/062-initial-player-token-issuance"))
    end

    for feature <- [nil, "specs/unknown"], fun <- allowances do
      assert fun.(feature) == []
    end

    refute MarketCase.allowed(
             "specs/062-initial-player-token-issuance",
             "lib/football_market/market/unplanned.ex"
           )

    for fun <- allowances do
      assert Enum.sort(fun.("specs/062-initial-player-token-issuance")) == Enum.sort(paths)

      refute "lib/football_market/market/unplanned.ex" in fun.(
               "specs/062-initial-player-token-issuance"
             )
    end

    assert File.read!("mix.exs") =~ "test/support"

    for path <- Enum.filter(paths, &String.ends_with?(&1, "_test.exs")) do
      text = File.read!(path)
      assert length(Regex.scan(~r/@moduletag :(unit|integration)/, text)) == 1
      refute text =~ ~r/@tag\s+:skip|@moduletag\s+:skip/
    end
  end

  test "pure domain, trusted facade and persistence retain narrow dependency and write boundaries" do
    for name <- ~w(input consistency error) do
      source = File.read!("lib/football_market/market/#{name}.ex")

      refute source =~
               ~r/\b(Repo|Postgrex|DBConnection|Application|System)\b|DateTime\.(utc_now|now)|:ets/
    end

    facade = File.read!("lib/football_market/market.ex")
    refute facade =~ ~r/\bRepo\b|Ecto.Query|query!/
    functions = FootballMarket.Market.__info__(:functions)

    assert Enum.sort(functions) == [
             get_initial_issuance: 1,
             initialize_player: 1,
             initialize_player: 2
           ]

    for path <- [
          "lib/football_market/market.ex" | Path.wildcard("lib/football_market/market/*.ex")
        ] do
      source = File.read!(path)

      refute source =~
               ~r/FootballMarketWeb|FootballMarket\.(Providers|Valuation|Trading)|\b(Oban|Redix|Req|Finch)\b|PubSub|String.to_atom|Task\.async/

      refute source =~ ~r/password|credential|balance|purchase|\bsale\b|\bfloat\b/
    end

    store = File.read!("lib/football_market/market/store.ex")

    assert Enum.sort(Regex.scan(~r/Repo\.insert!\(%(\w+)/, store) |> Enum.map(fn [_, m] -> m end)) ==
             ~w(Holding InitialRecipient Issuance Quote)

    refute store =~ ~r/Repo\.(update|delete|insert_all)|UPDATE\s|DELETE\s|INSERT\s/i
    assert_config_boundary(File.read!("config/config.exs"))

    assert Application.get_env(:football_market, :initial_issuance_recipients) == []

    for path <- Path.wildcard("lib/football_market_web/**/*.ex") do
      refute File.read!(path) =~ "initialize_player"
    end
  end

  test "configuration boundary rejects changes outside the approved fail-closed default" do
    source = File.read!("config/config.exs")

    for changed <- [
          String.replace(
            source,
            "initial_issuance_recipients: []",
            "initial_issuance_recipients: [:other]"
          ),
          String.replace(source, ",\n  initial_issuance_recipients: []", ""),
          String.replace(
            source,
            "initial_issuance_recipients: []",
            "initial_issuance_recipients: [], initial_issuance_recipients: []"
          ),
          String.replace(
            source,
            "development_seed_enabled: false",
            "development_seed_enabled: true"
          ),
          String.replace(source, "t_cost: 2", "t_cost: 1"),
          source <> "\nconfig :football_market, unplanned: true\n"
        ] do
      refute changed == source
      assert_raise ExUnit.AssertionError, fn -> assert_config_boundary(changed) end
    end
  end

  defp assert_config_boundary(source) do
    # Normalize only the approved TASK-046 secret-filter extension.
    source =
      String.replace(
        source,
        ~s(["password", "token", "cursor", "browser_handle", "token_digest", "secret"]),
        ~s(["password", "token", "cursor"])
      )

    # Pin the approved configuration, including the fail-closed issuance default.
    # Git HEAD changes after publication and is not a stable content oracle.
    assert Base.encode16(:crypto.hash(:sha256, source), case: :lower) ==
             "b2f9904816f5efed3b630e782e7519058f96b18dc8b5d101dcbeb81ec8577251"
  end

  # Evaluate the actual allowlist function without loading the unit test module
  # into the integration profile; preserve independent profile membership.
  defp allowance(path) do
    {_, functions} =
      Macro.prewalk(Code.string_to_quoted!(File.read!(path)), [], fn
        {:def, _, [{:market_paths, _, [arg]}, [do: body]]} = node, acc ->
          {fun, _} = Code.eval_quoted({:fn, [], [{:->, [], [[arg], body]}]})
          {node, [fun | acc]}

        node, acc ->
          {node, acc}
      end)

    assert [fun] = functions
    fun
  end

  def synchronization_paths(feature) do
    if feature == "specs/063-scheduled-synchronization-jobs" do
      [
        "lib/football_market/synchronization.ex",
        "lib/football_market/synchronization/input.ex",
        "lib/football_market/synchronization/policy.ex",
        "lib/football_market/synchronization/clock.ex",
        "lib/football_market/synchronization/run.ex",
        "lib/football_market/synchronization/attempt.ex",
        "lib/football_market/synchronization/trigger.ex",
        "lib/football_market/synchronization/schedule.ex",
        "lib/football_market/synchronization/occurrence.ex",
        "lib/football_market/synchronization/store.ex",
        "lib/football_market/synchronization/execution_guard.ex",
        "lib/football_market/synchronization/scheduler.ex",
        "lib/football_market/synchronization/recovery.ex",
        "lib/football_market/synchronization/dispatcher.ex",
        "lib/football_market/workers/catalog_sync.ex",
        "lib/football_market/catalog/ingestion/delivery_receipt.ex",
        "config/synchronization.exs",
        "priv/repo/migrations/20261015000000_add_oban.exs",
        "priv/repo/migrations/20261015000100_create_synchronization_ledgers.exs",
        "priv/repo/migrations/20261015000200_create_catalog_delivery_receipts.exs",
        "test/support/synchronization/case.ex",
        "test/support/synchronization/clock.ex",
        "test/support/synchronization/fixtures.ex",
        "test/support/synchronization/runtime_probe.ex",
        "test/fixtures/synchronization/expected.exs",
        "test/football_market/synchronization/input_test.exs",
        "test/football_market/synchronization/policy_test.exs",
        "test/football_market/synchronization/migration_test.exs",
        "test/football_market/synchronization/request_test.exs",
        "test/football_market/synchronization/inspection_test.exs",
        "test/football_market/synchronization/scheduler_test.exs",
        "test/football_market/synchronization/concurrency_test.exs",
        "test/football_market/synchronization/retry_test.exs",
        "test/football_market/synchronization/recovery_test.exs",
        "test/football_market/synchronization/integrity_test.exs",
        "test/football_market/synchronization/scope_test.exs",
        "test/football_market/catalog/ingestion/delivery_receipt_test.exs",
        "test/football_market/catalog/query_test.exs",
        "mix.exs",
        "mix.lock",
        "lib/football_market/application.ex",
        "config/runtime.exs",
        "config/test.exs",
        "lib/football_market/catalog/ingestion.ex",
        "lib/football_market/catalog/ingestion/publisher.ex",
        "test/football_market/providers/scope_test.exs",
        "test/football_market/statistics/scope_test.exs",
        "test/football_market/market/scope_test.exs"
      ]
    else
      []
    end
  end

  defp product_change_lines(paths) do
    case System.cmd("git", ["rev-parse", "--verify", "MERGE_HEAD"]) do
      {_merge_head, 0} ->
        {changed, 0} = System.cmd("git", ["diff", "--name-only", "MERGE_HEAD", "--" | paths])

        {untracked, 0} =
          System.cmd("git", ["ls-files", "--others", "--exclude-standard", "--" | paths])

        Enum.map(String.split(changed, "\n", trim: true), &(" M " <> &1)) ++
          Enum.map(String.split(untracked, "\n", trim: true), &("?? " <> &1))

      _ ->
        {out, 0} =
          System.cmd("git", ["status", "--porcelain", "--untracked-files=all", "--" | paths])

        String.split(out, "\n", trim: true)
    end
  end

  defp active_feature, do: FootballMarket.WorkflowScope.active_feature()
end
