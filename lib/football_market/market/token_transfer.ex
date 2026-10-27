defmodule FootballMarket.Market.TokenTransfer do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_token_transfers" do
    field :purchase_id, :binary_id
    field :sale_id, :binary_id
    field :player_id, :binary_id
    field :from_user_id, :binary_id
    field :to_user_id, :binary_id
    field :quantity, :integer
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    cast(record, attrs, [
      :purchase_id,
      :sale_id,
      :player_id,
      :from_user_id,
      :to_user_id,
      :quantity,
      :inserted_at
    ])
  end
end
