defmodule FootballMarket.Valuation.Evidence do
  @moduledoc """
  Canonicalization, struct-shape verification, and config normalization for
  tamper-evident valuation descriptors and replays.
  """

  alias FootballMarket.Valuation.{DecimalMath, Descriptor}

  def attach(prepared) do
    descriptor = %Descriptor{
      request: prepared.request,
      facts: prepared.facts,
      scopes: prepared.scopes
    }

    %{prepared | descriptor: descriptor}
  end

  @doc "Converts any valuation term into an exact, order-independent canonical representation."
  def canonical(%Decimal{} = decimal) do
    if DecimalMath.finite?(decimal) do
      {numerator, denominator} = DecimalMath.ratio(decimal)
      divisor = Integer.gcd(abs(numerator), denominator)
      {:decimal, div(numerator, divisor), div(denominator, divisor)}
    else
      {:invalid_decimal}
    end
  end

  def canonical(%DateTime{} = datetime) do
    case FootballMarket.Statistics.Input.instant(datetime, :instant) do
      {:ok, value} -> {:instant, DateTime.to_unix(value, :microsecond)}
      _ -> {:invalid_instant}
    end
  end

  def canonical(value) when is_struct(value),
    do: {:struct, value.__struct__, canonical(Map.from_struct(value))}

  def canonical(value) when is_map(value) do
    entries =
      value
      |> Enum.map(fn {key, entry} -> {canonical(key), canonical(entry)} end)
      |> Enum.sort()

    {:map, entries}
  end

  def canonical(value) when is_list(value) do
    if proper_list?(value), do: {:list, Enum.map(value, &canonical/1)}, else: {:unsupported}
  end

  def canonical(value) when is_integer(value), do: {:integer, value}
  def canonical(value) when is_binary(value), do: {:string, value}
  def canonical(value) when is_atom(value), do: {:atom, Atom.to_string(value)}
  def canonical(_), do: {:unsupported}

  def shape?(value, module) do
    is_struct(value, module) and
      Enum.sort(Map.keys(value)) == Enum.sort(Map.keys(module.__struct__()))
  end

  def normalize_config(%Decimal{coef: coef, exp: exp} = decimal) do
    {reduced_coef, reduced_exp} = reduce_decimal(coef, exp)

    %{
      decimal
      | coef: reduced_coef,
        exp: reduced_exp,
        sign: if(reduced_coef == 0, do: 1, else: decimal.sign)
    }
  end

  def normalize_config(value) when is_map(value) and not is_struct(value),
    do: Map.new(value, fn {key, entry} -> {key, normalize_config(entry)} end)

  def normalize_config(value) when is_list(value) do
    if proper_list?(value), do: Enum.map(value, &normalize_config/1), else: value
  end

  def normalize_config(value), do: value

  def valid_config?(%Decimal{} = value), do: DecimalMath.finite?(value)

  def valid_config?(value) when is_map(value) and not is_struct(value) do
    Enum.all?(value, fn {key, entry} ->
      (is_atom(key) or is_binary(key)) and valid_config?(entry)
    end)
  end

  def valid_config?(value) when is_list(value),
    do: proper_list?(value) and Enum.all?(value, &valid_config?/1)

  def valid_config?(value), do: is_integer(value) or is_binary(value) or is_atom(value)

  # `is_list/1` accepts improper cons cells (`[a | b]`), so verify the list tail first.
  def proper_list?([]), do: true
  def proper_list?([_head | tail]), do: proper_list?(tail)
  def proper_list?(_), do: false

  defp reduce_decimal(0, _exp), do: {0, 0}

  defp reduce_decimal(coef, exp) when rem(coef, 10) == 0,
    do: reduce_decimal(div(coef, 10), exp + 1)

  defp reduce_decimal(coef, exp), do: {coef, exp}
end
