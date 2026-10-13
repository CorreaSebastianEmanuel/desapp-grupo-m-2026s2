defmodule FootballMarket.Valuation.Configurations.Codec do
  @moduledoc "Schema-1 typed exact rules. No executable names, atom interning or numeric coercion."
  alias FootballMarket.Valuation.{Evidence, Request, DecimalMath}
  @keys ~w(schema_version config references requirements position_mapping)

  def encode(r) do
    %{
      "schema_version" => 1,
      "config" => %{"weights" => weights(r.config.weights)},
      "references" => metrics(r.references),
      "requirements" =>
        for(
          s <- Request.scopes(),
          Map.has_key?(r.requirements, s),
          do: [Atom.to_string(s), Enum.map(r.requirements[s], &Atom.to_string/1)]
        ),
      "position_mapping" =>
        Enum.map(Enum.sort(r.position_mapping), fn {id, g} -> [id, Atom.to_string(g)] end)
    }
  end

  defp weights(w) do
    if Map.has_key?(w, :goalkeeper),
      do: for(g <- tl(Request.scopes()), do: [Atom.to_string(g), metrics(w[g])]),
      else: metrics(w)
  end

  defp metrics(w),
    do: for(m <- Request.metrics(), Map.has_key?(w, m), do: [Atom.to_string(m), number(w[m])])

  defp number(n) when is_integer(n), do: %{"type" => "integer", "value" => Integer.to_string(n)}

  defp number(%Decimal{} = d) do
    d = Evidence.normalize_config(d)

    %{
      "type" => "decimal",
      "sign" => Integer.to_string(d.sign),
      "coefficient" => Integer.to_string(d.coef),
      "exponent" => Integer.to_string(d.exp)
    }
  end

  def decode(data) do
    try do
      require_shape(data, @keys)
      require_true(data["schema_version"] === 1)
      require_shape(data["config"], ["weights"])
      w = decode_weights(data["config"]["weights"])
      refs = pairs(data["references"], Request.metrics(), &decode_number/1)

      req =
        pairs(data["requirements"], Request.scopes(), fn ms ->
          require_true(Evidence.proper_list?(ms) and ms != [])
          Enum.map(ms, &enum(&1, Request.metrics()))
        end)

      mapping = data["position_mapping"]
      require_true(Evidence.proper_list?(mapping) and mapping != [])

      mapping =
        Enum.map(mapping, fn
          [id, g] when is_binary(id) -> {id, enum(g, tl(Request.scopes()))}
          _ -> invalid()
        end)

      derived =
        if Map.has_key?(w, :goalkeeper),
          do:
            Map.new(w, fn {g, m} -> {g, Enum.filter(Request.metrics(), &Map.has_key?(m, &1))} end),
          else: %{overall: Enum.filter(Request.metrics(), &Map.has_key?(w, &1))}

      require_true(req == derived)

      fields =
        case Request.rule_fields(req, refs, mapping) do
          {:ok, fields} -> fields
          _ -> invalid()
        end

      decoded = Map.put(fields, :config, %{weights: w})
      require_true(encode(decoded) == data)
      {:ok, decoded}
    catch
      :invalid_stored_rules -> {:error, :invalid_stored_rules}
    end
  end

  defp decode_weights(w) do
    require_true(Evidence.proper_list?(w) and w != [])

    case w do
      [[g, _] | _] when g in ["goalkeeper", "defender", "midfielder", "forward"] ->
        result = pairs(w, tl(Request.scopes()), &decode_metrics/1)
        require_true(map_size(result) == 4)
        result

      _ ->
        decode_metrics(w)
    end
  end

  defp decode_metrics(m), do: pairs(m, Request.metrics(), &decode_number/1)

  defp pairs(xs, allowed, fun) do
    require_true(Evidence.proper_list?(xs) and xs != [])

    Enum.reduce(xs, %{}, fn
      [key, value], acc ->
        key = enum(key, allowed)
        require_true(not Map.has_key?(acc, key))
        Map.put(acc, key, fun.(value))

      _, _ ->
        invalid()
    end)
  end

  defp enum(s, allowed) do
    case Enum.find(allowed, &(Atom.to_string(&1) == s)) do
      nil -> invalid()
      value -> value
    end
  end

  defp decode_number(%{"type" => "integer", "value" => value} = n) when map_size(n) == 2,
    do: integer(value)

  defp decode_number(%{"type" => "decimal", "sign" => s, "coefficient" => c, "exponent" => e} = n)
       when map_size(n) == 4 do
    value = %Decimal{sign: integer(s), coef: integer(c), exp: integer(e)}
    require_true(DecimalMath.finite?(value))
    value
  end

  defp decode_number(_), do: invalid()

  defp integer(s) when is_binary(s) do
    require_true(Regex.match?(~r/^(0|-?[1-9][0-9]*)$/, s))
    String.to_integer(s)
  end

  defp integer(_), do: invalid()

  defp require_shape(v, keys),
    do: require_true(is_map(v) and not is_struct(v) and Enum.sort(Map.keys(v)) == Enum.sort(keys))

  defp require_true(true), do: :ok
  defp require_true(_), do: invalid()
  defp invalid, do: throw(:invalid_stored_rules)
end
