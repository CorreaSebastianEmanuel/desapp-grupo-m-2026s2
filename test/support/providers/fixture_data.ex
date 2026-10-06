defmodule FootballMarket.Providers.FixtureData do
  @moduledoc """
  Test-only declarative edits to independently written fixture bases.

  Paths use map keys, zero-based list indexes, or source B's literal cell names.
  Packet/rows wrappers are transparent; cell order and list order are retained.
  A put replaces one value (including nil); a drop removes a required field.
  No normalization, validation, source translation or expected-result derivation.
  """

  def patch(base, edits) do
    Enum.reduce(edits, base, fn
      {:put, path, value}, data -> edit(data, path, fn _ -> value end)
      {:drop, path}, data -> drop(data, path)
    end)
  end

  def case_entry(id, base, edits) do
    base |> Map.merge(%{id: id, sources: %{a: id, b: id}}) |> patch(edits)
  end

  def source_a(id, base, edits) do
    base |> patch([{:put, ["document", "candidate", "fixture_id"], id}]) |> patch(edits)
  end

  def source_b(id, base, edits) do
    base |> patch([{:put, ["CANDIDATE", "FIXTURE_ID"], id}]) |> patch(edits)
  end

  defp edit(data, [], fun), do: fun.(data)
  defp edit({:packet, data, ignored}, path, fun), do: {:packet, edit(data, path, fun), ignored}
  defp edit({:rows, data}, path, fun), do: {:rows, edit(data, path, fun)}

  defp edit({:cells, cells}, [key | rest], fun) do
    # Missing cell edits are deliberately explicit replacements of the cells
    # in fixture declarations. A misspelled path must fail, not create data.
    {^key, value} = List.keyfind(cells, key, 0)
    {:cells, List.keyreplace(cells, key, 0, {key, edit(value, rest, fun)})}
  end

  defp edit(data, [index | rest], fun) when is_list(data) and is_integer(index) do
    value = Enum.fetch!(data, index)
    List.replace_at(data, index, edit(value, rest, fun))
  end

  defp edit(data, [key], fun) when is_map(data), do: Map.put(data, key, fun.(Map.get(data, key)))

  defp edit(data, [key | rest], fun) when is_map(data),
    do: Map.put(data, key, edit(Map.fetch!(data, key), rest, fun))

  defp drop(data, [key]) when is_map(data) do
    _ = Map.fetch!(data, key)
    Map.delete(data, key)
  end

  defp drop({:cells, cells}, [key]) do
    {^key, _} = List.keyfind(cells, key, 0)
    {:cells, List.keydelete(cells, key, 0)}
  end

  defp drop({:packet, data, ignored}, path), do: {:packet, drop(data, path), ignored}
  defp drop({:rows, data}, path), do: {:rows, drop(data, path)}
  defp drop(data, [key | rest]), do: edit(data, [key], &drop(&1, rest))
end
