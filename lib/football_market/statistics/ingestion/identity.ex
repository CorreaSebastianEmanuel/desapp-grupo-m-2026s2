defmodule FootballMarket.Statistics.Ingestion.Identity do
  @moduledoc "Qualified provider identity lookup for normalized result references."

  def source_id(result, kind, ref) do
    case Enum.find(result.provenance.bindings, &(&1.kind == kind and &1.ref == ref)) do
      %{source_id: id} when is_binary(id) -> {:ok, id}
      _ -> {:error, :unbound_identity}
    end
  end

  def fetch!(result, kind, ref) do
    case source_id(result, kind, ref) do
      {:ok, id} -> id
      {:error, reason} -> raise ArgumentError, Atom.to_string(reason)
    end
  end
end
