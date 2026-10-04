defmodule FootballMarket.Statistics.Count do
  use Ecto.Type
  def type, do: :decimal
  def cast(nil), do: {:ok, nil}
  def cast(n) when is_integer(n) and n >= 0, do: {:ok, n}
  def cast(_), do: :error
  def dump(nil), do: {:ok, nil}
  def dump(n) when is_integer(n) and n >= 0, do: {:ok, Decimal.new(n)}
  def dump(_), do: :error
  def load(nil), do: {:ok, nil}

  def load(%Decimal{coef: coef} = value) when is_integer(coef) do
    if Decimal.compare(value, 0) != :lt and Decimal.equal?(value, Decimal.round(value, 0)),
      do: {:ok, Decimal.to_integer(value)},
      else: :error
  end

  def load(_), do: :error
end
