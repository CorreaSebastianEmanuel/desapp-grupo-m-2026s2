defmodule FootballMarket.Catalog.Scouting do
  @moduledoc "Bounded, durable scouting for validated local catalog misses."

  alias FootballMarket.{Catalog, Providers, Synchronization}
  alias FootballMarket.Catalog.ScoutStore

  @max_name_length 80
  @scope_fields [:league_code, :start_year, :end_year, :source_ref]

  def search(term) do
    case normalize_name(term) do
      {:ok, display_name, normalized_name} ->
        search_normalized(display_name, normalized_name)

      :error ->
        {:ok, [], %{state: :rejected, next_attempt_at: nil, configured_scope_count: 0}}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp search_normalized(display_name, normalized_name) do
    with {:ok, players} <- Catalog.search_local_players(display_name) do
      status =
        if players == [], do: ScoutStore.admit(display_name, normalized_name, configured_scopes())

      {:ok, players, status}
    end
  end

  def normalize_name(term) when is_binary(term) do
    if String.valid?(term) do
      display_name = term |> String.trim() |> String.split() |> Enum.join(" ")
      normalized_name = normalize_identity(display_name)

      if valid_name?(display_name), do: {:ok, display_name, normalized_name}, else: :error
    else
      :error
    end
  end

  def normalize_name(_), do: :error

  def normalize_identity(value) when is_binary(value) do
    value
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{M}/u, "")
    |> String.downcase()
    |> String.trim()
    |> String.split()
    |> Enum.join(" ")
  end

  def configured_scopes do
    config = Application.get_env(:football_market, Synchronization, [])
    config |> Keyword.get(:scouting_scopes, []) |> validate_scopes()
  rescue
    _ -> []
  end

  defp validate_scopes(scopes) when is_list(scopes) and length(scopes) <= 5 do
    values = Enum.map(scopes, &validate_scope/1)

    if Enum.any?(values, &is_nil/1) or duplicate_leagues?(values),
      do: [],
      else: Enum.sort_by(values, & &1["league_code"])
  end

  defp validate_scopes(_), do: []

  defp validate_scope(scope) when is_map(scope) do
    if Enum.sort(Map.keys(scope)) == Enum.sort(@scope_fields) and
         Enum.any?(Providers.Request.leagues(), fn {code, _} ->
           scope.league_code == code
         end) do
      request = Map.take(scope, [:league_code, :start_year, :end_year])

      with {:ok, _} <- Providers.Request.normalize(:catalog, request),
           true <- is_binary(scope.source_ref),
           {:ok, _} <-
             FootballMarket.Synchronization.Input.normalize(request, source_ref: scope.source_ref) do
        %{
          "league_code" => scope.league_code,
          "start_year" => scope.start_year,
          "end_year" => scope.end_year,
          "source_ref" => scope.source_ref
        }
      else
        _ -> nil
      end
    end
  end

  defp validate_scope(_), do: nil

  defp duplicate_leagues?(scopes) do
    leagues = Enum.map(scopes, & &1["league_code"])
    length(leagues) != length(Enum.uniq(leagues))
  end

  defp valid_name?(value) do
    length = String.length(value)
    letters = Regex.scan(~r/\p{L}/u, value) |> length()

    length in 2..@max_name_length and letters >= 2 and
      Regex.match?(~r/\A[\p{L}\p{M}][\p{L}\p{M} .’'-]*\z/u, value)
  end

  def digest(scopes),
    do: :crypto.hash(:sha256, Jason.encode!(scopes)) |> Base.encode16(case: :lower)
end
