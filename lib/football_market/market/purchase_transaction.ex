defmodule FootballMarket.Market.PurchaseTransaction do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.{Repo, Quotes}
  alias FootballMarket.Accounts.User
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    Error,
    Purchase,
    CreditBalance,
    CreditEntry,
    TokenTransfer,
    Holding,
    Issuance,
    InitialRecipient,
    Quote,
    Consistency
  }

  def complete(i) do
    {issue, balances, holdings} = lock_resources!(i)
    quote = current_quote!(i.player_id)
    resources = eligible(i, issue, balances, holdings, quote)

    case resources do
      {:ok, prepared} -> write!(i, issue, holdings, quote, prepared, DateTime.utc_now())
      {:error, kind} -> reject(kind)
    end
  end

  def write!(i, issue, holdings, quote, {buyer, seller, source, total}, now) do
    debit!(buyer, total, now)
    credit!(seller, issue.recipient_id, total, now)
    Repo.update!(Ecto.Changeset.change(source, quantity: source.quantity - i.quantity))
    receive_tokens!(holdings, i)
    p = insert_purchase!(i, issue, quote, total, now)

    Repo.insert!(%TokenTransfer{
      purchase_id: p.id,
      player_id: i.player_id,
      from_user_id: issue.recipient_id,
      to_user_id: i.buyer_id,
      quantity: i.quantity,
      inserted_at: now
    })

    for {side, user} <- [{"debit", i.buyer_id}, {"credit", issue.recipient_id}] do
      Repo.insert!(%CreditEntry{
        purchase_id: p.id,
        user_id: user,
        side: side,
        amount: total,
        inserted_at: now
      })
    end

    p
  end

  def lock_resources!(i) do
    if is_nil(Repo.one(from p in Player, where: p.id == ^i.player_id, lock: "FOR UPDATE")),
      do: reject(:player_not_found)

    issue = Repo.one(from s in Issuance, where: s.player_id == ^i.player_id)
    if is_nil(issue), do: reject(:not_initialized)
    if issue.recipient_id == i.buyer_id, do: reject(:self_purchase)
    ids = Enum.sort([i.buyer_id, issue.recipient_id])
    users = Repo.all(from u in User, where: u.id in ^ids, order_by: u.id, lock: "FOR UPDATE")
    if length(users) != 2, do: reject(:inconsistent_state)

    balances =
      Repo.all(
        from b in CreditBalance, where: b.user_id in ^ids, order_by: b.user_id, lock: "FOR UPDATE"
      )

    holdings = Repo.all(from h in Holding, where: h.player_id == ^i.player_id)

    {issue, balances, holdings}
  end

  def current_quote!(player_id) do
    case Quotes.latest(player_id) do
      {:ok, q} -> if exact_positive?(q.unit_price), do: q, else: nil
      {:error, :temporarily_unavailable} -> reject(:temporarily_unavailable)
      _ -> nil
    end
  end

  def eligible(_, _, _, _, nil), do: {:error, :quote_unavailable}

  def eligible(i, issue, balances, holdings, quote) do
    coherent!(i.player_id, issue, holdings)
    total = exact_total!(quote.unit_price, i.quantity)
    buyer = Enum.find(balances, &(&1.user_id == i.buyer_id))
    seller = Enum.find(balances, &(&1.user_id == issue.recipient_id))

    source = Enum.find(holdings, &(&1.user_id == issue.recipient_id))

    cond do
      buyer == nil or Decimal.compare(buyer.amount, total) == :lt -> {:error, :insufficient_funds}
      source == nil or source.quantity < i.quantity -> {:error, :insufficient_inventory}
      true -> {:ok, {buyer, seller, source, total}}
    end
  end

  defp coherent!(player, issue, holdings) do
    fixed = Repo.get(InitialRecipient, 1)

    state = %{
      player_id: player,
      recipient_id: issue.recipient_id,
      fixed_recipient: fixed && fixed.user_id,
      issuance_recipients: Repo.all(from s in Issuance, select: s.recipient_id),
      issuance: issue,
      holdings: holdings,
      quotes: Repo.all(from q in Quote, where: q.player_id == ^player),
      user_ids: Repo.all(from u in User, select: u.id)
    }

    unless Consistency.validate(state) == {:ok, :issued}, do: reject(:inconsistent_state)
  end

  defp exact_positive?(%Decimal{coef: c, sign: 1} = n) when is_integer(c) and c > 0,
    do: Decimal.equal?(n, Decimal.round(n, 2))

  defp exact_positive?(_), do: false

  defp exact_total!(unit_price, quantity) do
    case Repo.query!("SELECT $1::numeric * $2::numeric", [unit_price, quantity]).rows do
      [[%Decimal{} = total]] -> total
      _ -> reject(:inconsistent_state)
    end
  end

  defp debit!(buyer, total, now),
    do: adjust_balance!(buyer, Decimal.negate(total), now)

  defp credit!(nil, id, total, now),
    do: Repo.insert!(%CreditBalance{user_id: id, amount: total, updated_at: now})

  defp credit!(seller, _, total, now),
    do: adjust_balance!(seller, total, now)

  defp adjust_balance!(balance, delta, now) do
    case Repo.query!(
           "UPDATE market_credit_balances SET amount = amount + $1::numeric, updated_at = $2 WHERE user_id = $3",
           [delta, now, Ecto.UUID.dump!(balance.user_id)]
         ).num_rows do
      1 -> :ok
      0 -> reject(:inconsistent_state)
    end
  end

  defp receive_tokens!(holdings, i) do
    case Enum.find(holdings, &(&1.user_id == i.buyer_id)) do
      nil ->
        Repo.insert!(%Holding{player_id: i.player_id, user_id: i.buyer_id, quantity: i.quantity})

      h ->
        Repo.update!(Ecto.Changeset.change(h, quantity: h.quantity + i.quantity))
    end
  end

  defp insert_purchase!(i, issue, q, total, now) do
    Repo.insert!(%Purchase{
      conditional_order_id: Map.get(i, :conditional_order_id),
      buyer_id: i.buyer_id,
      recipient_id: issue.recipient_id,
      player_id: i.player_id,
      request_key: i.request_key,
      quantity: i.quantity,
      quote_id: q.id,
      unit_price: q.unit_price,
      total: total,
      quote_effective_at: q.effective_at,
      rule_id: q.rule_id,
      rule_version: q.rule_version,
      configuration_version_id: q.configuration_version_id,
      mapping_id: q.mapping_id,
      performance_sequence: q.performance_sequence,
      completed_at: now
    })
  end

  def evidence(p) do
    p
    |> Map.from_struct()
    |> Map.drop([:__meta__, :conditional_order_id])
    |> Map.put(:transfer, Repo.one(from t in TokenTransfer, where: t.purchase_id == ^p.id))
    |> Map.put(
      :ledger,
      Repo.all(from e in CreditEntry, where: e.purchase_id == ^p.id, order_by: e.side)
    )
  end

  defp reject(kind), do: Repo.rollback(%Error{kind: kind, reason: kind})
end
