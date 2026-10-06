defmodule FootballMarket.Providers.Error do
  @moduledoc "Closed, template-only caller-facing failures."
  defstruct [
    :category,
    :operation,
    :scope,
    :explanation,
    :retryable,
    :retry_after_ms,
    :field,
    :reference
  ]

  @templates %{
    invalid_request: "Request input is invalid.",
    unsupported_capability: "Provider does not support this operation or scope.",
    not_found: "Requested league season was not found.",
    authentication_failed: "Provider access must be corrected.",
    rate_limited: "Provider rate limit prevents completion.",
    unavailable: "Provider is temporarily unavailable.",
    timeout: "Provider request deadline expired.",
    invalid_response: "Provider facts violate the contract."
  }
  @fields [
    :request,
    :league_code,
    :start_year,
    :end_year,
    :from,
    :to,
    :interval,
    :timeout_ms,
    :positions,
    :operation,
    :scope,
    :league,
    :season,
    :teams,
    :players,
    :matches,
    :performances,
    :provenance,
    :bindings,
    :minutes_played,
    :goals,
    :assists,
    :shots_on_target,
    :tackles,
    :interceptions,
    :saves,
    :goals_conceded,
    :yellow_cards,
    :red_cards
  ]
  def categories, do: Map.keys(@templates)

  def new(category, operation, scope, field \\ nil, delay \\ nil) do
    category = if Map.has_key?(@templates, category), do: category, else: :invalid_response

    %__MODULE__{
      category: category,
      operation: operation,
      scope: scope,
      explanation: Map.fetch!(@templates, category),
      retryable: category in [:rate_limited, :unavailable, :timeout],
      retry_after_ms: delay,
      field: if(field in @fields, do: field),
      reference: nil
    }
  end

  def failure(value, request) do
    if is_map(value) and Enum.all?(Map.keys(value), &(&1 in [:category, :retry_after_ms])) and
         Map.get(value, :category) in categories() and valid_delay?(value) do
      new(value.category, request.operation, request.scope, nil, Map.get(value, :retry_after_ms))
    else
      new(:invalid_response, request.operation, request.scope)
    end
  end

  defp valid_delay?(v) do
    case Map.get(v, :retry_after_ms) do
      nil -> true
      n -> v.category == :rate_limited and is_integer(n) and n > 0
    end
  end
end
