defmodule FootballMarket.Valuation.Configurations.Editor do
  @moduledoc "Closed-key form translation into explicit immutable rules; blanks exclude metrics."
  alias FootballMarket.Valuation.Request

  def groups(%{strategy_id: "balanced"}), do: [:overall]
  def groups(_), do: tl(Request.scopes())

  def values(version) do
    weights =
      if version.strategy_id == "balanced",
        do: %{overall: version.config.weights},
        else: version.config.weights

    %{
      "weights" =>
        Map.new(groups(version), fn group ->
          {Atom.to_string(group),
           Map.new(Request.metrics(), &{Atom.to_string(&1), number(weights[group][&1])})}
        end),
      "references" =>
        Map.new(Request.metrics(), &{Atom.to_string(&1), number(version.references[&1])})
    }
  end

  def rules(version, %{"weights" => weights, "references" => refs} = params) do
    try do
      true = Enum.sort(Map.keys(params)) == ["references", "weights"]

      true =
        Enum.sort(Map.keys(weights)) == Enum.sort(Enum.map(groups(version), &Atom.to_string/1))

      groups = Map.new(groups(version), &{&1, metrics(weights[Atom.to_string(&1)])})
      config = if version.strategy_id == "balanced", do: groups.overall, else: groups

      {:ok,
       %{
         strategy_id: version.strategy_id,
         formula_version: version.formula_version,
         position_mapping: version.position_mapping,
         config: %{weights: config},
         references: metrics(refs)
       }}
    rescue
      _ -> {:error, :invalid_editor_values}
    end
  end

  def rules(_, _), do: {:error, :invalid_editor_values}

  defp metrics(values) when is_map(values) do
    true =
      Enum.all?(
        Map.keys(values),
        &(&1 in Enum.map(Request.metrics(), fn m -> Atom.to_string(m) end))
      )

    Map.new(
      Enum.flat_map(Request.metrics(), fn metric ->
        case Map.get(values, Atom.to_string(metric), "") do
          "" ->
            []

          value when is_binary(value) and byte_size(value) <= 64 ->
            true = Regex.match?(~r/\A-?\d+(?:\.\d+)?\z/, value)
            [{metric, Decimal.new(value)}]
        end
      end)
    )
  end

  defp number(nil), do: ""
  defp number(%Decimal{} = d), do: Decimal.to_string(d, :normal)
  defp number(n), do: Integer.to_string(n)
end
