defmodule FootballMarket.Market.SaleCreditEntry do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "market_sale_credit_entries" do
    field :sale_id, :binary_id
    field :user_id, :binary_id
    field :side, :string
    field :amount, :decimal
    field :inserted_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    changeset = cast(record, attrs, [:sale_id, :user_id, :side, :amount, :inserted_at])
    raw = Map.get(attrs, :amount, Map.get(attrs, "amount"))
    value = get_field(changeset, :amount)

    valid =
      case value do
        %Decimal{coef: coefficient, sign: 1} when is_integer(coefficient) ->
          Decimal.equal?(value, Decimal.round(value, 2))

        nil ->
          true

        _ ->
          false
      end

    if is_float(raw) or not valid,
      do: add_error(changeset, :amount, "must be exact finite cents"),
      else: changeset
  end
end
