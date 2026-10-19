defmodule FootballMarket.Valuation.Evidence do
  @moduledoc false
  alias FootballMarket.Valuation.{Descriptor, DecimalMath}

  def attach(prepared) do
    %{
      prepared
      | descriptor: %Descriptor{
          request: prepared.request,
          facts: prepared.facts,
          scopes: prepared.scopes
        }
    }
  end

  def canonical(%Decimal{} = n) do
    if DecimalMath.finite?(n) do
      {numerator, denominator} = DecimalMath.ratio(n)
      divisor = Integer.gcd(abs(numerator), denominator)
      {:decimal, div(numerator, divisor), div(denominator, divisor)}
    else
      {:invalid_decimal}
    end
  end

  def canonical(%DateTime{} = dt) do
    case FootballMarket.Statistics.Input.instant(dt, :instant) do
      {:ok, value} -> {:instant, DateTime.to_unix(value, :microsecond)}
      _ -> {:invalid_instant}
    end
  end

  def canonical(v) when is_struct(v), do: {:struct, v.__struct__, canonical(Map.from_struct(v))}

  def canonical(v) when is_map(v),
    do: {:map, Enum.map(v, fn {k, x} -> {canonical(k), canonical(x)} end) |> Enum.sort()}

  def canonical(v) when is_list(v) do
    if proper_list?(v), do: {:list, Enum.map(v, &canonical/1)}, else: {:unsupported}
  end

  def canonical(v) when is_integer(v), do: {:integer, v}
  def canonical(v) when is_binary(v), do: {:string, v}
  def canonical(v) when is_atom(v), do: {:atom, Atom.to_string(v)}
  def canonical(_), do: {:unsupported}

  def shape?(value, module),
    do:
      is_struct(value, module) and
        Enum.sort(Map.keys(value)) == Enum.sort(Map.keys(module.__struct__()))

  def normalize_config(%Decimal{coef: c, exp: e} = d) do
    {c, e} = reduce_decimal(c, e)
    %{d | coef: c, exp: e, sign: if(c == 0, do: 1, else: d.sign)}
  end

  def normalize_config(v) when is_map(v) and not is_struct(v),
    do: Map.new(v, fn {k, x} -> {k, normalize_config(x)} end)

  def normalize_config(v) when is_list(v) do
    if proper_list?(v), do: Enum.map(v, &normalize_config/1), else: v
  end

  def normalize_config(v), do: v
  defp reduce_decimal(0, _), do: {0, 0}
  defp reduce_decimal(c, e) when rem(c, 10) == 0, do: reduce_decimal(div(c, 10), e + 1)
  defp reduce_decimal(c, e), do: {c, e}
  def valid_config?(%Decimal{} = v), do: DecimalMath.finite?(v)

  def valid_config?(v) when is_map(v) and not is_struct(v),
    do: Enum.all?(v, fn {k, x} -> (is_atom(k) or is_binary(k)) and valid_config?(x) end)

  def valid_config?(v) when is_list(v), do: proper_list?(v) and Enum.all?(v, &valid_config?/1)
  def valid_config?(v), do: is_integer(v) or is_binary(v) or is_atom(v)

  # is_list/1 also accepts improper cons cells; check tails before Enumerable traversal.
  def proper_list?([]), do: true
  def proper_list?([_ | tail]), do: proper_list?(tail)
  def proper_list?(_), do: false
end
