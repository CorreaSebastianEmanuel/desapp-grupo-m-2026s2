defmodule FootballMarket.Market.InitializationLock do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :integer, autogenerate: false}
  @foreign_key_type :binary_id
  schema "market_initialization_locks" do
  end

  def changeset(record, attrs) do
    record
    |> cast(attrs, [])
    |> validate_required([])
  end
end
