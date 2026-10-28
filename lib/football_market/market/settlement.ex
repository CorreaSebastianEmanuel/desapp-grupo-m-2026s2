defmodule FootballMarket.Market.Settlement do
  @moduledoc "Exact credit settlement primitives shared by purchases and sales."
  import Ecto.Changeset
  alias FootballMarket.Repo
  alias FootballMarket.Market.{CreditBalance, Error}

  def exact_positive?(%Decimal{coef: coef, sign: 1} = value) when is_integer(coef) and coef > 0,
    do: Decimal.equal?(value, Decimal.round(value, 2))

  def exact_positive?(_), do: false

  def exact_total!(unit_price, quantity) do
    case Repo.query!("SELECT $1::numeric * $2::numeric", [unit_price, quantity]).rows do
      [[%Decimal{} = total]] -> total
      _ -> reject(:inconsistent_state)
    end
  end

  def exact_money_changeset(record, attrs, cast_fields, money_fields) do
    changeset = cast(record, attrs, cast_fields)

    Enum.reduce(money_fields, changeset, fn field, acc ->
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

  def debit!(balance, total, now), do: adjust_balance!(balance, Decimal.negate(total), now)

  def credit!(nil, id, total, now),
    do: Repo.insert!(%CreditBalance{user_id: id, amount: total, updated_at: now})

  def credit!(balance, _, total, now), do: adjust_balance!(balance, total, now)

  def adjust_balance!(balance, delta, now) do
    case Repo.query!(
           "UPDATE market_credit_balances SET amount = amount + $1::numeric, updated_at = $2 WHERE user_id = $3",
           [delta, now, Ecto.UUID.dump!(balance.user_id)]
         ).num_rows do
      1 -> :ok
      0 -> reject(:inconsistent_state)
    end
  end

  def reject(kind), do: Repo.rollback(%Error{kind: kind, reason: kind})
end
