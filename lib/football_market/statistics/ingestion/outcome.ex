defmodule FootballMarket.Statistics.Ingestion.Outcome do
  @moduledoc false
  defstruct [
    :status,
    :scope,
    :run_id,
    :check_id,
    :calculation_intent_id,
    :reason,
    :recovery,
    :provider_category,
    :retryable,
    :retry_after_ms
  ]

  @statuses [:accepted_changes, :accepted_unchanged, :replay, :accepted_empty]

  def accepted(status, scope, attrs \\ []) when status in @statuses do
    {:ok, struct!(__MODULE__, Keyword.merge([status: status, scope: scope], attrs))}
  end

  def failure(status, scope, reason, options \\ []) do
    {:error,
     struct!(
       __MODULE__,
       Keyword.merge(
         [status: status, scope: scope, reason: reason, recovery: :inspect_run],
         options
       )
     )}
  end
end
