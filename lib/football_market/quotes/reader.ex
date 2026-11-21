defmodule FootballMarket.Quotes.Reader do
  @moduledoc """
  Local immutable quote queries (latest, history, as-of date) and historical
  calculation replay verification.
  """

  import Ecto.Query

  alias FootballMarket.Catalog.Player
  alias FootballMarket.Market.Quote
  alias FootballMarket.Quotes.{Calculation, CalculationRequest, EvidenceCodec, Mappings}
  alias FootballMarket.{Repo, Valuation}

  # --- Local Quote Queries ---

  def list_history(player_id) do
    with {:ok, id} <- validate_player_identity(player_id) do
      {:ok,
       Repo.all(
         from q in Quote,
           where: q.player_id == ^id,
           order_by: [
             asc: fragment("COALESCE(?, 0)", q.performance_sequence),
             asc: q.inserted_at,
             asc: q.id
           ]
       )}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def latest(player_id), do: select_quote(player_id, nil)

  def at_date(player_id, %Date{calendar: Calendar.ISO} = date) do
    case DateTime.new(date, ~T[23:59:59.999999], "Etc/UTC") do
      {:ok, cutoff} -> select_quote(player_id, cutoff)
      _ -> {:error, :invalid_date}
    end
  end

  def at_date(_, _), do: {:error, :invalid_date}

  def get_calculation(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Calculation{} = calculation <- Repo.get(Calculation, uuid) do
      {:ok, calculation}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def get_request(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %CalculationRequest{} = request <- Repo.get(CalculationRequest, uuid) do
      {:ok, request}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  # --- Historical Replay Verification ---

  @doc "Reproduces a historical quote calculation from retained evidence without mutating history."
  def replay(calculation_id) do
    case get_calculation(calculation_id) do
      {:ok, calculation} -> replay_calculation(calculation)
      _ -> {:error, :unreproducible}
    end
  rescue
    _ -> {:error, :unreproducible}
  end

  # --- Private Helpers ---

  defp select_quote(player_id, cutoff) do
    with {:ok, id} <- validate_player_identity(player_id) do
      query =
        from q in Quote,
          where: q.player_id == ^id,
          order_by: [
            desc: fragment("COALESCE(?, 0)", q.performance_sequence),
            desc: q.effective_at,
            desc: q.inserted_at,
            desc: q.id
          ],
          limit: 1

      query = if cutoff, do: where(query, [q], q.effective_at <= ^cutoff), else: query

      case Repo.one(query) do
        nil -> {:error, :quote_not_found}
        quote -> {:ok, quote}
      end
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp validate_player_identity(value) do
    uuid_pattern = ~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/

    with true <- is_binary(value) and Regex.match?(uuid_pattern, value),
         {:ok, id} <- Ecto.UUID.cast(value),
         true <- Repo.exists?(from p in Player, where: p.id == ^id) do
      {:ok, id}
    else
      _ -> {:error, :player_not_found}
    end
  end

  defp replay_calculation(calculation) do
    subject = %{
      player_id: calculation.player_id,
      season_id: calculation.season_id,
      week_start: calculation.week_start,
      week_end: calculation.week_end
    }

    with {:ok, facts} <- EvidenceCodec.decode_facts(calculation.evidence["facts"]),
         {:ok, mapping} <- Mappings.get(calculation.mapping_id),
         :ok <- verify_evidence_mapping(calculation, mapping) do
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
    with {:ok, result} <- EvidenceCodec.outcome(managed.score, mapping.scale),
         :ok <- verify_same_result(calculation, result.score, result) do
      {:ok, %{calculation: calculation, score: result.score, outcome: result}}
    else
      _ -> {:error, :unreproducible}
    end
  end

  defp replay_failure(calculation, error) do
    case EvidenceCodec.safe_failure(error) do
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

  defp verify_evidence_mapping(calculation, mapping) do
    evidence = calculation.evidence

    matches? =
      evidence["mapping_id"] == mapping.id and
        evidence["mapping_name"] == mapping.name and
        evidence["mapping_version"] == mapping.version and
        evidence["scale"] == Decimal.to_string(mapping.scale) and
        evidence["rounding_rule"] == mapping.rounding_rule and
        evidence["configuration_version_id"] == calculation.configuration_version_id

    if matches?, do: :ok, else: {:error, :evidence_mismatch}
  end

  defp verify_same_result(calc, score, %{status: "successful", price: price}) do
    if calc.status == "successful" and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score) and
         Decimal.equal?(calc.unit_price, price),
       do: :ok,
       else: {:error, :mismatch}
  end

  defp verify_same_result(calc, score, %{status: status, reason: reason}) do
    if calc.status == status and calc.reason == reason and Decimal.equal?(calc.score, score) and
         calc.evidence["score"] == Decimal.to_string(score),
       do: :ok,
       else: {:error, :mismatch}
  end
end
