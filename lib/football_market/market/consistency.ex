defmodule FootballMarket.Market.Consistency do
  @moduledoc "Pure defense against contradictory retained financial snapshots."
  alias FootballMarket.Market.{Error, Input}

  def validate(s) do
    cond do
      s.fixed_recipient != nil and s.fixed_recipient != s.recipient_id ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      Enum.any?(s.issuance_recipients, &(&1 != s.recipient_id)) ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      s.fixed_recipient == nil != (s.issuance_recipients == []) ->
        Error.new(:inconsistent_state, :partial_recipient_fixation)

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

    uuid?(s.player_id) and uuid?(s.recipient_id) and s.fixed_recipient == s.recipient_id and
      s.recipient_id in s.user_ids and
      uuid?(Map.get(i, :id)) and Map.get(i, :player_id) == s.player_id and
      Map.get(i, :recipient_id) == s.recipient_id and Map.get(i, :quantity) === 100 and
      Input.exact_one?(Map.get(i, :initial_unit_price)) and uuid?(Map.get(i, :initial_quote_id)) and
      instant?(Map.get(i, :completed_at)) and
      valid_holdings?(s) and valid_quotes?(s) and
      is_map(q) and Map.get(q, :player_id) == s.player_id and
      Input.exact_one?(Map.get(q, :unit_price)) and Map.get(q, :rule_id) == "initial_issuance" and
      Map.get(q, :rule_version) == "1" and Map.get(q, :effective_at) == Map.get(i, :completed_at)
  end

  defp valid_holdings?(s) do
    Enum.all?(s.holdings, fn h ->
      is_map(h) and uuid?(Map.get(h, :id)) and Map.get(h, :player_id) == s.player_id and
        uuid?(Map.get(h, :user_id)) and Map.get(h, :user_id) in s.user_ids and
        is_integer(Map.get(h, :quantity)) and Map.get(h, :quantity) >= 0
    end) and
      unique?(s.holdings, :id) and unique?(s.holdings, :user_id) and
      Enum.sum(Enum.map(s.holdings, & &1.quantity)) == 100
  end

  defp valid_quotes?(s) do
    Enum.all?(s.quotes, fn q ->
      is_map(q) and uuid?(Map.get(q, :id)) and Map.get(q, :player_id) == s.player_id and
        positive_exact?(Map.get(q, :unit_price)) and instant?(Map.get(q, :effective_at)) and
        instant?(Map.get(q, :inserted_at)) and text?(Map.get(q, :rule_id)) and
        text?(Map.get(q, :rule_version))
    end) and unique?(s.quotes, :id) and
      Enum.count(s.quotes, &(Map.get(&1, :rule_id) == "initial_issuance")) == 1
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
end
