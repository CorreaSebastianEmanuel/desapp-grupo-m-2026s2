defmodule FootballMarket.Catalog.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "positions" do
    field :code, :string
    field :name, :string
    has_many :players, FootballMarket.Catalog.Player
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:code, :name])
    |> trim([:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code, name: :positions_normalized_code_index)
    |> unique_constraint(:name, name: :positions_normalized_name_index)
  end

  def delete_changeset(position), do: position |> change() |> no_assoc_constraint(:players)

  defp trim(changeset, fields),
    do:
      Enum.reduce(fields, changeset, fn field, cs ->
        case get_change(cs, field) do
          value when is_binary(value) -> put_change(cs, field, String.trim(value))
          _ -> cs
        end
      end)
end
