defmodule FootballMarket.Providers.FootballData do
  @moduledoc "Read-only Football-Data.org current catalog adapter."
  @behaviour FootballMarket.Providers.Adapter
  alias FootballMarket.Providers.FootballData.{Configuration, Scope, Translator, Errors}
  def provider_label, do: "football-data-org"

  def read(request, context, state) do
    with {:ok, state} <- Configuration.validate(state, context) do
      if not Enum.all?(
           [
             provider_label(),
             request.scope.league_code,
             Integer.to_string(request.scope.start_year),
             Integer.to_string(request.scope.end_year)
           ],
           &Configuration.clean?(&1, state.token)
         ) do
        throw({:source_error, :invalid_request})
      end

      if request.operation == :performances,
        do: {:error, %{category: :unsupported_capability}},
        else: collect(request, context, state)
    end
  catch
    {:source_error, category} -> {:error, %{category: category}}
  end

  defp collect(request, context, state) do
    try do
      discovery = fetch!({:discovery, request.scope.league_code}, context, state)
      evidence = Scope.discovery!(discovery, request, state.token)
      source = fetch!({:teams, evidence.code, request.scope.start_year}, context, state)
      teams = Scope.teams!(source, evidence, request, state.token)

      {portions, _seen} =
        teams
        |> Enum.with_index()
        |> Enum.reduce({[], MapSet.new()}, fn {listed, index}, {portions, seen} ->
          detail = fetch!({:team, listed["id"]}, context, state)
          squad = Scope.team!(detail, listed, evidence, state.token)

          {players, seen} =
            Enum.reduce(squad, {[], seen}, fn row, {players, seen} ->
              player = Translator.player!(row, state)
              Scope.require!(not MapSet.member?(seen, player["id"]))
              person = fetch!({:person, player["id"]}, context, state)
              Scope.person!(person, player, detail, evidence, state.token)
              {players ++ [player], MapSet.put(seen, player["id"])}
            end)

          {portions ++ [{Map.put(detail, :index, index), players}], seen}
        end)

      final = fetch!({:discovery, evidence.code}, context, state)
      # A changed discovery is an inconsistent response, even if now historical.
      Scope.require!(final["id"] == evidence.competition and final["code"] == evidence.code)
      Scope.require!(Scope.season!(final["currentSeason"], state.token) == evidence.current)

      final_evidence =
        try do
          Scope.discovery!(final, request, state.token)
        catch
          _, _ -> throw({:source_error, :invalid_response})
        end

      Scope.require!(final_evidence == evidence)
      {:ok, Translator.candidate(request, evidence, portions, state, context)}
    rescue
      _ -> {:error, %{category: :invalid_response}}
    catch
      {:source_error, category} -> {:error, %{category: category}}
      {:source_failure, failure} -> {:error, failure}
      _, _ -> {:error, %{category: :unavailable}}
    end
  end

  defp fetch!(route, context, state) do
    {runtime, clock} = context.runtime
    if runtime.now_us(clock) >= context.deadline_us, do: throw({:source_error, :timeout})
    {transport, transport_state} = state.transport

    response =
      try do
        transport.request(route, state.token, context, transport_state)
      rescue
        _ -> {:error, :unavailable}
      catch
        _, _ -> {:error, :unavailable}
      end

    case response do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} when is_map(data) -> data
          _ -> throw({:source_error, :invalid_response})
        end

      {:ok, response} ->
        throw({:source_failure, Errors.response(response, context)})

      {:error, reason} when reason in [:timeout, :invalid_response] ->
        throw({:source_error, reason})

      _ ->
        throw({:source_error, :unavailable})
    end
  end
end
