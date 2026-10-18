defmodule FootballMarket.Quotes.Mappings do
  @moduledoc "Trusted immutable exact quote conversion mappings."
  alias FootballMarket.Repo
  alias FootballMarket.Quotes.Mapping

  def save(name, version, %Decimal{} = scale) when is_binary(name) and is_binary(version) do
    with :ok <- valid_name(name), :ok <- valid_name(version), :ok <- positive(scale) do
      %Mapping{}
      |> Mapping.changeset(%{
        id: Ecto.UUID.generate(),
        name: name,
        version: version,
        scale: scale,
        rounding_rule: "two-half-away-v1",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      })
      |> Repo.insert()
      |> case do
        {:ok, mapping} -> {:ok, mapping}
        {:error, changeset} -> {:error, changeset}
      end
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def save(_, _, _), do: {:error, :invalid_mapping}

  def get(id) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         %Mapping{} = mapping <- Repo.get(Mapping, id) do
      {:ok, mapping}
    else
      _ -> {:error, :mapping_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp valid_name(value),
    do: if(String.trim(value) != "", do: :ok, else: {:error, :invalid_mapping})

  defp positive(%Decimal{} = value),
    do:
      if(Decimal.compare(value, Decimal.new(0)) == :gt, do: :ok, else: {:error, :invalid_mapping})
end
