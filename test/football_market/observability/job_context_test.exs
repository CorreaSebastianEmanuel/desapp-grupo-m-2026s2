defmodule FootballMarket.Observability.JobContextTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, FreshnessCase, Synchronization}
  alias FootballMarket.Observability.{Context, JobContext}
  alias FootballMarket.Synchronization.{Run, Recovery, Store}

  setup do
    previous = Logger.metadata()
    on_exit(fn -> Logger.reset_metadata(previous) end)
    {:ok, FreshnessCase.fixture()}
  end

  test "origin persists through coalescing retry and recovery without entering identity material",
       f do
    origin = Ecto.UUID.generate()

    first =
      Context.with_context([correlation_id: origin], fn ->
        Synchronization.request_statistics(f.scope, f.options)
      end)

    assert {:ok, first} = first
    run = Repo.get!(Run, first.run_id)
    original_job = Repo.get!(Oban.Job, run.job_id)
    assert run.correlation_id == origin
    assert original_job.meta["correlation_id"] == origin
    refute Map.has_key?(run.input, "correlation_id")
    assert {:ok, inspection} = Synchronization.get_run(run.id)
    refute Map.has_key?(inspection, :correlation_id)

    Context.with_context([correlation_id: Ecto.UUID.generate()], fn ->
      assert {:ok, %{disposition: :coalesced}} =
               Synchronization.request_statistics(f.scope, f.options)
    end)

    assert Repo.get!(Run, run.id).correlation_id == origin
    assert Repo.get!(Run, run.id).input_digest == run.input_digest

    Repo.update!(Ecto.Changeset.change(original_job, state: "discarded"))
    assert {:ok, _} = Recovery.reconcile(DateTime.utc_now())
    recovered = Repo.get!(Run, run.id)
    refute recovered.job_id == run.job_id
    assert Repo.get!(Oban.Job, recovered.job_id).meta["correlation_id"] == origin

    now = DateTime.utc_now()
    assert {:ok, _} = Store.claim(recovered.id, recovered.delivery_id, now)

    assert {:ok, _} =
             Store.complete(recovered.id, recovered.delivery_id, {:error, :interrupted}, now)

    retried = Repo.get!(Run, run.id)
    assert retried.state == "retry_wait"
    assert Repo.get!(Oban.Job, retried.job_id).meta["correlation_id"] == origin
  end

  test "delayed dispatch and quote recovery retain lineage even if the root job is removed", f do
    origin = Ecto.UUID.generate()
    run = Context.with_context([correlation_id: origin], fn -> FreshnessCase.perform!(f) end)
    intent = Repo.one!(FootballMarket.Statistics.Ingestion.CalculationIntent)
    Repo.delete!(Repo.get!(Oban.Job, run.job_id))
    assert JobContext.for_intents([intent.id]) == %{intent.id => origin}
    assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick()

    dispatch =
      Repo.one!(
        from j in Oban.Job, where: j.worker == "FootballMarket.Workers.CalculationDispatch"
      )

    assert dispatch.meta["correlation_id"] == origin
    assert :ok = FootballMarket.Workers.CalculationDispatch.perform(dispatch)
    calculation = Repo.one!(FootballMarket.Quotes.CalculationRequest)

    assert Repo.all(
             from j in Oban.Job, where: j.worker == "FootballMarket.Workers.QuoteCalculation"
           ) == []

    close_time = DateTime.add(DateTime.utc_now(), 2 * 86_400, :second)
    assert {:ok, %{imports: 1}} = FootballMarket.Quotes.Closing.admit_due(close_time)

    job =
      Repo.one!(from j in Oban.Job, where: j.worker == "FootballMarket.Workers.QuoteCalculation")

    assert job.meta["correlation_id"] == origin
    assert JobContext.for_calculations([calculation.id]) == %{calculation.id => origin}
    Repo.update!(Ecto.Changeset.change(job, state: "discarded"))
    assert {:ok, 1} = FootballMarket.Quotes.Recovery.recover_pending()

    latest =
      Repo.one!(
        from j in Oban.Job,
          where: j.worker == "FootballMarket.Workers.QuoteCalculation" and j.state == "available"
      )

    assert latest.meta["correlation_id"] == origin
  end

  test "legacy nullable roots use the run UUID and annotations preserve unrelated metadata", f do
    assert {:ok, admitted} = Synchronization.request_statistics(f.scope, f.options)
    run = Repo.get!(Run, admitted.run_id)
    run = Repo.update!(Ecto.Changeset.change(run, correlation_id: nil))
    assert JobContext.for_run(run) == run.id

    original =
      FootballMarket.Workers.StatisticsImport.new(%{"run_id" => run.id}, meta: %{"other" => 1})

    annotated = JobContext.annotate(original, run.id)

    assert Ecto.Changeset.get_field(annotated, :meta) == %{
             "other" => 1,
             "correlation_id" => run.id
           }

    assert Ecto.Changeset.get_field(annotated, :args) == Ecto.Changeset.get_field(original, :args)
  end
end
