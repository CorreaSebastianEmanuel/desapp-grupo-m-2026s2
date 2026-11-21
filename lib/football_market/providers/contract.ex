defmodule FootballMarket.Providers.Adapter do
  @moduledoc "Read-only source port. All portions share Context.deadline_us."
  @callback provider_label() :: String.t()
  @callback read(FootballMarket.Providers.Request.t(), map(), term()) ::
              {:ok, map()} | {:error, map()}
  @doc "Optional read-only guard captured before source work and checked after final validation."
  @callback publication_guard(FootballMarket.Providers.Request.t(), map(), term()) ::
              (-> :ok | {:error, map()})
  @optional_callbacks publication_guard: 3
end

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
    :completeness,
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
      n -> v.category in [:rate_limited, :unavailable, :timeout] and is_integer(n) and n > 0
    end
  end
end

defmodule FootballMarket.Providers.Instant do
  @moduledoc "Lossless explicit instants normalized to UTC microseconds."

  def normalize(%DateTime{} = value) do
    try do
      {micro, precision} = value.microsecond

      if valid_datetime?(value, micro, precision) do
        value = %{value | microsecond: {micro, 6}}

        case DateTime.from_iso8601(DateTime.to_iso8601(value)) do
          {:ok, parsed, _} ->
            if DateTime.to_unix(parsed, :microsecond) == DateTime.to_unix(value, :microsecond),
              do:
                {:ok, DateTime.from_unix!(DateTime.to_unix(parsed, :microsecond), :microsecond)},
              else: :error

          _ ->
            :error
        end
      else
        :error
      end
    rescue
      _ -> :error
    end
  end

  def normalize(value) when is_binary(value) do
    if String.valid?(value) and not Regex.match?(~r/\.\d{7,}/, value) do
      case DateTime.from_iso8601(value) do
        {:ok, datetime, _} -> normalize(datetime)
        _ -> :error
      end
    else
      :error
    end
  end

  def normalize(_), do: :error

  defp valid_datetime?(value, micro, precision) do
    precision in 0..6 and micro in 0..999_999 and value.calendar == Calendar.ISO and
      is_binary(value.time_zone) and is_integer(value.utc_offset) and
      is_integer(value.std_offset) and value.year in 1..9999
  end
end

defmodule FootballMarket.Providers.Media do
  @moduledoc "Public image locations for identities accepted by the catalog adapters."

  def url("fotmob-public-html-v1", "player", id),
    do: numeric_url(id, "https://images.fotmob.com/image_resources/playerimages/")

  def url("fotmob-public-html-v1", "team", id),
    do: numeric_url(id, "https://images.fotmob.com/image_resources/logo/teamlogo/")

  def url("football-data.org-v4", "team", id),
    do: numeric_url(id, "https://crests.football-data.org/")

  def url(_, _, _), do: nil

  defp numeric_url(id, base) when is_binary(id) do
    if Regex.match?(~r/\A[1-9][0-9]{0,11}\z/, id), do: base <> id <> ".png"
  end

  defp numeric_url(_, _), do: nil
end

defmodule FootballMarket.Providers.Provenance do
  @moduledoc "Safe, separate, scope-qualified source provenance."
  alias FootballMarket.Providers.Binding
  defstruct [:provider, :retrieved_at, :bindings, :fixture_id]

  def safe_text?(value) when is_binary(value) do
    String.valid?(value) and String.trim(value) != "" and
      not Regex.match?(
        ~r/[\p{Cc}\p{Cf}]|[a-z][a-z0-9+.-]*:\/\/|(?:bearer|basic|authorization|password|secret|token|api[_-]?key)\s*[:= ]/iu,
        value
      )
  end

  def safe_text?(_), do: false

  def validate(bindings, fixture_id, facts, request, label, retrieved_at) do
    require!(is_list(bindings), :bindings)
    require!(is_nil(fixture_id) or safe_text?(fixture_id), :provenance)

    targets =
      [{:league, facts.league.ref}, {:season, facts.season.ref}] ++
        Enum.map(facts.teams, &{:team, &1.ref}) ++
        Enum.map(facts.players, &{:player, &1.ref}) ++
        Enum.map(Map.get(facts, :matches, []), &{:match, &1.ref})

    result =
      Enum.map(bindings, fn b ->
        shape!(b, [:kind, :ref, :source_id], :bindings)
        require!({b.kind, b.ref} in targets and safe_text?(b.source_id), :bindings)

        struct!(
          Binding,
          Map.merge(b, %{
            provider: label,
            league_code: request.scope.league_code,
            start_year: request.scope.start_year,
            end_year: request.scope.end_year
          })
        )
      end)

    unique!(result, &{&1.kind, &1.ref}, :bindings)
    unique!(result, &{&1.kind, &1.source_id}, :bindings)
    require!(Enum.sort(Enum.map(result, &{&1.kind, &1.ref})) == Enum.sort(targets), :bindings)

    %__MODULE__{
      provider: label,
      retrieved_at: retrieved_at,
      bindings: result,
      fixture_id: fixture_id
    }
  end

  defp require!(condition, field), do: if(not condition, do: throw({:invalid, field}))

  defp shape!(value, fields, field) do
    require!(is_map(value) and not is_struct(value), field)
    require!(Enum.sort(Map.keys(value)) == Enum.sort(fields), field)
  end

  defp unique!(rows, key, field),
    do: require!(length(rows) == length(Enum.uniq_by(rows, key)), field)
end

defmodule FootballMarket.Providers.RateLimit do
  @moduledoc "Credential-scoped durable request reservation boundary."

  def reserve(token, interval_ms, max_wait_ms),
    do: backend().reserve(key(token), interval_ms, max_wait_ms)

  def block(token, duration_ms), do: backend().block(key(token), duration_ms)

  def reserve_volume(provider, limit, window_ms),
    do: backend().reserve_volume(key(provider), limit, window_ms)

  defp backend, do: Application.fetch_env!(:football_market, :provider_rate_limit_backend)
  defp key(token), do: :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
end
