defmodule FootballMarket.Workers.CalculationDispatch do
  @moduledoc "Durable post-commit delivery of a statistics calculation request."
  use Oban.Worker, queue: :statistics_import, max_attempts: 1
  @attempt_limit 3
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.CalculationIntent

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"intent_id" => intent_id}}) do
    case Repo.get(CalculationIntent, intent_id) do
      %CalculationIntent{state: "pending", attempts: attempts} = intent
      when attempts < @attempt_limit ->
        if due?(intent.next_attempt_at), do: deliver(intent), else: :ok

      _ ->
        :ok
    end
  rescue
    _ -> {:error, :request_unavailable}
  end

  defp deliver(intent) do
    result =
      FootballMarket.Valuation.CalculationRequests.accept(
        intent.id,
        intent.accepted_check_id,
        intent.changed_performance_ids
      )

    case result do
      {:ok, _} ->
        crash_after_accept_for_test!(intent.id)

        Repo.update!(
          Ecto.Changeset.change(intent,
            state: "delivered",
            delivered_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
          )
        )

        :ok

      {:error, :calculation_request_conflict} ->
        Repo.update!(Ecto.Changeset.change(intent, state: "failed", attempts: @attempt_limit))
        :ok

      {:error, _} ->
        next_attempt = intent.attempts + 1
        next_state = if(next_attempt >= @attempt_limit, do: "failed", else: "pending")
        wait = Enum.at([60, 300], next_attempt - 1, 300)

        next_at =
          if(next_state == "pending",
            do:
              DateTime.add(DateTime.utc_now(), wait, :second)
              |> DateTime.truncate(:microsecond)
          )

        Repo.update!(
          Ecto.Changeset.change(intent,
            attempts: next_attempt,
            state: next_state,
            next_attempt_at: next_at
          )
        )

        {:error, :request_unavailable}
    end
  end

  defp due?(nil), do: true

  defp due?(%DateTime{} = at),
    do: DateTime.compare(at, DateTime.utc_now()) in [:lt, :eq]

  if Mix.env() == :test do
    defp crash_after_accept_for_test!(intent_id) do
      case Application.get_env(:football_market, :task021_calculation_dispatch_failpoint) do
        {parent, ^intent_id} when is_pid(parent) ->
          send(parent, {:task021_calculation_request_accepted, intent_id, self()})
          Application.delete_env(:football_market, :task021_calculation_dispatch_failpoint)
          exit(:task021_worker_interrupted)

        _ ->
          :ok
      end
    end
  else
    defp crash_after_accept_for_test!(_intent_id), do: :ok
  end
end
