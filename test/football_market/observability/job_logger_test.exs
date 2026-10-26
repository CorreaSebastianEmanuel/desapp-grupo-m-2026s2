defmodule FootballMarket.Observability.JobLoggerTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  import ExUnit.CaptureLog
  alias FootballMarket.Observability.{Context, JSONFormatter}

  setup do
    previous = Logger.metadata()
    level = Logger.level()
    Logger.configure(level: :info)

    on_exit(fn ->
      Logger.configure(level: level)
      Logger.reset_metadata(previous)
    end)

    :ok
  end

  defp job do
    %Oban.Job{
      id: 3601,
      worker: "Fixture.Worker",
      queue: "fixture",
      attempt: 2,
      max_attempts: 3,
      args: %{"request_id" => "11111111-1111-4111-8111-111111111111", "secret" => "DO-NOT-LOG"},
      meta: %{"correlation_id" => "origin", "secret" => "DO-NOT-LOG"}
    }
  end

  defp events(log), do: log |> String.split("\n", trim: true) |> Enum.map(&Jason.decode!/1)

  test "job lifecycle records only safe fields and restores caller metadata" do
    Logger.reset_metadata(correlation_id: "caller", request_id: "http", secret: "private")
    original = Logger.metadata()

    log =
      capture_log(JSONFormatter.options(), fn ->
        :telemetry.execute([:oban, :job, :start], %{system_time: 1}, %{job: job()})
        assert Logger.metadata()[:correlation_id] == "origin"
        refute Logger.metadata()[:request_id]

        :telemetry.execute([:oban, :job, :exception], %{duration: 1_000_000, queue_time: 0}, %{
          job: job(),
          state: :failure,
          kind: :error,
          reason: RuntimeError.exception("DO-NOT-LOG"),
          result: {:error, "DO-NOT-LOG"}
        })

        assert Logger.metadata() == original
      end)

    assert [start, failure] = events(log)
    assert start["event"] == "job.start"
    assert failure["event"] == "job.exception"
    assert failure["execution_state"] == "failure"
    assert failure["correlation_id"] == "origin"
    assert failure["attempt"] == 2
    assert failure["calculation_request_id"] == job().args["request_id"]
    refute log =~ "DO-NOT-LOG"
    refute log =~ "private"
    refute failure["request_id"]
  end

  test "terminal reporting in another process uses job context and restores reporter" do
    parent = self()

    log =
      capture_log(JSONFormatter.options(), fn ->
        task =
          Task.async(fn ->
            Logger.reset_metadata(correlation_id: "reporter", request_id: "reporter-http")

            :telemetry.execute([:oban, :job, :exception], %{duration: 0}, %{
              job: job(),
              state: :discard,
              kind: :exit,
              reason: "DO-NOT-LOG"
            })

            send(parent, {:restored, Context.capture()})
          end)

        Task.await(task)
      end)

    assert_receive {:restored, restored}
    assert Map.new(restored) == %{correlation_id: "reporter", request_id: "reporter-http"}
    assert [%{"event" => "job.exception", "correlation_id" => "origin"}] = events(log)
  end

  test "legacy jobs have deterministic IDs and registration is idempotent" do
    :ok = FootballMarket.Observability.attach()
    :ok = FootballMarket.Observability.attach()

    assert Enum.count(
             :telemetry.list_handlers([:oban, :job, :start]),
             &(&1.id == {FootballMarket.Observability, FootballMarket.Observability.JobLogger})
           ) == 1

    legacy = %{job() | meta: %{}}

    log =
      capture_log(JSONFormatter.options(), fn ->
        for _ <- 1..2 do
          :telemetry.execute([:oban, :job, :start], %{}, %{job: legacy})

          :telemetry.execute([:oban, :job, :stop], %{duration: 0}, %{job: legacy, state: :success})
        end
      end)

    assert length(events(log)) == 4
    assert Enum.uniq(Enum.map(events(log), & &1["correlation_id"])) == [legacy.args["request_id"]]
  end

  test "malformed optional data and unrelated legacy jobs keep the subscription alive" do
    malformed = %{job() | args: "invalid", meta: [invalid: true]}

    log =
      capture_log(JSONFormatter.options(), fn ->
        :telemetry.execute([:oban, :job, :start], %{}, %{job: malformed})

        :telemetry.execute([:oban, :job, :stop], %{duration: 0}, %{
          job: malformed,
          state: :success
        })

        FootballMarket.Observability.JobLogger.handle_event(
          [:oban, :job, :stop],
          :invalid,
          %{job: malformed},
          nil
        )
      end)

    assert [start, terminal] = events(log)
    assert start["execution_state"] == "executing"
    assert terminal["correlation_id"] == "oban:3601"

    assert Enum.any?(
             :telemetry.list_handlers([:oban, :job, :stop]),
             &(&1.id == {FootballMarket.Observability, FootballMarket.Observability.JobLogger})
           )
  end

  test "concurrent job processes keep their own context and restore their callers" do
    parent = self()

    log =
      capture_log(JSONFormatter.options(), fn ->
        1..8
        |> Enum.map(fn index ->
          Task.async(fn ->
            current = %{job() | id: 3700 + index, meta: %{"correlation_id" => "origin-#{index}"}}
            :telemetry.execute([:oban, :job, :start], %{}, %{job: current})
            send(parent, {:ready, self()})

            receive do
              :finish -> :ok
            end

            assert Logger.metadata()[:correlation_id] == "origin-#{index}"

            :telemetry.execute([:oban, :job, :stop], %{duration: 0}, %{
              job: current,
              state: :success
            })

            refute Logger.metadata()[:correlation_id]
          end)
        end)
        |> then(fn tasks ->
          for _ <- tasks, do: assert_receive({:ready, _})
          for task <- tasks, do: send(task.pid, :finish)
          Enum.each(tasks, &Task.await/1)
        end)
      end)

    for {id, records} <- Enum.group_by(events(log), & &1["job_id"]) do
      assert length(records) == 2
      assert Enum.uniq(Enum.map(records, & &1["correlation_id"])) == ["origin-#{id - 3700}"]
    end
  end
end
