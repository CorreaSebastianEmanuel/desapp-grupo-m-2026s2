defmodule FootballMarket.Market.CreditBalance do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "market_credit_balances" do
    field :user_id, :binary_id, primary_key: true
    field :amount, :decimal
    field :updated_at, :utc_datetime_usec
  end

  def changeset(record, attrs) do
    changeset = cast(record, attrs, [:user_id, :amount, :updated_at])

    Enum.reduce([:amount], changeset, fn field, acc ->
      raw = Map.get(attrs, field, Map.get(attrs, Atom.to_string(field)))
      value = get_field(acc, field)

      valid =
        case value do
          %Decimal{coef: coef, sign: sign} when is_integer(coef) ->
            (sign == 1 or coef == 0) and Decimal.equal?(value, Decimal.round(value, 2))

          nil ->
            true

          _ ->
            false
        end

      if is_float(raw) or not valid,
        do: add_error(acc, field, "must be exact finite cents"),
        else: acc
    end)
  end
end
