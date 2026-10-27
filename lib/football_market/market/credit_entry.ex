defmodule FootballMarket.Market.CreditEntry do
  @moduledoc false
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "market_credit_entries" do
    field :purchase_id, :binary_id
    field :sale_id, :binary_id
    field :user_id, :binary_id
    field :side, :string
    field :amount, :decimal
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    FootballMarket.Market.Settlement.exact_money_changeset(
      record,
      attrs,
      [:purchase_id, :sale_id, :user_id, :side, :amount, :inserted_at],
      [:amount]
    )
  end
end
