defmodule FootballMarket.E2E.CorrelatedLoggingTest do
  use ExUnit.Case, async: false
  @moduletag :e2e
  @tag timeout: 170_000
  import Ecto.Query
  import ExUnit.CaptureLog
  alias FootballMarket.{Repo, Accounts, Synchronization}
  alias FootballMarket.E2E.Runtime
  alias FootballMarket.Observability.JSONFormatter
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}

  test "real HTTP detail import downstream calculations and timeout reports use JSON context" do
    level = Logger.level()
    Logger.configure(level: :info)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn base ->
        scope = Fixtures.scope(2025)
        Case.seed_catalog!(scope)
        candidate = Case.candidate(Fixtures.request(scope))
        sync = Application.fetch_env!(:football_market, Synchronization)

        Application.put_env(
          :football_market,
          Synchronization,
          Keyword.put(sync, :sources, %{"logging-fixture" => Case.source(candidate)})
        )

        Application.put_env(:football_market, FootballMarket.Statistics.Freshness,
          refresh_options_by_scope: %{{"PL", 2025, 2026} => [source_ref: "logging-fixture"]}
        )

        {:ok, user} = Accounts.register_user(FootballMarket.AccountsCase.registration_attrs())
        {:ok, jwt} = Accounts.Authentication.issue(user.id)
        player = Repo.one!(FootballMarket.Catalog.Player)
        correlation = Ecto.UUID.generate()
        timeout_correlation = Ecto.UUID.generate()

        log =
          capture_log(JSONFormatter.options(), fn ->
            headers = [
              {~c"authorization", String.to_charlist("Bearer " <> jwt)},
              {~c"x-request-id", String.to_charlist(correlation)}
            ]

            assert {:ok, {{_, 200, _}, response_headers, body}} =
                     :httpc.request(
                       :get,
                       {String.to_charlist(base <> "/api/players/" <> player.id), headers},
                       [timeout: 5000],
                       body_format: :binary
                     )

            assert {~c"x-request-id", String.to_charlist(correlation)} in response_headers
            run_id = Jason.decode!(body)["statistics_status"]["refresh"]["run_id"]

            run =
              Runtime.await!(fn ->
                case Repo.get!(FootballMarket.Synchronization.Run, run_id) do
                  %{state: "succeeded"} = run -> {:ok, run}
                  _ -> :pending
                end
              end)

            assert run.correlation_id == correlation
            assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick()

            Runtime.await!(fn ->
              jobs =
                Repo.all(
                  from j in Oban.Job,
                    where:
                      j.worker in [
                        "FootballMarket.Workers.StatisticsImport",
                        "FootballMarket.Workers.CalculationDispatch"
                      ]
                )

              quote_jobs =
                Repo.all(
                  from j in Oban.Job,
                    where: j.worker == "FootballMarket.Workers.QuoteCalculation"
                )

              if length(jobs) == 2 and quote_jobs == [] and
                   Enum.all?(jobs, &(&1.state == "completed")),
                 do: {:ok, jobs},
                 else: :pending
            end)

            close_time = DateTime.add(DateTime.utc_now(), 2 * 86_400, :second)
            assert {:ok, %{imports: 1}} = FootballMarket.Quotes.Closing.admit_due(close_time)

            Runtime.await!(fn ->
              quote_jobs =
                Repo.all(
                  from j in Oban.Job,
                    where: j.worker == "FootballMarket.Workers.QuoteCalculation"
                )

              if length(quote_jobs) == 1 and Enum.all?(quote_jobs, &(&1.state == "completed")),
                do: {:ok, quote_jobs},
                else: :pending
            end)

            {:ok, timeout} =
              Oban.insert(
                FootballMarket.Observability.TimeoutWorker.new(
                  %{"private" => "DO-NOT-LOG"},
                  meta: %{"correlation_id" => timeout_correlation}
                )
              )

            Runtime.await!(fn ->
              if Repo.get!(Oban.Job, timeout.id).state == "discarded",
                do: {:ok, :discarded},
                else: :pending
            end)

            Logger.flush()
          end)

        records = log |> String.split("\n", trim: true) |> Enum.map(&Jason.decode!/1)
        linked = Enum.filter(records, &(&1["correlation_id"] == correlation))
        assert Enum.any?(linked, &(&1["event"] == "http.request.stop" and &1["status"] == 200))

        for worker <- [
              "FootballMarket.Workers.StatisticsImport",
              "FootballMarket.Workers.CalculationDispatch",
              "FootballMarket.Workers.QuoteCalculation"
            ] do
          assert Enum.any?(linked, &(&1["worker"] == worker and &1["event"] == "job.start"))
          assert Enum.any?(linked, &(&1["worker"] == worker and &1["event"] == "job.stop"))
        end

        assert Enum.any?(
                 records,
                 &(&1["correlation_id"] == timeout_correlation and
                     &1["event"] == "job.exception" and &1["execution_state"] == "discard")
               )

        refute log =~ jwt
        refute log =~ "DO-NOT-LOG"
      end)
    after
      Logger.configure(level: level)
    end
  end
end
