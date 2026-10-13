defmodule FootballMarket.Valuation.Configurations.ScopeTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.{Valuation, ValuationCase}
  alias FootballMarket.Valuation.Configurations

  test "exact 33-path active inventory preserves inherited exclusions and module purity" do
    inventory = FootballMarket.ValuationConfigurationCase.inventory()
    assert length(inventory) == 33
    assert Enum.all?(inventory, &File.regular?/1)
    production = Enum.filter(inventory, &String.starts_with?(&1, "lib/"))
    new_root = ~w(configurations managed managed_types)

    actual =
      Path.wildcard("lib/football_market/valuation/configurations/*.ex") ++
        Enum.map(new_root, &"lib/football_market/valuation/#{&1}.ex")

    assert Enum.sort(actual) ==
             Enum.sort(
               production --
                 ["lib/football_market/valuation.ex", "lib/football_market/valuation/request.ex"]
             )

    for path <- ~w(statistics providers) do
      source = File.read!("test/football_market/#{path}/scope_test.exs")

      {_, body} =
        Macro.prewalk(Code.string_to_quoted!(source), nil, fn
          {:def, _, [{:valuation_paths, _, [_]}, [do: body]]} = node, _ -> {node, body}
          node, acc -> {node, acc}
        end)

      allowance = fn feature -> elem(Code.eval_quoted(body, active_feature: feature), 0) end

      assert Enum.sort(allowance.("specs/061-valuation-strategy-versioning")) ==
               Enum.sort(inventory)

      assert allowance.("specs/unknown") == []

      for forbidden <- [
            "lib/football_market/catalog.ex",
            "lib/football_market/valuation/unplanned.ex",
            "test/football_market/valuation/configurations/unplanned_test.exs"
          ] do
        refute forbidden in allowance.("specs/061-valuation-strategy-versioning")
      end

      assert "lib/football_market/valuation/position_aware.ex" in allowance.(
               "specs/060-position-aware-valuation"
             )

      assert "lib/football_market/valuation/balanced.ex" in allowance.(
               "specs/059-balanced-valuation-strategy"
             )
    end

    for path <- production do
      source = File.read!(path)

      refute source =~
               ~r/FootballMarketWeb|FootballMarket\.(Providers|Quotes|Trading|Cache)|\b(Finch|Req|Redix|HTTPoison|Task|Port)\b/

      Macro.prewalk(Code.string_to_quoted!(source), fn
        {{:., _, [_, function]}, _, _} = node ->
          refute function in [
                   :to_atom,
                   :to_existing_atom,
                   :binary_to_term,
                   :utc_now,
                   :broadcast,
                   :apply
                 ]

          if not String.ends_with?(path, "/store.ex"),
            do:
              refute(
                function in [:insert, :insert!, :insert_all, :update, :delete, :query!, :query]
              )

          node

        {:__aliases__, _, [:FootballMarket, :Repo]} = node ->
          assert String.ends_with?(path, "/store.ex")
          node

        node ->
          node
      end)
    end

    registry = File.read!("lib/football_market/valuation/configurations/registry.ex")
    assert registry =~ ~s|resolve("balanced", "1")|
    assert registry =~ ~s|resolve("position_aware", "1")|
    refute registry =~ "Application."
  end

  test "SQL and provider/event/external/job boundaries permit only own lifecycle inserts" do
    f = ValuationCase.fixture()
    {match, performance} = ValuationCase.record(f, "original", %{goals: 1})
    original = FootballMarket.Statistics.get_performance(performance.player_id, match.id)
    owner = self()
    handler = {__MODULE__, make_ref()}
    :telemetry.attach(handler, [:football_market, :repo, :query], &__MODULE__.query/4, owner)
    boundaries = [FootballMarket.Providers, Phoenix.PubSub, :httpc, Redix]

    jobs = [
      {Task, :start, :_},
      {Task, :start_link, :_},
      {Task, :async, :_},
      {Task, :async_stream, :_}
    ]

    for pattern <- jobs, do: :erlang.trace_pattern(pattern, true, [:local])
    tracer = spawn(fn -> trace_events(owner) end)

    for m <- boundaries do
      Code.ensure_loaded!(m)
      :erlang.trace_pattern({m, :_, :_}, true, [:local])
    end

    :erlang.trace(owner, true, [:call, {:tracer, tracer}])
    old = Application.fetch_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)

    try do
      assert {:ok, a} = Configurations.create(rules(f.position.id))
      writes = queries() |> mutations()
      assert length(writes) == 1
      assert hd(writes) =~ ~r/INSERT INTO "valuation_configuration_versions"/i
      assert {:ok, _} = Configurations.activate(a.id, nil)
      writes = queries() |> mutations()
      assert length(writes) == 1
      assert hd(writes) =~ ~r/INSERT INTO "valuation_selection_changes"/i
      assert {:ok, _} = Configurations.list()
      assert {:ok, _} = Configurations.get(a.id)
      assert {:ok, _} = Configurations.active()
      assert {:ok, _} = Configurations.history()
      assert {:ok, result} = Valuation.evaluate_managed(subject(f), :active)

      assert {:error, %{kind: :validation}} =
               Valuation.evaluate_managed(Map.put(subject(f), :config, %{}), :active)

      assert {:error, %{kind: :validation}} = Configurations.create(%{})
      assert {:error, %{kind: :conflict}} = Configurations.activate(a.id, nil)
      assert {:ok, %{change: nil}} = Configurations.activate(a.id, a.id)
      reads = queries()
      assert reads != []
      assert mutations(reads) == []
      assert result.score == "1.000000"
      assert {:ok, ^result} = Valuation.replay_managed(result.descriptor)

      assert {:error, %{kind: :inconsistent_replay}} =
               Valuation.replay_managed(%{
                 result.descriptor
                 | evidence: %{result.descriptor.evidence | score: "99.000000"}
               })

      assert mutations(queries()) == []

      assert FootballMarket.Statistics.get_performance(performance.player_id, match.id) ==
               original

      delivery = :erlang.trace_delivered(owner)
      assert_receive {:trace_delivered, ^owner, ^delivery}
      send(tracer, :flush)
      assert_receive :flushed
      refute_receive {:effect, _}
    after
      :erlang.trace(owner, false, [:call])
      for m <- boundaries, do: :erlang.trace_pattern({m, :_, :_}, false, [:local])
      for pattern <- jobs, do: :erlang.trace_pattern(pattern, false, [:local])
      send(tracer, :stop)
      :telemetry.detach(handler)

      case old do
        {:ok, value} -> Application.put_env(:football_market, FootballMarket.Providers, value)
        :error -> Application.delete_env(:football_market, FootballMarket.Providers)
      end
    end
  end

  test "real isolated database read failures stay visible across management and calculations" do
    f = ValuationCase.fixture()
    {:ok, v} = Configurations.create(rules(f.position.id))
    record(f, "storage-original", %{goals: 1})
    {:ok, original} = Valuation.evaluate_managed(subject(f), {:version, v.id})

    for fun <- [
          fn -> Configurations.list() end,
          fn -> Configurations.get(v.id) end,
          fn -> Configurations.active() end,
          fn -> Configurations.history() end,
          fn -> Valuation.evaluate_managed(subject(f), :active) end,
          fn -> Valuation.evaluate_managed(subject(f), {:version, v.id}) end,
          fn -> Valuation.replay_managed(original.descriptor) end,
          fn -> Configurations.create(rules(f.position.id)) end,
          fn -> Configurations.activate(v.id, nil) end
        ] do
      error =
        assert_raise Postgrex.Error, fn ->
          Repo.transaction(fn ->
            Repo.query!("SET LOCAL search_path TO pg_catalog")
            fun.()
          end)
        end

      assert error.postgres.code == :undefined_table
    end

    assert {:ok, %{version: ^v}} = Configurations.get(v.id)
  end

  def query(_, _, metadata, owner),
    do: if(self() == owner, do: send(owner, {:sql, metadata.query}))

  defp queries(acc \\ []) do
    receive do
      {:sql, q} -> queries([q | acc])
    after
      0 -> acc
    end
  end

  defp mutations(qs),
    do:
      Enum.filter(
        qs,
        &Regex.match?(~r/^\s*(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP|TRUNCATE)\b/i, &1)
      )

  defp trace_events(owner) do
    receive do
      {:trace, ^owner, :call, {Task, :async_stream, [functions, mapper, _]}} ->
        # Ecto's inherited parallel read preloads are not market follow-up jobs.
        allowed =
          is_list(functions) and is_function(mapper) and
            :erlang.fun_info(mapper, :module) == {:module, Ecto.Repo.Preloader} and
            Enum.all?(
              functions,
              &(is_function(&1) and
                  :erlang.fun_info(&1, :module) == {:module, Ecto.Repo.Preloader})
            )

        unless allowed, do: send(owner, {:effect, :unexpected_task_stream})
        trace_events(owner)

      {:trace, ^owner, :call, call} ->
        send(owner, {:effect, call})
        trace_events(owner)

      :flush ->
        send(owner, :flushed)
        trace_events(owner)

      :stop ->
        :ok
    end
  end
end
