defmodule FootballMarket.Valuation.Configurations do
  @moduledoc """
  Pure valuation strategy registry, rule validation, schema-1 serialization codec,
  educational presets, and administrator facade.

  All database operations live exclusively in `FootballMarket.Valuation.Configurations.Store`
  (`configuration_store.ex`); this module never touches `Repo`.
  """

  alias FootballMarket.Accounts
  alias FootballMarket.Valuation.{Balanced, DecimalMath, Error, Evidence, PositionAware, Request}
  alias FootballMarket.Valuation.Configurations.Store

  @rule_keys [:strategy_id, :formula_version, :config, :references, :position_mapping]
  @encoded_keys ~w(schema_version config references requirements position_mapping)

  # --- Public Management Facade (Delegates persistence to Store) ---

  def inspect_for(actor) do
    if Accounts.administrator?(actor) do
      with {:ok, bases} <- Store.ensure_presets(),
           {:ok, data} <- list(),
           do: {:ok, %{data | versions: bases}}
    else
      {:error, :forbidden}
    end
  end

  def activate_for(actor, target, expected) do
    if Accounts.administrator?(actor) do
      activate_base(target, expected)
    else
      {:error, :forbidden}
    end
  end

  defdelegate create(rules), to: Store
  defdelegate get(id), to: Store
  defdelegate list(), to: Store
  defdelegate active(), to: Store
  defdelegate activate(target, expected), to: Store
  defdelegate history(), to: Store

  # --- Strategy Registry ---

  @doc "Reviewed formula dispatch; persisted data never selects arbitrary modules."
  def resolve("balanced", "1"), do: {:ok, Balanced}
  def resolve("position_aware", "1"), do: {:ok, PositionAware}
  def resolve(_, _), do: Error.new(:unsupported_strategy, :unknown_identity_version)

  # --- Rule Validation ---

  def validate_rules(rules) when is_map(rules) and not is_struct(rules) do
    if Enum.sort(Map.keys(rules)) == Enum.sort(@rule_keys) do
      with {:ok, module} <- resolve(rules.strategy_id, rules.formula_version),
           {:ok, config} <- validate_strategy_config(module, rules.config),
           {:ok, requirements} <- module.requirements(config),
           {:ok, fields} <-
             Request.rule_fields(requirements, rules.references, rules.position_mapping),
           :ok <- require_nonempty_mapping(fields.position_mapping) do
        {:ok, rules |> Map.merge(fields) |> Map.put(:config, Evidence.normalize_config(config))}
      end
    else
      Error.new(:validation, :invalid_rule_keys)
    end
  end

  def validate_rules(_), do: Error.new(:validation, :invalid_rules)

  # --- Schema-1 JSON Codec (Pure) ---

  def encode_rules(rules) do
    encoded_requirements =
      for scope <- Request.scopes(),
          Map.has_key?(rules.requirements, scope) do
        [Atom.to_string(scope), Enum.map(rules.requirements[scope], &Atom.to_string/1)]
      end

    encoded_mapping =
      rules.position_mapping
      |> Enum.sort()
      |> Enum.map(fn {id, group} -> [id, Atom.to_string(group)] end)

    %{
      "schema_version" => 1,
      "config" => %{"weights" => encode_weights(rules.config.weights)},
      "references" => encode_metrics(rules.references),
      "requirements" => encoded_requirements,
      "position_mapping" => encoded_mapping
    }
  end

  def decode_rules(data) do
    try do
      require_shape!(data, @encoded_keys)
      require_true!(data["schema_version"] === 1)
      require_shape!(data["config"], ["weights"])

      weights = decode_weights!(data["config"]["weights"])
      references = decode_pairs!(data["references"], Request.metrics(), &decode_number!/1)

      requirements =
        decode_pairs!(data["requirements"], Request.scopes(), fn metric_names ->
          require_true!(Evidence.proper_list?(metric_names) and metric_names != [])
          Enum.map(metric_names, fn name -> decode_enum!(name, Request.metrics()) end)
        end)

      raw_mapping = data["position_mapping"]
      require_true!(Evidence.proper_list?(raw_mapping) and raw_mapping != [])

      position_mapping =
        Enum.map(raw_mapping, fn
          [id, group] when is_binary(id) -> {id, decode_enum!(group, tl(Request.scopes()))}
          _ -> invalid_rules!()
        end)

      derived_requirements = derive_requirements(weights)
      require_true!(requirements == derived_requirements)

      fields =
        case Request.rule_fields(requirements, references, position_mapping) do
          {:ok, valid_fields} -> valid_fields
          _ -> invalid_rules!()
        end

      decoded = Map.put(fields, :config, %{weights: weights})
      require_true!(encode_rules(decoded) == data)
      {:ok, decoded}
    catch
      :invalid_stored_rules -> {:error, :invalid_stored_rules}
    end
  end

  # --- Educational Presets ---

  def preset_roles,
    do: %{"GK" => :goalkeeper, "DEF" => :defender, "MID" => :midfielder, "FWD" => :forward}

  def preset_families, do: ["balanced", "position_aware"]

  def preset_rules(strategy, mapping) do
    common = %{yellow_cards: Decimal.new("-0.5"), red_cards: -2}

    weights =
      case strategy do
        "balanced" ->
          Map.merge(common, %{goals: 4, assists: 3})

        "position_aware" ->
          %{
            goalkeeper: Map.merge(common, %{goals: 4, assists: 3, saves: 4, goals_conceded: -2}),
            defender:
              Map.merge(common, %{
                goals: 4,
                assists: 3,
                shots_on_target: 1,
                tackles: 3,
                interceptions: 3
              }),
            midfielder:
              Map.merge(common, %{
                goals: 4,
                assists: 4,
                shots_on_target: Decimal.new("1.5"),
                tackles: 2,
                interceptions: 2
              }),
            forward: Map.merge(common, %{goals: 5, assists: 3, shots_on_target: 2})
          }
      end

    references = %{
      goals: 2,
      assists: 2,
      shots_on_target: 6,
      tackles: 8,
      interceptions: 6,
      saves: 10,
      goals_conceded: 4,
      yellow_cards: 2,
      red_cards: 1
    }

    required_metrics = if strategy == "balanced", do: Map.keys(weights), else: Request.metrics()

    %{
      strategy_id: strategy,
      formula_version: "1",
      config: %{weights: weights},
      references: Map.take(references, required_metrics),
      position_mapping: Enum.sort(mapping)
    }
  end

  def preset_key(strategy, mapping) do
    encoded_pairs =
      mapping
      |> Enum.sort()
      |> Enum.map(fn {id, role} -> [id, Atom.to_string(role)] end)

    digest = :crypto.hash(:sha256, Jason.encode!(encoded_pairs)) |> Base.encode16(case: :lower)
    strategy <> ":educational-v1:" <> digest
  end

  def preset_equivalent_key(version) do
    {
      version.strategy_id,
      version.formula_version,
      canonical_numeric(version.config),
      canonical_numeric(version.references),
      Enum.sort(version.position_mapping)
    }
  end

  # --- Private Helpers ---

  defp activate_base(target, expected) do
    with {:ok, bases} <- Store.ensure_presets() do
      activate_if_supported(bases, target, expected)
    end
  end

  defp activate_if_supported(bases, target, expected) do
    if Enum.any?(bases, fn version -> version.id == target end),
      do: activate(target, expected),
      else: {:error, :unsupported_configuration}
  end

  defp validate_strategy_config(module, config) do
    case module.validate_config(config) do
      {:ok, valid} -> {:ok, valid}
      _ -> Error.new(:validation, :invalid_config)
    end
  end

  defp require_nonempty_mapping([]),
    do: Error.new(:validation, :invalid_mapping, [:position_mapping])

  defp require_nonempty_mapping(_), do: :ok

  defp derive_requirements(weights) do
    if Map.has_key?(weights, :goalkeeper) do
      Map.new(weights, fn {group, group_metrics} ->
        {group,
         Enum.filter(Request.metrics(), fn metric -> Map.has_key?(group_metrics, metric) end)}
      end)
    else
      %{overall: Enum.filter(Request.metrics(), fn metric -> Map.has_key?(weights, metric) end)}
    end
  end

  defp encode_weights(weights) do
    if Map.has_key?(weights, :goalkeeper) do
      for group <- tl(Request.scopes()),
          do: [Atom.to_string(group), encode_metrics(weights[group])]
    else
      encode_metrics(weights)
    end
  end

  defp encode_metrics(metrics_map) do
    for metric <- Request.metrics(),
        Map.has_key?(metrics_map, metric),
        do: [Atom.to_string(metric), encode_number(metrics_map[metric])]
  end

  defp encode_number(value) when is_integer(value),
    do: %{"type" => "integer", "value" => Integer.to_string(value)}

  defp encode_number(%Decimal{} = decimal) do
    normalized = Evidence.normalize_config(decimal)

    %{
      "type" => "decimal",
      "sign" => Integer.to_string(normalized.sign),
      "coefficient" => Integer.to_string(normalized.coef),
      "exponent" => Integer.to_string(normalized.exp)
    }
  end

  defp decode_weights!(raw_weights) do
    require_true!(Evidence.proper_list?(raw_weights) and raw_weights != [])

    case raw_weights do
      [[group, _] | _] when group in ["goalkeeper", "defender", "midfielder", "forward"] ->
        result = decode_pairs!(raw_weights, tl(Request.scopes()), &decode_metrics!/1)
        require_true!(map_size(result) == 4)
        result

      _ ->
        decode_metrics!(raw_weights)
    end
  end

  defp decode_metrics!(raw_metrics),
    do: decode_pairs!(raw_metrics, Request.metrics(), &decode_number!/1)

  defp decode_pairs!(entries, allowed_keys, decode_value) do
    require_true!(Evidence.proper_list?(entries) and entries != [])

    Enum.reduce(entries, %{}, fn
      [key, value], acc ->
        atom_key = decode_enum!(key, allowed_keys)
        require_true!(not Map.has_key?(acc, atom_key))
        Map.put(acc, atom_key, decode_value.(value))

      _, _ ->
        invalid_rules!()
    end)
  end

  defp decode_enum!(text, allowed_atoms) do
    case Enum.find(allowed_atoms, fn atom -> Atom.to_string(atom) == text end) do
      nil -> invalid_rules!()
      atom -> atom
    end
  end

  defp decode_number!(%{"type" => "integer", "value" => value} = node) when map_size(node) == 2,
    do: parse_strict_integer!(value)

  defp decode_number!(
         %{"type" => "decimal", "sign" => sign, "coefficient" => coef, "exponent" => exp} = node
       )
       when map_size(node) == 4 do
    value = %Decimal{
      sign: parse_strict_integer!(sign),
      coef: parse_strict_integer!(coef),
      exp: parse_strict_integer!(exp)
    }

    require_true!(DecimalMath.finite?(value))
    value
  end

  defp decode_number!(_), do: invalid_rules!()

  defp parse_strict_integer!(text) when is_binary(text) do
    require_true!(Regex.match?(~r/^(0|-?[1-9][0-9]*)$/, text))
    String.to_integer(text)
  end

  defp parse_strict_integer!(_), do: invalid_rules!()

  defp require_shape!(value, keys) do
    require_true!(
      is_map(value) and not is_struct(value) and Enum.sort(Map.keys(value)) == Enum.sort(keys)
    )
  end

  defp require_true!(true), do: :ok
  defp require_true!(_), do: invalid_rules!()
  defp invalid_rules!, do: throw(:invalid_stored_rules)

  defp canonical_numeric(value) when is_integer(value),
    do: value |> Decimal.new() |> canonical_numeric()

  defp canonical_numeric(%Decimal{} = decimal),
    do: decimal |> Evidence.normalize_config() |> Decimal.to_string(:normal)

  defp canonical_numeric(map) when is_map(map),
    do: Map.new(map, fn {key, val} -> {key, canonical_numeric(val)} end)
end
