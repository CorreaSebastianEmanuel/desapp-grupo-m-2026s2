defmodule FootballMarket.Statistics.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  if System.get_env("MIX_TEST_PARTITION") == "statistics_concurrency" do
    alias FootballMarket.{Repo, Statistics}
    alias FootballMarket.Statistics.Match
    import FootballMarket.StatisticsCase
    alias Ecto.Adapters.SQL.Sandbox

    defp start(fun) do
      task = Task.async(fn -> Sandbox.unboxed_run(Repo, fun) end)

      ExUnit.Callbacks.on_exit(fn ->
        if Process.alive?(task.pid), do: Process.exit(task.pid, :kill)
      end)

      task
    end

    defp concurrent(fun1, fun2) do
      parent = self()

      tasks =
        for fun <- [fun1, fun2] do
          start(fn ->
            send(parent, {:ready, self()})

            receive do
              :go -> fun.()
            after
              5000 -> raise "barrier timeout"
            end
          end)
        end

      for _ <- tasks, do: assert_receive({:ready, _}, 5000)
      for task <- tasks, do: send(task.pid, :go)
      Enum.map(tasks, &Task.await(&1, 10000))
    end

    defp fixture!, do: Sandbox.unboxed_run(Repo, &unique_fixture/0)

    test "identical and conflicting normalized match races have exactly one winner" do
      f = fixture!()

      for conflict <- [false, true], padding <- ["\t", "\u00A0", "\u2003\u202F"] do
        attrs = match_attrs(f)

        other = %{
          attrs
          | match_identity: "#{padding}#{String.upcase(attrs.match_identity)}#{padding}",
            kickoff_at: if(conflict, do: "2026-02-02T12:00:00Z", else: attrs.kickoff_at)
        }

        results =
          concurrent(fn -> Statistics.record_match(attrs) end, fn ->
            Statistics.record_match(other)
          end)

        assert Enum.count(results, &match?({:ok, _}, &1)) == 1
        assert Enum.count(results, &match?({:error, %{kind: :conflict}}, &1)) == 1
        {:ok, winner} = Enum.find(results, &match?({:ok, _}, &1))

        assert {:ok, ^winner} =
                 Sandbox.unboxed_run(Repo, fn ->
                   Statistics.get_match(f.season.id, attrs.match_identity)
                 end)
      end
    end

    test "identical and conflicting pair races retain exactly one unchanged fact" do
      f = fixture!()

      for conflict <- [false, true] do
        {:ok, m} = Sandbox.unboxed_run(Repo, fn -> Statistics.record_match(match_attrs(f)) end)
        attrs = performance_attrs(f, m)
        other = Map.put(attrs, :goals, if(conflict, do: 7, else: nil))

        results =
          concurrent(fn -> Statistics.record_performance(attrs) end, fn ->
            Statistics.record_performance(other)
          end)

        assert Enum.count(results, &match?({:ok, _}, &1)) == 1
        assert Enum.count(results, &match?({:error, %{kind: :conflict}}, &1)) == 1
        {:ok, winner} = Enum.find(results, &match?({:ok, _}, &1))

        assert {:ok, ^winner} =
                 Sandbox.unboxed_run(Repo, fn ->
                   Statistics.get_performance(winner.player_id, m.id)
                 end)
      end
    end

    defp interleaved(first, second) do
      parent = self()

      t1 =
        start(fn ->
          Repo.transaction(fn ->
            result = first.()
            send(parent, {:first_written, self()})

            receive do
              :commit -> result
            after
              5000 -> raise "commit barrier timeout"
            end
          end)
        end)

      assert_receive {:first_written, pid}, 5000

      t2 =
        start(fn ->
          %{rows: [[backend]]} = Ecto.Adapters.SQL.query!(Repo, "SELECT pg_backend_pid()")
          send(parent, {:second_started, backend})

          try do
            second.()
          rescue
            error in Postgrex.Error -> {:db_error, error.postgres.code}
          end
        end)

      assert_receive {:second_started, backend}, 5000
      # A database lock wait demonstrates real concurrent connections, not Sandbox sharing.
      Sandbox.unboxed_run(Repo, fn ->
        deadline = System.monotonic_time(:millisecond) + 5000
        wait_for_lock(deadline, backend)
      end)

      send(pid, :commit)
      {Task.await(t1, 10000), Task.await(t2, 10000)}
    end

    defp wait_for_lock(deadline, backend) do
      %{rows: [[waiting]]} =
        Ecto.Adapters.SQL.query!(
          Repo,
          "SELECT count(*) FROM pg_stat_activity WHERE datname = current_database() AND wait_event_type = 'Lock' AND pid = $1",
          [backend]
        )

      cond do
        waiting > 0 ->
          :ok

        System.monotonic_time(:millisecond) > deadline ->
          flunk("second connection never waited on database lock")

        true ->
          Process.sleep(10)
          wait_for_lock(deadline, backend)
      end
    end

    test "season metadata mutation cannot race a stale witness insert in either order" do
      for order <- [:insert_first, :mutation_first] do
        f = fixture!()
        attrs = match_attrs(f) |> Map.put(:kickoff_at, ~U[2026-01-01 12:00:00.123456Z])
        insert = fn -> Repo.insert(Match.changeset(attrs, f.season)) end
        {:ok, uuid} = Ecto.UUID.dump(f.season.id)

        mutate = fn ->
          Ecto.Adapters.SQL.query!(
            Repo,
            "UPDATE seasons SET start_year = start_year + 1, end_year = end_year + 1 WHERE id = $1",
            [uuid]
          )
        end

        case order do
          :insert_first ->
            assert {{:ok, {:ok, m}}, {:db_error, :foreign_key_violation}} =
                     interleaved(insert, mutate)

            assert {:ok, ^m} = Sandbox.unboxed_run(Repo, fn -> Statistics.get_match(m.id) end)

          :mutation_first ->
            assert {{:ok, _}, {:error, %Ecto.Changeset{}}} = interleaved(mutate, insert)

            assert {:error, :not_found} =
                     Sandbox.unboxed_run(Repo, fn ->
                       Statistics.get_match(f.season.id, attrs.match_identity)
                     end)
        end
      end
    end
  else
    test "default suite executes nonempty independent committed race cases" do
      env = [
        {"MIX_TEST_PARTITION", "statistics_concurrency"},
        {"CP1_PROFILE", nil},
        {"CP1_PROFILE_COVERAGE", nil},
        {"CP1_PROFILE_RECEIPT", nil},
        {"CP1_PROFILE_SENTINEL_PATH", nil}
      ]

      {out, status} =
        System.cmd("mix", ["test", __ENV__.file, "--warnings-as-errors"],
          env: env,
          stderr_to_stdout: true
        )

      assert status == 0, String.slice(out, -4000, 4000)
      assert Regex.match?(~r/Result: [1-9]\d*(?:\/[1-9]\d*)? passed/, out), out
      refute String.contains?(out, "Failed:")
    end
  end
end
