defmodule FootballMarket.Quotes.Replay do
  @moduledoc "Reproduces historical outcomes from retained evidence without changing history."
  alias FootballMarket.Valuation
  alias FootballMarket.Quotes.{Mappings, Reader, Result}

  def replay(calculation_id) do
    case Reader.get_calculation(calculation_id) do
      {:ok, calculation} -> replay_calculation(calculation)
      _ -> {:error, :unreproducible}
    end
  rescue
    _ -> {:error, :unreproducible}
  end

  defp replay_calculation(calculation) do
    subject = %{
      player_id: calculation.player_id,
      season_id: calculation.season_id,
      week_start: calculation.week_start,
      week_end: calculation.week_end
    }

    with {:ok, facts} <-
           FootballMarket.Quotes.EvidenceCodec.decode_facts(calculation.evidence["facts"]),
         {:ok, mapping} <- Mappings.get(calculation.mapping_id),
         :ok <- evidence_mapping(calculation, mapping) do
      replay_evidence(calculation, subject, facts, mapping)
    else
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_evidence(calculation, subject, facts, mapping) do
    case Valuation.evaluate_managed_membership(
           subject,
           {:version, calculation.configuration_version_id},
           facts
         ) do
      {:ok, managed} -> replay_success(calculation, managed, mapping)
      {:error, %Valuation.Error{} = error} -> replay_failure(calculation, error)
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_success(calculation, managed, mapping) do
    with {:ok, result} <- Result.outcome(managed.score, mapping.scale),
         :ok <- same_result(calculation, result.score, result) do
      {:ok, %{calculation: calculation, score: result.score, outcome: result}}
    else
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_failure(calculation, error) do
    case Result.safe_failure(error) do
      {:ok, status, reason}
      when calculation.status == status and calculation.reason == reason and
             is_nil(calculation.score) ->
        {:ok,
         %{
           calculation: calculation,
           score: nil,
           outcome: %{status: status, reason: reason, price: nil}
         }}

      _ ->
        {:error, :unreproducible}
    end
  end

  defp evidence_mapping(calculation, mapping) do
    evidence = calculation.evidence

    if evidence["mapping_id"] == mapping.id and evidence["mapping_name"] == mapping.name and
         evidence["mapping_version"] == mapping.version and
         evidence["scale"] == Decimal.to_string(mapping.scale) and
         evidence["rounding_rule"] == mapping.rounding_rule and
         evidence["configuration_version_id"] == calculation.configuration_version_id,
       do: :ok,
       else: {:error, :evidence_mismatch}
  end

  defp same_result(calc, score, %{status: "successful", price: price}) do
    if calc.status == "successful" and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score) and
         Decimal.equal?(calc.unit_price, price), do: :ok, else: {:error, :mismatch}
  end

  defp same_result(calc, score, %{status: status, reason: reason}) do
    if calc.status == status and calc.reason == reason and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score),
       do: :ok,
       else: {:error, :mismatch}
  end
end
