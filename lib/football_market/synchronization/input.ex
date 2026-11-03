defmodule FootballMarket.Synchronization.Input do
  @moduledoc "Closed source resolution and versioned, non-secret canonical identity."
  alias FootballMarket.Providers.{Request, Provenance}
  alias FootballMarket.Synchronization.Policy

  @allowed_providers [FootballMarket.Providers.Scraping, FootballMarket.Providers.FootballDataOrg] ++
                       if(Mix.env() == :test,
                         do: [
                           FootballMarket.IngestionFixtureAdapter,
                           FootballMarket.IngestionReplacementAdapter,
                           FootballMarket.Synchronization.ScriptAdapter
                         ],
                         else: []
                       )

  def normalize(scope, options), do: normalize(:catalog, scope, options)

  def normalize(operation, scope, options) when operation in [:catalog, :statistics] do
    with true <- Keyword.keyword?(options),
         true <-
           Enum.all?(
             Keyword.keys(options),
             &(&1 in [
                 :source_ref,
                 :fixture_ref,
                 :mappings,
                 :new_players,
                 :trigger,
                 :policy,
                 :player_id,
                 :player_source_id,
                 :player_name,
                 :player_team_name,
                 :player_position_code
               ])
           ),
         :ok <-
           Policy.validate_runtime(
             Application.get_env(:football_market, FootballMarket.Synchronization, [])
           ),
         {:ok, request} <-
           Request.normalize(if(operation == :catalog, do: :catalog, else: :performances), scope),
         true <-
           operation == :catalog or (is_nil(request.scope.from) and is_nil(request.scope.to)),
         scope_values <- Map.take(request.scope, [:league_code, :start_year, :end_year]),
         {:ok, policy} <- Policy.normalize(Keyword.get(options, :policy, %{})),
         true <- policy["worker_timeout_ms"] > request.timeout_ms + 1000,
         true <- operation == :catalog or Keyword.get(options, :new_players, []) == [],
         ref when is_binary(ref) <- Keyword.get(options, :source_ref),
         true <- Provenance.safe_text?(ref),
         {:ok, source} <- resolve(ref),
         {:ok, identity} <- source_identity(source),
         {:ok, instructions} <- instructions(scope_values, options, source, operation),
         fixture <- Keyword.get(options, :fixture_ref),
         true <- is_nil(fixture) or Provenance.safe_text?(fixture),
         trigger <- Keyword.get(options, :trigger, :manual),
         true <- trigger in [:manual, :initial, :scheduled],
         {:ok, player_id, player_source_id, player_name, player_team_name, player_position_code} <-
           player_target(operation, options) do
      material = %{
        "version" => if(operation == :catalog, do: 1, else: 2),
        "source_ref" => ref,
        "fixture_ref" => fixture,
        "source_identity" => identity,
        "scope" => json(scope_values),
        "timeout_ms" => request.timeout_ms,
        "instructions" => instructions
      }

      material =
        if operation == :statistics,
          do: Map.put(material, "operation", "statistics"),
          else: material

      material =
        if player_id do
          material
          |> Map.put("player_id", player_id)
          |> Map.put("player_source_id", player_source_id)
          |> maybe_put("player_name", player_name)
          |> maybe_put("player_team_name", player_team_name)
          |> maybe_put("player_position_code", player_position_code)
        else
          material
        end

      input_scope =
        if player_id, do: Map.put(scope_values, :player_id, player_id), else: scope_values

      {:ok,
       %{
         scope: input_scope,
         operation: operation,
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

  def normalize(_, _, _), do: {:error, :request}

  def resolve(ref) do
    sources =
      Application.get_env(:football_market, FootballMarket.Synchronization, [])
      |> Keyword.get(:sources, %{})

    case Map.fetch(sources, ref) do
      {:ok, %{provider: {module, _}} = source} ->
        if module in @allowed_providers and valid_source_runtime?(source) and
             valid_provider_source?(source),
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

  defp valid_provider_source?(%{provider: {FootballMarket.Providers.FootballDataOrg, state}}),
    do: FootballMarket.Providers.FootballDataOrg.valid_token?(state[:token])

  defp valid_provider_source?(_), do: true

  def source_identity(source) do
    case source[:fixture_path] do
      path when is_binary(path) ->
        case File.read(path) do
          {:ok, bytes} ->
            {:ok,
             %{
               "artifact_digest" => digest(bytes),
               "configuration_digest" =>
                 digest(
                   :erlang.term_to_binary(Map.take(source, [:provider, :runtime]), [
                     :deterministic
                   ])
                 )
             }}

          _ ->
            {:error, :fixture_ref}
        end

      nil ->
        case {source[:provider], source[:identity]} do
          {{module, _}, identity} when is_atom(module) and is_map(identity) ->
            {:ok,
             %{
               "configuration_digest" =>
                 digest(:erlang.term_to_binary({module, identity}, [:deterministic]))
             }}

          _ ->
            {:error, :fixture_ref}
        end
    end
  end

  def execution(material) do
    with {:ok, source} <- resolve(material["source_ref"]),
         {:ok, identity} <- source_identity(source),
         true <- identity == material["source_identity"] do
      instructions =
        for key <- ["mappings", "new_players"] do
          values =
            Enum.map(material["instructions"][key], &execution_entry/1)

          {String.to_existing_atom(key), values}
        end

      options =
        [
          player_id: material["player_id"],
          player_source_id: material["player_source_id"],
          player_name: material["player_name"],
          player_team_name: material["player_team_name"],
          player_position_code: material["player_position_code"]
        ]
        |> Enum.reject(fn {_key, value} -> is_nil(value) end)

      {:ok,
       Keyword.merge(
         Map.to_list(Map.take(source, [:provider, :runtime])),
         instructions ++ options
       )}
    else
      false -> {:error, :input_drift}
      _ -> {:error, :missing_configuration}
    end
  end

  defp player_target(:catalog, options) do
    if is_nil(Keyword.get(options, :player_id)) and
         is_nil(Keyword.get(options, :player_source_id)) and
         is_nil(Keyword.get(options, :player_name)) and
         is_nil(Keyword.get(options, :player_team_name)),
       do: {:ok, nil, nil, nil, nil, nil},
       else: {:error, :player_target}
  end

  defp player_target(:statistics, options) do
    case {Keyword.get(options, :player_id), Keyword.get(options, :player_source_id),
          Keyword.get(options, :player_name), Keyword.get(options, :player_team_name),
          Keyword.get(options, :player_position_code)} do
      {nil, nil, nil, nil, nil} ->
        {:ok, nil, nil, nil, nil, nil}

      {player_id, source_id, name, team, position_code}
      when is_binary(player_id) and (is_binary(source_id) or is_nil(source_id)) and
             (is_binary(name) or is_nil(name)) and (is_binary(team) or is_nil(team)) and
             (is_binary(position_code) or is_nil(position_code)) ->
        with {:ok, uuid} <- Ecto.UUID.cast(player_id),
             true <- is_nil(source_id) or Provenance.safe_text?(source_id),
             true <- is_nil(name) or Provenance.safe_text?(name),
             true <- is_nil(team) or Provenance.safe_text?(team),
             true <- is_nil(position_code) or position_code in ["GK", "DEF", "MID", "FWD"],
             true <- is_binary(source_id) or (is_binary(name) and is_binary(team)),
             true <- (is_nil(name) and is_nil(team)) or (is_binary(name) and is_binary(team)) do
          {:ok, String.downcase(uuid), source_id, name, team, position_code}
        else
          _ -> {:error, :player_target}
        end

      _ ->
        {:error, :player_target}
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  def digest(value) do
    bytes = if is_binary(value), do: value, else: :erlang.term_to_binary(value, [:deterministic])
    :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
  end

  def json(value), do: value |> Jason.encode!() |> Jason.decode!()

  defp instructions(scope, options, %{provider: {provider, _}}, operation) do
    label = provider.provider_label()

    values =
      for key <- [:mappings, :new_players], into: %{} do
        instruction_values(key, scope, options, operation, label)
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

  defp execution_entry(entry), do: Map.new(entry, &execution_field/1)

  defp execution_field({key, value}) do
    {String.to_existing_atom(key),
     if(key == "kind", do: String.to_existing_atom(value), else: value)}
  end

  defp instruction_values(key, scope, options, operation, label) do
    entries = Keyword.get(options, key, [])
    unless is_list(entries), do: throw(:invalid_instructions)

    for entry <- entries do
      fields =
        [:provider, :league_code, :start_year, :end_year, :kind, :source_id] ++
          if(key == :mappings, do: [:target_id], else: [])

      validate_instruction!(entry, fields, scope, key, operation, label)
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

  defp validate_instruction!(entry, fields, scope, key, operation, label) do
    unless instruction_shape?(entry, fields, scope) and instruction_kind?(entry, key, operation) and
             instruction_identity?(entry, key, label),
           do: throw(:invalid_instructions)
  end

  defp instruction_shape?(entry, fields, scope) do
    is_map(entry) and not is_struct(entry) and Enum.sort(Map.keys(entry)) == Enum.sort(fields) and
      Map.take(entry, [:league_code, :start_year, :end_year]) == scope
  end

  defp instruction_kind?(entry, key, operation) do
    entry.kind in ([:league, :season, :team, :player] ++
                     if(operation == :statistics and key == :mappings, do: [:match], else: [])) and
      (key == :mappings or entry.kind == :player)
  end

  defp instruction_identity?(entry, key, label) do
    entry.provider == label and Provenance.safe_text?(entry.provider) and
      Provenance.safe_text?(entry.source_id) and
      (key != :mappings or match?({:ok, _}, Ecto.UUID.cast(entry.target_id)))
  end
end
