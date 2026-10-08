defmodule FootballMarket.Catalog.Ingestion.Outcome do
  @moduledoc "Safe internal reconciliation result; counts always refer to incoming entities."
  defstruct [
    :status,
    :scope,
    :provider,
    :fixture_id,
    :acceptance_reference,
    :revision,
    :retrieved_at,
    :accepted_at,
    :counts,
    :applied_counts,
    :reason,
    :recovery,
    :provider_error,
    :new_bindings_count,
    :applied_new_bindings_count,
    counts_historical: false
  ]

  def failure(status, scope, reason) do
    recovery =
      case status do
        :stale_observation -> :new_retrieval
        :reconciliation_conflict -> :correct_facts_or_instructions
        :concurrent_change -> :retry_new_attempt
        :persistence_failure -> :caller_may_retry
      end

    {:error, %__MODULE__{status: status, scope: scope, reason: reason, recovery: recovery}}
  end
end
