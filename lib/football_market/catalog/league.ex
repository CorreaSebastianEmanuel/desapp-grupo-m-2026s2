defmodule FootballMarket.Catalog.League do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "leagues" do
    field :code, :string
    field :name, :string
    has_many :seasons, FootballMarket.Catalog.Season
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(league, attrs) do
    league
    |> cast(attrs, [:code, :name])
    |> trim([:code, :name])
    |> validate_required([:code, :name])
    |> validate_supported_pair()
    |> check_constraint(:code, name: :leagues_supported_code)
    |> unique_constraint(:code, name: :leagues_normalized_code_index)
    |> unique_constraint(:name, name: :leagues_normalized_name_index)
  end

  def delete_changeset(league), do: league |> change() |> no_assoc_constraint(:seasons)

  defp validate_supported_pair(changeset) do
    pair = {get_field(changeset, :code), get_field(changeset, :name)}

    if pair in FootballMarket.Catalog.supported_leagues(),
      do: changeset,
      else: add_error(changeset, :code, "is not a supported league pair")
  end

  defp trim(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      case get_change(cs, field) do
        value when is_binary(value) -> put_change(cs, field, String.trim(value))
        _ -> cs
      end
    end)
  end
end
