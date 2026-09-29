defmodule FootballMarket.TestProfileAudit do
  @moduledoc false

  @profiles ~w(unit integration)
  @allowed_module_tags ~w(unit integration performance)

  def audit!(profile, root \\ File.cwd!())

  def audit!(profile, root) when profile in @profiles do
    modules = discovered_modules(root)

    if modules == [] do
      raise ArgumentError, "CP1 profile audit found no Mix-default test modules"
    end

    Enum.each(modules, &validate_module!/1)

    selected_modules = Enum.filter(modules, &(&1.profile == profile))
    ids = Enum.map(selected_modules, & &1.id)

    if ids == [] do
      raise ArgumentError, "CP1 profile audit found an empty #{profile} scope"
    end

    if ids != Enum.sort(ids) or length(ids) != length(Enum.uniq(ids)) do
      raise ArgumentError, "CP1 profile audit found unstable #{profile} membership"
    end

    %{
      profile: profile,
      ids: ids,
      files: selected_modules |> Enum.map(& &1.file) |> Enum.uniq(),
      count: length(ids)
    }
  end

  def audit!(profile, _root), do: raise(ArgumentError, "unknown CP1 profile: #{inspect(profile)}")

  def discovered_modules(root \\ File.cwd!()) do
    root
    |> Path.join("test/**/*_test.exs")
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.flat_map(&parse_modules!(&1, root))
    |> Enum.sort_by(& &1.id)
  end

  defp validate_module!(module) do
    unknown_tags = Enum.reject(module.module_tags, &(&1 in @allowed_module_tags))

    cond do
      unknown_tags != [] ->
        raise ArgumentError,
              "unknown module tag in #{module.file}: #{Enum.join(unknown_tags, ", ")}"

      Enum.any?(module.test_tags, &(&1 in @profiles)) ->
        raise ArgumentError, "test-level profile tag in #{module.file}"

      "skip" in module.module_tags or "skip" in module.test_tags ->
        raise ArgumentError, "explicit skip tag in #{module.file}"

      length(module.profile_tags) != 1 ->
        raise ArgumentError, "expected one module-level CP1 profile tag in #{module.file}"

      true ->
        :ok
    end
  end

  defp parse_modules!(file, root) do
    relative = Path.relative_to(file, root)
    ast = file |> File.read!() |> Code.string_to_quoted!()
    definitions = module_definitions!(ast, relative)

    Enum.map(definitions, fn {name, body} ->
      module_tags = direct_attributes(body, :moduletag)
      test_tags = all_attributes(body, :tag)

      %{
        file: relative,
        module: name,
        profile_tags: Enum.filter(module_tags, &(&1 in @profiles)),
        module_tags: module_tags,
        test_tags: test_tags,
        id: relative <> ":" <> name,
        profile: Enum.find(module_tags, &(&1 in @profiles))
      }
    end)
  end

  defp module_definitions!(ast, file) do
    definitions =
      ast
      |> top_level_nodes()
      |> Enum.flat_map(fn
        {:defmodule, _, [name_ast, [do: body]]} ->
          [{Macro.to_string(name_ast), top_level_nodes(body)}]

        _ ->
          []
      end)

    {_ast, all_count} =
      Macro.prewalk(ast, 0, fn
        {:defmodule, _, _} = node, count -> {node, count + 1}
        node, count -> {node, count}
      end)

    if definitions == [] or length(definitions) != all_count do
      raise ArgumentError, "unable to identify every ExUnit module in #{file}"
    end

    definitions
  end

  defp top_level_nodes({:__block__, _, nodes}), do: nodes
  defp top_level_nodes(node), do: List.wrap(node)

  defp direct_attributes(body, attribute) do
    Enum.flat_map(body, fn
      {:@, _, [{^attribute, _, [value]}]} -> attribute_values(value)
      _ -> []
    end)
  end

  defp all_attributes(ast, attribute) do
    {_ast, values} =
      Macro.prewalk(ast, [], fn
        {:@, _, [{^attribute, _, [value]}]} = node, acc -> {node, attribute_values(value) ++ acc}
        node, acc -> {node, acc}
      end)

    values
  end

  defp attribute_values(value) when is_atom(value), do: [Atom.to_string(value)]

  defp attribute_values(values) when is_list(values),
    do: Enum.flat_map(values, &attribute_values/1)

  defp attribute_values(_value), do: ["indirect"]
end
