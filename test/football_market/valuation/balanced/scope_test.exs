defmodule FootballMarket.Valuation.Balanced.ScopeTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Statistics}
  alias FootballMarket.Valuation.{Balanced, Definition}

  @planned [
             "lib/football_market/valuation/balanced.ex",
             "lib/football_market/valuation/decimal_math.ex"
           ] ++
             Enum.map(
               ~w(config formula outcomes arithmetic replay scope),
               &"test/football_market/valuation/balanced/#{&1}_test.exs"
             ) ++
             Enum.map(
               ~w(valuation statistics providers),
               &"test/football_market/#{&1}/scope_test.exs"
             )

  test "active allowances equal the exact eleven paths and preserve legacy exclusions" do
    assert length(@planned) == 11

    for path <- ~w(statistics providers) do
      source = File.read!("test/football_market/#{path}/scope_test.exs")

      {_, body} =
        Macro.prewalk(Code.string_to_quoted!(source), nil, fn
          {:def, _, [{:valuation_paths, _, [_]}, [do: body]]} = node, _ -> {node, body}
          node, acc -> {node, acc}
        end)

      allowance = fn feature -> elem(Code.eval_quoted(body, active_feature: feature), 0) end
      assert Enum.sort(allowance.("specs/059-balanced-valuation-strategy")) == Enum.sort(@planned)
      assert allowance.("specs/unknown") == []

      refute "lib/football_market/valuation/balanced.ex" in allowance.(
               "specs/058-valuation-contract-normalization"
             )

      for forbidden <- [
            "lib/football_market/catalog.ex",
            "lib/football_market/valuation/unplanned.ex",
            "test/football_market/valuation/balanced/unplanned_test.exs"
          ] do
        refute forbidden in allowance.("specs/059-balanced-valuation-strategy")
      end
    end
  end

  test "production scorer exists and has only pure feature/config dependencies" do
    source = File.read!("lib/football_market/valuation/balanced.ex")

    Macro.prewalk(Code.string_to_quoted!(source), fn
      {:__aliases__, _, [:FootballMarket | rest]} = node ->
        assert hd(rest) == :Valuation
        node

      {:__aliases__, _, [name | _]} = node ->
        refute name in [
                 :Repo,
                 :Catalog,
                 :Statistics,
                 :Providers,
                 :Phoenix,
                 :Finch,
                 :Req,
                 :Redix,
                 :System,
                 :File,
                 :Task,
                 :Port,
                 :DateTime
               ]

        node

      {name, _, args} = node when is_atom(name) and is_list(args) ->
        refute name in [:send, :spawn, :spawn_link, :spawn_monitor, :apply]
        node

      {{:., _, [_, name]}, _, _} = node ->
        refute name in [
                 :insert,
                 :insert!,
                 :update,
                 :update!,
                 :delete,
                 :delete!,
                 :broadcast,
                 :send,
                 :spawn,
                 :utc_now,
                 :uniform,
                 :strong_rand_bytes
               ]

        node

      node ->
        node
    end)

    refute source =~ ~r/FootballMarketWeb|Providers|Quotes|Trading|Cache|:rand|:crypto|:erlang/
  end

  test "local workflows succeed with providers unavailable, with no writes or follow-up events" do
    f = fixture()
    {match, row} = record(f, "original", %{goals: 1, saves: nil})
    before = Statistics.get_performance(row.player_id, match.id)
    req = request(f)

    d = %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: %{goals: 2}}
    }

    assert {:ok, p} = Valuation.prepare(req)
    owner = self()
    handler = {__MODULE__, make_ref()}
    old = Application.fetch_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)

    on_exit(fn ->
      case old do
        {:ok, value} -> Application.put_env(:football_market, FootballMarket.Providers, value)
        :error -> Application.delete_env(:football_market, FootballMarket.Providers)
      end
    end)

    :ok =
      :telemetry.attach(
        handler,
        [:football_market, :repo, :query],
        &__MODULE__.capture_query/4,
        owner
      )

    tracer = spawn(fn -> trace_events(owner) end)

    for module <- [Phoenix.PubSub, FootballMarket.Providers] do
      Code.ensure_loaded!(module)
      :erlang.trace_pattern({module, :_, :_}, true, [:local])
    end

    :erlang.trace(owner, true, [:call, {:tracer, tracer}])

    try do
      assert {:ok, result} = Valuation.evaluate(req, d)
      assert {:ok, ^result} = Valuation.score(p, d)
      assert {:ok, ^result} = Valuation.replay(result.descriptor, d)

      assert {:error, %{kind: :validation}} =
               Valuation.evaluate(req, %{d | config: %{weights: %{}}})

      assert {:error, %{kind: :insufficient_data}} =
               Valuation.evaluate(
                 %{
                   req
                   | requirements: %{overall: [:goals, :saves]},
                     references: %{goals: 4, saves: 1}
                 },
                 %{d | config: %{weights: %{goals: 2, saves: 0}}}
               )

      assert {:error, %{kind: :inconsistent_replay}} = Valuation.score(%{p | scopes: %{}}, d)

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay(%{result.descriptor | score: "99.000000"}, d)

      assert Statistics.get_performance(row.player_id, match.id) == before
      assert Statistics.get_match(match.id) == {:ok, match}
      assert {:ok, history} = Statistics.list_player_history(row.player_id)
      assert length(history) == 1
      delivery = :erlang.trace_delivered(owner)
      assert_receive {:trace_delivered, ^owner, ^delivery}
      send(tracer, {:flush, owner})
      assert_receive :trace_flushed
      refute_receive {:effect_call, _}
      queries = queries([])
      assert queries != []

      for query <- queries do
        refute query =~ ~r/\b(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE)\b/i
      end
    after
      :erlang.trace(owner, false, [:call])

      for module <- [Phoenix.PubSub, FootballMarket.Providers],
          do: :erlang.trace_pattern({module, :_, :_}, false, [:local])

      send(tracer, :stop)
      :telemetry.detach(handler)
    end
  end

  def capture_query(_, _, metadata, owner) do
    if self() == owner, do: send(owner, {:valuation_query, metadata.query})
  end

  defp queries(acc) do
    receive do
      {:valuation_query, query} -> queries([query | acc])
    after
      0 -> acc
    end
  end

  defp trace_events(owner) do
    receive do
      {:trace, ^owner, :call, call} ->
        send(owner, {:effect_call, call})
        trace_events(owner)

      {:flush, ^owner} ->
        send(owner, :trace_flushed)
        trace_events(owner)

      :stop ->
        :ok
    end
  end
end

defmodule FootballMarket.Valuation.Balanced.ReadFailureTest do
  use FootballMarket.DataCase, async: true
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Balanced, Definition}

  test "public evaluate exposes infrastructure read failure instead of empty football history" do
    f = fixture()
    record(f, "original", %{goals: 1})
    req = request(f)

    d = %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: %{goals: 2}}
    }

    # The application sandbox defaults to :auto. Isolate a manual pool rather
    # than changing global ownership mode or stopping shared services.
    pool = start_supervised!({Repo, name: nil, ownership_mode: :manual, pool_size: 1})
    owner = self()

    {pid, ref} =
      spawn_monitor(fn ->
        Repo.put_dynamic_repo(pool)

        outcome =
          try do
            {:returned, Valuation.evaluate(req, d)}
          rescue
            error in DBConnection.OwnershipError -> {:read_failure, error.__struct__}
          end

        send(owner, {:read_outcome, self(), outcome})
      end)

    assert_receive {:read_outcome, ^pid, {:read_failure, DBConnection.OwnershipError}}, 5000
    assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
  end
end
