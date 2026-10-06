defmodule FootballMarket.Providers.Provenance do
  @moduledoc "Safe, separate, scope-qualified source provenance."
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
    alias FootballMarket.Providers.Binding
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
