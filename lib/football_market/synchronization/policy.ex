defmodule FootballMarket.Synchronization.Policy do
  @moduledoc "Finite accepted execution policy; the run ledger owns the budget."

  def normalize(input) when is_map(input) and not is_struct(input) do
    allowed = [:attempt_limit, :waits, :worker_timeout_ms]

    if Enum.all?(Map.keys(input), &(&1 in allowed)) do
      policy = Map.merge(%{attempt_limit: 3, waits: [60, 300], worker_timeout_ms: 30_000}, input)

      if is_integer(policy.attempt_limit) and policy.attempt_limit > 0 and
           is_list(policy.waits) and length(policy.waits) == policy.attempt_limit - 1 and
           Enum.all?(policy.waits, &(is_integer(&1) and &1 > 0)) and
           is_integer(policy.worker_timeout_ms) and policy.worker_timeout_ms > 1000 do
        {:ok, Map.new(policy, fn {k, v} -> {Atom.to_string(k), v} end)}
      else
        {:error, :policy}
      end
    else
      {:error, :policy}
    end
  end

  def normalize(_), do: {:error, :policy}

  def validate_runtime(config) do
    if Keyword.keyword?(config) and is_boolean(Keyword.get(config, :enabled, false)) and
         is_integer(Keyword.get(config, :concurrency, 1)) and
         Keyword.get(config, :concurrency, 1) > 0 and
         is_integer(Keyword.get(config, :tick_ms, 15_000)) and
         Keyword.get(config, :tick_ms, 15_000) > 0, do: :ok, else: {:error, :policy}
  end

  def decision(outcome, number, policy, now) do
    retryable =
      outcome["status"] in ["persistence_failure", "concurrent_change", "interrupted"] ||
        (outcome["status"] == "provider_failure" && outcome["retryable"] == true &&
           outcome["category"] in ["rate_limited", "unavailable", "timeout"])

    cond do
      not retryable ->
        {:failed,
         if(outcome["status"] in ["input_drift", "missing_configuration"],
           do: outcome["status"],
           else: "non_retryable"
         )}

      number >= policy["attempt_limit"] ->
        {:failed,
         if(outcome["status"] == "interrupted", do: "exhausted_unconfirmed", else: "exhausted")}

      true ->
        local = Enum.at(policy["waits"], number - 1)

        provider =
          case outcome["retry_after_ms"] do
            n when is_integer(n) and n > 0 -> div(n + 999, 1000)
            _ -> 0
          end

        {:retry, DateTime.add(now, max(local, provider), :second)}
    end
  end
end
