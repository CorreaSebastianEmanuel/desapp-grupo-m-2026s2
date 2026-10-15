defmodule FootballMarket.Synchronization.Input do
  @moduledoc "Closed source resolution and versioned, non-secret canonical identity."
  alias FootballMarket.Providers.{Request, Provenance}
  alias FootballMarket.Synchronization.Policy
  @test Mix.env() == :test

  def normalize(scope, options) do
    with true <- Keyword.keyword?(options),
         true <-
           Enum.all?(
             Keyword.keys(options),
             &(&1 in [:source_ref, :fixture_ref, :mappings, :new_players, :trigger, :policy])
           ),
         :ok <-
           Policy.validate_runtime(
             Application.get_env(:football_market, FootballMarket.Synchronization, [])
           ),
         {:ok, request} <- Request.normalize(:catalog, scope),
         {:ok, policy} <- Policy.normalize(Keyword.get(options, :policy, %{})),
         true <- policy["worker_timeout_ms"] > request.timeout_ms + 1000,
         ref when is_binary(ref) <- Keyword.get(options, :source_ref),
         true <- Provenance.safe_text?(ref),
         {:ok, source} <- resolve(ref),
         {:ok, identity} <- source_identity(source),
         {:ok, instructions} <- instructions(request.scope, options, source),
         fixture <- Keyword.get(options, :fixture_ref),
         true <- is_nil(fixture) or Provenance.safe_text?(fixture),
         trigger <- Keyword.get(options, :trigger, :manual),
         true <- trigger in [:manual, :initial, :scheduled] do
      material = %{
        "version" => 1,
        "source_ref" => ref,
        "fixture_ref" => fixture,
        "source_identity" => identity,
        "scope" => json(request.scope),
        "timeout_ms" => request.timeout_ms,
        "instructions" => instructions
      }

      {:ok,
       %{
         scope: request.scope,
         material: material,
         digest: digest(material),
         policy: policy,
         trigger: trigger,
         source: source
       }}
    else
      {:error, field} when is_atom(field) -> {:error, field}
      _ -> {:error, :source_ref}
    end
  rescue
    _ -> {:error, :source_ref}
  end

  def resolve(ref) do
    sources =
      Application.get_env(:football_market, FootballMarket.Synchronization, [])
      |> Keyword.get(:sources, %{})

    case Map.fetch(sources, ref) do
      {:ok, %{provider: {module, _}} = source} ->
        allowed =
          [FootballMarket.Providers.Scraping] ++
            if(@test,
              do: [
                FootballMarket.IngestionFixtureAdapter,
                FootballMarket.IngestionReplacementAdapter,
                FootballMarket.Synchronization.ScriptAdapter
              ],
              else: []
            )

        if module in allowed and valid_source_runtime?(source),
          do: {:ok, source},
          else: {:error, :source_ref}

      _ ->
        {:error, :source_ref}
    end
  end

  # Validate structure and callback availability only: admission must never launch
  # provider work or execute runtime callbacks. Omission uses Providers' default.
  defp valid_source_runtime?(source) do
    case Map.get(source, :runtime, {FootballMarket.Providers.Runtime, nil}) do
      {module, _state} when is_atom(module) ->
        Code.ensure_loaded?(module) and
          Enum.all?([now_us: 1, utc_now: 1, launch: 3, await: 3, cancel: 2, close: 2], fn
            {callback, arity} -> function_exported?(module, callback, arity)
          end)

      _ ->
        false
    end
  end

  def source_identity(source) do
    with path when is_binary(path) <- source[:fixture_path],
         {:ok, bytes} <- File.read(path) do
      {:ok,
       %{
         "artifact_digest" => digest(bytes),
         "configuration_digest" =>
           digest(
             :erlang.term_to_binary(Map.take(source, [:provider, :runtime]), [:deterministic])
           )
       }}
    else
      _ -> {:error, :fixture_ref}
    end
  end

  def execution(material) do
    with {:ok, source} <- resolve(material["source_ref"]),
         {:ok, identity} <- source_identity(source),
         true <- identity == material["source_identity"] do
      instructions =
        for key <- ["mappings", "new_players"] do
          values =
            Enum.map(material["instructions"][key], fn entry ->
              Map.new(entry, fn {k, v} ->
                {String.to_existing_atom(k),
                 if(k == "kind", do: String.to_existing_atom(v), else: v)}
              end)
            end)

          {String.to_existing_atom(key), values}
        end

      {:ok, Keyword.merge(Map.to_list(Map.take(source, [:provider, :runtime])), instructions)}
    else
      false -> {:error, :input_drift}
      _ -> {:error, :missing_configuration}
    end
  end

  def digest(value) do
    bytes = if is_binary(value), do: value, else: :erlang.term_to_binary(value, [:deterministic])
    :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
  end

  def json(value), do: value |> Jason.encode!() |> Jason.decode!()

  defp instructions(scope, options, %{provider: {provider, _}}) do
    label = provider.provider_label()

    values =
      for key <- [:mappings, :new_players], into: %{} do
        entries = Keyword.get(options, key, [])
        unless is_list(entries), do: throw(:invalid_instructions)

        for entry <- entries do
          fields =
            [:provider, :league_code, :start_year, :end_year, :kind, :source_id] ++
              if(key == :mappings, do: [:target_id], else: [])

          unless is_map(entry) and not is_struct(entry) and
                   Enum.sort(Map.keys(entry)) == Enum.sort(fields) and
                   Map.take(entry, [:league_code, :start_year, :end_year]) == scope and
                   entry.kind in [:league, :season, :team, :player] and
                   (key == :mappings or entry.kind == :player) and
                   entry.provider == label and Provenance.safe_text?(entry.provider) and
                   Provenance.safe_text?(entry.source_id) and
                   (key != :mappings or match?({:ok, _}, Ecto.UUID.cast(entry.target_id))),
                 do: throw(:invalid_instructions)
        end

        entries =
          Enum.map(entries, fn entry ->
            if key == :mappings do
              {:ok, target} = Ecto.UUID.cast(entry.target_id)
              Map.put(entry, :target_id, String.downcase(target))
            else
              entry
            end
          end)

        {Atom.to_string(key), entries |> Enum.map(&json/1) |> Enum.sort()}
      end

    entries = values["mappings"] ++ values["new_players"]
    keys = Enum.map(entries, &{&1["kind"], &1["source_id"]})
    targets = Enum.map(values["mappings"], &{&1["kind"], &1["target_id"]})

    if length(keys) != length(Enum.uniq(keys)) or length(targets) != length(Enum.uniq(targets)),
      do: throw(:invalid_instructions)

    {:ok, values}
  catch
    :invalid_instructions -> {:error, :instructions}
  end
end
