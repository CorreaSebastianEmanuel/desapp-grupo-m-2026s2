defmodule FootballMarket.Market.Consistency do
  @moduledoc "Pure defense against contradictory retained financial snapshots."
  alias FootballMarket.Market.{Error, Input}

  def validate(s) do
    case recipient_state(s) do
      :ok -> validate_history(s)
      error -> error
    end
  end

  defp recipient_state(s) do
    cond do
      s.fixed_recipient != nil and s.fixed_recipient != s.recipient_id ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      Enum.any?(s.issuance_recipients, &(&1 != s.recipient_id)) ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      s.fixed_recipient == nil != (s.issuance_recipients == []) ->
        Error.new(:inconsistent_state, :partial_recipient_fixation)

      true ->
        :ok
    end
  end

  defp validate_history(s) do
    cond do
      s.issuance == nil and s.holdings == [] and s.quotes == [] ->
        {:ok, :unissued}

      s.issuance == nil ->
        Error.new(:inconsistent_state, :orphan_history)

      not coherent?(s) ->
        Error.new(:inconsistent_state, :invalid_retained_evidence)

      true ->
        {:ok, :issued}
    end
  end

  defp coherent?(s) do
    i = s.issuance
    q = Enum.find(s.quotes, &(Map.get(&1, :id) == Map.get(i, :initial_quote_id)))

    valid_issuance?(s, i) and
      valid_holdings?(s) and valid_quotes?(s) and
      valid_initial_quote?(q, s, i)
  end

  defp valid_issuance?(s, issuance) do
    valid_issuance_identity?(s, issuance) and
      Map.get(issuance, :player_id) == s.player_id and
      Map.get(issuance, :recipient_id) == s.recipient_id and Map.get(issuance, :quantity) === 100 and
      Input.exact_one?(Map.get(issuance, :initial_unit_price)) and
      uuid?(Map.get(issuance, :initial_quote_id)) and instant?(Map.get(issuance, :completed_at))
  end

  defp valid_initial_quote?(quote, s, issuance) do
    is_map(quote) and Map.get(quote, :player_id) == s.player_id and
      Input.exact_one?(Map.get(quote, :unit_price)) and
      Map.get(quote, :rule_id) == "initial_issuance" and
      Map.get(quote, :rule_version) == "1" and
      Map.get(quote, :effective_at) == Map.get(issuance, :completed_at)
  end

  defp valid_holdings?(s) do
    Enum.all?(s.holdings, &valid_holding?(&1, s)) and
      unique?(s.holdings, :id) and unique?(s.holdings, :user_id) and
      Enum.sum(Enum.map(s.holdings, & &1.quantity)) == 100
  end

  defp valid_holding?(holding, s) do
    is_map(holding) and uuid?(Map.get(holding, :id)) and
      Map.get(holding, :player_id) == s.player_id and
      uuid?(Map.get(holding, :user_id)) and Map.get(holding, :user_id) in s.user_ids and
      is_integer(Map.get(holding, :quantity)) and Map.get(holding, :quantity) >= 0
  end

  defp valid_quotes?(s) do
    Enum.all?(s.quotes, &valid_quote?(&1, s)) and unique?(s.quotes, :id) and
      Enum.count(s.quotes, &(Map.get(&1, :rule_id) == "initial_issuance")) == 1
  end

  defp valid_quote?(quote, s) do
    is_map(quote) and uuid?(Map.get(quote, :id)) and Map.get(quote, :player_id) == s.player_id and
      positive_exact?(Map.get(quote, :unit_price)) and instant?(Map.get(quote, :effective_at)) and
      instant?(Map.get(quote, :inserted_at)) and text?(Map.get(quote, :rule_id)) and
      text?(Map.get(quote, :rule_version))
  end

  defp unique?(rows, key), do: length(rows) == length(Enum.uniq_by(rows, &Map.get(&1, key)))
  defp uuid?(id) when is_binary(id), do: match?({:ok, _}, Ecto.UUID.cast(id))
  defp uuid?(_), do: false
  defp instant?(%DateTime{utc_offset: 0, std_offset: 0}), do: true
  defp instant?(_), do: false
  defp text?(s) when is_binary(s), do: String.trim(s) != ""
  defp text?(_), do: false
  defp positive_exact?(%Decimal{coef: coef, sign: 1}) when is_integer(coef), do: coef > 0
  defp positive_exact?(_), do: false

  defp valid_issuance_identity?(s, issuance) do
    uuid?(s.player_id) and uuid?(s.recipient_id) and s.fixed_recipient == s.recipient_id and
      s.recipient_id in s.user_ids and uuid?(Map.get(issuance, :id))
  end
end
