defmodule FootballMarket.Valuation.Configurations.Presets do
  @moduledoc "Approved educational calibration v1. Provisioning never selects it."
  alias FootballMarket.Valuation.{Request, Evidence}

  def roles,
    do: %{"GK" => :goalkeeper, "DEF" => :defender, "MID" => :midfielder, "FWD" => :forward}

  def families, do: ["balanced", "position_aware"]

  def rules(strategy, mapping) do
    common = %{yellow_cards: Decimal.new("-0.5"), red_cards: -2}

    weights =
      case strategy do
        "balanced" ->
          Map.merge(common, %{goals: 4, assists: 3})

        "position_aware" ->
          %{
            goalkeeper: Map.merge(common, %{goals: 4, assists: 3, saves: 4, goals_conceded: -2}),
            defender:
              Map.merge(common, %{
                goals: 4,
                assists: 3,
                shots_on_target: 1,
                tackles: 3,
                interceptions: 3
              }),
            midfielder:
              Map.merge(common, %{
                goals: 4,
                assists: 4,
                shots_on_target: Decimal.new("1.5"),
                tackles: 2,
                interceptions: 2
              }),
            forward: Map.merge(common, %{goals: 5, assists: 3, shots_on_target: 2})
          }
      end

    references = %{
      goals: 2,
      assists: 2,
      shots_on_target: 6,
      tackles: 8,
      interceptions: 6,
      saves: 10,
      goals_conceded: 4,
      yellow_cards: 2,
      red_cards: 1
    }

    required = if strategy == "balanced", do: Map.keys(weights), else: Request.metrics()

    %{
      strategy_id: strategy,
      formula_version: "1",
      config: %{weights: weights},
      references: Map.take(references, required),
      position_mapping: Enum.sort(mapping)
    }
  end

  def key(strategy, mapping) do
    digest =
      :crypto.hash(
        :sha256,
        Jason.encode!(
          Enum.map(Enum.sort(mapping), fn {id, role} -> [id, Atom.to_string(role)] end)
        )
      )
      |> Base.encode16(case: :lower)

    strategy <> ":educational-v1:" <> digest
  end

  def equivalent_key(version) do
    {version.strategy_id, version.formula_version, numeric(version.config),
     numeric(version.references), Enum.sort(version.position_mapping)}
  end

  defp numeric(n) when is_integer(n), do: n |> Decimal.new() |> numeric()
  defp numeric(%Decimal{} = n), do: n |> Evidence.normalize_config() |> Decimal.to_string(:normal)
  defp numeric(m) when is_map(m), do: Map.new(m, fn {k, v} -> {k, numeric(v)} end)
end
